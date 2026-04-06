/**
 * Category data model for song classification
 */
export interface Category {
  /** Category ID */
  id: number;
  /** Category name */
  name: string;
  /** Category icon (emoji) */
  icon: string;
  /** Song count in this category */
  songCount: number;
}

/**
 * Default categories
 */
export const DEFAULT_CATEGORIES: Category[] = [
  { id: 1, name: '流行', icon: '🎵', songCount: 0 },
  { id: 2, name: '摇滚', icon: '🎸', songCount: 0 },
  { id: 3, name: '电子', icon: '🎹', songCount: 0 },
  { id: 4, name: '古典', icon: '🎻', songCount: 0 },
  { id: 5, name: '爵士', icon: '🎷', songCount: 0 },
  { id: 6, name: '民谣', icon: '🪕', songCount: 0 },
  { id: 7, name: '嘻哈', icon: '🎤', songCount: 0 },
  { id: 8, name: '轻音乐', icon: '🌙', songCount: 0 },
  { id: 9, name: '电影原声', icon: '🎬', songCount: 0 },
  { id: 10, name: '儿童', icon: '🧒', songCount: 0 },
];
