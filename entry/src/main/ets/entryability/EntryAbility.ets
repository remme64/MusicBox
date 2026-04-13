import UIAbility from '@ohos.app.ability.UIAbility';
import { hilog } from '@kit.PerformanceAnalysisKit';
import window from '@ohos.window';
import { getAVSessionUtil } from '../utils/AVSessionUtil';
import { getAudioManager } from '../utils/AudioManager';
import { getStorageManager } from '../utils/StorageManager';

/**
 * EntryAbility - Main application entry point
 * Handles window creation, lifecycle events, and background audio session
 */
export default class EntryAbility extends UIAbility {
  private readonly TAG: string = 'MusicBox_EntryAbility';

  /**
   * Called when the ability is being created
   */
  onCreate(want: object, launchParam: object): void {
    hilog.info(0x0000, this.TAG, 'EntryAbility onCreate');

    // Initialize audio manager with context
    const audioManager = getAudioManager();
    audioManager.initialize(this.context);

    // Initialize AVSession for background playback
    const avSessionUtil = getAVSessionUtil();
    avSessionUtil.initialize(this.context);

    // Initialize storage manager
    const storageManager = getStorageManager();
    storageManager.initialize(this.context);
  }

  /**
   * Called when the ability is being destroyed
   */
  onDestroy(): void {
    hilog.info(0x0000, this.TAG, 'EntryAbility onDestroy');

    // Release AVSession resources
    const avSessionUtil = getAVSessionUtil();
    avSessionUtil.release();

    // Release audio manager
    const audioManager = getAudioManager();
    audioManager.release();
  }

  /**
   * Called when the window is being created
   */
  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(0x0000, this.TAG, 'EntryAbility onWindowStageCreate');

    // Load main page
    windowStage.loadContent('pages/MainPage', (err: object) => {
      if (err) {
        hilog.error(0x0000, this.TAG, 'Failed to load content: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(0x0000, this.TAG, 'Successfully loaded content');
    });
  }

  /**
   * Called when the window stage is being destroyed
   */
  onWindowStageDestroy(): void {
    hilog.info(0x0000, this.TAG, 'EntryAbility onWindowStageDestroy');
  }

  /**
   * Called when the ability is in the foreground
   */
  onForeground(): void {
    hilog.info(0x0000, this.TAG, 'EntryAbility onForeground');
  }

  /**
   * Called when the ability is moved to the background
   */
  onBackground(): void {
    hilog.info(0x0000, this.TAG, 'EntryAbility onBackground');
  }

  /**
   * Called when a new want is received
   */
  onNewWant(want: object, launchParam: object): void {
    hilog.info(0x0000, this.TAG, 'EntryAbility onNewWant');
  }
}
