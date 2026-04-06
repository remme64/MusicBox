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
          colors: [['#1a1a2e', 0], ['#16213e', 1]]
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
        .fontColor('#ffffff')

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
        .placeholderColor('#a0a0b0')
        .placeholderFont({ size: 14 })
        .fontColor('#ffffff')
        .fontSize(16)
        .backgroundColor('rgba(255, 255, 255, 0.1)')
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
        .onClear(() => this.onClear())

      if (this.searchResults.length > 0) {
        Text(`找到 ${this.searchResults.length} 首歌曲`)
          .fontSize(12)
          .fontColor('#a0a0b0')
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
        .fontColor('#a0a0b0')
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 16, bottom: 12 })

      // Hot keywords
      Column() {
        Text('热门搜索')
          .fontSize(12)
          .fontColor('#606080')
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 16, bottom: 8 })

        Row({ space: 8 }) {
          ForEach(['Dream', 'Electronic', 'Midnight', 'Ocean'], (keyword: string) => {
            Text(keyword)
              .fontSize(12)
              .fontColor('#9B59B6')
              .backgroundColor('rgba(155, 89, 182, 0.2)')
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
          .fontColor('#606080')
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 16, top: 24, bottom: 8 })

        Scroll() {
          Column({ space: 8 }) {
            ForEach(this.allSongs.slice(0, 5), (song: Song) => {
              Row() {
                Text('🎵')
                  .fontSize(16)
                  .margin({ right: 8 })

                Text(song.title)
                  .fontSize(14)
                  .fontColor('#ffffff')
                  .layoutWeight(1)

                Text(song.artist)
                  .fontSize(11)
                  .fontColor('#a0a0b0')
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .backgroundColor('rgba(255, 255, 255, 0.03)')
              .borderRadius(8)
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
        .fontColor('#ffffff')
        .margin({ top: 16 })

      Text(`没有找到与"${this.searchText}"相关的歌曲`)
        .fontSize(14)
        .fontColor('#a0a0b0')
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
      .backgroundColor('rgba(155, 89, 182, 0.2)')
      .borderRadius(8)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)

      Column() {
        Text(song.title)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#ffffff')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(`${song.artist} · ${song.album}`)
          .fontSize(11)
          .fontColor('#a0a0b0')
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 10 })

      Button() {
        Text('▶')
          .fontSize(12)
          .fontColor('#ffffff')
      }
      .width(32)
      .height(32)
      .type(ButtonType.Circle)
      .backgroundColor('#9B59B6')
      .onClick(() => this.playSong(song))
    }
    .width('100%')
    .padding({ top: 8, bottom: 8, left: 10, right: 10 })
    .backgroundColor('rgba(255, 255, 255, 0.05)')
    .borderRadius(10)
  }
}
