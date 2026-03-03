import type { ExtensionContext } from "@mariozechner/pi-coding-agent";
import type { NyaaItem, SearchParams } from "../types.js";
import { fetchNyaaRSS, formatItemForDisplay } from "../rss.js";

export interface SearchResult {
  content: Array<{ type: "text"; text: string }>;
  details: NyaaItem[];
  newCount: number;
  duplicateCount: number;
  isError?: boolean;
}

export async function executeSearch(
  params: SearchParams,
  signal: AbortSignal,
  ctx: ExtensionContext,
  sessionItems: NyaaItem[],
  seenHashes: Set<string>
): Promise<SearchResult> {
  try {
    const items = await fetchNyaaRSS(
      params.query,
      params.category,
      params.filter,
      params.user,
      params.sort,
      signal
    );

    if (signal.aborted) {
      return {
        content: [{ type: "text", text: "Search cancelled" }],
        details: [],
        newCount: 0,
        duplicateCount: 0,
      };
    }

    if (items.length === 0) {
      return {
        content: [
          { type: "text", text: "No results found for the given query." },
        ],
        details: [],
        newCount: 0,
        duplicateCount: 0,
      };
    }

    // Deduplicate against global session items
    const displayIndices: number[] = [];
    let newCount = 0;
    let duplicateCount = 0;

    for (const item of items) {
      if (!seenHashes.has(item.infoHash)) {
        // New unique item
        seenHashes.add(item.infoHash);
        sessionItems.push(item);
        displayIndices.push(sessionItems.length - 1);
        newCount++;
      } else {
        // Duplicate - find its global index
        const existingIdx = sessionItems.findIndex(i => i.infoHash === item.infoHash);
        displayIndices.push(existingIdx);
        duplicateCount++;
      }
    }

    // Build summary for LLM - show global indices
    const summary = [
      `Found ${newCount} new result(s)${duplicateCount > 0 ? `, ${duplicateCount} duplicate(s) skipped` : ""}:`,
      "",
      ...displayIndices.slice(0, 20).map((globalIdx, i) => {
        const item = sessionItems[globalIdx]!;
        return `${globalIdx}. ${formatItemForDisplay(item)}`;
      }),
      displayIndices.length > 20 ? `\n... and ${displayIndices.length - 20} more` : "",
      "",
      "Use nyaa_queue_add with global indices (first column) to add items to queue.",
    ].join("\n");

    return {
      content: [{ type: "text", text: summary }],
      details: displayIndices.map(idx => sessionItems[idx]!),
      newCount,
      duplicateCount,
    };
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error";
    return {
      content: [{ type: "text", text: `Error fetching results: ${message}` }],
      details: [],
      newCount: 0,
      duplicateCount: 0,
      isError: true,
    };
  }
}
