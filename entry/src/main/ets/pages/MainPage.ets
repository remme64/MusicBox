import router from '@ohos.router';
import { Song, DEFAULT_SONGS } from '../model/Song';
import { getStorageManager } from '../utils/StorageManager';
import { getAudioManager, PlaybackState } from '../utils/AudioManager';
import { getAVSessionUtil } from '../utils/AVSessionUtil';
import { parseLrc, ParsedLyrics } from '../utils/LyricParser';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct MainPage {
  private storageManager = getStorageManager();
  private audioManager = getAudioManager();
  private avSessionUtil = getAVSessionUtil();
  private tabsController: TabsController = new TabsController();

  @State private currentTabIndex: number = 0;
  @State private library: Song[] = [];
  @State private recommendedSong: Song | null = null;
  @State private currentSong: Song | null = null;
  @State private isPlaying: boolean = false;
  @State private currentTimeMs: number = 0;
  @State private totalTimeMs: number = 0;
  @State private currentLyrics: ParsedLyrics | null = null;
  @State private searchValue: string = '';
  @State private favoriteCount: number = 0;
  @State private historyCount: number = 0;
  @State private playCount: number = 0;

  aboutToAppear(): void {
    this.loadData();
    this.setupEventHandlers();
  }

  async loadData(): Promise<void> {
    try {
      // Always reload from DEFAULT_SONGS to ensure fresh data
      await this.storageManager.clearLibrary();
      for (const song of DEFAULT_SONGS) {
        await this.storageManager.addToLibrary(song);
      }
      let library = await this.storageManager.getLibrary();
      this.library = library;

      if (library.length > 0) {
        const idx = Math.floor(Math.random() * library.length);
        this.recommendedSong = library[idx];
      }

      this.currentSong = this.audioManager.getCurrentSong();
      this.isPlaying = this.audioManager.getPlaybackState() === PlaybackState.PLAYING;

      const favorites = await this.storageManager.getFavorites();
      const history = await this.storageManager.getHistory();
      this.favoriteCount = favorites.length;
      this.historyCount = history.length;
      this.playCount = history.length;
    } catch (error) {
      console.error('Failed to load data:', JSON.stringify(error));
    }
  }

  setupEventHandlers(): void {
    this.audioManager.setEventHandlers({
      onPlayStateChange: (state: PlaybackState) => {
        this.isPlaying = state === PlaybackState.PLAYING;
        this.avSessionUtil.updatePlaybackState(this.isPlaying, this.currentTimeMs);
      },
      onSongChange: (song: Song) => {
        this.currentSong = song;
        this.totalTimeMs = song.duration;
        this.currentTimeMs = 0;
        this.avSessionUtil.setSongMetadata(song);
        this.loadLyrics(song);
        this.loadData();
      },
      onProgressUpdate: (currentTime: number, duration: number) => {
        this.currentTimeMs = currentTime;
        if (duration > 0) {
          this.totalTimeMs = duration;
        }
      },
      onError: (error: string) => {
        promptAction.showToast({ message: error, duration: 2000 });
      },
      onComplete: () => {}
    });

    this.avSessionUtil.setOnPlayCallback(() => { this.audioManager.play(); });
    this.avSessionUtil.setOnPauseCallback(() => { this.audioManager.pause(); });
    this.avSessionUtil.setOnNextCallback(() => { this.audioManager.playNext(); });
    this.avSessionUtil.setOnPreviousCallback(() => { this.audioManager.playPrevious(); });
    this.avSessionUtil.setOnSeekCallback((pos: number) => { this.audioManager.seekTo(pos); });
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

  async playSong(song: Song): Promise<void> {
    try {
      await this.storageManager.addToHistory(song);
      this.audioManager.setPlaylist(this.library, this.library.findIndex((s: Song) => s.id === song.id));
      await this.audioManager.loadSong(song);
      await this.audioManager.play();
      this.currentSong = song;
      promptAction.showToast({ message: 'Playing: ' + song.title, duration: 1500 });
    } catch (error) {
      console.error('Failed to play song:', JSON.stringify(error));
      promptAction.showToast({ message: 'Play failed', duration: 1500 });
    }
  }

  async onPlayPause(): Promise<void> {
    try {
      await this.audioManager.togglePlayPause();
    } catch (error) {
      console.error('Play/Pause error:', JSON.stringify(error));
    }
  }

  navigateToLibrary(): void {
    router.pushUrl({ url: 'pages/LibraryPage' });
  }

  navigateToFullPlayer(): void {
    router.pushUrl({ url: 'pages/Index' });
  }

  navigateToLyrics(): void {
    if (!this.currentSong) {
      return;
    }
    router.pushUrl({
      url: 'pages/LyricsPage',
      params: { song: this.currentSong, lyrics: this.currentLyrics }
    });
  }

  navigateToFavorites(): void {
    router.pushUrl({ url: 'pages/FavoritesPage' });
  }

  navigateToHistory(): void {
    router.pushUrl({ url: 'pages/HistoryPage' });
  }

  navigateToSettings(): void {
    router.pushUrl({ url: 'pages/SettingsPage' });
  }

  navigateToAbout(): void {
    router.pushUrl({ url: 'pages/AboutPage' });
  }

  async onSearchSubmit(): Promise<void> {
    if (this.searchValue.trim().length === 0) {
      return;
    }
    const query = this.searchValue.toLowerCase();
    const results = this.library.filter((song: Song) =>
      song.title.toLowerCase().includes(query) ||
      song.artist.toLowerCase().includes(query) ||
      song.album.toLowerCase().includes(query)
    );
    if (results.length > 0) {
      await this.playSong(results[0]);
    } else {
      promptAction.showToast({ message: '未找到结果', duration: 1500 });
    }
  }

  build() {
    Column() {
      Tabs({ controller: this.tabsController, barPosition: BarPosition.End }) {
        TabContent() {
          this.buildHomeTab()
        }
        .tabBar(new BottomTabBarStyle('*', '首页'))

        TabContent() {
          this.buildPersonalCenterTab()
        }
        .tabBar(new BottomTabBarStyle('U', '个人中心'))
      }
      .onChange((index: number) => {
        this.currentTabIndex = index;
        this.loadData();
      })
      .barHeight(56)
      .animationDuration(0)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF0EB')
  }

  @Builder
  buildHomeTab(): void {
    Column() {
      if (this.currentSong) {
        this.buildBottomPlayer()
      }
      this.buildSearchBar()
      this.buildHomeContent()
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildSearchBar(): void {
    Column() {
      Row() {
        Text('音乐盒')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#3D2A2A')
          .margin({ top: 44 })
      }
      .width('100%')
      .padding({ left: 20, right: 20 })
      .margin({ top: 8 })

      Row() {
        TextInput({ placeholder: '搜索歌曲...', text: this.searchValue })
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#FFF8F5')
          .borderRadius(22)
          .fontSize(15)
          .placeholderColor('#C8A8A0')
          .onChange((value: string) => {
            this.searchValue = value;
          })
          .onSubmit(() => {
            this.onSearchSubmit();
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12 })
    }
    .width('100%')
  }

  @Builder
  buildHomeContent(): void {
    Scroll() {
      Column() {
        this.buildLibraryCard()
        this.buildRecommendedSection()
        this.buildAllSongsSection()
        Divider().height(100).color('transparent')
      }
      .padding({ left: 16, right: 16 })
    }
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Off)
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  buildLibraryCard(): void {
    Row() {
      Column() {
        Text('我的收藏')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#ffffff')
        Text(this.library.length + ' 首歌曲')
          .fontSize(12)
          .fontColor('#ffffff99')
          .margin({ top: 4 })
      }
      .width('100%')
      .height(120)
      .backgroundColor('#FF7A59')
      .borderRadius(16)
      .justifyContent(FlexAlign.Center)
      .onClick(() => this.navigateToLibrary())
    }
    .width('100%')
    .padding({ top: 20 })
  }

  @Builder
  buildRecommendedSection(): void {
    Column() {
      Row() {
        Text('推荐歌曲')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#3D2A2A')
        Blank()
        Text('查看全部')
          .fontSize(12)
          .fontColor('#C8A8A0')
      }
      .width('100%')
      .padding({ top: 24, bottom: 12 })

      if (this.recommendedSong) {
        Row() {
          Image($r(this.recommendedSong.coverImage))
            .width(80)
            .height(80)
            .borderRadius(12)
            .objectFit(ImageFit.Cover)

          Column() {
            Text(this.recommendedSong.title)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#3D2A2A')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Text(this.recommendedSong.artist)
              .fontSize(14)
              .fontColor('#C8A8A0')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ top: 4 })
            Text(this.formatDuration(this.recommendedSong.duration))
              .fontSize(12)
              .fontColor('#C8A8A0')
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          .margin({ left: 16 })
          .alignItems(HorizontalAlign.Start)

          Button() {
            Text(this.isPlaying && this.currentSong?.id === this.recommendedSong?.id ? '||' : '>')
              .fontSize(24)
              .fontColor('#ffffff')
          }
          .width(56)
          .height(56)
          .type(ButtonType.Circle)
          .backgroundColor('#FF7A59')
          .onClick(() => {
            if (this.recommendedSong && this.currentSong?.id === this.recommendedSong?.id) {
              this.onPlayPause();
            } else if (this.recommendedSong) {
              this.playSong(this.recommendedSong);
            }
          })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#ffffff')
        .borderRadius(16)
      }
    }
  }

  @Builder
  buildAllSongsSection(): void {
    Column() {
      Row() {
        Text('全部歌曲')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#3D2A2A')
        Blank()
        Text('共: ' + this.library.length + ' 首')
          .fontSize(12)
          .fontColor('#888888')
      }
      .width('100%')
      .padding({ top: 24, bottom: 12 })

      Column({ space: 8 }) {
        ForEach(this.library, (song: Song) => {
          this.buildSongListItem(song)
        })
      }
    }
  }

  @Builder
  buildSongListItem(song: Song): void {
    Row() {
      Image($r(song.coverImage))
        .width(48)
        .height(48)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)

      Column() {
        Text(song.title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.currentSong?.id === song.id ? '#007aff' : '#1a1a2e')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(song.artist)
          .fontSize(12)
          .fontColor('#888888')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 2 })
      }
      .layoutWeight(1)
      .margin({ left: 12 })
      .alignItems(HorizontalAlign.Start)

      Text(this.formatDuration(song.duration))
        .fontSize(12)
        .fontColor('#C8A8A0')

      Button() {
        Text('>').fontSize(14).fontColor('#FF8C69')
      }
      .width(36)
      .height(36)
      .type(ButtonType.Circle)
      .backgroundColor('rgba(255, 140, 105, 0.12)')
      .margin({ left: 8 })
      .onClick(() => this.playSong(song))
    }
    .width('100%')
    .height(64)
    .padding({ left: 8, right: 8 })
    .backgroundColor(this.currentSong?.id === song.id ? '#f0f8ff' : '#ffffff')
    .borderRadius(12)
    .onClick(() => this.playSong(song))
  }

  @Builder
  buildPersonalCenterTab(): void {
    Scroll() {
      Column() {
        Text('个人中心')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#3D2A2A')
          .margin({ top: 48, bottom: 24 })
          .alignSelf(ItemAlign.Start)
          .padding({ left: 20 })

        Column() {
          Row() {
            StatItem({ label: '收藏', value: this.favoriteCount + '' })
            StatItem({ label: '播放次数', value: this.playCount + '' })
            StatItem({ label: '历史记录', value: this.historyCount + '' })
          }
          .margin({ top: 16 })
        }
        .width('100%')
        .padding({ top: 32, bottom: 32 })
        .backgroundColor('#ffffff')
        .borderRadius(16)
        .margin({ left: 16, right: 16, bottom: 24 })

        Column() {
          Row() {
            Text('我的音乐')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#666666')
          }
          .width('100%')
          .padding({ left: 4, bottom: 8 })
          .alignSelf(ItemAlign.Start)

          this.buildMenuItem('我的收藏', this.favoriteCount + ' 首歌曲', () => {
            this.navigateToFavorites();
          })
          this.buildMenuItem('历史记录', this.historyCount + ' 条记录', () => {
            this.navigateToHistory();
          })
          this.buildMenuItem('音乐库', this.library.length + ' 首歌曲', () => {
            this.navigateToLibrary();
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 24 })

        Column() {
          Row() {
            Text('设置')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#666666')
          }
          .width('100%')
          .padding({ left: 4, bottom: 8 })
          .alignSelf(ItemAlign.Start)

          this.buildMenuItem('系统设置', '自定义设置', () => {
            this.navigateToSettings();
          })
          this.buildMenuItem('关于', '音乐盒 v1.0.0', () => {
            this.navigateToAbout();
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16 })

        Text('音乐盒 v1.0.0')
          .fontSize(12)
          .fontColor('#999999')
          .margin({ top: 32, bottom: 100 })

        Divider().height(50).color('transparent')
      }
      .width('100%')
    }
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
  }

  @Builder
  buildMenuItem(title: string, subtitle: string, onClick: () => void): void {
    Row() {
      Column() {
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#3D2A2A')
        Text(subtitle)
          .fontSize(13)
          .fontColor('#8B6B6B')
          .margin({ top: 2 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text('>').fontSize(22).fontColor('#D8C0B8')
    }
    .width('100%')
    .height(60)
    .padding({ left: 8, right: 8 })
    .backgroundColor('#ffffff')
    .borderRadius(12)
    .margin({ bottom: 8 })
    .onClick(onClick)
  }

  @Builder
  buildBottomPlayer(): void {
    Column() {
      Row() {
        Column()
          .width(this.totalTimeMs > 0 ? (this.currentTimeMs / this.totalTimeMs) * 100 : 0)
          .height(2)
          .backgroundColor('#FF8C69')
        Column().layoutWeight(1).height(2).backgroundColor('#5A3A3A')
      }
      .width('100%').height(2)

      Row() {
        Row() {
          Image($r(this.currentSong?.coverImage || ''))
            .width(48)
            .height(48)
            .borderRadius(6)
            .objectFit(ImageFit.Cover)
        }
        .onClick(() => this.navigateToFullPlayer())

        Column() {
          Text(this.currentSong?.title || '')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#3D2A2A')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.currentSong?.artist || '')
            .fontSize(11)
            .fontColor('#8B6B6B')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
        .margin({ left: 12 })
        .alignItems(HorizontalAlign.Start)
        .onClick(() => this.navigateToFullPlayer())

        Row({ space: 4 }) {
          Button() {
            Text(this.isPlaying ? '||' : '>')
              .fontSize(20)
              .fontColor('#3D2A2A')
          }
          .width(44)
          .height(44)
          .type(ButtonType.Circle)
          .backgroundColor('transparent')
          .onClick(() => this.onPlayPause())

          Button() {
            Text('>>').fontSize(18).fontColor('#3D2A2A')
          }
          .width(40)
          .height(40)
          .type(ButtonType.Circle)
          .backgroundColor('transparent')
          .onClick(() => this.audioManager.playNext())

          Button() {
            Text('L').fontSize(18).fontColor('#3D2A2A')
          }
          .width(40)
          .height(40)
          .type(ButtonType.Circle)
          .backgroundColor('transparent')
          .onClick(() => this.navigateToLyrics())
        }
      }
      .width('100%')
      .height(64)
      .padding({ left: 12, right: 12 })
    }
    .width('100%')
    .backgroundColor('#FFF8F5')
    .borderRadius({ topLeft: 16, topRight: 16 })
  }

  formatDuration(ms: number): string {
    const totalSeconds = Math.floor(ms / 1000);
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60;
    return minutes + ':' + (seconds < 10 ? '0' : '') + seconds;
  }
}

@Component
struct StatItem {
  @Prop label: string;
  @Prop value: string;

  build() {
    Column() {
      Text(this.value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#3D2A2A')
      Text(this.label)
        .fontSize(13)
        .fontColor('#8B6B6B')
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .padding({ top: 12, bottom: 12 })
  }
}
