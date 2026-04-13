# MusicBox 毕设项目

## 当前状态

### ✅ 已完成修改

1. **底部双 Tab 导航**：歌曲 / 个人中心
2. **白色主色调**：从深色改为浅色主题
3. **10 首歌曲**：已添加到乐曲库

### ⚠️ 关于音频文件

当前 `rawfile/music/` 中的音频文件是**简单的正弦波音调**（不是真正的音乐）：
- 每个文件约 689KB，是 8 秒的纯音调
- 不同歌曲使用不同频率：song1=440Hz, song2=330Hz, 等
- 这仅用于测试播放器功能是否正常

### 🎵 替换为真实音乐

如需真实音乐，可从以下来源获取（需手动下载后替换）：

**免费/开源音乐**：
- Pixabay Music: https://pixabay.com/music/
- Free Music Archive: https://freemusicarchive.org/
- Incompetech (Kevin MacLeod): https://incompetech.com/music/
- Freesound: https://freesound.org/ (需注册)

**下载后**：
1. 将 `.mp3` 文件放入 `rawfile/music/` 目录
2. 文件命名为 `song1.mp3` ~ `song10.mp3`
3. 更新 `model/Song.ets` 中的 `duration` 字段为实际时长

## 项目结构

```
entry/src/main/
├── ets/
│   ├── pages/
│   │   ├── Index.ets          # 主页面（含 Tab 导航）
│   │   ├── SongsPage.ets      # 歌曲列表页
│   │   └── PersonalCenterPage.ets  # 个人中心页
│   ├── components/            # UI 组件（已更新白色主题）
│   ├── model/
│   │   └── Song.ets           # 10 首歌曲数据
│   └── utils/
└── resources/rawfile/
    ├── images/                # 10 张专辑封面 ✅
    └── music/                 # 10 首音频文件 ⚠️ (测试用)
```

## 运行

在 DevEco Studio 中打开 `E:\musicbox`，然后运行即可。
