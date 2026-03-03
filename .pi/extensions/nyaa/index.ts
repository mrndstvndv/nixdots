import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";
import { Type } from "@sinclair/typebox";
import type { NyaaItem } from "./types.js";
import { executeSearch } from "./tools/search.js";
import { executeSave } from "./tools/save.js";
import {
  getQueue,
  clearQueue,
  addToQueue,
  removeFromQueue,
  getQueueSize,
  backupQueue,
  restoreQueue,
} from "./queue.js";

export default function (pi: ExtensionAPI) {
  // Global session items (deduplicated across all searches)
  const sessionItems: NyaaItem[] = [];
  const seenHashes = new Set<string>();

  // Clear state on new session
  pi.on("session_start", async (_event, ctx) => {
    sessionItems.length = 0;
    seenHashes.clear();
    clearQueue();
    ctx.ui.notify("Queue cleared for new session", "info");
  });

  // /nyaa-queue command to show queue status
  pi.registerCommand("nyaa-queue", {
    description: "Show current queue status",
    handler: async (_args, ctx) => {
      const size = getQueueSize();
      ctx.ui.notify(`Queue: ${size} item(s)`, "info");
    },
  });

  // /nyaa-clear command to clear queue
  pi.registerCommand("nyaa-clear", {
    description: "Clear the save queue",
    handler: async (_args, ctx) => {
      const size = getQueueSize();
      clearQueue();
      ctx.ui.notify(`Cleared ${size} items from queue`, "info");
    },
  });

  // /nyaa-undo command to restore last queue
  pi.registerCommand("nyaa-undo", {
    description: "Restore the previous queue after accidental clear",
    handler: async (_args, ctx) => {
      const restored = restoreQueue();
      if (restored) {
        ctx.ui.notify(`Restored ${getQueueSize()} item(s) to queue`, "success");
      } else {
        ctx.ui.notify("No previous queue to restore", "warning");
      }
    },
  });

  // nyaa_search tool - accumulates to global session items
  pi.registerTool({
    name: "nyaa_search",
    label: "Nyaa Search",
    description:
      "Search for torrents on nyaa.si. Results are deduplicated globally across the session. " +
      "Use the global indices (first column) with nyaa_queue_add to add items to queue.",
    promptSnippet: "Search nyaa.si for anime torrents",
    parameters: Type.Object({
      query: Type.String({ description: "Search query" }),
      category: Type.Optional(
        Type.Union([
          Type.Literal("0_0", { description: "All categories" }),
          Type.Literal("1_0", { description: "Anime" }),
          Type.Literal("1_1", { description: "Anime - Anime Music Video" }),
          Type.Literal("1_2", { description: "Anime - English-translated" }),
          Type.Literal("1_3", { description: "Anime - Non-English-translated" }),
          Type.Literal("1_4", { description: "Anime - Raw" }),
          Type.Literal("2_0", { description: "Audio" }),
          Type.Literal("2_1", { description: "Audio - Lossless" }),
          Type.Literal("2_2", { description: "Audio - Lossy" }),
          Type.Literal("3_0", { description: "Literature" }),
          Type.Literal("3_1", { description: "Literature - English-translated" }),
          Type.Literal("3_2", { description: "Literature - Non-English-translated" }),
          Type.Literal("3_3", { description: "Literature - Raw" }),
          Type.Literal("4_0", { description: "Live Action" }),
          Type.Literal("4_1", { description: "Live Action - English-translated" }),
          Type.Literal("4_2", { description: "Live Action - Idol/Promotional Video" }),
          Type.Literal("4_3", { description: "Live Action - Non-English-translated" }),
          Type.Literal("4_4", { description: "Live Action - Raw" }),
          Type.Literal("5_0", { description: "Pictures" }),
          Type.Literal("5_1", { description: "Pictures - Graphics" }),
          Type.Literal("5_2", { description: "Pictures - Photos" }),
          Type.Literal("6_0", { description: "Software" }),
          Type.Literal("6_1", { description: "Software - Applications" }),
          Type.Literal("6_2", { description: "Software - Games" }),
        ])
      ),
      filter: Type.Optional(
        Type.Union([
          Type.Literal("trusted", { description: "Only trusted uploads" }),
          Type.Literal("remakes", { description: "Only remakes" }),
          Type.Literal("no-filter", { description: "No filter (default)" }),
        ])
      ),
      user: Type.Optional(
        Type.String({
          description: "Filter by uploader username",
        })
      ),
      sort: Type.Optional(
        Type.Union([
          Type.Literal("seeders_desc", { description: "Most seeders first" }),
          Type.Literal("seeders_asc", { description: "Fewest seeders first" }),
          Type.Literal("date_desc", { description: "Newest first (default)" }),
          Type.Literal("date_asc", { description: "Oldest first" }),
          Type.Literal("size_desc", { description: "Largest first" }),
          Type.Literal("size_asc", { description: "Smallest first" }),
        ])
      ),
      limit: Type.Optional(
        Type.Number({
          description: "Number of items to return in the summary (default: 10, max: 50)",
          minimum: 1,
          maximum: 50,
        })
      ),
    }),
    async execute(toolCallId, params, signal, onUpdate, ctx) {
      onUpdate?.({ content: [{ type: "text", text: "Searching nyaa.si..." }] });

      const result = await executeSearch(params, signal, ctx, sessionItems, seenHashes);

      return {
        content: result.content,
        details: result.details,
        isError: result.isError,
      };
    },
    renderCall(args, theme) {
      const { Text } = require("@mariozechner/pi-tui");
      let text = theme.fg("toolTitle", theme.bold("nyaa_search "));
      text += theme.fg("text", args.query);
      if (args.category && args.category !== "0_0") {
        text += " " + theme.fg("dim", `cat:${args.category}`);
      }
      if (args.sort) {
        text += " " + theme.fg("dim", `sort:${args.sort}`);
      }
      return new Text(text, 0, 0);
    },
    renderResult(result, options, theme) {
      const { Text } = require("@mariozechner/pi-tui");
      const { keyHint } = require("@mariozechner/pi-coding-agent");

      if (options.isPartial) {
        return new Text(theme.fg("warning", "Searching..."), 0, 0);
      }

      if (result.isError) {
        const errorText = result.content[0]?.text ?? "Unknown error";
        return new Text(theme.fg("error", `✗ ${errorText}`), 0, 0);
      }

      const items = result.details as NyaaItem[] | undefined;
      const count = items?.length ?? 0;

      if (count === 0) {
        return new Text(theme.fg("muted", "○ No results found"), 0, 0);
      }

      // Show items with global indices
      const limit = (result.details as NyaaItem[] | undefined)?.length ?? 10;
      const displayCount = Math.min(items.length, limit);
      const lines: string[] = [];

      lines.push(theme.fg("success", `✓ Found ${count} result(s)`));
      lines.push("");

      // Header
      const idxWidth = 4;
      const titleWidth = options.expanded ? 65 : 45;
      const titleHeader = "Title".padEnd(titleWidth);
      lines.push(theme.fg("accent", `${"Idx".padEnd(idxWidth)} ${titleHeader} Size        S/L    Date`));
      lines.push(theme.fg("dim", "─".repeat(idxWidth + titleWidth + 28)));

      // Find global indices for display items
      for (let i = 0; i < displayCount; i++) {
        const item = items[i]!;
        const globalIdx = sessionItems.findIndex(si => si.infoHash === item.infoHash);
        const idxStr = String(globalIdx).padEnd(idxWidth);

        const title = item.title.length > titleWidth
          ? item.title.substring(0, titleWidth - 3) + "..."
          : item.title.padEnd(titleWidth);

        const size = item.size.padEnd(11);

        const seeders = item.seeders > 0
          ? theme.fg("success", `+${item.seeders}`)
          : theme.fg("dim", "0");
        const leechers = item.leechers > 0
          ? theme.fg("error", `-${item.leechers}`)
          : theme.fg("dim", "0");

        const dateStr = item.date !== "Unknown"
          ? new Date(item.date).toLocaleDateString()
          : "Unknown";

        lines.push(`${theme.fg("dim", idxStr)} ${theme.fg("text", title)} ${theme.fg("muted", size)} ${seeders}/${leechers}  ${theme.fg("dim", dateStr)}`);
      }

      if (items.length > displayCount) {
        lines.push(theme.fg("dim", `... and ${items.length - displayCount} more`));
      }

      return new Text(lines.join("\n"), 0, 0);
    },
  });

  // nyaa_queue_add tool - add items from global session to queue
  pi.registerTool({
    name: "nyaa_queue_add",
    label: "Nyaa Queue Add",
    description:
      "Add items from the global session to the save queue. " +
      "Use global indices from nyaa_search results.",
    promptSnippet: "Add search results to save queue",
    parameters: Type.Object({
      indices: Type.Array(Type.Number(), {
        description: "Global indices of items to add to queue (from nyaa_search results)",
      }),
    }),
    async execute(toolCallId, params, signal, onUpdate, ctx) {
      if (sessionItems.length === 0) {
        return {
          content: [{ type: "text", text: "No search results available. Run nyaa_search first." }],
          details: [],
          isError: true,
        };
      }

      const itemsToAdd = params.indices
        .map(i => sessionItems[i])
        .filter((item): item is NyaaItem => item !== undefined);

      addToQueue(itemsToAdd);

      return {
        content: [{
          type: "text",
          text: `Added ${itemsToAdd.length} item(s) to queue. Queue now has ${getQueueSize()} item(s).`,
        }],
        details: itemsToAdd,
      };
    },
    renderCall(args, theme) {
      const { Text } = require("@mariozechner/pi-tui");
      let text = theme.fg("toolTitle", theme.bold("nyaa_queue_add "));
      text += theme.fg("text", `${args.indices?.length ?? 0} items`);
      return new Text(text, 0, 0);
    },
    renderResult(result, options, theme) {
      const { Text } = require("@mariozechner/pi-tui");
      if (result.isError) {
        return new Text(theme.fg("error", "✗ No search results"), 0, 0);
      }
      const count = (result.details as NyaaItem[] | undefined)?.length ?? 0;
      return new Text(theme.fg("success", `✓ Added ${count} to queue (${getQueueSize()} total)`), 0, 0);
    },
  });

  // nyaa_queue_remove tool - remove items from queue
  pi.registerTool({
    name: "nyaa_queue_remove",
    label: "Nyaa Queue Remove",
    description: "Remove items from the save queue by their queue indices.",
    promptSnippet: "Remove items from save queue",
    parameters: Type.Object({
      indices: Type.Array(Type.Number(), {
        description: "Indices of items in the queue to remove (0-based)",
      }),
    }),
    async execute(toolCallId, params, signal, onUpdate, ctx) {
      const beforeCount = getQueueSize();
      removeFromQueue(params.indices);
      const afterCount = getQueueSize();

      return {
        content: [{
          type: "text",
          text: `Removed ${beforeCount - afterCount} item(s) from queue. Queue now has ${afterCount} item(s).`,
        }],
        details: { removed: beforeCount - afterCount, remaining: afterCount },
      };
    },
    renderCall(args, theme) {
      const { Text } = require("@mariozechner/pi-tui");
      let text = theme.fg("toolTitle", theme.bold("nyaa_queue_remove "));
      text += theme.fg("text", `${args.indices?.length ?? 0} items`);
      return new Text(text, 0, 0);
    },
    renderResult(result, options, theme) {
      const { Text } = require("@mariozechner/pi-tui");
      const details = result.details as { removed: number; remaining: number } | undefined;
      return new Text(theme.fg("success", `✓ Removed ${details?.removed ?? 0} (${details?.remaining ?? 0} in queue)`), 0, 0);
    },
  });

  // nyaa_save tool - save from queue
  pi.registerTool({
    name: "nyaa_save",
    label: "Nyaa Save",
    description:
      "Show interactive UI to confirm and save magnet links from the queue. " +
      "Clears the queue after successful save. Use /nyaa-undo to restore if cancelled.",
    promptSnippet: "Save queued torrent magnet links to a file",
    parameters: Type.Object({
      outputPath: Type.Optional(
        Type.String({
          description: "Output file path (default: links.txt)",
        })
      ),
      message: Type.Optional(
        Type.String({
          description: "Context message shown in UI (e.g., 'Episodes 1-10')",
        })
      ),
      showIndices: Type.Optional(
        Type.Array(Type.Number(), {
          description: "Indices of items to DISPLAY in the UI (0-based). If omitted, ALL items are shown.",
        })
      ),
      checkedIndices: Type.Optional(
        Type.Array(Type.Number(), {
          description: "Indices of items to PRE-CHECK (0-based). If omitted, all SHOWN items are pre-checked.",
        })
      ),
      clearAfter: Type.Optional(
        Type.Boolean({
          description: "Clear queue after save (default: true)",
        })
      ),
    }),
    async execute(toolCallId, params, signal, onUpdate, ctx) {
      const queue = getQueue();
      if (queue.length === 0) {
        return {
          content: [{ type: "text", text: "Queue is empty. Use nyaa_search and nyaa_queue_add first." }],
          details: { saved: 0, path: null },
          isError: true,
        };
      }

      // Backup queue before save (for undo)
      backupQueue();

      onUpdate?.({
        content: [{ type: "text", text: `Opening selection UI for ${queue.length} queued item(s)...` }],
      });

      const result = await executeSave(params, queue, ctx, params.showIndices, params.checkedIndices);

      // Clear queue after successful save (unless told not to)
      if (!result.isError && result.details.saved > 0 && params.clearAfter !== false) {
        clearQueue();
      }

      return {
        content: result.content,
        details: result.details,
        isError: result.isError,
      };
    },
    renderCall(args, theme) {
      const { Text } = require("@mariozechner/pi-tui");
      let text = theme.fg("toolTitle", theme.bold("nyaa_save "));
      text += theme.fg("text", args.outputPath ?? "links.txt");
      const queueSize = getQueueSize();
      if (queueSize > 0) {
        text += theme.fg("muted", ` (${queueSize} queued)`);
      }
      return new Text(text, 0, 0);
    },
    renderResult(result, options, theme) {
      const { Text } = require("@mariozechner/pi-tui");

      if (options.isPartial) {
        return new Text(theme.fg("warning", "Waiting for selection..."), 0, 0);
      }

      const details = result.details as { saved: number; path: string | null } | undefined;

      if (result.isError) {
        const errorText = result.content[0]?.text ?? "Unknown error";
        return new Text(theme.fg("error", `✗ ${errorText}`), 0, 0);
      }

      const saved = details?.saved ?? 0;
      const path = details?.path;

      if (saved === 0) {
        return new Text(theme.fg("muted", "○ Cancelled - use /nyaa-undo to restore queue"), 0, 0);
      }

      return new Text(
        theme.fg("success", `✓ Saved ${saved} link(s) to ${path}`),
        0,
        0
      );
    },
  });
}
