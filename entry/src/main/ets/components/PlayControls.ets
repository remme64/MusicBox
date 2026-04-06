/**
 * PlayControls Component
 * Play/Pause, Previous, Next buttons with modern styling
 */
@Component
export struct PlayControls {
  // Whether music is currently playing
  @Prop isPlaying: boolean = false;
  // Loading state
  @Prop isLoading: boolean = false;

  // Event callbacks
  onPlayPause: () => void = () => {};
  onPrevious: () => void = () => {};
  onNext: () => void = () => {};

  // Button sizes
  private readonly MAIN_BUTTON_SIZE: number = 64;
  private readonly SECONDARY_BUTTON_SIZE: number = 48;

  build() {
    Row({ space: 32 }) {
      // Previous button
      Button() {
        Text('⏮')
          .fontSize(24)
          .fontColor('#ffffff')
      }
      .width(this.SECONDARY_BUTTON_SIZE)
      .height(this.SECONDARY_BUTTON_SIZE)
      .type(ButtonType.Circle)
      .backgroundColor('transparent')
      .onClick(() => {
        this.onPrevious();
      })

      // Play/Pause button
      Button() {
        if (this.isLoading) {
          LoadingProgress()
            .width(32)
            .height(32)
            .color('#ffffff')
        } else {
          Text(this.isPlaying ? '⏸' : '▶')
            .fontSize(28)
            .fontColor('#ffffff')
        }
      }
      .width(this.MAIN_BUTTON_SIZE)
      .height(this.MAIN_BUTTON_SIZE)
      .type(ButtonType.Circle)
      .backgroundColor('#6366f1')
      .shadow({
        radius: 16,
        color: '#406366f1',
        offsetX: 0,
        offsetY: 4
      })
      .onClick(() => {
        if (!this.isLoading) {
          this.onPlayPause();
        }
      })

      // Next button
      Button() {
        Text('⏭')
          .fontSize(24)
          .fontColor('#ffffff')
      }
      .width(this.SECONDARY_BUTTON_SIZE)
      .height(this.SECONDARY_BUTTON_SIZE)
      .type(ButtonType.Circle)
      .backgroundColor('transparent')
      .onClick(() => {
        this.onNext();
      })
    }
    .justifyContent(FlexAlign.Center)
  }
}

/**
 * Mini PlayControls for list items
 * Smaller version of play controls
 */
@Component
export struct MiniPlayControls {
  @Prop isPlaying: boolean = false;

  onPlayPause: () => void = () => {};

  private readonly BUTTON_SIZE: number = 40;

  build() {
    Button() {
      Text(this.isPlaying ? '⏸' : '▶')
        .fontSize(16)
        .fontColor('#6366f1')
    }
    .width(this.BUTTON_SIZE)
    .height(this.BUTTON_SIZE)
    .type(ButtonType.Circle)
    .backgroundColor('transparent')
    .onClick(() => {
      this.onPlayPause();
    })
  }
}
