import { writeFile } from "node:fs/promises";
import type { ExtensionContext } from "@mariozechner/pi-coding-agent";
import type { NyaaItem, SaveParams } from "../types.js";
import { createSelector } from "../components/selector.js";

export interface SaveResult {
  content: Array<{ type: "text"; text: string }>;
  details: { saved: number; path: string | null };
  isError?: boolean;
}

export async function executeSave(
  params: SaveParams,
  items: NyaaItem[],
  ctx: ExtensionContext,
  showIndices?: number[],
  checkedIndices?: number[]
): Promise<SaveResult> {
  if (items.length === 0) {
    return {
      content: [{ type: "text", text: "No search results available. Run nyaa_search first." }],
      details: { saved: 0, path: null },
      isError: true,
    };
  }

  const outputPath = params.outputPath ?? "links.txt";

  // In headless mode (no UI), save all items
  if (!ctx.hasUI) {
    const itemsWithMagnets = items.filter((item) => item.magnet);
    const magnetLinks = itemsWithMagnets.map((item) => item.magnet).join("\n");

    try {
      await writeFile(outputPath, magnetLinks + "\n", "utf-8");
      return {
        content: [
          {
            type: "text",
            text: `Saved ${itemsWithMagnets.length} magnet link(s) to ${outputPath} (headless mode: all items)`,
          },
        ],
        details: { saved: itemsWithMagnets.length, path: outputPath },
      };
    } catch (error) {
      const message = error instanceof Error ? error.message : "Unknown error";
      return {
        content: [{ type: "text", text: `Error writing file: ${message}` }],
        details: { saved: 0, path: null },
        isError: true,
      };
    }
  }

  // Filter items to show if showIndices provided
  const itemsToShow = showIndices
    ? showIndices.map(i => items[i]!).filter(Boolean)
    : items;

  // Show interactive selector
  const selectedIndices = await ctx.ui.custom<number[]>((tui, theme, _keybindings, done) => {
    const onConfirm = (indices: number[]) => {
      done(indices);
    };

    const onCancel = () => {
      done([]);
    };

    // Pass the filtered items and which original indices should be checked
    return createSelector(
      itemsToShow,
      params.message ?? "",
      onConfirm,
      onCancel,
      tui,
      theme,
      showIndices, // The original indices being shown
      checkedIndices // Which of those should be checked
    );
  });

  if (selectedIndices.length === 0) {
    return {
      content: [{ type: "text", text: "Selection cancelled. No links saved." }],
      details: { saved: 0, path: null },
    };
  }

  const selectedItems = selectedIndices.map((i) => items[i]!).filter((item) => item.magnet);
  const magnetLinks = selectedItems.map((item) => item.magnet).join("\n");

  try {
    await writeFile(outputPath, magnetLinks + "\n", "utf-8");
    return {
      content: [
        {
          type: "text",
          text: `Saved ${selectedItems.length} magnet link(s) to ${outputPath}`,
        },
      ],
      details: { saved: selectedItems.length, path: outputPath },
    };
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error";
    return {
      content: [{ type: "text", text: `Error writing file: ${message}` }],
      details: { saved: 0, path: null },
      isError: true,
    };
  }
}
