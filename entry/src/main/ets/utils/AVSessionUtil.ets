import { Song } from '../model/Song';

/**
 * AVSession utility for managing background audio playback
 * Simplified version without complex AVSession API
 */
export class AVSessionUtil {
  private static instance: AVSessionUtil | null = null;
  private isInitialized: boolean = false;

  // Callbacks for session events
  private onPlayCallback: (() => void) | null = null;
  private onPauseCallback: (() => void) | null = null;
  private onNextCallback: (() => void) | null = null;
  private onPreviousCallback: (() => void) | null = null;
  private onSeekCallback: ((position: number) => void) | null = null;

  private constructor() {}

  /**
   * Get singleton instance
   */
  public static getInstance(): AVSessionUtil {
    if (!AVSessionUtil.instance) {
      AVSessionUtil.instance = new AVSessionUtil();
    }
    return AVSessionUtil.instance;
  }

  /**
   * Initialize the AVSession for background playback
   */
  async initialize(ctx?: Context): Promise<void> {
    if (this.isInitialized) {
      console.info('AVSession already initialized');
      return;
    }

    try {
      // Note: Full AVSession implementation requires specific HarmonyOS SDK version
      // For now, we use simplified callbacks that can be connected to actual AVSession later
      this.isInitialized = true;
      console.info('AVSession utility initialized successfully');
    } catch (error) {
      console.error('Failed to initialize AVSession:', JSON.stringify(error));
    }
  }

  /**
   * Set the current playing song metadata
   */
  async setSongMetadata(song: Song): Promise<void> {
    console.info(`AVSession: set metadata for song: ${song.title}`);
  }

  /**
   * Update playback state
   */
  async updatePlaybackState(isPlaying: boolean, position: number = 0): Promise<void> {
    // State update would go here when AVSession is fully implemented
  }

  /**
   * Set callback for play command
   */
  setOnPlayCallback(callback: () => void): void {
    this.onPlayCallback = callback;
  }

  /**
   * Set callback for pause command
   */
  setOnPauseCallback(callback: () => void): void {
    this.onPauseCallback = callback;
  }

  /**
   * Set callback for next command
   */
  setOnNextCallback(callback: () => void): void {
    this.onNextCallback = callback;
  }

  /**
   * Set callback for previous command
   */
  setOnPreviousCallback(callback: () => void): void {
    this.onPreviousCallback = callback;
  }

  /**
   * Set callback for seek command
   */
  setOnSeekCallback(callback: (position: number) => void): void {
    this.onSeekCallback = callback;
  }

  /**
   * Deactivate and release the session
   */
  async release(): Promise<void> {
    this.isInitialized = false;
    console.info('AVSession released');
  }

  /**
   * Check if session is initialized
   */
  isSessionInitialized(): boolean {
    return this.isInitialized;
  }
}

// Export singleton getter
export function getAVSessionUtil(): AVSessionUtil {
  return AVSessionUtil.getInstance();
}
