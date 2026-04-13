import router from '@ohos.router';
import { Artist, DEFAULT_ARTISTS } from '../model/Artist';
import { Song } from '../model/Song';
import { getStorageManager } from '../utils/StorageManager';
import { getAudioManager } from '../utils/AudioManager';
import promptAction from '@ohos.promptAction';

/**
 * ArtistPage - Artist classification page
 */
@Entry
@Component
struct ArtistPage {
  @State private artists: Artist[] = [];
  @State private selectedArtist: Artist | null = null;
  @State private artistSongs: Song[] = [];
  @State private isLoading: boolean = true;

  aboutToAppear(): void {
    this.loadArtists();
  }

  /**
   * Load artists with song counts
   */
  async loadArtists(): Promise<void> {
    try {
      this.isLoading = true;
      const storage = getStorageManager();
      const library = await storage.getLibrary();

      // Group songs by artist
      const artistMap = new Map<string, number>();
      for (const song of library) {
        const count = artistMap.get(song.artist) || 0;
        artistMap.set(song.artist, count + 1);
      }

      // Create artist list
      const artistEntries = Array.from(artistMap.entries());
      const artistList: Artist[] = [];
      for (let i = 0; i < artistEntries.length; i++) {
        const entry = artistEntries[i];
        const name = entry[0];
        const count = entry[1];
        const defaultArtist = DEFAULT_ARTISTS.find(a => a.name === name);
        const newArtist: Artist = {
          id: i + 1,
          name: name,
          avatar: defaultArtist ? defaultArtist.avatar : '🎤',
          songCount: count,
          albumCount: 1
        };
        artistList.push(newArtist);
      }
      this.artists = artistList;

      this.isLoading = false;
    } catch (error) {
      console.error('Failed to load artists:', JSON.stringify(error));
      this.isLoading = false;
    }
  }

  /**
   * Select an artist to view songs
   */
  async selectArtist(artist: Artist): Promise<void> {
    try {
      this.selectedArtist = artist;
      const storage = getStorageManager();
      this.artistSongs = await storage.getSongsByArtist(artist.name);
    } catch (error) {
      console.error('Failed to load artist songs:', JSON.stringify(error));
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

      audioManager.setPlaylist(this.artistSongs, this.artistSongs.findIndex(s => s.id === song.id));
      await audioManager.loadSong(song);
      await audioManager.play();

      promptAction.showToast({ message: `正在播放: ${song.title}`, duration: 2000 });
    } catch (error) {
      console.error('Failed to play song:', JSON.stringify(error));
    }
  }

  /**
   * Go back
   */
  goBack(): void {
    if (this.selectedArtist) {
      this.selectedArtist = null;
      this.artistSongs = [];
    } else {
      router.back();
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Top,
          colors: [['#2D1B35', 0], ['#4A2C4A', 1]]
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
        } else if (this.selectedArtist) {
          this.buildArtistDetail()
        } else {
          this.buildArtistList()
        }
      }
    }
  }

  @Builder
  buildHeader(): void {
    Row() {
      Button() {
        Text(this.selectedArtist ? '‹ 歌手' : '‹ 返回')
          .fontSize(18)
          .fontColor('#ffffff')
      }
      .type(ButtonType.Normal)
      .backgroundColor('transparent')
      .onClick(() => this.goBack())

      Blank()

      Text(this.selectedArtist ? `👤 ${this.selectedArtist.name}` : '👤 歌手分类')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#ffffff')

      Blank()

      Text('')
        .width(60)
    }
    .width('100%')
    .padding({ top: 48, left: 16, right: 16, bottom: 16 })
  }

  @Builder
  buildArtistList(): void {
    Scroll() {
      Column({ space: 12 }) {
        ForEach(this.artists, (artist: Artist) => {
          this.buildArtistItem(artist)
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
    .height('100%')
  }

  @Builder
  buildArtistItem(artist: Artist): void {
    Row() {
      // Avatar
      Column() {
        Text(artist.avatar)
          .fontSize(28)
      }
      .width(60)
      .height(60)
      .backgroundColor('rgba(233, 75, 60, 0.2)')
      .borderRadius(30)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)

      // Info
      Column() {
        Text(artist.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#ffffff')

        Text(`${artist.songCount} 首歌曲`)
          .fontSize(12)
          .fontColor('#C8A8B0')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 16 })

      // Arrow
      Text('›')
        .fontSize(24)
        .fontColor('#C8A8B8')
    }
    .width('100%')
    .padding({ top: 12, bottom: 12, left: 16, right: 16 })
    .backgroundColor('rgba(255, 255, 255, 0.05)')
    .borderRadius(16)
    .onClick(() => this.selectArtist(artist))
  }

  @Builder
  buildArtistDetail(): void {
    Column() {
      if (this.artistSongs.length === 0) {
        Column() {
          Text('🎤')
            .fontSize(48)
            .margin({ top: 48 })

          Text('该歌手暂无歌曲')
            .fontSize(16)
            .fontColor('#a0a0b0')
            .margin({ top: 16 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 8 }) {
            ForEach(this.artistSongs, (song: Song) => {
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

        Text(song.album)
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
      .backgroundColor('#E94B3C')
      .onClick(() => this.playSong(song))
    }
    .width('100%')
    .padding({ top: 8, bottom: 8, left: 10, right: 10 })
    .backgroundColor('rgba(255, 255, 255, 0.05)')
    .borderRadius(10)
  }
}
