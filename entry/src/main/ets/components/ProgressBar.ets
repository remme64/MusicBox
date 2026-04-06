/**
 * ProgressBar Component
 * Displays playback progress with time indicators
 * Supports seeking via slider interaction
 */
@Component
export struct ProgressBar {
  // Current playback position in milliseconds
  @Prop currentTimeMs: number = 0;
  // Total duration in milliseconds
  @Prop totalTimeMs: number = 0;
  // Whether seeking is allowed
  @Prop isSeekable: boolean = true;

  // Event callbacks
  onSeek: (positionMs: number) => void = () => {};

  // Progress percentage (0-100)
  @State progressPercent: number = 0;

  // Format time helper
  private readonly FORMATTER = (ms: number): string => {
    const totalSeconds = Math.floor(ms / 1000);
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60;
    return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
  };

  /**
   * Update progress when time changes
   */
  aboutToAppear(): void {
    this.updateProgress();
  }

  /**
   * Update progress percentage
   */
  updateProgress(): void {
    if (this.totalTimeMs > 0) {
      this.progressPercent = (this.currentTimeMs / this.totalTimeMs) * 100;
    } else {
      this.progressPercent = 0;
    }
  }

  build() {
    Column({ space: 8 }) {
      // Progress slider
      Row() {
        Column()
          .width(this.progressPercent + '%')
          .height(4)
          .backgroundColor('#6366f1')
          .borderRadius(2)

        Column()
          .layoutWeight(1)
          .height(4)
          .backgroundColor('#404060')
          .borderRadius(2)
      }
      .width('100%')
      .height(4)
      .onTouch((event: TouchEvent) => {
        if (this.isSeekable && event.type === 2) { // 2 = TouchType.End
          // Calculate seek position based on touch
          const trackWidth = 300; // Approximate width
          const touchX = event.touches[0]?.x ?? 0;
          const percent = Math.max(0, Math.min(100, (touchX / trackWidth) * 100));
          const seekPosition = (percent / 100) * this.totalTimeMs;
          this.onSeek(seekPosition);
        }
      })

      // Time indicators
      Row() {
        // Current time
        Text(this.FORMATTER(this.currentTimeMs))
          .fontSize(12)
          .fontColor('#a0a0b0')
          .fontWeight(FontWeight.Medium)

        Blank()

        // Total time
        Text(this.FORMATTER(this.totalTimeMs))
          .fontSize(12)
          .fontColor('#a0a0b0')
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .padding({ left: 4, right: 4 })
    }
  }
}

/**
 * Mini ProgressBar for list items
 * Simplified progress without time labels
 */
@Component
export struct MiniProgressBar {
  @Prop progressValue: number = 0; // 0-100

  build() {
    Column() {
      Progress({
        value: this.progressValue,
        total: 100,
        style: ProgressStyle.Linear
      })
        .width('100%')
        .height(4)
        .color('#6366f1')
        .backgroundColor('#404060')
    }
  }
}
