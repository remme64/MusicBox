import router from '@ohos.router';
import { Song } from '../model/Song';
import { AudioManager, PlaybackState, getAudioManager } from '../utils/AudioManager';
import { ParsedLyrics, parseLrc } from '../utils/LyricParser';
import { LyricView } from '../components/LyricView';

/**
 * LyricsPage - Full Screen Lyrics View
 * Displays synchronized lyrics with scroll and tap-to-seek
 */
@Entry
@Component
struct LyricsPage {
  // Audio manager instance
  private audioManager: AudioManager = getAudioManager();

  // State variables
  @State currentSong: Song | null = null;
  @State lyrics: ParsedLyrics | null = null;
  @State currentTimeMs: number = 0;
  @State totalTimeMs: number = 0;
  @State isPlaying: boolean = false;
  @State isLyricsEnabled: boolean = true;

  // Sample lyrics for demo
  private readonly SAMPLE_LYRICS: string = `[ti:Dream Waves]
[ar:Electronic Dreams]
[al:Synthesizer Nights]
[00:00.00]♪ Dream Waves ♪
[00:05.00]Let the music take you away
[00:10.00]To a place where worries fade
[00:15.00]Feel the rhythm in your heart
[00:20.00]This is where the dreams start
[00:25.00]Waves of sound surround you now
[00:30.00]Let the music show you how
[00:35.00]To float upon this melody
[00:40.00]To a world where you are free
[00:45.00]Dream waves, dream waves
[00:50.00]Let the music be your guide
[00:55.00]Dream waves, dream waves
[01:00.00]Let the rhythm be your tide
[01:05.00]Rising up, we reach the sky
[01:10.00]Waves of sound lifting us high
[01:15.00]In this moment, we are free
[01:20.00]Let the music set us free
[01:25.00]Electronic dreams come alive
[01:30.00]In this music, we revive
[01:35.00]Dream waves, dream waves
[01:40.00]Feel the magic in the sound
[01:45.00]Dream waves, dream waves
[01:50.00]Let the melody abound
[01:55.00]Music flows like an ocean wide
[02:00.00]Take you on a timeless ride
[02:05.00]Dreams are calling, can't you hear
[02:10.00]Let the music disappear
[02:15.00]Into the waves of sound tonight
[02:20.00]Everything will feel so right
[02:25.00]Dream waves, dream waves
[02:30.00]Let the rhythm carry you
[02:35.00]Dream waves, dream waves
[02:40.00]The music sees you through
[02:45.00]Let the melody set you free
[02:50.00]Dream waves...`;

  aboutToAppear(): void {
    // Get current song from audio manager
    this.currentSong = this.audioManager.getCurrentSong();

    // Parse lyrics
    this.lyrics = parseLrc(this.SAMPLE_LYRICS);

    // Set up event handlers
    this.setupEventHandlers();
  }

  /**
   * Set up event handlers
   */
  setupEventHandlers(): void {
    this.audioManager.setEventHandlers({
      onPlayStateChange: (state: PlaybackState): void => {
        this.isPlaying = state === PlaybackState.PLAYING;
      },
      onProgressUpdate: (currentTime: number, duration: number): void => {
        this.currentTimeMs = currentTime;
        this.totalTimeMs = duration;
      },
      onSongChange: (song: Song): void => {
        this.currentSong = song;
      }
    });

    // Get initial state
    this.isPlaying = this.audioManager.getPlaybackState() === PlaybackState.PLAYING;
  }

  /**
   * Go back to previous page
   */
  goBack(): void {
    router.back();
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      // Background gradient
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Top,
          colors: [['#2D1B35', 0], ['#4A2C4A', 1]]
        })

      // Top bar with close button and song info
      this.buildTopBar()

      // Lyrics display
      LyricView({
        lyrics: this.isLyricsEnabled ? this.lyrics : null,
        currentTimeMs: this.currentTimeMs,
        visibleLinesCount: 5,
        isEnabled: this.isLyricsEnabled
      })
      .padding({
        top: 80,
        bottom: 120
      })

      // Bottom controls
      this.buildBottomControls()
    }
  }

  /**
   * Build top navigation bar
   */
  @Builder
  buildTopBar(): void {
    Column() {
      Row() {
        // Close button
        Button() {
          Text('✕')
            .fontSize(20)
            .fontColor('#FFF5F0')
        }
        .width(48)
        .height(48)
        .type(ButtonType.Circle)
        .backgroundColor('rgba(255, 200, 180, 0.15)')
        .onClick(() => {
          this.goBack();
        })

        Column() {
          Text('Lyrics')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#ffffff')

          Text(this.currentSong?.title || 'Unknown Title')
            .fontSize(13)
            .fontColor('#a0a0b0')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        // Toggle lyrics button
        Button() {
          Text(this.isLyricsEnabled ? 'Hide' : 'Show')
            .fontSize(14)
            .fontColor('#FF8C69')
        }
        .width(60)
        .height(36)
        .type(ButtonType.Capsule)
        .backgroundColor('transparent')
        .onClick(() => {
          this.isLyricsEnabled = !this.isLyricsEnabled;
        })
      }
      .width('100%')
      .padding({ left: 8, right: 16 })
    }
    .width('100%')
  }

  /**
   * Build bottom controls
   */
  @Builder
  buildBottomControls(): void {
    Column() {
      // Progress indicator
      Row() {
        Text(this.formatTime(this.currentTimeMs))
          .fontSize(12)
          .fontColor('#a0a0b0')

        Blank()

        Text(this.formatTime(this.totalTimeMs))
          .fontSize(12)
          .fontColor('#a0a0b0')
      }
      .width('80%')
      .padding({ bottom: 8 })

      // Mini progress bar
      Row() {
        Column()
          .width(this.totalTimeMs > 0 ? (this.currentTimeMs / this.totalTimeMs) * 100 : 0)
          .height(3)
          .backgroundColor('#FF8C69')

        Column()
          .layoutWeight(1)
          .height(3)
          .backgroundColor('#5A3A3A')
      }
      .width('80%')
      .borderRadius(2)
    }
    .width('100%')
    .padding({ bottom: 40 })
    .alignItems(HorizontalAlign.Center)
  }

  /**
   * Format time helper
   */
  private formatTime(ms: number): string {
    const totalSeconds = Math.floor(ms / 1000);
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60;
    return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
  }
}
