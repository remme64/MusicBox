import router from '@ohos.router';

/**
 * AboutPage - About MusicBox Page
 */
@Entry
@Component
struct AboutPage {
  @State appVersion: string = '1.0.0';
  @State buildNumber: string = '20260412';

  build() {
    Column() {
      Row() {
        Text('<')
          .fontSize(28)
          .fontColor('#3D2A2A')
          .onClick(() => {
            router.back();
          })
        Text('关于')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#3D2A2A')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .margin({ right: 40 })
      }
      .width('100%')
      .padding({ top: 48, left: 16, right: 16, bottom: 16 })

      Column() {
        Column() {
          Text('🎵')
            .fontSize(60)
        }
        .width(100)
        .height(100)
        .backgroundColor('#FFE8E0')
        .borderRadius(24)
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 24 })

        Text('音乐盒')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#3D2A2A')
          .margin({ bottom: 8 })

        Text('版本 ' + this.appVersion + ' (' + this.buildNumber + ')')
          .fontSize(14)
          .fontColor('#8B6B6B')
          .margin({ bottom: 32 })

        Column() {
          Text('基于 OpenHarmony 的音乐播放器应用')
            .fontSize(14)
            .fontColor('#8B6B6B')
            .textAlign(TextAlign.Center)
            .margin({ bottom: 8 })
          Text('使用 ArkTS / ArkUI 开发')
            .fontSize(14)
            .fontColor('#8B6B6B')
            .textAlign(TextAlign.Center)
        }
        .padding({ left: 32, right: 32 })
        .margin({ bottom: 32 })

        Column() {
          Text('功能特点')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#3D2A2A')
            .width('100%')
            .textAlign(TextAlign.Start)
            .margin({ bottom: 12 })

          this.buildFeatureItem('🎤', '歌词显示', '支持 LRC 格式歌词')
          this.buildFeatureItem('📀', '专辑封面', '美观的专辑封面展示')
          this.buildFeatureItem('▶', '播放控制', '播放、暂停、上下一曲')
          this.buildFeatureItem('📊', '进度控制', '拖动进度条跳转播放')
          this.buildFeatureItem('🔊', '音量调节', '支持音量大小调节')
          this.buildFeatureItem('📋', '播放列表', '管理播放队列')
        }
        .width('100%')
        .padding({ left: 24, right: 24 })
        .backgroundColor('#FFF8F5')
        .borderRadius(16)
        .padding(20)
        .margin({ left: 16, right: 16, bottom: 24 })

        Text('© 2024 音乐盒')
          .fontSize(12)
          .fontColor('#C8A8A0')
          .margin({ bottom: 8 })
        Text('基于 OpenHarmony 开源项目')
          .fontSize(12)
          .fontColor('#D8C0B8')
          .margin({ bottom: 32 })
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF0EB')
  }

  @Builder
  buildFeatureItem(icon: string, title: string, desc: string) {
    Row() {
      Text(icon)
        .fontSize(20)
        .width(32)

      Column() {
        Text(title)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#3D2A2A')
        Text(desc)
          .fontSize(12)
          .fontColor('#8B6B6B')
          .margin({ top: 2 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
  }
}
