import router from '@ohos.router';
import { getStorageManager } from '../utils/StorageManager';
import { DEFAULT_SONGS } from '../model/Song';
import promptAction from '@ohos.promptAction';

/**
 * HomePage - Main entry page with navigation to all features
 */
@Entry
@Component
struct HomePage {
  @State private menuItems: MenuItem[] = [];
  @State private recentSongs: string[] = [];
  @State private isLoading: boolean = true;

  aboutToAppear(): void {
    this.initializeMenu();
    this.loadData();
  }

  /**
   * Initialize menu items
   */
  initializeMenu(): void {
    this.menuItems = [
      { id: 'library', title: '歌曲库', icon: '📚', subtitle: '管理我的音乐收藏', color: '#4A90D9' },
      { id: 'category', title: '歌曲分类', icon: '🏷️', subtitle: '按流派浏览歌曲', color: '#67B26F' },
      { id: 'artist', title: '歌手分类', icon: '👤', subtitle: '按歌手浏览歌曲', color: '#E94B3C' },
      { id: 'history', title: '历史记录', icon: '🕐', subtitle: '最近播放', color: '#F5A623' },
      { id: 'favorites', title: '我喜欢的音乐', icon: '❤️', subtitle: '收藏的歌曲', color: '#FF6B9D' },
      { id: 'search', title: '搜索', icon: '🔍', subtitle: '搜索歌曲和歌手', color: '#9B59B6' },
    ];
  }

  /**
   * Load initial data
   */
  async loadData(): Promise<void> {
    try {
      const storage = getStorageManager();
      // Initialize with default songs if library is empty
      const library = await storage.getLibrary();
      if (library.length === 0) {
        for (const song of DEFAULT_SONGS) {
          await storage.addToLibrary(song);
        }
      }
      this.isLoading = false;
    } catch (error) {
      console.error('Failed to load data:', JSON.stringify(error));
      this.isLoading = false;
    }
  }

  /**
   * Navigate to selected page
   */
  navigateTo(pageId: string): void {
    const routes: Record<string, string> = {
      'library': 'pages/LibraryPage',
      'category': 'pages/CategoryPage',
      'artist': 'pages/ArtistPage',
      'history': 'pages/HistoryPage',
      'favorites': 'pages/FavoritesPage',
      'search': 'pages/SearchPage'
    };

    const url = routes[pageId];
    if (url) {
      router.pushUrl({ url: url });
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
          colors: [['#1a1a2e', 0], ['#16213e', 0.5], ['#0f3460', 1]]
        })

      // Content
      Column() {
        // Header
        this.buildHeader()

        // Loading indicator
        if (this.isLoading) {
          Column() {
            LoadingProgress()
              .width(48)
              .height(48)
              .color('#ffffff')
            Text('加载中...')
              .fontSize(14)
              .fontColor('#a0a0b0')
              .margin({ top: 16 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        } else {
          // Menu grid
          this.buildMenuGrid()
        }
      }
      .width('100%')
      .height('100%')
    }
  }

  /**
   * Build header
   */
  @Builder
  buildHeader(): void {
    Column() {
      Row() {
        Text('🎵')
          .fontSize(32)

        Text('MusicBox')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#ffffff')
          .margin({ left: 12 })
      }
      .alignItems(VerticalAlign.Center)

      Text('发现音乐，享受生活')
        .fontSize(14)
        .fontColor('#a0a0b0')
        .margin({ top: 8 })
    }
    .width('100%')
    .padding({ top: 48, bottom: 32, left: 24, right: 24 })
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * Build menu grid
   */
  @Builder
  buildMenuGrid(): void {
    Scroll() {
      Column() {
        // Quick access row
        Row() {
          this.buildQuickAccessButton('❤️', '我喜欢', '#FF6B9D', () => this.navigateTo('favorites'))
          this.buildQuickAccessButton('🕐', '最近', '#F5A623', () => this.navigateTo('history'))
          this.buildQuickAccessButton('📚', '曲库', '#4A90D9', () => this.navigateTo('library'))
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
        .margin({ bottom: 24 })

        // Main menu title
        Text('功能')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#ffffff')
          .width('100%')
          .padding({ left: 24, right: 24, bottom: 16 })

        // Menu list
        Column({ space: 12 }) {
          ForEach(this.menuItems, (item: MenuItem) => {
            this.buildMenuItem(item)
          })
        }
        .padding({ left: 16, right: 16 })

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
   * Build quick access button
   */
  @Builder
  buildQuickAccessButton(icon: string, label: string, color: string, onClick: () => void): void {
    Column() {
      Button() {
        Column() {
          Text(icon)
            .fontSize(28)
          Text(label)
            .fontSize(12)
            .fontColor('#ffffff')
            .margin({ top: 8 })
        }
        .alignItems(HorizontalAlign.Center)
      }
      .width(90)
      .height(90)
      .backgroundColor(color)
      .borderRadius(20)
      .shadow({
        radius: 10,
        color: color + '40',
        offsetX: 0,
        offsetY: 4
      })
      .onClick(onClick)
    }
    .layoutWeight(1)
  }

  /**
   * Build menu item
   */
  @Builder
  buildMenuItem(item: MenuItem): void {
    Row() {
      // Icon
      Column() {
        Text(item.icon)
          .fontSize(24)
      }
      .width(48)
      .height(48)
      .backgroundColor(item.color)
      .borderRadius(12)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)

      // Text content
      Column() {
        Text(item.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#ffffff')

        Text(item.subtitle)
          .fontSize(12)
          .fontColor('#a0a0b0')
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 16 })

      // Arrow
      Text('›')
        .fontSize(24)
        .fontColor('#606080')
    }
    .width('100%')
    .padding({ top: 12, bottom: 12, left: 16, right: 16 })
    .backgroundColor('rgba(255, 255, 255, 0.05)')
    .borderRadius(16)
    .onClick(() => this.navigateTo(item.id))
  }
}

/**
 * Menu item data
 */
interface MenuItem {
  id: string;
  title: string;
  icon: string;
  subtitle: string;
  color: string;
}
