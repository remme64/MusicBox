# MusicBox 🎵

基于 OpenHarmony 的音乐播放器应用

## 功能特性

- 🎤 歌词显示（支持 LRC 格式）
- 📀 专辑封面展示
- ▶️ 播放控制（播放/暂停/上一首/下一首）
- 📊 进度条控制
- 🔊 音量调节
- 📋 播放列表

## 技术栈

- OpenHarmony
- ArkTS/ArkUI
- Hvigor 构建系统

## 项目结构

```
entry/src/main/ets/
├── components/     # UI 组件
│   ├── AlbumCover.ets
│   ├── LyricView.ets
│   ├── PlayControls.ets
│   ├── ProgressBar.ets
│   └── VolumeControl.ets
├── pages/         # 页面
│   ├── Index.ets
│   ├── LyricsPage.ets
│   └── PlayList.ets
├── model/         # 数据模型
│   └── Song.ets
└── utils/         # 工具类
    ├── AudioManager.ets
    ├── AVSessionUtil.ets
    └── LyricParser.ets
```

## 运行

使用 DevEco Studio 打开项目，在设备或模拟器上运行。
