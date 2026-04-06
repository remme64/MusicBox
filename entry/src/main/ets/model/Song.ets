/**
 * Song data model representing a music track
 * Contains all information about a song including metadata,
 * file paths, and associated assets like cover art and lyrics
 */
export interface Song {
  /** Unique identifier for the song */
  id: number;
  /** Song title */
  title: string;
  /** Artist name */
  artist: string;
  /** Album name */
  album: string;
  /** Cover image path (relative to rawfile or absolute path) */
  coverImage: string;
  /** Audio file path (rawfile:// protocol) */
  audioFile: string;
  /** LRC lyrics file path */
  lrcFile: string;
  /** Duration in milliseconds */
  duration: number;
}

/**
 * Default song list for demonstration
 * In production, these would be actual files in rawfile directory
 */
export const DEFAULT_SONGS: Song[] = [
  {
    id: 1,
    title: 'Dream Waves',
    artist: 'Electronic Dreams',
    album: 'Synthesizer Nights',
    coverImage: 'rawfile://images/cover1.png',
    audioFile: 'rawfile://music/song1.mp3',
    lrcFile: 'rawfile://lyrics/song1.lrc',
    duration: 240000 // 4:00
  },
  {
    id: 2,
    title: 'Midnight City',
    artist: 'Urban Beats',
    album: 'Neon Streets',
    coverImage: 'rawfile://images/cover2.png',
    audioFile: 'rawfile://music/song2.mp3',
    lrcFile: 'rawfile://lyrics/song2.lrc',
    duration: 195000 // 3:15
  },
  {
    id: 3,
    title: 'Ocean Breeze',
    artist: 'Chill Vibes',
    album: 'Relaxation Station',
    coverImage: 'rawfile://images/cover3.png',
    audioFile: 'rawfile://music/song3.mp3',
    lrcFile: 'rawfile://lyrics/song3.lrc',
    duration: 312000 // 5:12
  }
];

/**
 * Creates a default/empty song instance
 */
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
