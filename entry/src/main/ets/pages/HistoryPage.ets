import router from '@ohos.router';
import { HistoryRecord } from '../model/HistoryRecord';
import { getStorageManager } from '../utils/StorageManager';
import { getAudioManager } from '../utils/AudioManager';
import promptAction from '@ohos.promptAction';

/**
 * HistoryPage - Play history page
 */
@Entry
@Component
struct HistoryPage {
  @State private history: HistoryRecord[] = [];
  @State private isLoading: boolean = true;

  aboutToAppear(): void {
    this.loadHistory();
  }

  /**
   * Load play history
   */
  async loadHistory(): Promise<void> {
    try {
      this.isLoading = true;
      const storage = getStorageManager();
      this.history = await storage.getHistory();
      this.isLoading = false;
    } catch (error) {
      console.error('Failed to load history:', JSON.stringify(error));
      this.isLoading = false;
    }
  }

  /**
   * Play a song from history
   */
  async playSong(record: HistoryRecord): Promise<void> {
    try {
      const audioManager = getAudioManager();
      const storage = getStorageManager();

      // Update history timestamp
      await storage.addToHistory(record.song, 0);

      audioManager.setPlaylist(this.history.map(h => h.song), this.history.findIndex(h => h.id === record.id));
      await audioManager.loadSong(record.song);
      await audioManager.play();

      promptAction.showToast({ message: `正在播放: ${record.song.title}`, duration: 2000 });
    } catch (error) {
      console.error('Failed to play song:', JSON.stringify(error));
    }
  }

  /**
   * Clear all history
   */
  async clearHistory(): Promise<void> {
    try {
      const storage = getStorageManager();
      await storage.clearHistory();
      this.history = [];
      promptAction.showToast({ message: '历史记录已清除', duration: 2000 });
    } catch (error) {
      console.error('Failed to clear history:', JSON.stringify(error));
    }
  }

  /**
   * Format timestamp to readable date
   */
  formatTime(timestamp: number): string {
    const now = Date.now();
    const diff = now - timestamp;
    const minutes = Math.floor(diff / 60000);
    const hours = Math.floor(diff / 3600000);
    const days = Math.floor(diff / 86400000);

    if (minutes < 1) return '刚刚';
    if (minutes < 60) return `${minutes} 分钟前`;
    if (hours < 24) return `${hours} 小时前`;
    if (days < 7) return `${days} 天前`;

    const date = new Date(timestamp);
    return `${date.getMonth() + 1}/${date.getDate()}`;
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Top,
          colors: [['#1a1a2e', 0], ['#16213e', 1]]
        })

      Column() {
        this.buildHeader()

        if (this.isLoading) {
          Column() {
            LoadingProgress()
              .width(48)
              .height(48)
              .color('#ffffff')
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        } else if (this.history.length === 0) {
          this.buildEmptyState()
        } else {
          this.buildHistoryList()
        }
      }
    }
  }

  @Builder
  buildHeader(): void {
    Row() {
      Button() {
        Text('‹ 返回')
          .fontSize(18)
          .fontColor('#ffffff')
      }
      .type(ButtonType.Normal)
      .backgroundColor('transparent')
      .onClick(() => router.back())

      Blank()

      Text('🕐 历史记录')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#ffffff')

      Blank()

      if (this.history.length > 0) {
        Button() {
          Text('清除')
            .fontSize(14)
            .fontColor('#F5A623')
        }
        .type(ButtonType.Normal)
        .backgroundColor('transparent')
        .onClick(() => this.clearHistory())
      } else {
        Text('')
          .width(40)
      }
    }
    .width('100%')
    .padding({ top: 48, left: 16, right: 16, bottom: 16 })
  }

  @Builder
  buildEmptyState(): void {
    Column() {
      Text('🕐')
        .fontSize(64)

      Text('暂无播放历史')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#ffffff')
        .margin({ top: 16 })

      Text('开始播放音乐以查看历史记录')
        .fontSize(14)
        .fontColor('#a0a0b0')
        .margin({ top: 8 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildHistoryList(): void {
    Scroll() {
      Column({ space: 8 }) {
        ForEach(this.history, (record: HistoryRecord) => {
          this.buildHistoryItem(record)
        })

        Divider()
          .height(100)
          .color('transparent')
      }
      .padding({ left: 16, right: 16 })
    }
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
  }

  @Builder
  buildHistoryItem(record: HistoryRecord): void {
    Row() {
      Column() {
        Text('🎵')
          .fontSize(20)
      }
      .width(44)
      .height(44)
      .backgroundColor('rgba(245, 166, 35, 0.2)')
      .borderRadius(8)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)

      Column() {
        Text(record.song.title)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#ffffff')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(`${record.song.artist} · ${this.formatTime(record.playedAt)}`)
          .fontSize(11)
          .fontColor('#a0a0b0')
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 10 })

      Button() {
        Text('▶')
          .fontSize(12)
          .fontColor('#ffffff')
      }
      .width(32)
      .height(32)
      .type(ButtonType.Circle)
      .backgroundColor('#F5A623')
      .onClick(() => this.playSong(record))
    }
    .width('100%')
    .padding({ top: 8, bottom: 8, left: 10, right: 10 })
    .backgroundColor('rgba(255, 255, 255, 0.05)')
    .borderRadius(10)
  }
}
