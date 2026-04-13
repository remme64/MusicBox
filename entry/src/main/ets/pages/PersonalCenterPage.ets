import router from '@ohos.router';

/**
 * PersonalCenterPage - Personal Center Page
 * User profile and app settings with working navigation
 */
@Entry
@Component
struct PersonalCenterPage {
  @State userName: string = '音乐爱好者';
  @State favoriteCount: number = 0;
  @State playCount: number = 0;
  @State listenTime: string = '0小时';

  // Navigation routes for settings items
  private settingsRoutes: Record<string, string> = {
    '我的收藏': 'pages/FavoritesPage',
    '播放历史': 'pages/HistoryPage',
    '设置': 'pages/SettingsPage',
    '关于': 'pages/AboutPage'
  };

  build() {
    Column() {
      // Header
      Text('个人中心')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#3D2A2A')
        .margin({ top: 48, bottom: 24 })

      // Profile card
      Column() {
        // Avatar placeholder
        Column() {
          Text('🎵')
            .fontSize(40)
        }
        .width(80)
        .height(80)
        .backgroundColor('#FFE8E0')
        .borderRadius(40)
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 16 })

        // User name
        Text(this.userName)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#3D2A2A')
          .margin({ bottom: 8 })

        // User stats
        Row() {
          StatItem({ label: '收藏', value: `${this.favoriteCount}` })
          StatItem({ label: '播放', value: `${this.playCount}` })
          StatItem({ label: '时长', value: this.listenTime })
        }
        .margin({ top: 16 })
      }
      .width('100%')
      .padding({ top: 32, bottom: 32 })
      .backgroundColor('#FFF8F5')
      .borderRadius(16)
      .margin({ left: 16, right: 16, bottom: 24 })

      // Settings list
      Column() {
        this.buildSettingsItem('❤️', '我的收藏', '查看收藏的歌曲', '我的收藏')
        this.buildSettingsItem('📋', '播放历史', '最近播放的歌曲', '播放历史')
        this.buildSettingsItem('⚙️', '设置', '应用偏好设置', '设置')
        this.buildSettingsItem('ℹ️', '关于', 'MusicBox v1.0.0', '关于')
      }
      .width('100%')
      .padding({ left: 16, right: 16 })

      Blank()

      // Version info
      Text('MusicBox v1.0.0 · 基于 OpenHarmony')
        .fontSize(12)
        .fontColor('#C8A8A0')
        .margin({ bottom: 32 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF0EB')
  }

  /**
   * Build a clickable settings item
   */
  @Builder
  buildSettingsItem(icon: string, title: string, subtitle: string, routeKey: string): void {
    Row() {
      // Icon
      Text(icon)
        .fontSize(24)
        .width(44)
        .textAlign(TextAlign.Center)

      // Text content
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

      // Arrow
      Text('›')
        .fontSize(22)
        .fontColor('#D8C0B8')
    }
    .width('100%')
    .height(60)
    .padding({ left: 8, right: 8 })
    .backgroundColor('#FFF8F5')
    .borderRadius(12)
    .margin({ bottom: 8 })
    .onClick(() => {
      const route = this.settingsRoutes[routeKey];
      if (route) {
        router.pushUrl({ url: route });
      }
    })
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
