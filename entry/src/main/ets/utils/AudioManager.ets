import { audio } from '@kit.AudioKit';
import { media } from '@kit.MediaKit';
import { Song } from '../model/Song';

/**
 * Playback state enumeration
 */
export enum PlaybackState {
  IDLE = 'idle',
  PLAYING = 'playing',
  PAUSED = 'paused',
  STOPPED = 'stopped',
  ERROR = 'error'
}

/**
 * Audio player events interface
 */
export interface AudioPlayerEvents {
  onPlayStateChange?: (state: PlaybackState) => void;
  onProgressUpdate?: (currentTime: number, duration: number) => void;
  onSongChange?: (song: Song) => void;
  onError?: (error: string) => void;
  onComplete?: () => void;
}

/**
 * AudioManager - Singleton class for managing audio playback
 * Handles AVPlayer operations, volume control, and playback state
 */
export class AudioManager {
  private static instance: AudioManager | null = null;
  private avPlayer: media.AVPlayer | null = null;
  private currentSong: Song | null = null;
  private currentIndex: number = 0;
  private playlist: Song[] = [];
  private playbackState: PlaybackState = PlaybackState.IDLE;
  private progressTimer: number = -1;
  private events: AudioPlayerEvents = {};
  private currentVolume: number = 1.0;
  private appContext: Context | null = null;


  private constructor() {}

  /**
   * Get singleton instance of AudioManager
   */
  public static getInstance(): AudioManager {
    if (!AudioManager.instance) {
      AudioManager.instance = new AudioManager();
    }
    return AudioManager.instance;
  }

  /**
   * Initialize the audio manager with context
   */
  async initialize(context: Context): Promise<void> {
    try {
      this.appContext = context;

      // Create AVPlayer instance
      this.avPlayer = await media.createAVPlayer();

      if (!this.avPlayer) {
        throw new Error('Failed to create AVPlayer');
      }

      // Set up event listeners
      this.setupEventListeners();

      console.info('AudioManager initialized successfully');
    } catch (error) {
      console.error('Failed to initialize AudioManager:', JSON.stringify(error));
      this.emitError('Initialization failed');
    }
  }

  /**
   * Set up AVPlayer event listeners
   */
  private setupEventListeners(): void {
    if (!this.avPlayer) {
      return;
    }

    // State change callback
    this.avPlayer.on('stateChange', (state: media.AVPlayerState) => {
      console.info(`AVPlayer state changed to: ${state}`);
      switch (state) {
        case 'idle':
          this.updatePlaybackState(PlaybackState.IDLE);
          break;
        case 'playing':
          this.updatePlaybackState(PlaybackState.PLAYING);
          this.startProgressTimer();
          break;
        case 'paused':
          this.updatePlaybackState(PlaybackState.PAUSED);
          this.stopProgressTimer();
          break;
        case 'stopped':
          this.updatePlaybackState(PlaybackState.STOPPED);
          this.stopProgressTimer();
          break;
        case 'error':
          this.updatePlaybackState(PlaybackState.ERROR);
          this.emitError('Playback error occurred');
          break;
        case 'completed':
          this.updatePlaybackState(PlaybackState.STOPPED);
          this.onSongComplete();
          break;
        default:
          break;
      }
    });

    // Current position update callback
    this.avPlayer.on('timeUpdate', (time: number) => {
      this.emitProgressUpdate(time);
    });
  }

  /**
   * Load and prepare a song for playback
   */
  async loadSong(song: Song): Promise<void> {
    if (!this.avPlayer) {
      console.error('AVPlayer not initialized');
      return;
    }

    try {
      this.currentSong = song;
      this.updatePlaybackState(PlaybackState.IDLE);

      // Set audio source FIRST via fdSrc for rawfile
      // This is the ONLY way to load rawfile resources in OpenHarmony
      const rawFilePath = song.audioFile.replace('rawfile://', '');
      const fdData = await this.appContext?.resourceManager.getRawFd(rawFilePath);
      if (fdData) {
        const avFileDescriptor: media.AVFileDescriptor = {
          fd: fdData.fd,
          offset: fdData.offset,
          length: fdData.length
        };
        this.avPlayer.fdSrc = avFileDescriptor;
        console.info(`Set fdSrc for: ${song.title}`);
      } else {
        this.emitError(`Cannot open audio file: ${rawFilePath}`);
        return;
      }

      // Now call prepare - player should be in 'idle' state after setting fdSrc
      // If it auto-transitions to 'initialized', we may need to call prepare again
      try {
        await this.avPlayer.prepare();
        console.info(`AVPlayer prepared for: ${song.title}`);
      } catch (prepError) {
        console.error(`prepare() failed: ${JSON.stringify(prepError)}, trying stop then prepare`);
        // If prepare fails because we're not in stopped/idle, try stopping first
        try {
          await this.avPlayer.stop();
        } catch (e) {
          // Ignore
        }
        await this.avPlayer.prepare();
        console.info(`AVPlayer prepared after stop-retry for: ${song.title}`);
      }

      console.info(`Loaded song: ${song.title}`);
      this.emitSongChange(song);
    } catch (error) {
      console.error('Failed to load song:', JSON.stringify(error));
      this.emitError('Failed to load song: ' + JSON.stringify(error));
    }
  }



  /**
   * Start or resume playback
   */
  async play(): Promise<void> {
    if (!this.avPlayer) {
      console.error('AVPlayer not initialized');
      return;
    }

    try {
      await this.avPlayer.play();
      console.info('Playback started');
    } catch (error) {
      console.error('Failed to start playback:', JSON.stringify(error));
      this.emitError('Failed to start playback');
    }
  }

  /**
   * Pause playback
   */
  async pause(): Promise<void> {
    if (!this.avPlayer) {
      console.error('AVPlayer not initialized');
      return;
    }

    try {
      await this.avPlayer.pause();
      console.info('Playback paused');
    } catch (error) {
      console.error('Failed to pause playback:', JSON.stringify(error));
      this.emitError('Failed to pause playback');
    }
  }

  /**
   * Toggle play/pause state
   */
  async togglePlayPause(): Promise<void> {
    if (this.playbackState === PlaybackState.PLAYING) {
      await this.pause();
    } else {
      await this.play();
    }
  }

  /**
   * Seek to specific position
   */
  async seekTo(positionMs: number): Promise<void> {
    if (!this.avPlayer) {
      console.error('AVPlayer not initialized');
      return;
    }

    try {
      await this.avPlayer.seek(positionMs);
      console.info(`Seeked to position: ${positionMs}`);
    } catch (error) {
      console.error('Failed to seek:', JSON.stringify(error));
      this.emitError('Failed to seek');
    }
  }

  /**
   * Get current playback position
   */
  getCurrentPosition(): number {
    if (!this.avPlayer) {
      return 0;
    }
    return this.avPlayer.currentTime;
  }

  /**
   * Get current song duration
   */
  getDuration(): number {
    if (!this.avPlayer || !this.currentSong) {
      return 0;
    }
    return this.currentSong.duration;
  }

  /**
   * Play next song in playlist
   */
  async playNext(): Promise<void> {
    if (this.playlist.length === 0) {
      return;
    }

    this.currentIndex = (this.currentIndex + 1) % this.playlist.length;
    const nextSong = this.playlist[this.currentIndex];
    await this.loadSong(nextSong);
    await this.play();
  }

  /**
   * Play previous song in playlist
   */
  async playPrevious(): Promise<void> {
    if (this.playlist.length === 0) {
      return;
    }

    // If more than 3 seconds in, restart current song
    if (this.getCurrentPosition() > 3000) {
      await this.seekTo(0);
      return;
    }

    this.currentIndex = (this.currentIndex - 1 + this.playlist.length) % this.playlist.length;
    const prevSong = this.playlist[this.currentIndex];
    await this.loadSong(prevSong);
    await this.play();
  }

  /**
   * Set the playback playlist
   */
  setPlaylist(songs: Song[], startIndex: number = 0): void {
    this.playlist = songs;
    this.currentIndex = Math.max(0, Math.min(startIndex, songs.length - 1));
  }

  /**
   * Play a specific song by index
   */
  async playByIndex(index: number): Promise<void> {
    if (index < 0 || index >= this.playlist.length) {
      console.error('Invalid song index');
      return;
    }

    this.currentIndex = index;
    const song = this.playlist[index];
    await this.loadSong(song);
    await this.play();
  }

  /**
   * Set volume (0.0 to 1.0)
   */
  async setVolume(volume: number): Promise<void> {
    this.currentVolume = Math.max(0, Math.min(1, volume));

    if (this.avPlayer) {
      try {
        await this.avPlayer.setVolume(this.currentVolume);
      } catch (error) {
        console.error('Failed to set volume:', JSON.stringify(error));
      }
    }
  }

  /**
   * Get current volume
   */
  getVolume(): number {
    return this.currentVolume;
  }

  /**
   * Get current playback state
   */
  getPlaybackState(): PlaybackState {
    return this.playbackState;
  }

  /**
   * Get current song
   */
  getCurrentSong(): Song | null {
    return this.currentSong;
  }

  /**
   * Get current song index
   */
  getCurrentIndex(): number {
    return this.currentIndex;
  }

  /**
   * Get playlist
   */
  getPlaylist(): Song[] {
    return this.playlist;
  }

  /**
   * Set event handlers
   */
  setEventHandlers(events: AudioPlayerEvents): void {
    this.events = events;
  }

  /**
   * Stop playback and release resources
   */
  async stop(): Promise<void> {
    if (!this.avPlayer) {
      return;
    }

    try {
      await this.avPlayer.stop();
      this.stopProgressTimer();
      this.updatePlaybackState(PlaybackState.STOPPED);
    } catch (error) {
      console.error('Failed to stop playback:', JSON.stringify(error));
    }
  }

  /**
   * Release all resources
   */
  async release(): Promise<void> {
    await this.stop();

    if (this.avPlayer) {
      this.avPlayer.off('stateChange');
      this.avPlayer.off('error');
      this.avPlayer.off('timeUpdate');
      this.avPlayer = null;
    }

    this.playlist = [];
    this.currentSong = null;
    this.updatePlaybackState(PlaybackState.IDLE);
  }

  // Private helper methods

  private updatePlaybackState(state: PlaybackState): void {
    this.playbackState = state;
    if (this.events.onPlayStateChange) {
      this.events.onPlayStateChange(state);
    }
  }

  private startProgressTimer(): void {
    this.stopProgressTimer();
    this.progressTimer = setInterval((): void => {
      if (this.avPlayer) {
        this.emitProgressUpdate(this.avPlayer.currentTime);
      }
    }, 1000) as number;
  }

  private stopProgressTimer(): void {
    if (this.progressTimer !== -1) {
      clearInterval(this.progressTimer);
      this.progressTimer = -1;
    }
  }

  private emitProgressUpdate(currentTime: number): void {
    const duration = this.getDuration();
    if (this.events.onProgressUpdate) {
      this.events.onProgressUpdate(currentTime, duration);
    }
  }

  private emitSongChange(song: Song): void {
    if (this.events.onSongChange) {
      this.events.onSongChange(song);
    }
  }

  private emitError(error: string): void {
    if (this.events.onError) {
      this.events.onError(error);
    }
  }

  private onSongComplete(): void {
    if (this.events.onComplete) {
      this.events.onComplete();
    }
    // Only auto-play next if playlist has more than 1 song
    if (this.playlist.length > 1) {
      this.playNext();
    } else {
      // Single song or empty playlist - just stop
      this.stop();
    }
  }
}

// Export singleton getter
export function getAudioManager(): AudioManager {
  return AudioManager.getInstance();
}
