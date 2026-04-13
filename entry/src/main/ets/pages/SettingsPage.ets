import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

/**
 * SettingsPage - Application Settings Page
 */
@Entry
@Component
struct SettingsPage {
  @State notificationsEnabled: boolean = true;
  @State autoPlayNext: boolean = true;
  @State highQualityPlayback: boolean = false;
  @State volume: number = 80;

  build() {
    Column() {
      // Header
      Row() {
        Text('‹')
          .fontSize(28)
          .fontColor('#3D2A2A')
          .onClick(() => {
            router.back();
          })
        Text('设置')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#3D2A2A')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .margin({ right: 40 })
      }
      .width('100%')
      .padding({ top: 48, left: 16, right: 16, bottom: 16 })

      Scroll() {
        Column() {
          // Playback settings
          this.buildSectionTitle('播放设置')
          this.buildToggleItem('▶️', '自动播放下一首', '播放完毕后自动播放', this.autoPlayNext, (val) => {
            this.autoPlayNext = val;
          })
          this.buildToggleItem('🎧', '高品质播放', '使用高比特率播放', this.highQualityPlayback, (val) => {
            this.highQualityPlayback = val;
          })

          // Notification settings
          this.buildSectionTitle('通知')
          this.buildToggleItem('🔔', '消息通知', '接收播放通知和更新', this.notificationsEnabled, (val) => {
            this.notificationsEnabled = val;
          })

          // Volume
          this.buildSectionTitle('音量')
          Row() {
            Text('🔈')
              .fontSize(20)
            Slider({
              value: this.volume,
              min: 0,
              max: 100,
              step: 1,
              style: SliderStyle.OutSet
            })
              .layoutWeight(1)
              .onChange((value: number) => {
                this.volume = value;
              })
            Text('🔊')
              .fontSize(20)
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .backgroundColor('#FFF8F5')
          .borderRadius(12)
          .margin({ bottom: 8 })

          // Clear data
          this.buildSectionTitle('数据')
          this.buildActionItem('🗑️', '清除缓存', '清理临时文件', () => {
            promptAction.showToast({ message: '缓存已清除', duration: 1500 });
          })
          this.buildActionItem('📊', '重置播放统计', '清除播放历史和统计数据', () => {
            promptAction.showToast({ message: '统计数据已重置', duration: 1500 });
          })
        }
        .padding({ left: 16, right: 16 })
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF0EB')
  }

  @Builder
  buildSectionTitle(title: string) {
    Text(title)
      .fontSize(14)
      .fontWeight(FontWeight.Medium)
      .fontColor('#8B6B6B')
      .width('100%')
      .padding({ top: 16, bottom: 8, left: 4 })
  }

  @Builder
  buildToggleItem(icon: string, title: string, subtitle: string, isOn: boolean, onChange: (val: boolean) => void) {
    Row() {
      Text(icon)
        .fontSize(22)
        .width(40)

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

      Toggle({ type: ToggleType.Switch, isOn: isOn })
        .selectedColor('#FF8C69')
        .onChange((isOn: boolean) => {
          onChange(isOn);
        })
    }
    .width('100%')
    .padding({ left: 8, right: 16, top: 12, bottom: 12 })
    .backgroundColor('#FFF8F5')
    .borderRadius(12)
    .margin({ bottom: 8 })
  }

  @Builder
  buildActionItem(icon: string, title: string, subtitle: string, onClick: () => void) {
    Row() {
      Text(icon)
        .fontSize(22)
        .width(40)

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

      Text('›')
        .fontSize(22)
        .fontColor('#D8C0B8')
    }
    .width('100%')
    .padding({ left: 8, right: 8, top: 12, bottom: 12 })
    .backgroundColor('#FFF8F5')
    .borderRadius(12)
    .margin({ bottom: 8 })
    .onClick(onClick)
  }
}
