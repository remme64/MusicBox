/**
 * SongCard - Displays a song in list format
 * Used in library, recommendations, and playlists
 */
import { Song } from '../model/Song';

@Component
export struct SongCard {
  // Song data
  @Prop song: Song;
  @Prop showIndex: boolean = false;
  @Prop index: number = 0;
  @Prop isPlaying: boolean = false;

  // Event callbacks
  onPlay: () => void = () => {};
  onMoreClick: () => void = () => {};

  build() {
    Row() {
      // Index or playing indicator
      if (this.showIndex) {
        Column() {
          if (this.isPlaying) {
            Text('🎵')
              .fontSize(16)
              .fontColor('#FF8C69')
          } else {
            Text((this.index + 1).toString())
              .fontSize(14)
              .fontColor('#C8A8A0')
          }
        }
        .width(32)
        .alignItems(HorizontalAlign.Center)
      }

      // Cover art
      Column() {
        if (this.song.coverImage) {
          Image($r(this.song.coverImage))
            .width(48)
            .height(48)
            .borderRadius(8)
            .objectFit(ImageFit.Cover)
        } else {
          Column() {
            Text('🎵')
              .fontSize(20)
          }
          .width(48)
          .height(48)
          .backgroundColor('#3D2828')
          .borderRadius(8)
          .justifyContent(FlexAlign.Center)
        }
      }
      .margin({ left: this.showIndex ? 8 : 0 })

      // Song info
      Column() {
        Text(this.song.title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.isPlaying ? '#FF8C69' : '#FFF5F0')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(this.song.artist + ' · ' + this.song.album)
          .fontSize(12)
          .fontColor('#C8A8A0')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })

      // Duration
      Text(this.formatDuration(this.song.duration))
        .fontSize(12)
        .fontColor('#A88888')
        .margin({ right: 8 })

      // More button
      Button() {
        Text('⋯')
          .fontSize(18)
          .fontColor('#C8A8A0')
      }
      .width(36)
      .height(36)
      .type(ButtonType.Circle)
      .backgroundColor('rgba(255, 200, 180, 0.1)')
      .onClick(() => {
        this.onMoreClick();
      })
    }
    .width('100%')
    .height(64)
    .padding({ left: 8, right: 8 })
    .backgroundColor(this.isPlaying ? 'rgba(255, 140, 105, 0.08)' : 'transparent')
    .borderRadius(10)
    .onClick(() => {
      this.onPlay();
    })
  }

  formatDuration(durationMs: number): string {
    const totalSeconds = Math.floor(durationMs / 1000);
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60;
    return `${minutes}:${seconds.toString().padStart(2, '0')}`;
  }
}

/**
 * SongCardCompact - Smaller version for horizontal lists
 */
@Component
export struct SongCardCompact {
  @Prop song: Song;
  @Prop isPlaying: boolean = false;

  onPlay: () => void = () => {};

  build() {
    Column() {
      // Cover art
      Column() {
        if (this.song.coverImage) {
          Image($r(this.song.coverImage))
            .width('100%')
            .aspectRatio(1)
            .borderRadius(12)
            .objectFit(ImageFit.Cover)
        } else {
          Column() {
            Text('🎵')
              .fontSize(32)
          }
          .width('100%')
          .aspectRatio(1)
          .backgroundColor('#3D2828')
          .borderRadius(12)
          .justifyContent(FlexAlign.Center)
        }
      }

      // Title
      Text(this.song.title)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.isPlaying ? '#FF8C69' : '#FFF5F0')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ top: 8 })

      // Artist
      Text(this.song.artist)
        .fontSize(11)
        .fontColor('#C8A8A0')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ top: 2 })
    }
    .width(120)
    .onClick(() => {
      this.onPlay();
    })
  }
}
