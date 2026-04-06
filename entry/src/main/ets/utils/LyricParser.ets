/**
 * LyricParser - LRC format lyrics parser
 * Parses standard LRC format with timestamps and metadata
 */

export interface LyricLine {
  /** Time in milliseconds when this line should be displayed */
  time: number;
  /** The lyric text content */
  text: string;
}

export interface ParsedLyrics {
  /** Song title from metadata */
  title: string;
  /** Artist from metadata */
  artist: string;
  /** Album from metadata */
  album: string;
  /** Offset in milliseconds (positive = delay, negative = advance) */
  offset: number;
  /** Array of parsed lyric lines sorted by time */
  lines: LyricLine[];
}

/**
 * Default parsed lyrics when no lyrics are available
 */
const DEFAULT_LYRICS: ParsedLyrics = {
  title: '',
  artist: '',
  album: '',
  offset: 0,
  lines: []
};

/**
 * Regular expressions for parsing LRC format
 */
const LRC_TIME_REGEX = /\[(\d{2}):(\d{2})\.(\d{2,3})\]/g;
const LRC_METADATA_REGEX = /\[(ti|ar|al|au|offset|by):([^\]]*)\]/;
const LRC_OFFSET_REGEX = /\[offset:(-?\d+)\]/;

/**
 * Parse time string to milliseconds
 * Supports both [mm:ss.xx] and [mm:ss.xxx] formats
 */
function parseTimeToMs(minutes: string, seconds: string, ms: string): number {
  const min = parseInt(minutes, 10) || 0;
  const sec = parseInt(seconds, 10) || 0;
  // Handle both 2-digit (centiseconds) and 3-digit (milliseconds) formats
  const millis = ms.length === 2 ? parseInt(ms, 10) * 10 : parseInt(ms, 10);
  return min * 60 * 1000 + sec * 1000 + millis;
}

/**
 * Parse a single line of LRC content
 */
function parseLrcLine(line: string): LyricLine | null {
  const trimmedLine = line.trim();
  if (!trimmedLine) {
    return null;
  }

  // Skip metadata lines
  if (LRC_METADATA_REGEX.test(trimmedLine)) {
    return null;
  }

  // Find all timestamps in the line
  const timestamps: number[] = [];
  let match: RegExpExecArray | null;

  // Reset regex state
  LRC_TIME_REGEX.lastIndex = 0;

  while ((match = LRC_TIME_REGEX.exec(trimmedLine)) !== null) {
    const time = parseTimeToMs(match[1], match[2], match[3]);
    timestamps.push(time);
  }

  if (timestamps.length === 0) {
    return null;
  }

  // Extract text content (everything after the last timestamp bracket)
  const lastBracketIndex = trimmedLine.lastIndexOf(']');
  const text = trimmedLine.substring(lastBracketIndex + 1).trim();

  // Return the first timestamp (most LRC files have one timestamp per line)
  return {
    time: timestamps[0],
    text: text
  };
}

/**
 * Parse LRC content string into structured data
 * @param lrcContent Raw LRC file content
 * @returns ParsedLyrics object with metadata and lines
 */
export function parseLrc(lrcContent: string): ParsedLyrics {
  if (!lrcContent || lrcContent.trim().length === 0) {
    return DEFAULT_LYRICS;
  }

  const lines = lrcContent.split('\n');
  const result: ParsedLyrics = {
    title: '',
    artist: '',
    album: '',
    offset: 0,
    lines: []
  };

  for (const line of lines) {
    const trimmedLine = line.trim();
    if (!trimmedLine) {
      continue;
    }

    // Parse metadata
    const metadataMatch = trimmedLine.match(LRC_METADATA_REGEX);
    if (metadataMatch) {
      const key = metadataMatch[1];
      const value = metadataMatch[2];
      switch (key.toLowerCase()) {
        case 'ti':
          result.title = value.trim();
          break;
        case 'ar':
          result.artist = value.trim();
          break;
        case 'al':
          result.album = value.trim();
          break;
        case 'offset':
          result.offset = parseInt(value, 10) || 0;
          break;
      }
      continue;
    }

    // Parse lyric line
    const lyricLine = parseLrcLine(trimmedLine);
    if (lyricLine && lyricLine.text) {
      result.lines.push(lyricLine);
    }
  }

  // Sort lines by time
  result.lines.sort((a, b) => a.time - b.time);

  return result;
}

/**
 * Get the current lyric line index based on playback time
 * @param lyrics Parsed lyrics object
 * @param currentTimeMs Current playback position in milliseconds
 * @returns Index of the current lyric line, or -1 if no match
 */
export function getCurrentLyricIndex(lyrics: ParsedLyrics, currentTimeMs: number): number {
  if (!lyrics.lines || lyrics.lines.length === 0) {
    return -1;
  }

  // Apply offset adjustment
  const adjustedTime = currentTimeMs + lyrics.offset;

  // Binary search for the current line
  let low = 0;
  let high = lyrics.lines.length - 1;
  let result = -1;

  while (low <= high) {
    const mid = Math.floor((low + high) / 2);
    const lineTime = lyrics.lines[mid].time;

    if (lineTime <= adjustedTime) {
      result = mid;
      low = mid + 1;
    } else {
      high = mid - 1;
    }
  }

  return result;
}

/**
 * Get surrounding lyric lines for display (previous and next)
 * @param lyrics Parsed lyrics object
 * @param currentIndex Current lyric line index
 * @param count Number of lines to show on each side
 * @returns Array of lyric lines with context
 */
export function getSurroundingLyrics(
  lyrics: ParsedLyrics,
  currentIndex: number,
  count: number = 3
): LyricLine[] {
  if (currentIndex < 0 || !lyrics.lines || lyrics.lines.length === 0) {
    return lyrics.lines.slice(0, count * 2 + 1);
  }

  const start = Math.max(0, currentIndex - count);
  const end = Math.min(lyrics.lines.length - 1, currentIndex + count);

  return lyrics.lines.slice(start, end + 1);
}

/**
 * Format time in milliseconds to mm:ss format
 */
export function formatTime(timeMs: number): string {
  const totalSeconds = Math.floor(timeMs / 1000);
  const minutes = Math.floor(totalSeconds / 60);
  const seconds = totalSeconds % 60;
  return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
}
