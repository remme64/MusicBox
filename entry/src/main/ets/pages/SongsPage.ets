import router from '@ohos.router';
import { Song, DEFAULT_SONGS, formatDuration } from '../model/Song';
import { getAudioManager } from '../utils/AudioManager';
import { PlaybackState } from '../utils/AudioManager';

/**
 * SongsPage - Song List Page
 * Displays all available songs in a list format
 */
@Entry
@Component
struct SongsPage {
  @State currentSongId: number = -1;
  @State isPlaying: boolean = false;

  private audioManager = getAudioManager();

  aboutToAppear(): void {
    this.updateCurrentSong();
    this.setupEventHandlers();
  }

  setupEventHandlers(): void {
    this.audioManager.setEventHandlers({
      onSongChange: (song: Song) => {
        this.currentSongId = song.id;
      },
      onPlayStateChange: (state: PlaybackState) => {
        this.isPlaying = state === PlaybackState.PLAYING;
      }
    });
  }

  updateCurrentSong(): void {
    const song = this.audioManager.getCurrentSong();
    if (song) {
      this.currentSongId = song.id;
    }
    this.isPlaying = this.audioManager.getPlaybackState() === PlaybackState.PLAYING;
  }

  async playSong(index: number): Promise<void> {
    try {
      await this.audioManager.playByIndex(index);
    } catch (error) {
      console.error('Failed to play song:', JSON.stringify(error));
    }
  }

  build() {
    Column() {
      // Header
      Text('歌曲列表')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#3D2A2A')
        .margin({ top: 48, bottom: 24, left: 20 })

      // Song count
      Text(`共 ${DEFAULT_SONGS.length} 首歌曲`)
        .fontSize(14)
        .fontColor('#8B6B6B')
        .margin({ left: 20, bottom: 16 })

      // Song list
      List() {
        ForEach(DEFAULT_SONGS, (song: Song, index: number) => {
          ListItem() {
            this.SongItem(song, index)
          }
        })
      }
      .listDirection(Axis.Vertical)
      .divider({ strokeWidth: 0.5, color: '#e0e0e0', startMargin: 70, endMargin: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF0EB')
  }

  @Builder
  SongItem(song: Song, index: number) {
    Row() {
      // Index number
      Text(`${index + 1}`)
        .fontSize(16)
        .fontColor(this.currentSongId === song.id ? '#FF8C69' : '#C8A8A0')
        .width(40)
        .textAlign(TextAlign.Center)

      // Song info
      Column() {
        Text(song.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.currentSongId === song.id ? '#FF8C69' : '#3D2A2A')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(`${song.artist} · ${song.album}`)
          .fontSize(13)
          .fontColor('#8B6B6B')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // Duration
      Text(formatDuration(song.duration))
        .fontSize(13)
        .fontColor('#C8A8A0')
        .margin({ right: 8 })

      // Playing indicator
      if (this.currentSongId === song.id) {
        Text(this.isPlaying ? '▶️' : '⏸️')
          .fontSize(16)
          .margin({ right: 8 })
      } else {
        Text('🎵')
          .fontSize(16)
          .opacity(0.5)
          .margin({ right: 8 })
      }
    }
    .width('100%')
    .height(64)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.currentSongId === song.id ? 'rgba(255, 140, 105, 0.08)' : 'transparent')
    .borderRadius(10)
    .onClick(() => {
      this.playSong(index);
    })
  }
}
