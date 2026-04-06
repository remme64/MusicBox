import dataPreferences from '@ohos.data.preferences';
import { Song } from '../model/Song';
import { HistoryRecord, createHistoryRecord } from '../model/HistoryRecord';
import { Category, DEFAULT_CATEGORIES } from '../model/Category';

/**
 * StorageManager - Handles persistent storage for MusicBox
 * Uses preferences for storing favorites, history, and library data
 */
export class StorageManager {
  private static instance: StorageManager | null = null;
  private context: Context | null = null;
  private preferences: dataPreferences.Preferences | null = null;

  // Storage keys
  private static readonly KEY_FAVORITES = 'favorites';
  private static readonly KEY_HISTORY = 'history';
  private static readonly KEY_LIBRARY = 'library';
  private static readonly KEY_CATEGORIES = 'categories';
  private static readonly KEY_SONG_CATEGORIES = 'song_categories';

  private constructor() {}

  /**
   * Get singleton instance
   */
  public static getInstance(): StorageManager {
    if (!StorageManager.instance) {
      StorageManager.instance = new StorageManager();
    }
    return StorageManager.instance;
  }

  /**
   * Initialize with context
   */
  async initialize(context: Context): Promise<void> {
    try {
      this.context = context;
      this.preferences = await dataPreferences.Preferences.getPreferences(context, 'musicbox_data');
      console.info('StorageManager initialized successfully');
    } catch (error) {
      console.error('Failed to initialize StorageManager:', JSON.stringify(error));
    }
  }

  // ==================== FAVORITES ====================

  /**
   * Get all favorite songs
   */
  async getFavorites(): Promise<Song[]> {
    try {
      if (!this.preferences) return [];
      const data = await this.preferences.get(StorageManager.KEY_FAVORITES, '');
      if (data && typeof data === 'string') {
        return JSON.parse(data) as Song[];
      }
      return [];
    } catch (error) {
      console.error('Failed to get favorites:', JSON.stringify(error));
      return [];
    }
  }

  /**
   * Add song to favorites
   */
  async addFavorite(song: Song): Promise<boolean> {
    try {
      const favorites = await this.getFavorites();
      if (!favorites.find(s => s.id === song.id)) {
        favorites.push(song);
        await this.preferences?.put(StorageManager.KEY_FAVORITES, JSON.stringify(favorites));
        await this.preferences?.flush();
      }
      return true;
    } catch (error) {
      console.error('Failed to add favorite:', JSON.stringify(error));
      return false;
    }
  }

  /**
   * Remove song from favorites
   */
  async removeFavorite(songId: number): Promise<boolean> {
    try {
      const favorites = await this.getFavorites();
      const filtered = favorites.filter(s => s.id !== songId);
      await this.preferences?.put(StorageManager.KEY_FAVORITES, JSON.stringify(filtered));
      await this.preferences?.flush();
      return true;
    } catch (error) {
      console.error('Failed to remove favorite:', JSON.stringify(error));
      return false;
    }
  }

  /**
   * Check if song is favorite
   */
  async isFavorite(songId: number): Promise<boolean> {
    const favorites = await this.getFavorites();
    return favorites.some(s => s.id === songId);
  }

  // ==================== HISTORY ====================

  /**
   * Get play history
   */
  async getHistory(): Promise<HistoryRecord[]> {
    try {
      if (!this.preferences) return [];
      const data = await this.preferences.get(StorageManager.KEY_HISTORY, '');
      if (data && typeof data === 'string') {
        return JSON.parse(data) as HistoryRecord[];
      }
      return [];
    } catch (error) {
      console.error('Failed to get history:', JSON.stringify(error));
      return [];
    }
  }

  /**
   * Add to play history
   */
  async addToHistory(song: Song, playDuration: number = 0): Promise<boolean> {
    try {
      const history = await this.getHistory();
      const record = createHistoryRecord(song, playDuration);
      history.unshift(record); // Add to beginning
      // Keep only last 100 records
      if (history.length > 100) {
        history.splice(100);
      }
      await this.preferences?.put(StorageManager.KEY_HISTORY, JSON.stringify(history));
      await this.preferences?.flush();
      return true;
    } catch (error) {
      console.error('Failed to add to history:', JSON.stringify(error));
      return false;
    }
  }

  /**
   * Clear play history
   */
  async clearHistory(): Promise<boolean> {
    try {
      await this.preferences?.put(StorageManager.KEY_HISTORY, JSON.stringify([]));
      await this.preferences?.flush();
      return true;
    } catch (error) {
      console.error('Failed to clear history:', JSON.stringify(error));
      return false;
    }
  }

  // ==================== LIBRARY ====================

  /**
   * Get all songs in library
   */
  async getLibrary(): Promise<Song[]> {
    try {
      if (!this.preferences) return [];
      const data = await this.preferences.get(StorageManager.KEY_LIBRARY, '');
      if (data && typeof data === 'string') {
        return JSON.parse(data) as Song[];
      }
      return [];
    } catch (error) {
      console.error('Failed to get library:', JSON.stringify(error));
      return [];
    }
  }

  /**
   * Add song to library
   */
  async addToLibrary(song: Song): Promise<boolean> {
    try {
      const library = await this.getLibrary();
      if (!library.find(s => s.id === song.id)) {
        library.push(song);
        await this.preferences?.put(StorageManager.KEY_LIBRARY, JSON.stringify(library));
        await this.preferences?.flush();
      }
      return true;
    } catch (error) {
      console.error('Failed to add to library:', JSON.stringify(error));
      return false;
    }
  }

  /**
   * Remove song from library
   */
  async removeFromLibrary(songId: number): Promise<boolean> {
    try {
      const library = await this.getLibrary();
      const filtered = library.filter(s => s.id !== songId);
      await this.preferences?.put(StorageManager.KEY_LIBRARY, JSON.stringify(filtered));
      await this.preferences?.flush();
      return true;
    } catch (error) {
      console.error('Failed to remove from library:', JSON.stringify(error));
      return false;
    }
  }

  /**
   * Check if song is in library
   */
  async isInLibrary(songId: number): Promise<boolean> {
    const library = await this.getLibrary();
    return library.some(s => s.id === songId);
  }

  // ==================== SONG-CATEGORY MAPPING ====================

  /**
   * Get category for a song
   */
  async getSongCategory(songId: number): Promise<number | null> {
    try {
      if (!this.preferences) return null;
      const data = await this.preferences.get(StorageManager.KEY_SONG_CATEGORIES, '');
      if (data && typeof data === 'string') {
        const mapping = JSON.parse(data) as Record<number, number>;
        return mapping[songId] ?? null;
      }
      return null;
    } catch (error) {
      console.error('Failed to get song category:', JSON.stringify(error));
      return null;
    }
  }

  /**
   * Set category for a song
   */
  async setSongCategory(songId: number, categoryId: number): Promise<boolean> {
    try {
      const data = await this.preferences?.get(StorageManager.KEY_SONG_CATEGORIES, '');
      let mapping: Record<number, number> = {};
      if (data && typeof data === 'string') {
        mapping = JSON.parse(data);
      }
      mapping[songId] = categoryId;
      await this.preferences?.put(StorageManager.KEY_SONG_CATEGORIES, JSON.stringify(mapping));
      await this.preferences?.flush();
      return true;
    } catch (error) {
      console.error('Failed to set song category:', JSON.stringify(error));
      return false;
    }
  }

  /**
   * Get songs by category
   */
  async getSongsByCategory(categoryId: number): Promise<Song[]> {
    try {
      const library = await this.getLibrary();
      const data = await this.preferences?.get(StorageManager.KEY_SONG_CATEGORIES, '');
      let mapping: Record<number, number> = {};
      if (data && typeof data === 'string') {
        mapping = JSON.parse(data);
      }
      return library.filter(song => mapping[song.id] === categoryId);
    } catch (error) {
      console.error('Failed to get songs by category:', JSON.stringify(error));
      return [];
    }
  }

  /**
   * Get songs by artist
   */
  async getSongsByArtist(artistName: string): Promise<Song[]> {
    const library = await this.getLibrary();
    return library.filter(song => song.artist === artistName);
  }
}

// Export singleton getter
export function getStorageManager(): StorageManager {
  return StorageManager.getInstance();
}
