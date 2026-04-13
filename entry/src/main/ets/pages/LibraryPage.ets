import router from '@ohos.router';
import { Song, DEFAULT_SONGS } from '../model/Song';
import { getStorageManager } from '../utils/StorageManager';
import { getAudioManager, PlaybackState } from '../utils/AudioManager';
import { parseLrc, ParsedLyrics, LyricLine } from '../utils/LyricParser';
import promptAction from '@ohos.promptAction';
import picker from '@ohos.file.picker';


/**
 * LibraryPage - Song library page
 * Shows all songs, click to play and view lyrics, supports adding local songs
 */
@Entry
@Component
struct LibraryPage {
  @State private songs: Song[] = [];
  @State private isLoading: boolean = true;
  @State private sortBy: string = 'name';
  @State private selectedSong: Song | null = null;
  @State private currentLyrics: ParsedLyrics | null = null;
  @State private currentTimeMs: number = 0;
  @State private isPlaying: boolean = false;
  @State private showLyrics: boolean = false;
  @State private nextSongId: number = 100;
  private audioManager = getAudioManager();

  aboutToAppear(): void {
    this.loadLibrary();
    this.setupEventHandlers();
  }

  async loadLibrary(): Promise<void> {
    try {
      this.isLoading = true;
      const storage = getStorageManager();
      let library = await storage.getLibrary();
      if (library.length === 0) {
        for (const song of DEFAULT_SONGS) {
          await storage.addToLibrary(song);
        }
        library = await storage.getLibrary();
      }
      this.songs = this.sortSongs(library);
      // Find max id to assign new songs
      let maxId = 0;
      for (const s of library) {
        if (s.id > maxId) {
          maxId = s.id;
        }
      }
      this.nextSongId = maxId + 1;
      this.isLoading = false;
    } catch (error) {
      console.error('Failed to load library:', JSON.stringify(error));
      this.isLoading = false;
    }
  }

  setupEventHandlers(): void {
    this.audioManager.setEventHandlers({
      onPlayStateChange: (state: PlaybackState) => {
        this.isPlaying = state === PlaybackState.PLAYING;
      },
      onProgressUpdate: (currentTime: number) => {
        this.currentTimeMs = currentTime;
      },
      onSongChange: (song: Song) => {
        if (this.selectedSong?.id === song.id) {
          this.loadLyrics(song);
        }
      },
      onError: (error: string) => {
        promptAction.showToast({ message: error, duration: 2000 });
      },
      onComplete: () => {}
    });
  }

  sortSongs(songs: Song[]): Song[] {
    const sorted = [...songs];
    sorted.sort((a: Song, b: Song): number => {
      switch (this.sortBy) {
        case 'name': return a.title.localeCompare(b.title);
        case 'artist': return a.artist.localeCompare(b.artist);
        case 'album': return a.album.localeCompare(b.album);
        default: return 0;
      }
    });
    return sorted;
  }

  async playSong(song: Song): Promise<void> {
    try {
      const storage = getStorageManager();
      await storage.addToHistory(song);
      this.audioManager.setPlaylist(this.songs, this.songs.findIndex(s => s.id === song.id));
      await this.audioManager.loadSong(song);
      await this.audioManager.play();
      this.selectedSong = song;
      await this.loadLyrics(song);
      this.showLyrics = true;
      promptAction.showToast({ message: `正在播放: ${song.title}`, duration: 2000 });
    } catch (error) {
      console.error('Failed to play song:', JSON.stringify(error));
      promptAction.showToast({ message: '播放失败', duration: 2000 });
    }
  }

  async loadLyrics(song: Song): Promise<void> {
    try {
      const rawFilePath = song.lrcFile.replace('rawfile://', '');
      const fileContent: Uint8Array = getContext(this).resourceManager.getRawFileContentSync(rawFilePath);
      const chars: string[] = [];
      for (let i = 0; i < fileContent.length; i++) {
        chars.push(String.fromCharCode(fileContent[i]));
      }
      const lrcContent = chars.join('');
      this.currentLyrics = parseLrc(lrcContent);
    } catch (error) {
      this.currentLyrics = null;
    }
  }

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

  async addLocalSong(): Promise<void> {
    try {
      const documentPicker = new picker.DocumentViewPicker();
      const results: string[] = await documentPicker.select();

      if (results && results.length > 0) {
        const filePath = results[0];
        const fileName = filePath.substring(filePath.lastIndexOf('/') + 1);
        const title = fileName.replace(/\.[^.]+$/, '');

        const newSong: Song = {
          id: this.nextSongId++,
          title: title,
          artist: '本地音乐',
          album: '本地收藏',
          coverImage: 'rawfile://images/cover_user1.png',
          audioFile: filePath,
          lrcFile: '',
          duration: 0
        };

        const storage = getStorageManager();
        await storage.addToLibrary(newSong);
        await this.loadLibrary();
        promptAction.showToast({ message: `已添加: ${title}`, duration: 2000 });
      }
    } catch (error) {
      console.error('Failed to add song:', JSON.stringify(error));
      promptAction.showToast({ message: '添加失败，请重试', duration: 2000 });
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Top,
          colors: [['#2D1B35', 0], ['#4A2C4A', 1]]
        })

      Column() {
        this.buildHeader()
        this.buildSortOptions()
        if (this.isLoading) {
          Column() {
            LoadingProgress().width(48).height(48).color('#ffffff')
          }
          .width('100%').height('100%').justifyContent(FlexAlign.Center)
        } else if (this.songs.length === 0) {
          this.buildEmptyState()
        } else {
          this.buildSongList()
        }
      }

      if (this.showLyrics && this.selectedSong) {
        this.buildLyricsOverlay()
      }
    }
  }

  @Builder
  buildHeader(): void {
    Row() {
      Button() {
        Text('‹ 返回').fontSize(18).fontColor('#FFF5F0')
      }
      .type(ButtonType.Normal).backgroundColor('transparent')
      .onClick(() => router.back())

      Blank()

      Text('🎶 乐曲库')
        .fontSize(20).fontWeight(FontWeight.Bold).fontColor('#FFF5F0')

      Blank()

      Button() {
        Text('+ 添加歌曲').fontSize(14).fontColor('#FFB347')
      }
      .type(ButtonType.Normal).backgroundColor('transparent')
      .onClick(() => this.addLocalSong())
    }
    .width('100%')
    .padding({ top: 48, left: 16, right: 16, bottom: 16 })
  }

  @Builder
  buildSortOptions(): void {
    Row() {
      Text(`共 ${this.songs.length} 首歌曲`).fontSize(14).fontColor('#C8A8B0')
      Blank()
      Row({ space: 8 }) {
        Text('名称').fontSize(12).fontColor(this.sortBy === 'name' ? '#FFB347' : '#C8A8B0')
          .onClick(() => { this.sortBy = 'name'; this.songs = this.sortSongs(this.songs); })
        Text('|').fontSize(12).fontColor('#C8A8B8')
        Text('歌手').fontSize(12).fontColor(this.sortBy === 'artist' ? '#FFB347' : '#C8A8B0')
          .onClick(() => { this.sortBy = 'artist'; this.songs = this.sortSongs(this.songs); })
      }
    }
    .width('100%').padding({ left: 20, right: 20, bottom: 12 })
  }

  @Builder
  buildEmptyState(): void {
    Column() {
      Text('📚').fontSize(64)
      Text('曲库为空').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#FFF5F0').margin({ top: 16 })
      Text('点击"添加歌曲"导入本地音乐').fontSize(14).fontColor('#C8A8B0').margin({ top: 8 })
      Button() {
        Text('+ 添加歌曲').fontSize(16).fontColor('#FFF5F0')
      }
      .width(160).height(44).type(ButtonType.Normal).backgroundColor('#FF7A59')
      .borderRadius(22).margin({ top: 24 })
      .onClick(() => this.addLocalSong())
    }
    .width('100%').height('100%').justifyContent(FlexAlign.Center)
  }

  @Builder
  buildSongList(): void {
    Scroll() {
      Column({ space: 8 }) {
        ForEach(this.songs, (song: Song) => {
          this.buildSongItem(song)
        })
        Divider().height(100).color('transparent')
      }
      .padding({ left: 16, right: 16 })
    }
    .scrollable(ScrollDirection.Vertical).scrollBar(BarState.Off).width('100%').layoutWeight(1)
  }

  @Builder
  buildSongItem(song: Song): void {
    Row() {
      Image($r(song.coverImage))
        .width(56).height(56).borderRadius(8).objectFit(ImageFit.Cover)

      Column() {
        Text(song.title)
          .fontSize(16).fontWeight(FontWeight.Medium).fontColor('#FFF5F0')
          .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(`${song.artist} · ${song.album}`)
          .fontSize(12).fontColor('#C8A8B0')
          .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis }).margin({ top: 4 })
        Text(this.formatDuration(song.duration))
          .fontSize(11).fontColor('#A88888').margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start).layoutWeight(1).margin({ left: 12 })

      Button() {
        Text('▶').fontSize(16).fontColor('#FFF5F0')
      }
      .width(40).height(40).type(ButtonType.Circle).backgroundColor('#FF7A59')
      .onClick(() => this.playSong(song))

      Button() {
        Text('✕').fontSize(14).fontColor('#A88888')
      }
      .width(36).height(36).type(ButtonType.Circle).backgroundColor('transparent')
      .onClick(() => this.removeSong(song))
    }
    .width('100%').padding({ top: 10, bottom: 10, left: 12, right: 12 })
    .backgroundColor('rgba(255, 255, 255, 0.07)').borderRadius(14)
  }

  @Builder
  buildLyricsOverlay(): void {
    Column() {
      Row() {
        Image($r(this.selectedSong?.coverImage || ''))
          .width(48).height(48).borderRadius(8).objectFit(ImageFit.Cover)

        Column() {
          Text(this.selectedSong?.title || '')
            .fontSize(16).fontWeight(FontWeight.Bold).fontColor('#ffffff')
            .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.selectedSong?.artist || '')
            .fontSize(13).fontColor('#a0a0b0').maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis }).margin({ top: 2 })
        }
        .layoutWeight(1).margin({ left: 12 }).alignItems(HorizontalAlign.Start)
      }
      .width('100%').padding({ left: 20, right: 20, top: 16, bottom: 16 })

      if (this.currentLyrics && this.currentLyrics.lines.length > 0) {
        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.currentLyrics.lines, (line: LyricLine, index: number) => {
              Text(line.text || '...')
                .fontSize(index === this.getCurrentLyricIndex() ? 20 : 15)
                .fontWeight(index === this.getCurrentLyricIndex() ? FontWeight.Bold : FontWeight.Normal)
                .fontColor(index === this.getCurrentLyricIndex() ? '#ffffff' : '#707090')
                .textAlign(TextAlign.Center)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .padding({ left: 24, right: 24, top: 8, bottom: 8 })
            })
          }
          .width('100%')
        }
        .scrollable(ScrollDirection.Vertical).scrollBar(BarState.Off).width('100%').layoutWeight(1)
      } else {
        Column() {
          Text('🎵').fontSize(48).margin({ top: 40 })
          Text('暂无歌词').fontSize(16).fontColor('#707090').margin({ top: 16 })
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      }
    }
    .width('100%').height('65%')
    .backgroundColor('rgba(20, 20, 40, 0.97)')
    .borderRadius({ topLeft: 24, topRight: 24 })
  }

  getCurrentLyricIndex(): number {
    if (!this.currentLyrics || this.currentLyrics.lines.length === 0) return -1;
    const adjustedTime = this.currentTimeMs + this.currentLyrics.offset;
    let result = -1;
    for (let i = 0; i < this.currentLyrics.lines.length; i++) {
      if (this.currentLyrics.lines[i].time <= adjustedTime) {
        result = i;
      }
    }
    return result;
  }

  formatDuration(ms: number): string {
    const totalSeconds = Math.floor(ms / 1000);
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60;
    return `${minutes}:${seconds.toString().padStart(2, '0')}`;
  }
}
