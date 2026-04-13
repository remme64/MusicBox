/**
 * MiniPlayer - Compact bottom music player bar
 * Displays current song with play/pause control
 */
@Component
export struct MiniPlayer {
  // Current song info
  @Prop currentSong: Song | null = null;
  @Prop isPlaying: boolean = false;
  @Prop coverImage: string = '';

  // Event callbacks
  onPlayPause: () => void = () => {};
  onTap: () => void = () => {};

  build() {
    if (this.currentSong) {
      Row() {
        // Album art thumbnail
        Column() {
          if (this.coverImage) {
            Image($r(this.coverImage))
              .width(48)
              .height(48)
              .borderRadius(8)
              .objectFit(ImageFit.Cover)
          } else {
            Column() {
              Text('🎵')
                .fontSize(24)
            }
            .width(48)
            .height(48)
            .backgroundColor('#FFE8E0')
            .borderRadius(8)
            .justifyContent(FlexAlign.Center)
          }
        }

        // Song info
        Column() {
          Text(this.currentSong.title)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#3D2A2A')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(this.currentSong.artist)
            .fontSize(12)
            .fontColor('#8B6B6B')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: 12 })

        // Play/Pause button
        Button() {
          Text(this.isPlaying ? '⏸️' : '▶️')
            .fontSize(22)
        }
        .width(44)
        .height(44)
        .type(ButtonType.Circle)
        .backgroundColor('rgba(255, 140, 105, 0.15)')
        .onClick(() => {
          this.onPlayPause();
        })
      }
      .width('100%')
      .height(64)
      .padding({ left: 12, right: 12 })
      .backgroundColor('#FFF8F5')
      .borderRadius({ topLeft: 16, topRight: 16 })
      .shadow({
        radius: 12,
        color: '#20000000',
        offsetX: 0,
        offsetY: -4
      })
      .onClick(() => {
        this.onTap();
      })
    }
  }
}
