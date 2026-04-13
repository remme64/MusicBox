import { LyricLine, ParsedLyrics, getCurrentLyricIndex } from '../utils/LyricParser';

/**
 * LyricView Component
 * Displays synchronized lyrics with current line highlighting
 * Supports scrolling animation and touch interaction
 */
@Component
export struct LyricView {
  @Prop lyrics: ParsedLyrics | null = null;
  @Prop currentTimeMs: number = 0;
  @Prop visibleLinesCount: number = 5;
  @Prop isEnabled: boolean = true;

  @State currentLineIndex: number = -1;

  private readonly ACTIVE_FONT_SIZE: number = 24;
  private readonly INACTIVE_FONT_SIZE: number = 16;

  aboutToAppear(): void {
    this.updateCurrentLine();
  }

  updateCurrentLine(): void {
    if (!this.lyrics) {
      this.currentLineIndex = -1;
      return;
    }
    this.currentLineIndex = getCurrentLyricIndex(this.lyrics, this.currentTimeMs);
  }

  build() {
    if (!this.isEnabled || !this.lyrics || this.lyrics.lines.length === 0) {
      Column() {
        Text('暂无歌词')
          .fontSize(16)
          .fontColor('#8B6B6B')
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    } else {
      List() {
        ForEach(
          this.lyrics.lines,
          (line: LyricLine, index: number) => {
            ListItem() {
              Text(line.text || '...')
                .fontSize(this.getFontSize(index))
                .fontWeight(this.getFontWeight(index))
                .fontColor(this.getFontColor(index))
                .textAlign(TextAlign.Center)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .padding({
                  top: this.getPaddingTop(index),
                  bottom: this.getPaddingBottom(index),
                  left: 24,
                  right: 24
                })
                .width('100%')
            }
          },
          (line: LyricLine, index: number) => index.toString()
        )
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .padding({ top: 60, bottom: 60 })
    }
  }

  private getFontSize(index: number): number {
    return index === this.currentLineIndex ? this.ACTIVE_FONT_SIZE : this.INACTIVE_FONT_SIZE;
  }

  private getFontWeight(index: number): FontWeight {
    return index === this.currentLineIndex ? FontWeight.Bold : FontWeight.Normal;
  }

  private getFontColor(index: number): string {
    if (index === this.currentLineIndex) {
      return '#FFF5F0';
    }
    if (Math.abs(index - this.currentLineIndex) <= 2) {
      return '#C8A8A0';
    }
    return '#8B6B6B';
  }

  private getPaddingTop(index: number): number {
    return index === this.currentLineIndex ? 12 : 8;
  }

  private getPaddingBottom(index: number): number {
    return index === this.currentLineIndex ? 12 : 8;
  }
}

/**
 * Compact LyricView for main player display
 * Shows current and surrounding lines without scrolling
 */
@Component
export struct LyricViewCompact {
  @Prop lyrics: ParsedLyrics | null = null;
  @Prop currentTimeMs: number = 0;

  @State currentLineIndex: number = -1;

  aboutToAppear(): void {
    this.updateCurrentLine();
  }

  updateCurrentLine(): void {
    if (!this.lyrics) {
      this.currentLineIndex = -1;
      return;
    }
    this.currentLineIndex = getCurrentLyricIndex(this.lyrics, this.currentTimeMs);
  }

  build() {
    if (!this.lyrics || this.lyrics.lines.length === 0) {
      Column() {
        Text('♪♪...')
          .fontSize(20)
          .fontColor('#8B6B6B')
          .textAlign(TextAlign.Center)
      }
      .width('100%')
    } else {
      Column({ space: 16 }) {
        if (this.currentLineIndex > 0) {
          Text(this.lyrics.lines[this.currentLineIndex - 1]?.text || '')
            .fontSize(14)
            .fontColor('#8B6B6B')
            .textAlign(TextAlign.Center)
            .opacity(0.6)
        }

        Text(
          this.currentLineIndex >= 0
            ? this.lyrics.lines[this.currentLineIndex].text
            : '等待播放...'
        )
          .fontSize(22)
          .fontWeight(FontWeight.Medium)
          .fontColor('#3D2A2A')
          .textAlign(TextAlign.Center)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        if (
          this.currentLineIndex >= 0 &&
          this.currentLineIndex < this.lyrics.lines.length - 1
        ) {
          Text(this.lyrics.lines[this.currentLineIndex + 1]?.text || '')
            .fontSize(14)
            .fontColor('#8B6B6B')
            .textAlign(TextAlign.Center)
            .opacity(0.6)
        }
      }
      .width('100%')
    }
  }
}
