/**
 * VolumeControl Component
 * Displays volume level with slider control
 * Includes speaker icon that changes based on volume level
 */
@Component
export struct VolumeControl {
  // Current volume level (0.0 to 1.0)
  @Prop volume: number = 1.0;
  // Whether the component is enabled
  @Prop isEnabled: boolean = true;

  // Event callbacks
  onVolumeChange: (volume: number) => void = () => {};

  // Internal state for slider
  @State sliderValue: number = 100;

  // Icon size
  private readonly ICON_SIZE: number = 24;
  // Slider width
  private readonly SLIDER_WIDTH: number = 120;

  /**
   * Get speaker icon based on volume level
   */
  private getVolumeIcon(): string {
    if (this.volume <= 0) {
      return '🔇';
    } else if (this.volume < 0.3) {
      return '🔈';
    } else if (this.volume < 0.7) {
      return '🔉';
    } else {
      return '🔊';
    }
  }

  /**
   * Get volume icon color
   */
  private getVolumeIconColor(): string {
    if (!this.isEnabled) {
      return '#606060';
    }
    return '#ffffff';
  }

  aboutToAppear(): void {
    this.sliderValue = this.volume * 100;
  }

  build() {
    Row({ space: 8 }) {
      // Speaker/Volume icon
      Text(this.getVolumeIcon())
        .fontSize(this.ICON_SIZE)
        .fontColor(this.getVolumeIconColor())

      // Volume slider via touch
      Row() {
        Column()
          .width(this.sliderValue + '%')
          .height(4)
          .backgroundColor('#6366f1')
          .borderRadius(2)

        Column()
          .layoutWeight(1)
          .height(4)
          .backgroundColor('#404060')
          .borderRadius(2)
      }
      .width(this.SLIDER_WIDTH)
      .height(4)
      .onTouch((event: TouchEvent) => {
        if (this.isEnabled && event.type === 2) { // 2 = TouchType.End
          const trackWidth = this.SLIDER_WIDTH;
          const touchX = event.touches[0]?.x ?? 0;
          const percent = Math.max(0, Math.min(100, (touchX / trackWidth) * 100));
          this.sliderValue = percent;
          const newVolume = percent / 100;
          this.onVolumeChange(newVolume);
        }
      })
    }
    .padding({
      left: 12,
      right: 12,
      top: 8,
      bottom: 8
    })
    .backgroundColor('rgba(42, 42, 74, 0.6)')
    .borderRadius(20)
  }
}

/**
 * Compact VolumeControl for inline use
 * Just the icon with tap-to-toggle mute
 */
@Component
export struct VolumeControlCompact {
  @Prop volume: number = 1.0;

  onVolumeChange: (volume: number) => void = () => {};

  private readonly ICON_SIZE: number = 24;

  private isMuted: boolean = false;
  private previousVolume: number = 1.0;

  build() {
    Text(this.volume <= 0 ? '🔇' : '🔊')
      .fontSize(this.ICON_SIZE)
      .fontColor('#ffffff')
      .onClick(() => {
        if (this.volume > 0) {
          this.previousVolume = this.volume;
          this.isMuted = true;
          this.onVolumeChange(0);
        } else {
          this.isMuted = false;
          this.onVolumeChange(this.previousVolume);
        }
      })
  }
}
