import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { Song, DEFAULT_SONGS } from '../model/Song';
import { AudioManager, PlaybackState, getAudioManager } from '../utils/AudioManager';
import { getAVSessionUtil } from '../utils/AVSessionUtil';
import { getStorageManager } from '../utils/StorageManager';
import { parseLrc, ParsedLyrics } from '../utils/LyricParser';
import { AlbumCover } from '../components/AlbumCover';
import { LyricViewCompact } from '../components/LyricView';
import { PlayControls } from '../components/PlayControls';
import { ProgressBar } from '../components/ProgressBar';
import { VolumeControl } from '../components/VolumeControl';

/**
 * Index - Main Music Player Page with Tab Navigation
 * White theme with two bottom tabs: 歌曲 and 个人中心
 */
@Entry
@Component
struct Index {
  // Audio manager instance - initialized once
  private audioManager: AudioManager = getAudioManager();
  // AVSession util instance
  private avSessionUtil = getAVSessionUtil();

  // Tab index: 0 = player (歌曲), 1 = personal center
  @State currentTabIndex: number = 0;

  // State variables
  @State currentSong: Song | null = null;
  @State isPlaying: boolean = false;
  @State isLoading: boolean = false;
  @State currentTimeMs: number = 0;
  @State totalTimeMs: number = 0;
  @State volume: number = 1.0;
  @State lyrics: ParsedLyrics | null = null;
  @State isLyricsEnabled: boolean = true;
  @State isFavorite: boolean = false;

  // Sample LRC content for demo
  private readonly SAMPLE_LYRICS: string = `[ti:Dream Waves]
[ar:Electronic Dreams]
[al:Synthesizer Nights]
[00:00.00]♪ Dream Waves ♪
[00:05.00]Let the music take you away
[00:10.00]To a place where worries fade
[00:15.00]Feel the rhythm in your heart
[00:20.00]This is where the dreams start
[00:25.00]Waves of sound surround you now
[00:30.00]Let the music show you how
[00:35.00]To float upon this melody
[00:40.00]To a world where you are free
[00:45.00]Dream waves, dream waves
[00:50.00]Let the music be your guide
[00:55.00]Dream waves, dream waves
[01:00.00]Let the rhythm be your tide
[01:05.00]Rising up, we reach the sky
[01:10.00]Waves of sound lifting us high
[01:15.00]In this moment, we are free
[01:20.00]Let the music set us free
[01:25.00]Electronic dreams come alive
[01:30.00]In this music, we revive
[01:35.00]Dream waves, dream waves
[01:40.00]Feel the magic in the sound
[01:45.00]Dream waves, dream waves
[01:50.00]Let the melody abound
[01:55.00]Music flows like an ocean wide
[02:00.00]Take you on a timeless ride
[02:05.00]Dreams are calling, can't you hear
[02:10.00]Let the music disappear
[02:15.00]Into the waves of sound tonight
[02:20.00]Everything will feel so right
[02:25.00]Dream waves, dream waves
[02:30.00]Let the rhythm carry you
[02:35.00]Dream waves, dream waves
[02:40.00]The music sees you through
[02:45:00]Let the melody set you free
[02:50:00]Dream waves...`;

  aboutToAppear(): void {
    // Set up event handlers first
    this.setupEventHandlers();

    // Initialize player with first song
    this.initializePlayer();

    // Check if current song is favorite
    this.checkFavorite();
  }

  /**
   * Check if current song is favorite
   */
  async checkFavorite(): Promise<void> {
    if (this.currentSong) {
      const storage = getStorageManager();
      this.isFavorite = await storage.isFavorite(this.currentSong.id);
    }
  }

  aboutToDisappear(): void {
    // Resources will be cleaned up by EntryAbility
  }

  /**
   * Initialize the audio player
   */
  async initializePlayer(): Promise<void> {
    try {
      this.isLoading = true;

      // AudioManager should already be initialized by EntryAbility
      // Set playlist with 10 songs
      this.audioManager.setPlaylist(DEFAULT_SONGS, 0);

      // Load first song
      const firstSong = DEFAULT_SONGS[0];
      this.currentSong = firstSong;
      this.totalTimeMs = firstSong.duration;

      // Parse demo lyrics
      this.lyrics = parseLrc(this.SAMPLE_LYRICS);

      // Load song into player
      await this.audioManager.loadSong(firstSong);

      // Check if favorite
      await this.checkFavorite();

      this.isLoading = false;
    } catch (error) {
      console.error('Failed to initialize player:', JSON.stringify(error));
      this.isLoading = false;
      promptAction.showToast({
        message: 'Failed to initialize player',
        duration: 2000
      });
    }
  }

  /**
   * Set up audio manager event handlers
   */
  setupEventHandlers(): void {
    this.audioManager.setEventHandlers({
      onPlayStateChange: (state: PlaybackState) => {
        this.isPlaying = state === PlaybackState.PLAYING;
        this.isLoading = state === PlaybackState.IDLE;

        // Update AVSession playback state
        this.avSessionUtil.updatePlaybackState(this.isPlaying, this.currentTimeMs);
      },
      onProgressUpdate: (currentTime: number, duration: number) => {
        this.currentTimeMs = currentTime;
        if (duration > 0) {
          this.totalTimeMs = duration;
        }
      },
      onSongChange: (song: Song) => {
        this.currentSong = song;
        this.currentTimeMs = 0;
        this.totalTimeMs = song.duration;
        // Update AVSession metadata
        this.avSessionUtil.setSongMetadata(song);
        // Check if new song is favorite
        this.checkFavorite();
      },
      onError: (error: string) => {
        promptAction.showToast({
          message: error,
          duration: 2000
        });
      },
      onComplete: () => {
        // Handle song completion
      }
    });

    // Set up AVSession callbacks
    this.avSessionUtil.setOnPlayCallback(() => {
      this.audioManager.play();
    });

    this.avSessionUtil.setOnPauseCallback(() => {
      this.audioManager.pause();
    });

    this.avSessionUtil.setOnNextCallback(() => {
      this.audioManager.playNext();
    });

    this.avSessionUtil.setOnPreviousCallback(() => {
      this.audioManager.playPrevious();
    });

    this.avSessionUtil.setOnSeekCallback((position: number) => {
      this.audioManager.seekTo(position);
    });
  }

  /**
   * Toggle play/pause
   */
  async onPlayPause(): Promise<void> {
    try {
      await this.audioManager.togglePlayPause();
    } catch (error) {
      console.error('Play/Pause error:', JSON.stringify(error));
    }
  }

  /**
   * Play previous track
   */
  async onPrevious(): Promise<void> {
    try {
      await this.audioManager.playPrevious();
    } catch (error) {
      console.error('Previous error:', JSON.stringify(error));
    }
  }

  /**
   * Play next track
   */
  async onNext(): Promise<void> {
    try {
      await this.audioManager.playNext();
    } catch (error) {
      console.error('Next error:', JSON.stringify(error));
    }
  }

  /**
   * Seek to position
   */
  async onSeek(positionMs: number): Promise<void> {
    try {
      await this.audioManager.seekTo(positionMs);
    } catch (error) {
      console.error('Seek error:', JSON.stringify(error));
    }
  }

  /**
   * Change volume
   */
  async onVolumeChange(volume: number): Promise<void> {
    try {
      await this.audioManager.setVolume(volume);
      this.volume = volume;
    } catch (error) {
      console.error('Volume change error:', JSON.stringify(error));
    }
  }

  /**
   * Toggle favorite status
   */
  async toggleFavorite(): Promise<void> {
    if (!this.currentSong) return;

    try {
      const storage = getStorageManager();
      if (this.isFavorite) {
        await storage.removeFavorite(this.currentSong.id);
        promptAction.showToast({ message: '已取消收藏', duration: 1500 });
      } else {
        await storage.addFavorite(this.currentSong);
        promptAction.showToast({ message: '已添加到收藏', duration: 1500 });
      }
      this.isFavorite = !this.isFavorite;
    } catch (error) {
      console.error('Failed to toggle favorite:', JSON.stringify(error));
    }
  }

  /**
   * Navigate to full lyrics
   */
  navigateToLyrics(): void {
    router.pushUrl({
      url: 'pages/LyricsPage',
      params: {
        song: this.currentSong,
        lyrics: this.lyrics
      }
    });
  }

  build() {
    Column() {
      // Tab content based on selected tab
      if (this.currentTabIndex === 0) {
        // 歌曲 tab - Player view
        this.buildPlayerView()
      } else {
        // 个人中心 tab
        this.buildPersonalCenterView()
      }

      // Bottom TabBar
      this.buildTabBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF8F5')
  }

  /**
   * Build player view (歌曲 tab)
   */
  @Builder
  buildPlayerView() {
    Column() {
      // Top bar with song info
      this.buildTopBar()

      // Album cover with animation
      Column() {
        AlbumCover({
          coverImage: this.currentSong?.coverImage || '',
          isPlaying: this.isPlaying,
          coverSize: 280
        })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)

      // Lyrics preview
      Column() {
        LyricViewCompact({
          lyrics: this.isLyricsEnabled ? this.lyrics : null,
          currentTimeMs: this.currentTimeMs
        })
      }
      .height(100)
      .padding({ top: 16, bottom: 16 })

      // Control panel
      this.buildControlPanel()
    }
    .width('100%')
    .layoutWeight(1)
  }

  /**
   * Build personal center view (个人中心 tab)
   */
  @Builder
  buildPersonalCenterView() {
    Column() {
      // Header
      Text('个人中心')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#3D2A2A')
        .margin({ bottom: 16 })

        // User name
        Text('音乐爱好者')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#3D2A2A')
          .margin({ bottom: 8 })

        // User stats
        Row() {
          Column() {
            Text('0')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#3D2A2A')
            Text('收藏')
              .fontSize(13)
              .fontColor('#8B6B6B')
              .margin({ top: 4 })
          }
          .layoutWeight(1)

          Column() {
            Text('0')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#3D2A2A')
            Text('播放')
              .fontSize(13)
              .fontColor('#8B6B6B')
              .margin({ top: 4 })
          }
          .layoutWeight(1)

          Column() {
            Text('0小时')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#3D2A2A')
            Text('时长')
              .fontSize(13)
              .fontColor('#8B6B6B')
              .margin({ top: 4 })
          }
          .layoutWeight(1)
        }
        .margin({ top: 16 })
      }
      .width('100%')
      .padding({ top: 32, bottom: 32 })
      .backgroundColor('#FFF0EB')
      .borderRadius(16)
      .margin({ left: 16, right: 16, bottom: 24 })

      // Settings list
      Column() {
        this.buildSettingsItem('❤️', '我的收藏', '查看收藏的歌曲', 'pages/FavoritesPage')
        this.buildSettingsItem('📋', '播放历史', '最近播放的歌曲', 'pages/HistoryPage')
        this.buildSettingsItem('⚙️', '设置', '应用偏好设置', 'pages/SettingsPage')
        this.buildSettingsItem('ℹ️', '关于', 'MusicBox v1.0.0', 'pages/AboutPage')
      }
      .padding({ left: 16, right: 16 })

      Blank()
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor('#FFF8F5')
  }

  @Builder
  buildSettingsItem(icon: string, title: string, subtitle: string, routeUrl: string) {
    Row() {
      Text(icon)
        .fontSize(24)
        .width(44)
        .textAlign(TextAlign.Center)

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
    .height(60)
    .padding({ left: 8, right: 8 })
    .backgroundColor('#FFF0EB')
    .borderRadius(12)
    .margin({ bottom: 8 })
    .onClick(() => {
      router.pushUrl({ url: routeUrl });
    })
  }

  /**
   * Build bottom tab bar
   */
  @Builder
  buildTabBar() {
    Row() {
      // 歌曲 tab
      Column() {
        Text('🎵')
          .fontSize(24)
        Text('歌曲')
          .fontSize(12)
          .fontColor(this.currentTabIndex === 0 ? '#FF8C69' : '#C8A8A0')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .height(60)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.currentTabIndex = 0;
      })

      // 个人中心 tab
      Column() {
        Text('👤')
          .fontSize(24)
        Text('个人中心')
          .fontSize(12)
          .fontColor(this.currentTabIndex === 1 ? '#FF8C69' : '#C8A8A0')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .height(60)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.currentTabIndex = 1;
      })
    }
    .width('100%')
    .height(60)
    .backgroundColor('#FFF0EB')
    .borderRadius({ topLeft: 20, topRight: 20 })
  }

  /**
   * Build top navigation bar
   */
  @Builder
  buildTopBar(): void {
    Row() {
      // Song info
      Column() {
        Text(this.currentSong?.title || 'Unknown Title')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#3D2A2A')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(this.currentSong?.artist || 'Unknown Artist')
          .fontSize(14)
          .fontColor('#8B6B6B')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .alignItems(HorizontalAlign.Center)
      .layoutWeight(1)

      // Favorite button
      Button() {
        Text(this.isFavorite ? '❤️' : '🤍')
          .fontSize(20)
      }
      .width(40)
      .height(40)
      .type(ButtonType.Circle)
      .backgroundColor('transparent')
      .onClick(() => {
        this.toggleFavorite();
      })

      // Lyrics button
      Button() {
        Text('📝')
          .fontSize(20)
      }
      .width(40)
      .height(40)
      .type(ButtonType.Circle)
      .backgroundColor('transparent')
      .onClick(() => {
        this.navigateToLyrics();
      })
    }
    .width('100%')
    .padding({
      left: 16,
      right: 16,
      top: 48,
      bottom: 8
    })
  }

  /**
   * Build bottom control panel
   */
  @Builder
  buildControlPanel(): void {
    Column() {
      // Progress bar
      ProgressBar({
        currentTimeMs: this.currentTimeMs,
        totalTimeMs: this.totalTimeMs,
        isSeekable: true,
        onSeek: (positionMs: number) => {
          this.onSeek(positionMs);
        }
      })
      .padding({ left: 24, right: 24, bottom: 8 })

      // Playback controls
      PlayControls({
        isPlaying: this.isPlaying,
        isLoading: this.isLoading,
        onPlayPause: () => {
          this.onPlayPause();
        },
        onPrevious: () => {
          this.onPrevious();
        },
        onNext: () => {
          this.onNext();
        }
      })
      .padding({ top: 8, bottom: 16 })

      // Volume control
      VolumeControl({
        volume: this.volume,
        isEnabled: true,
        onVolumeChange: (vol: number) => {
          this.onVolumeChange(vol);
        }
      })
      .padding({ bottom: 16 })
    }
    .width('100%')
    .backgroundColor('#FFF8F5')
    .borderRadius({ topLeft: 24, topRight: 24 })
    .shadow({
      radius: 20,
      color: '#20000000',
      offsetX: 0,
      offsetY: -4
    })
  }
}
