import {
  Container,
  Text,
  Spacer,
  matchesKey,
  Key,
  type Component,
} from "@mariozechner/pi-tui";
import { DynamicBorder, keyHint } from "@mariozechner/pi-coding-agent";
import type { NyaaItem } from "../types.js";

interface SelectorItem {
  value: string;
  label: string;
  checked: boolean;
  originalIndex: number;
}

interface DisplayItem {
  item: NyaaItem;
  originalIndex: number;
}

export function createSelector(
  items: NyaaItem[],
  message: string,
  onConfirm: (selectedIndices: number[]) => void,
  onCancel: () => void,
  tui: { requestRender: () => void },
  theme: {
    fg: (color: string, text: string) => string;
    bg: (color: string, text: string) => string;
  },
  shownIndices?: number[],
  checkedIndices?: number[]
): Component {
  const container = new Container();

  // Header
  container.addChild(new DynamicBorder((s: string) => theme.fg("accent", s)));
  container.addChild(
    new Text(theme.fg("accent", theme.fg("accent", "Confirm Download Selection")), 1, 0)
  );
  if (message) {
    container.addChild(new Text(theme.fg("text", message), 1, 0));
  }

  // Build display items
  const displayItems: DisplayItem[] = items.slice(0, 50).map((item, displayIdx) => ({
    item,
    originalIndex: shownIndices?.[displayIdx] ?? displayIdx,
  }));

  const checkedSet = checkedIndices
    ? new Set(checkedIndices)
    : new Set(displayItems.map((d) => d.originalIndex));

  // Selector items - put seeders first so it's always visible even when title truncates
  const selectorItems: SelectorItem[] = displayItems.map(({ item, originalIndex }, displayIdx) => ({
    value: String(displayIdx),
    label: `[${checkedSet.has(originalIndex) ? "✓" : " "}] [${item.seeders}] ${item.title} (${item.size})`,
    checked: checkedSet.has(originalIndex),
    originalIndex,
  }));

  if (displayItems.length === 50 && items.length > 50) {
    selectorItems.push({
      value: "overflow",
      label: theme.fg("dim", `... and ${items.length - 50} more (not shown)`),
      checked: false,
      originalIndex: -1,
    });
  }

  // State
  let selectedIndex = 0;
  const maxVisible = Math.min(selectorItems.length, 15);
  let selectedCount = selectorItems.filter((i) => i.checked).length;

  const counterText = new Text(
    theme.fg("text", `Selected: ${selectedCount}/${items.length}`),
    1,
    0
  );

  // Custom list rendering
  const listComponent: Component = {
    render(width: number): string[] {
      const lines: string[] = [];
      const startIndex = Math.max(0, Math.min(selectedIndex - Math.floor(maxVisible / 2), selectorItems.length - maxVisible));
      const endIndex = Math.min(startIndex + maxVisible, selectorItems.length);

      for (let i = startIndex; i < endIndex; i++) {
        const item = selectorItems[i]!;
        const isSelected = i === selectedIndex;
        const prefix = isSelected ? "→ " : "  ";
        const maxLabelWidth = width - prefix.length;
        
        let label = item.label;
        if (label.length > maxLabelWidth) {
          label = label.slice(0, maxLabelWidth - 3) + "...";
        }
        
        const styledLabel = isSelected 
          ? theme.fg("accent", prefix + label)
          : prefix + label;
        
        lines.push(styledLabel);
      }

      if (startIndex > 0 || endIndex < selectorItems.length) {
        lines.push(theme.fg("dim", `  (${selectedIndex + 1}/${selectorItems.length})`));
      }

      return lines;
    },
    invalidate(): void {},
    handleInput: undefined,
  };

  container.addChild(listComponent);
  container.addChild(counterText);
  container.addChild(new Spacer(1));
  container.addChild(
    new Text(
      theme.fg("dim", `${keyHint("up", "↑")}/${keyHint("down", "↓")} navigate • space toggle • ${keyHint("selectConfirm", "enter")} save • esc cancel`),
      1,
      0
    )
  );
  container.addChild(new DynamicBorder((s: string) => theme.fg("accent", s)));

  // Input handling
  const handleInput = (data: string): void => {
    if (matchesKey(data, Key.up)) {
      selectedIndex = selectedIndex === 0 ? selectorItems.length - 1 : selectedIndex - 1;
      tui.requestRender();
    } else if (matchesKey(data, Key.down)) {
      selectedIndex = selectedIndex === selectorItems.length - 1 ? 0 : selectedIndex + 1;
      tui.requestRender();
    } else if (matchesKey(data, Key.space)) {
      const item = selectorItems[selectedIndex];
      if (item && item.value !== "overflow") {
        item.checked = !item.checked;
        const checkmark = item.checked ? "✓" : " ";
        const displayItem = displayItems[parseInt(item.value, 10)];
        if (displayItem) {
          item.label = `[${checkmark}] [${displayItem.item.seeders}] ${displayItem.item.title} (${displayItem.item.size})`;
        }
        selectedCount += item.checked ? 1 : -1;
        counterText.setText(theme.fg("text", `Selected: ${selectedCount}/${items.length}`));
        tui.requestRender();
      }
    } else if (matchesKey(data, Key.enter)) {
      const selectedIndices = selectorItems
        .filter((i) => i.checked && i.value !== "overflow")
        .map((i) => i.originalIndex);
      onConfirm(selectedIndices);
    } else if (matchesKey(data, Key.escape)) {
      onCancel();
    }
  };

  return {
    render: (width: number) => container.render(width),
    invalidate: () => container.invalidate(),
    handleInput: handleInput,
  };
}
