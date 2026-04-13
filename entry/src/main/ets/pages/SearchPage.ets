import router from '@ohos.router';
import { Song } from '../model/Song';
import { getStorageManager } from '../utils/StorageManager';
import { getAudioManager } from '../utils/AudioManager';
import promptAction from '@ohos.promptAction';

/**
 * SearchPage - Search songs and artists
 */
@Entry
@Component
struct SearchPage {
  @State private searchText: string = '';
  @State private searchResults: Song[] = [];
  @State private allSongs: Song[] = [];
  @State private recentSongs: Song[] = [];
  @State private isLoading: boolean = true;
  @State private hasSearched: boolean = false;

  private searchController: SearchController = new SearchController();

  aboutToAppear(): void {
    this.loadLibrary();
  }

  /**
   * Load all songs for searching
   */
  async loadLibrary(): Promise<void> {
    try {
      this.isLoading = true;
      const storage = getStorageManager();
      this.allSongs = await storage.getLibrary();
      // Get recent songs (first 5)
      const recent: Song[] = [];
      for (let i = 0; i < 5 && i < this.allSongs.length; i++) {
        recent.push(this.allSongs[i]);
      }
      this.recentSongs = recent;
      this.isLoading = false;
    } catch (error) {
      console.error('Failed to load library:', JSON.stringify(error));
      this.isLoading = false;
    }
  }

  /**
   * Perform search
   */
  async onSearch(value: string): Promise<void> {
    this.searchText = value;

    if (value.trim().length === 0) {
      this.searchResults = [];
      this.hasSearched = false;
      return;
    }

    try {
      const storage = getStorageManager();
      const library = await storage.getLibrary();
      const query = value.toLowerCase();

      const results: Song[] = [];
      for (let i = 0; i < library.length; i++) {
        const song = library[i];
        if (song.title.toLowerCase().includes(query) ||
          song.artist.toLowerCase().includes(query) ||
          song.album.toLowerCase().includes(query)) {
          results.push(song);
        }
      }
      this.searchResults = results;
      this.hasSearched = true;
    } catch (error) {
      console.error('Failed to search:', JSON.stringify(error));
    }
  }

  /**
   * Clear search
   */
  onClear(): void {
    this.searchText = '';
    this.searchResults = [];
    this.hasSearched = false;
  }

  /**
   * Play a song from search results
   */
  async playSong(song: Song): Promise<void> {
    try {
      const audioManager = getAudioManager();
      const storage = getStorageManager();

      await storage.addToHistory(song);

      const index = this.searchResults.findIndex(s => s.id === song.id);
      audioManager.setPlaylist(this.searchResults, index >= 0 ? index : 0);
      await audioManager.loadSong(song);
      await audioManager.play();

      promptAction.showToast({ message: `正在播放: ${song.title}`, duration: 2000 });
    } catch (error) {
      console.error('Failed to play song:', JSON.stringify(error));
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Top,
          colors: [['#2D1B35', 0], ['#4A2C4A', 1]]
        })

      Column() {
        this.buildHeader()
        this.buildSearchBar()

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
        } else if (!this.hasSearched) {
          this.buildSuggestions()
        } else if (this.searchResults.length === 0) {
          this.buildNoResults()
        } else {
          this.buildSearchResults()
        }
      }
    }
  }

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

      Text('🔍 搜索')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFF5F0')

      Blank()

      Text('')
        .width(60)
    }
    .width('100%')
    .padding({ top: 48, left: 16, right: 16, bottom: 16 })
  }

  @Builder
  buildSearchBar(): void {
    Column() {
      Search({
        placeholder: '搜索歌曲、歌手、专辑...',
        value: this.searchText,
        controller: this.searchController
      })
        .placeholderColor('#C8A8B0')
        .placeholderFont({ size: 14 })
        .fontColor('#FFF5F0')
        .backgroundColor('rgba(255, 255, 255, 0.12)')
        .borderRadius(24)
        .height(44)
        .padding({ left: 16, right: 16 })
        .onSubmit((value: string) => this.onSearch(value))
        .onChange((value: string) => {
          this.searchText = value;
          if (value.length === 0) {
            this.onClear();
          }
        })

      if (this.searchResults.length > 0) {
        Text(`找到 ${this.searchResults.length} 首歌曲`)
          .fontSize(12)
          .fontColor('#C8A8B0')
          .margin({ top: 8 })
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 16 })
  }

  @Builder
  buildSuggestions(): void {
    Column() {
      Text('搜索提示')
        .fontSize(14)
        .fontColor('#C8A8B0')
        .textAlign(TextAlign.Start)
        .width('100%')
        .margin({ left: 16, bottom: 12 })

      // Hot keywords
      Column() {
        Text('热门搜索')
          .fontSize(12)
          .fontColor('#A88888')
          .textAlign(TextAlign.Start)
          .width('100%')
          .margin({ left: 16, bottom: 8 })

        Row({ space: 8 }) {
          ForEach(['Dream', 'Electronic', 'Midnight', 'Ocean'], (keyword: string) => {
            Text(keyword)
              .fontSize(12)
              .fontColor('#FF8C69')
              .backgroundColor('rgba(255, 140, 105, 0.15)')
              .borderRadius(12)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .onClick(() => {
                this.searchText = keyword;
                this.onSearch(keyword);
              })
          })
        }
        .padding({ left: 16 })
      }
      .margin({ top: 16 })

      // Recent searches
      Column() {
        Text('曲库歌曲')
          .fontSize(12)
          .fontColor('#A88888')
          .textAlign(TextAlign.Start)
          .width('100%')
          .margin({ left: 16, top: 24, bottom: 8 })

        Scroll() {
          Column({ space: 8 }) {
            ForEach(this.recentSongs, (song: Song) => {
              Row() {
                Text('🎵')
                  .fontSize(16)
                  .margin({ right: 8 })

                Text(song.title)
                  .fontSize(14)
                  .fontColor('#FFF5F0')
                  .layoutWeight(1)

                Text(song.artist)
                  .fontSize(11)
                  .fontColor('#C8A8B0')
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .backgroundColor('rgba(255, 255, 255, 0.06)')
              .borderRadius(10)
              .onClick(() => this.playSong(song))
            })
          }
          .padding({ left: 16, right: 16 })
        }
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Off)
        .layoutWeight(1)
      }
    }
  }

  @Builder
  buildNoResults(): void {
    Column() {
      Text('🔍')
        .fontSize(64)

      Text('未找到相关歌曲')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFF5F0')
        .margin({ top: 16 })

      Text(`没有找到与"${this.searchText}"相关的歌曲`)
        .fontSize(14)
        .fontColor('#C8A8B0')
        .margin({ top: 8 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildSearchResults(): void {
    Scroll() {
      Column({ space: 8 }) {
        ForEach(this.searchResults, (song: Song) => {
          this.buildResultItem(song)
        })

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

  @Builder
  buildResultItem(song: Song): void {
    Row() {
      Column() {
        Text('🎵')
          .fontSize(20)
      }
      .width(44)
      .height(44)
      .backgroundColor('rgba(255, 140, 105, 0.2)')
      .borderRadius(10)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)

      Column() {
        Text(song.title)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFF5F0')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(`${song.artist} · ${song.album}`)
          .fontSize(11)
          .fontColor('#C8A8B0')
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 10 })

      Button() {
        Text('▶')
          .fontSize(12)
          .fontColor('#FFF5F0')
      }
      .width(32)
      .height(32)
      .type(ButtonType.Circle)
      .backgroundColor('#FF7A59')
      .onClick(() => this.playSong(song))
    }
    .width('100%')
    .padding({ top: 10, bottom: 10, left: 10, right: 10 })
    .backgroundColor('rgba(255, 255, 255, 0.08)')
    .borderRadius(12)
  }
}
