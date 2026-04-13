import router from '@ohos.router';
import { Song, DEFAULT_SONGS } from '../model/Song';
import { AudioManager, PlaybackState, getAudioManager } from '../utils/AudioManager';
import { AlbumCoverSimple } from '../components/AlbumCover';
import { MiniPlayControls } from '../components/PlayControls';
import { formatTime } from '../utils/LyricParser';

/**
 * PlayList - Music Playlist Page
 * Displays all available songs with playback controls
 */
@Entry
@Component
struct PlayList {
  // Audio manager instance
  private audioManager: AudioManager = getAudioManager();

  // State variables
  @State songs: Song[] = DEFAULT_SONGS;
  @State currentSongIndex: number = 0;
  @State isPlaying: boolean = false;
  @State currentTimeMs: number = 0;
  @State totalTimeMs: number = 0;

  aboutToAppear(): void {
    // Set up event handlers
    this.setupEventHandlers();

    // Get current state
    this.currentSongIndex = this.audioManager.getCurrentIndex();
    this.isPlaying = this.audioManager.getPlaybackState() === PlaybackState.PLAYING;

    // Update playlist
    this.songs = this.audioManager.getPlaylist();
    if (this.songs.length === 0) {
      this.songs = DEFAULT_SONGS;
      this.audioManager.setPlaylist(DEFAULT_SONGS, 0);
    }
  }

  /**
   * Set up event handlers
   */
  setupEventHandlers(): void {
    this.audioManager.setEventHandlers({
      onPlayStateChange: (state: PlaybackState): void => {
        this.isPlaying = state === PlaybackState.PLAYING;
      },
      onProgressUpdate: (currentTime: number, duration: number): void => {
        this.currentTimeMs = currentTime;
        this.totalTimeMs = duration;
      },
      onSongChange: (song: Song): void => {
        const index = this.songs.findIndex((s: Song): boolean => {
          return s.id === song.id;
        });
        if (index !== -1) {
          this.currentSongIndex = index;
        }
      },
      onError: (error: string): void => {
        console.error('Playlist error:', error);
      }
    });
  }

  /**
   * Play a specific song by index
   */
  async playSong(index: number): Promise<void> {
    try {
      await this.audioManager.playByIndex(index);
      this.currentSongIndex = index;
    } catch (error) {
      console.error('Failed to play song:', JSON.stringify(error));
    }
  }

  /**
   * Toggle play/pause for current song
   */
  async togglePlayPause(): Promise<void> {
    try {
      await this.audioManager.togglePlayPause();
    } catch (error) {
      console.error('Toggle play/pause failed:', JSON.stringify(error));
    }
  }

  /**
   * Go back to previous page
   */
  goBack(): void {
    router.back();
  }

  build() {
    Column() {
      // Header
      this.buildHeader()

      // Song list
      List({ space: 0 }) {
        ForEach(
          this.songs,
          (song: Song, index: number) => {
            ListItem() {
              this.buildSongRow(song, index)
            }
            .padding({ left: 8, right: 8 })
          },
          (song: Song) => song.id.toString()
        )
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#2D1B35')
  }

  /**
   * Build page header
   */
  @Builder
  buildHeader(): void {
    Column() {
      Row() {
        // Back button
        Button() {
          Text('←')
            .fontSize(24)
            .fontColor('#FFF5F0')
        }
        .width(48)
        .height(48)
        .type(ButtonType.Circle)
        .backgroundColor('rgba(255, 200, 180, 0.12)')
        .onClick(() => {
          this.goBack();
        })

        Text('播放列表')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFF5F0')

        Blank()
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 8 })

      // Playlist info
      Text(`${this.songs.length} 首歌曲`)
        .fontSize(14)
        .fontColor('#C8A8B0')
        .padding({ left: 16, bottom: 8 })
    }
    .width('100%')
  }

  /**
   * Build individual song row
   */
  @Builder
  buildSongRow(song: Song, index: number): void {
    Row() {
      // Album cover
      AlbumCoverSimple({
        coverImage: song.coverImage,
        coverSize: 60
      })

      // Song info
      Column() {
        Text(song.title)
          .fontSize(16)
          .fontWeight(this.isCurrentSong(index) ? FontWeight.Bold : FontWeight.Medium)
          .fontColor(this.isCurrentSong(index) ? '#FF8C69' : '#FFF5F0')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(song.artist)
          .fontSize(13)
          .fontColor('#C8A8B0')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .padding({ left: 12, right: 12 })
      .alignItems(HorizontalAlign.Start)

      // Duration
      Text(formatTime(song.duration))
        .fontSize(12)
        .fontColor('#A88888')
        .margin({ right: 8 })

      // Play/Pause button (only show for current song)
      if (this.isCurrentSong(index)) {
        MiniPlayControls({
          isPlaying: this.isPlaying,
          onPlayPause: () => {
            this.togglePlayPause();
          }
        })
      } else {
        // Play button for other songs
        Button() {
          Text('▶')
            .fontSize(14)
            .fontColor('#FF8C69')
        }
        .width(40)
        .height(40)
        .type(ButtonType.Circle)
        .backgroundColor('rgba(255, 140, 105, 0.12)')
        .onClick(() => {
          this.playSong(index);
        })
      }
    }
    .width('100%')
    .padding({
      left: 16,
      right: 16,
      top: 12,
      bottom: 12
    })
    .backgroundColor(this.isCurrentSong(index) ? '#252542' : 'transparent')
    .borderRadius(12)
    .onClick(() => {
      this.playSong(index);
    })
  }

  /**
   * Check if song is current playing
   */
  private isCurrentSong(index: number): boolean {
    return index === this.currentSongIndex;
  }
}
