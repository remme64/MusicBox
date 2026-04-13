import router from '@ohos.router';
import { getStorageManager } from '../utils/StorageManager';
import { DEFAULT_SONGS } from '../model/Song';
import promptAction from '@ohos.promptAction';

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

  initializeMenu(): void {
    this.menuItems = [
      { id: 'library', title: '乐曲库', icon: '🎶', subtitle: '管理我的音乐收藏', color: '#FF7A59' },
      { id: 'category', title: '歌曲分类', icon: '🏷', subtitle: '按流派浏览歌曲', color: '#FFB347' },
      { id: 'artist', title: '歌手分类', icon: '🎤', subtitle: '按歌手浏览歌曲', color: '#E94B3C' },
      { id: 'history', title: '历史记录', icon: '🕐', subtitle: '最近播放记录', color: '#F5A623' },
      { id: 'favorites', title: '我喜欢的音乐', icon: '❤️', subtitle: '收藏的歌曲', color: '#FF6B9D' },
      { id: 'search', title: '搜索', icon: '🔍', subtitle: '搜索歌曲和歌手', color: '#9B59B6' }
    ];
  }

  async loadData(): Promise<void> {
    try {
      const storage = getStorageManager();
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
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Top,
          colors: [['#2D1B35', 0], ['#4A2C4A', 0.4], ['#6B3D5C', 1]]
        })

      Column() {
        this.buildHeader()

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
          this.buildMenuGrid()
        }
      }
      .width('100%')
      .height('100%')
    }
  }

  @Builder
  buildHeader(): void {
    Column() {
      Row() {
        Text('🎵')
          .fontSize(32)
        Text('音乐盒')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFF5F0')
          .margin({ left: 12 })
      }
      .alignItems(VerticalAlign.Center)
      Text('发现音乐，享受生活')
        .fontSize(14)
        .fontColor('#E8C8C0')
        .margin({ top: 8 })
    }
    .width('100%')
    .padding({ top: 48, bottom: 32, left: 24, right: 24 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildMenuGrid(): void {
    Scroll() {
      Column() {
        Row() {
          this.buildQuickAccessButton('💗', '我喜欢', '#FF6B9D', () => this.navigateTo('favorites'))
          this.buildQuickAccessButton('🕐', '最近', '#F5A623', () => this.navigateTo('history'))
          this.buildQuickAccessButton('🎶', '曲库', '#FF7A59', () => this.navigateTo('library'))
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
        .margin({ bottom: 24 })
        .margin({ bottom: 24 })

        Text('功能')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFF5F0')
          .width('100%')
          .padding({ left: 24, right: 24, bottom: 16 })

        Column({ space: 12 }) {
          ForEach(this.menuItems, (item: MenuItem) => {
            this.buildMenuItem(item)
          })
        }
        .padding({ left: 16, right: 16 })

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

  @Builder
  buildMenuItem(item: MenuItem): void {
    Row() {
      Column() {
        Text(item.icon)
          .fontSize(24)
      }
      .width(48)
      .height(48)
      .backgroundColor(item.color)
      .borderRadius(14)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)

      Column() {
        Text(item.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFF5F0')
        Text(item.subtitle)
          .fontSize(12)
          .fontColor('#E8C8C0')
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 16 })

      Text('›')
        .fontSize(24)
        .fontColor('#C8A8B8')
    }
    .width('100%')
    .padding({ top: 14, bottom: 14, left: 16, right: 16 })
    .backgroundColor('rgba(255, 255, 255, 0.08)')
    .borderRadius(18)
    .onClick(() => this.navigateTo(item.id))
  }
}

interface MenuItem {
  id: string;
  title: string;
  icon: string;
  subtitle: string;
  color: string;
}
