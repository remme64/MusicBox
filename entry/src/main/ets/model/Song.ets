/**
 * Song data model representing a music track
 */
export interface Song {
  id: number;
  title: string;
  artist: string;
  album: string;
  coverImage: string;
  audioFile: string;
  lrcFile: string;
  duration: number;
}

export const DEFAULT_SONGS: Song[] = [
  {
    id: 1,
    title: '第一首歌曲',
    artist: '本地音乐',
    album: '本地收藏',
    coverImage: 'rawfile://images/cover_user1.png',
    audioFile: 'rawfile://music/song_user1.mp3',
    lrcFile: 'rawfile://lyrics/song_user1.lrc',
    duration: 0
  }
];

export function createEmptySong(): Song {
  return {
    id: -1,
    title: '',
    artist: '',
    album: '',
    coverImage: '',
    audioFile: '',
    lrcFile: '',
    duration: 0
  };
}

export function formatDuration(durationMs: number): string {
  const totalSeconds = Math.floor(durationMs / 1000);
  const minutes = Math.floor(totalSeconds / 60);
  const seconds = totalSeconds % 60;
  return minutes + ':' + (seconds < 10 ? '0' : '') + seconds;
}
