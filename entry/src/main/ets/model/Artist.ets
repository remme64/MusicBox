/**
 * Artist data model for artist classification
 */
export interface Artist {
  /** Artist ID */
  id: number;
  /** Artist name */
  name: string;
  /** Artist avatar/icon */
  avatar: string;
  /** Number of songs by this artist */
  songCount: number;
  /** Number of albums */
  albumCount: number;
}

/**
 * Default artists (extracted from DEFAULT_SONGS)
 */
export const DEFAULT_ARTISTS: Artist[] = [
  {
    id: 1,
    name: 'Electronic Dreams',
    avatar: '🎹',
    songCount: 1,
    albumCount: 1
  },
  {
    id: 2,
    name: 'Urban Beats',
    avatar: '🎧',
    songCount: 1,
    albumCount: 1
  },
  {
    id: 3,
    name: 'Chill Vibes',
    avatar: '🌊',
    songCount: 1,
    albumCount: 1
  }
];
