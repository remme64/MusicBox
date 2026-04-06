import router from '@ohos.router';
import { Song } from '../model/Song';
import { getStorageManager } from '../utils/StorageManager';
import { getAudioManager } from '../utils/AudioManager';
import promptAction from '@ohos.promptAction';

/**
 * FavoritesPage - Liked songs page
 */
@Entry
@Component
struct FavoritesPage {
  @State private favorites: Song[] = [];
  @State private isLoading: boolean = true;

  aboutToAppear(): void {
    this.loadFavorites();
  }

  /**
   * Load favorite songs
   */
  async loadFavorites(): Promise<void> {
    try {
      this.isLoading = true;
      const storage = getStorageManager();
      this.favorites = await storage.getFavorites();
      this.isLoading = false;
    } catch (error) {
      console.error('Failed to load favorites:', JSON.stringify(error));
      this.isLoading = false;
    }
  }

  /**
   * Play a favorite song
   */
  async playSong(song: Song): Promise<void> {
    try {
      const audioManager = getAudioManager();
      const storage = getStorageManager();

      await storage.addToHistory(song);

      audioManager.setPlaylist(this.favorites, this.favorites.findIndex(s => s.id === song.id));
      await audioManager.loadSong(song);
      await audioManager.play();

      promptAction.showToast({ message: `正在播放: ${song.title}`, duration: 2000 });
    } catch (error) {
      console.error('Failed to play song:', JSON.stringify(error));
    }
  }

  /**
   * Remove from favorites
   */
  async removeFromFavorites(song: Song): Promise<void> {
    try {
      const storage = getStorageManager();
      await storage.removeFavorite(song.id);
      await this.loadFavorites();
      promptAction.showToast({ message: `已取消收藏: ${song.title}`, duration: 2000 });
    } catch (error) {
      console.error('Failed to remove from favorites:', JSON.stringify(error));
    }
  }

  /**
   * Play all favorites
   */
  async playAll(): Promise<void> {
    if (this.favorites.length === 0) return;

    try {
      const audioManager = getAudioManager();
      const storage = getStorageManager();

      for (const song of this.favorites) {
        await storage.addToHistory(song);
      }

      audioManager.setPlaylist(this.favorites, 0);
      await audioManager.loadSong(this.favorites[0]);
      await audioManager.play();

      promptAction.showToast({ message: '开始播放收藏列表', duration: 2000 });
    } catch (error) {
      console.error('Failed to play all:', JSON.stringify(error));
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
        } else if (this.favorites.length === 0) {
          this.buildEmptyState()
        } else {
          this.buildFavoritesList()
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

      Text('❤️ 我的喜欢')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#ffffff')

      Blank()

      if (this.favorites.length > 0) {
        Button() {
          Text('播放全部')
            .fontSize(14)
            .fontColor('#FF6B9D')
        }
        .type(ButtonType.Normal)
        .backgroundColor('transparent')
        .onClick(() => this.playAll())
      } else {
        Text('')
          .width(60)
      }
    }
    .width('100%')
    .padding({ top: 48, left: 16, right: 16, bottom: 16 })
  }

  @Builder
  buildEmptyState(): void {
    Column() {
      Text('❤️')
        .fontSize(64)

      Text('暂无收藏')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#ffffff')
        .margin({ top: 16 })

      Text('点击心形图标收藏喜欢的歌曲')
        .fontSize(14)
        .fontColor('#a0a0b0')
        .margin({ top: 8 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildFavoritesList(): void {
    Column() {
      // Summary
      Row() {
        Text(`共 ${this.favorites.length} 首收藏歌曲`)
          .fontSize(14)
          .fontColor('#a0a0b0')
      }
      .width('100%')
      .padding({ left: 20, bottom: 12 })

      Scroll() {
        Column({ space: 8 }) {
          ForEach(this.favorites, (song: Song) => {
            this.buildFavoriteItem(song)
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

  @Builder
  buildFavoriteItem(song: Song): void {
    Row() {
      Column() {
        Text('🎵')
          .fontSize(20)
      }
      .width(44)
      .height(44)
      .backgroundColor('rgba(255, 107, 157, 0.2)')
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
      .backgroundColor('#FF6B9D')
      .onClick(() => this.playSong(song))

      Button() {
        Text('💔')
          .fontSize(12)
      }
      .width(32)
      .height(32)
      .type(ButtonType.Circle)
      .backgroundColor('transparent')
      .onClick(() => this.removeFromFavorites(song))
    }
    .width('100%')
    .padding({ top: 8, bottom: 8, left: 10, right: 10 })
    .backgroundColor('rgba(255, 255, 255, 0.05)')
    .borderRadius(10)
  }
}
