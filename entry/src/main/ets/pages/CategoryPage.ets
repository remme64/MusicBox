import router from '@ohos.router';
import { Category, DEFAULT_CATEGORIES } from '../model/Category';
import { Song } from '../model/Song';
import { getStorageManager } from '../utils/StorageManager';
import { getAudioManager } from '../utils/AudioManager';
import promptAction from '@ohos.promptAction';

/**
 * CategoryPage - Song classification page
 */
@Entry
@Component
struct CategoryPage {
  @State private categories: Category[] = [];
  @State private selectedCategory: Category | null = null;
  @State private categorySongs: Song[] = [];
  @State private isLoading: boolean = true;

  aboutToAppear(): void {
    this.loadCategories();
  }

  /**
   * Load categories with song counts
   */
  async loadCategories(): Promise<void> {
    try {
      this.isLoading = true;
      const storage = getStorageManager();
      const library = await storage.getLibrary();

      // Update song counts for each category
      const updatedCategories: Category[] = [];
      for (let i = 0; i < DEFAULT_CATEGORIES.length; i++) {
        const cat = DEFAULT_CATEGORIES[i];
        const songIds = await storage.getSongsByCategory(cat.id);
        const updatedCat: Category = {
          id: cat.id,
          name: cat.name,
          icon: cat.icon,
          songCount: songIds.length
        };
        updatedCategories.push(updatedCat);
      }
      this.categories = updatedCategories;

      this.isLoading = false;
    } catch (error) {
      console.error('Failed to load categories:', JSON.stringify(error));
      this.isLoading = false;
    }
  }

  /**
   * Select a category to view songs
   */
  async selectCategory(category: Category): Promise<void> {
    try {
      this.selectedCategory = category;
      const storage = getStorageManager();
      this.categorySongs = await storage.getSongsByCategory(category.id);
    } catch (error) {
      console.error('Failed to load category songs:', JSON.stringify(error));
    }
  }

  /**
   * Play a song
   */
  async playSong(song: Song): Promise<void> {
    try {
      const audioManager = getAudioManager();
      const storage = getStorageManager();

      await storage.addToHistory(song);

      audioManager.setPlaylist(this.categorySongs, this.categorySongs.findIndex(s => s.id === song.id));
      await audioManager.loadSong(song);
      await audioManager.play();

      promptAction.showToast({ message: `正在播放: ${song.title}`, duration: 2000 });
    } catch (error) {
      console.error('Failed to play song:', JSON.stringify(error));
    }
  }

  /**
   * Go back to category list
   */
  goBack(): void {
    if (this.selectedCategory) {
      this.selectedCategory = null;
      this.categorySongs = [];
    } else {
      router.back();
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

        // Content
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
        } else if (this.selectedCategory) {
          this.buildSongList()
        } else {
          this.buildCategoryList()
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
        Text(this.selectedCategory ? '‹ 分类' : '‹ 返回')
          .fontSize(18)
          .fontColor('#ffffff')
      }
      .type(ButtonType.Normal)
      .backgroundColor('transparent')
      .onClick(() => this.goBack())

      Blank()

      Text(this.selectedCategory ? `🏷️ ${this.selectedCategory.name}` : '🏷️ 歌曲分类')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#ffffff')

      Blank()

      // Placeholder for alignment
      Text('')
        .width(60)
    }
    .width('100%')
    .padding({ top: 48, left: 16, right: 16, bottom: 16 })
  }

  /**
   * Build category grid
   */
  @Builder
  buildCategoryList(): void {
    Scroll() {
      Column() {
        // Category grid
        Grid() {
          ForEach(this.categories, (category: Category) => {
            GridItem() {
              this.buildCategoryCard(category)
            }
          })
        }
        .columnsTemplate('1fr 1fr')
        .columnsGap(12)
        .rowsGap(12)
        .padding({ left: 16, right: 16 })
        .layoutWeight(1)

        // Bottom padding
        Divider()
          .height(100)
          .color('transparent')
      }
    }
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
  }

  /**
   * Build category card
   */
  @Builder
  buildCategoryCard(category: Category): void {
    Column() {
      Text(category.icon)
        .fontSize(36)
        .margin({ top: 16 })

      Text(category.name)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#ffffff')
        .margin({ top: 12 })

      Text(`${category.songCount} 首歌曲`)
        .fontSize(12)
        .fontColor('#a0a0b0')
        .margin({ top: 4 })
    }
    .width('100%')
    .height(140)
    .backgroundColor('rgba(255, 255, 255, 0.05)')
    .borderRadius(16)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .onClick(() => this.selectCategory(category))
  }

  /**
   * Build song list for selected category
   */
  @Builder
  buildSongList(): void {
    Column() {
      if (this.categorySongs.length === 0) {
        Column() {
          Text('📭')
            .fontSize(48)
            .margin({ top: 48 })

          Text('该分类暂无歌曲')
            .fontSize(16)
            .fontColor('#a0a0b0')
            .margin({ top: 16 })

          Text('从曲库中添加歌曲并设置分类')
            .fontSize(12)
            .fontColor('#606080')
            .margin({ top: 8 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 8 }) {
            ForEach(this.categorySongs, (song: Song) => {
              this.buildSongItem(song)
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
    }
  }

  /**
   * Build song item
   */
  @Builder
  buildSongItem(song: Song): void {
    Row() {
      Column() {
        Text('🎵')
          .fontSize(20)
      }
      .width(44)
      .height(44)
      .backgroundColor('rgba(255, 255, 255, 0.1)')
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

        Text(song.artist)
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
      .backgroundColor('#67B26F')
      .onClick(() => this.playSong(song))
    }
    .width('100%')
    .padding({ top: 8, bottom: 8, left: 10, right: 10 })
    .backgroundColor('rgba(255, 255, 255, 0.05)')
    .borderRadius(10)
  }
}
