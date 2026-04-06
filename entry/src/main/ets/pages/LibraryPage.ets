import router from '@ohos.router';
import { Song, DEFAULT_SONGS } from '../model/Song';
import { getStorageManager } from '../utils/StorageManager';
import { getAudioManager } from '../utils/AudioManager';
import promptAction from '@ohos.promptAction';

/**
 * LibraryPage - Song library management page
 */
@Entry
@Component
struct LibraryPage {
  @State private songs: Song[] = [];
  @State private isLoading: boolean = true;
  @State private sortBy: string = 'name';

  aboutToAppear(): void {
    this.loadLibrary();
  }

  /**
   * Load songs from library
   */
  async loadLibrary(): Promise<void> {
    try {
      this.isLoading = true;
      const storage = getStorageManager();
      let library = await storage.getLibrary();

      // If empty, initialize with default songs
      if (library.length === 0) {
        for (const song of DEFAULT_SONGS) {
          await storage.addToLibrary(song);
        }
        library = await storage.getLibrary();
      }

      // Sort songs
      this.songs = this.sortSongs(library);
      this.isLoading = false;
    } catch (error) {
      console.error('Failed to load library:', JSON.stringify(error));
      this.isLoading = false;
    }
  }

  /**
   * Sort songs by current sort option
   */
  sortSongs(songs: Song[]): Song[] {
    const sorted: Song[] = [];
    for (let i = 0; i < songs.length; i++) {
      sorted.push(songs[i]);
    }
    sorted.sort((a: Song, b: Song): number => {
      switch (this.sortBy) {
        case 'name':
          return a.title.localeCompare(b.title);
        case 'artist':
          return a.artist.localeCompare(b.artist);
        case 'album':
          return a.album.localeCompare(b.album);
        default:
          return 0;
      }
    });
    return sorted;
  }

  /**
   * Play a song
   */
  async playSong(song: Song): Promise<void> {
    try {
      const audioManager = getAudioManager();
      const storage = getStorageManager();

      // Add to history
      await storage.addToHistory(song);

      // Set playlist and play
      audioManager.setPlaylist(this.songs, this.songs.findIndex(s => s.id === song.id));
      await audioManager.loadSong(song);
      await audioManager.play();

      promptAction.showToast({ message: `正在播放: ${song.title}`, duration: 2000 });
    } catch (error) {
      console.error('Failed to play song:', JSON.stringify(error));
      promptAction.showToast({ message: '播放失败', duration: 2000 });
    }
  }

  /**
   * Remove song from library
   */
  async removeSong(song: Song): Promise<void> {
    try {
      const storage = getStorageManager();
      await storage.removeFromLibrary(song.id);
      await this.loadLibrary();
      promptAction.showToast({ message: `已从曲库移除: ${song.title}`, duration: 2000 });
    } catch (error) {
      console.error('Failed to remove song:', JSON.stringify(error));
    }
  }

  /**
   * Add sample song to library
   */
  async addSampleSong(): Promise<void> {
    try {
      const storage = getStorageManager();
      const newId = Date.now();
      const sampleSong: Song = {
        id: newId,
        title: `新歌曲 ${newId % 1000}`,
        artist: '示例歌手',
        album: '示例专辑',
        coverImage: 'rawfile://images/cover1.png',
        audioFile: 'rawfile://music/song1.mp3',
        lrcFile: 'rawfile://lyrics/song1.lrc',
        duration: 180000 + Math.floor(Math.random() * 120000)
      };
      await storage.addToLibrary(sampleSong);
      await this.loadLibrary();
      promptAction.showToast({ message: '已添加示例歌曲', duration: 2000 });
    } catch (error) {
      console.error('Failed to add sample song:', JSON.stringify(error));
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      // Background
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Top,
          colors: [['#1a1a2e', 0], ['#16213e', 1]]
        })

      Column() {
        // Header
        this.buildHeader()

        // Sort options
        this.buildSortOptions()

        // Song list
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
        } else if (this.songs.length === 0) {
          this.buildEmptyState()
        } else {
          this.buildSongList()
        }
      }
    }
  }

  /**
   * Build header
   */
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

      Text('📚 歌曲库')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#ffffff')

      Blank()

      Button() {
        Text('+ 添加')
          .fontSize(16)
          .fontColor('#4A90D9')
      }
      .type(ButtonType.Normal)
      .backgroundColor('transparent')
      .onClick(() => this.addSampleSong())
    }
    .width('100%')
    .padding({ top: 48, left: 16, right: 16, bottom: 16 })
  }

  /**
   * Build sort options
   */
  @Builder
  buildSortOptions(): void {
    Row() {
      Text(`共 ${this.songs.length} 首歌曲`)
        .fontSize(14)
        .fontColor('#a0a0b0')

      Blank()

      Row({ space: 8 }) {
        Text('排序:')
          .fontSize(12)
          .fontColor('#a0a0b0')

        Text('名称')
          .fontSize(12)
          .fontColor(this.sortBy === 'name' ? '#4A90D9' : '#a0a0b0')
          .onClick(() => {
            this.sortBy = 'name';
            this.songs = this.sortSongs(this.songs);
          })

        Text('|')
          .fontSize(12)
          .fontColor('#606080')

        Text('歌手')
          .fontSize(12)
          .fontColor(this.sortBy === 'artist' ? '#4A90D9' : '#a0a0b0')
          .onClick(() => {
            this.sortBy = 'artist';
            this.songs = this.sortSongs(this.songs);
          })
      }
    }
    .width('100%')
    .padding({ left: 20, right: 20, bottom: 12 })
  }

  /**
   * Build empty state
   */
  @Builder
  buildEmptyState(): void {
    Column() {
      Text('📚')
        .fontSize(64)

      Text('曲库为空')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#ffffff')
        .margin({ top: 16 })

      Text('点击"添加"按钮添加歌曲到曲库')
        .fontSize(14)
        .fontColor('#a0a0b0')
        .margin({ top: 8 })

      Button('添加示例歌曲')
        .fontSize(14)
        .fontColor('#ffffff')
        .backgroundColor('#4A90D9')
        .borderRadius(20)
        .padding({ left: 24, right: 24, top: 12, bottom: 12 })
        .margin({ top: 24 })
        .onClick(() => this.addSampleSong())
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  /**
   * Build song list
   */
  @Builder
  buildSongList(): void {
    Scroll() {
      Column({ space: 8 }) {
        ForEach(this.songs, (song: Song) => {
          this.buildSongItem(song)
        })

        // Bottom padding
        Divider()
          .height(100)
          .color('transparent')
      }
      .padding({ left: 16, right: 16 })
    }
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Off)
    .width('100%')
    .layoutWeight(1)
  }

  /**
   * Build song item
   */
  @Builder
  buildSongItem(song: Song): void {
    Row() {
      // Album art placeholder
      Column() {
        Text('🎵')
          .fontSize(24)
      }
      .width(56)
      .height(56)
      .backgroundColor('rgba(255, 255, 255, 0.1)')
      .borderRadius(8)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)

      // Song info
      Column() {
        Text(song.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#ffffff')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(`${song.artist} · ${song.album}`)
          .fontSize(12)
          .fontColor('#a0a0b0')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 4 })

        Text(this.formatDuration(song.duration))
          .fontSize(11)
          .fontColor('#606080')
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })

      // Play button
      Button() {
        Text('▶')
          .fontSize(16)
          .fontColor('#ffffff')
      }
      .width(40)
      .height(40)
      .type(ButtonType.Circle)
      .backgroundColor('#4A90D9')
      .onClick(() => this.playSong(song))

      // Delete button
      Button() {
        Text('✕')
          .fontSize(14)
          .fontColor('#606080')
      }
      .width(36)
      .height(36)
      .type(ButtonType.Circle)
      .backgroundColor('transparent')
      .onClick(() => this.removeSong(song))
    }
    .width('100%')
    .padding({ top: 8, bottom: 8, left: 12, right: 12 })
    .backgroundColor('rgba(255, 255, 255, 0.05)')
    .borderRadius(12)
  }

  /**
   * Format duration from ms to mm:ss
   */
  formatDuration(ms: number): string {
    const totalSeconds = Math.floor(ms / 1000);
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60;
    return `${minutes}:${seconds.toString().padStart(2, '0')}`;
  }
}
