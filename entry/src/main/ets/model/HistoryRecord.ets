import { Song } from './Song';

/**
 * History record for play history
 */
export interface HistoryRecord {
  /** Record ID */
  id: number;
  /** Song that was played */
  song: Song;
  /** Timestamp when played */
  playedAt: number;
  /** Play duration in ms */
  playDuration: number;
}

/**
 * Create a history record from a song
 */
export function createHistoryRecord(song: Song, playDuration: number = 0): HistoryRecord {
  return {
    id: Date.now(),
    song: song,
    playedAt: Date.now(),
    playDuration: playDuration
  };
}
