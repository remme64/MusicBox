/**
 * AlbumCover Component
 * Displays the album artwork with rotation animation during playback
 * Circular crop with shadow effect for modern music player look
 */
@Component
export struct AlbumCover {
  // Cover image path
  @Prop coverImage: string = '';
  // Whether the album is currently rotating (playing)
  @Prop isPlaying: boolean = false;
  // Size of the cover
  @Prop coverSize: number = 280;

  // Animation rotation angle
  @State rotationAngle: number = 0;

  // Timer for rotation animation
  private rotationTimer: number = -1;

  // Animation duration in milliseconds (20 seconds for full rotation)
  private readonly ANIMATION_DURATION: number = 20000;

  aboutToAppear(): void {
    if (this.isPlaying) {
      this.startRotationAnimation();
    }
  }

  aboutToDisappear(): void {
    this.stopRotationAnimation();
  }

  /**
   * Start the rotation animation
   */
  startRotationAnimation(): void {
    this.stopRotationAnimation();

    // Update rotation angle periodically
    // Simpler approach: animate using state updates
    const startTime = Date.now();
    this.rotationTimer = setInterval((): void => {
      const elapsed = Date.now() - startTime;
      // Calculate angle based on elapsed time
      this.rotationAngle = (elapsed / this.ANIMATION_DURATION) * 360 % 360;
    }, 16) as number; // ~60fps
  }

  /**
   * Stop the rotation animation
   */
  stopRotationAnimation(): void {
    if (this.rotationTimer !== -1) {
      clearInterval(this.rotationTimer);
      this.rotationTimer = -1;
    }
  }

  /**
   * Update animation based on playing state
   */
  onPlayingChange(newIsPlaying: boolean): void {
    if (newIsPlaying) {
      this.startRotationAnimation();
    } else {
      this.stopRotationAnimation();
    }
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      // Outer shadow ring
      Column()
        .width(this.coverSize + 16)
        .height(this.coverSize + 16)
        .borderRadius((this.coverSize + 16) / 2)
        .backgroundColor('#E8C0B0')
        .shadow({
          radius: 20,
          color: '#30000000',
          offsetX: 0,
          offsetY: 8
        })

      // Inner disc background
      Column()
        .width(this.coverSize)
        .height(this.coverSize)
        .borderRadius(this.coverSize / 2)
        .backgroundColor('#F5E6E0')

      // Album cover image
      if (this.coverImage) {
        Image(this.coverImage)
          .width(this.coverSize - 20)
          .height(this.coverSize - 20)
          .borderRadius((this.coverSize - 20) / 2)
          .objectFit(ImageFit.Cover)
          .shadow({
            radius: 10,
            color: '#60000000',
            offsetX: 0,
            offsetY: 4
          })
      } else {
        // Placeholder when no cover image
        Column() {
          Text('♪')
            .fontSize(this.coverSize / 4)
            .fontColor('#FF8C69')
        }
        .width(this.coverSize - 20)
        .height(this.coverSize - 20)
        .borderRadius((this.coverSize - 20) / 2)
        .backgroundColor('#FFF0EB')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }

      // Center hole (vinyl effect)
      Column()
        .width(this.coverSize / 6)
        .height(this.coverSize / 6)
        .borderRadius(this.coverSize / 12)
        .backgroundColor('#F5E6E0')
        .border({
          width: 2,
          color: '#D8C0B0'
        })
    }
    .width(this.coverSize + 32)
    .height(this.coverSize + 32)
    .rotate({
      x: 0,
      y: 0,
      z: 1,
      angle: this.rotationAngle
    })
  }
}

/**
 * Simple album cover without animation
 * For use in lists and smaller displays
 */
@Component
export struct AlbumCoverSimple {
  @Prop coverImage: string = '';
  @Prop coverSize: number = 60;

  build() {
    if (this.coverImage) {
      Image(this.coverImage)
        .width(this.coverSize)
        .height(this.coverSize)
        .borderRadius(this.coverSize / 8)
        .objectFit(ImageFit.Cover)
    } else {
      Column() {
        Text('♪')
          .fontSize(this.coverSize / 2)
          .fontColor('#FF8C69')
      }
      .width(this.coverSize)
      .height(this.coverSize)
      .borderRadius(this.coverSize / 8)
      .backgroundColor('#3D2A2A')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
  }
}
