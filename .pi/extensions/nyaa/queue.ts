import type { NyaaItem } from "./types.js";

// Dedicated queue state (separate from search results)
let queue: NyaaItem[] = [];
let queueBackup: NyaaItem[] | null = null;

export function getQueue(): NyaaItem[] {
  return [...queue];
}

export function clearQueue(): void {
  queue = [];
}

export function addToQueue(items: NyaaItem[]): void {
  const existingHashes = new Set(queue.map(r => r.infoHash));
  const newItems = items.filter(item => !existingHashes.has(item.infoHash));
  queue = [...queue, ...newItems];
}

export function removeFromQueue(indices: number[]): void {
  const indexSet = new Set(indices);
  queue = queue.filter((_, i) => !indexSet.has(i));
}

export function getQueueSize(): number {
  return queue.length;
}

// Backup queue before operations (for undo)
export function backupQueue(): void {
  queueBackup = [...queue];
}

// Restore queue from backup
export function restoreQueue(): boolean {
  if (queueBackup === null) {
    return false;
  }
  queue = [...queueBackup];
  return true;
}

// Reconstruct queue from session (look for nyaa_queue_add tool results)
export function reconstructQueue(entries: Array<{ type: string; message?: { role: string; toolName?: string; details?: unknown } }>): void {
  queue = [];
  for (const entry of entries) {
    if (entry.type === "message" && entry.message?.role === "toolResult") {
      if (entry.message.toolName === "nyaa_queue_add") {
        const items = (entry.message.details as NyaaItem[]) ?? [];
        const existingHashes = new Set(queue.map(r => r.infoHash));
        const newItems = items.filter(item => !existingHashes.has(item.infoHash));
        queue = [...queue, ...newItems];
      }
    }
  }
}
