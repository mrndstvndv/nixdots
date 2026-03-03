# Nyaa.si Extension Plan

## Overview
A `pi` extension to search and download torrents from nyaa.si via RSS API with a two-phase workflow: explore via LLM, confirm via interactive UI.

## Architecture

### Extension State
Stored in tool result `details` for session persistence:
```typescript
interface NyaaState {
  lastResults: NyaaItem[];  // Persisted between tool calls
}

interface NyaaItem {
  title: string;
  magnet: string;
  size: string;
  seeders: number;
  leechers: number;
  category: string;
  date: string;
}
```

### Tools

#### 1. `nyaa_search`
Fetches torrents from nyaa.si RSS API.

**Parameters:**
```typescript
{
  query: string;           // Search query
  category?: string;       // e.g., "1_2" (Anime - English-translated)
  filter?: string;         // "trusted", "remakes", "no-filter"
  user?: string;          // Filter by uploader
  episodeRange?: string;   // e.g., "1-10" (parsed by LLM)
}
```

**Returns:**
- `content`: Compact text summary for LLM context
- `details`: `{ results: NyaaItem[] }` stored in session

**Render:**
- `renderResult`: Simple success message with count

**Flow:**
1. Parse RSS from `https://nyaa.si/?page=rss&q={query}&c={category}&f={filter}&u={user}`
2. Handle custom nyaa XML namespaces (`nyaa:seeders`, `nyaa:size`, etc.)
3. Store results in extension state (via `details`)
4. Return for LLM to display/analyze

---

#### 2. `nyaa_save`
Shows confirmation UI and writes selected torrents to file.

**Parameters:**
```typescript
{
  outputPath?: string;     // Default: "links.txt"
  message?: string;        // Context shown in UI (e.g., "Episodes 1-10 from Erai-raws")
}
```

**Behavior:**
1. Read `lastResults` from extension state
2. If empty → return error
3. Show interactive selector UI with all items **pre-checked**
4. User can deselect unwanted items
5. On confirm → write magnet links to file
6. On cancel → return without writing

**UI Controls:**
- `↑/↓` - Navigate
- `Space` - Toggle selection
- `Enter` - Confirm and save
- `Esc` - Cancel

**Render:**
- `renderResult`: Success message with saved count and file path

---

## User Workflows

### Workflow 1: Search and Refine
```
User: "Search One Piece 1080p, episodes 1-10"
→ nyaa_search(query: "One Piece 1080p")
→ LLM displays results, filters to episodes 1-10
→ User: "Actually get 5-15 instead"
→ LLM adjusts filter
→ User: "Sort by seeders"
→ LLM reorders results
```

### Workflow 2: Save with Confirmation
```
User: "Save those to links.txt"
→ nyaa_save(outputPath: "links.txt", message: "Episodes 5-15")
→ UI shows table with all 11 episodes pre-checked
→ User toggles off episode 12 (LLM mistake)
→ User presses Enter
→ File written with 10 magnet links
```

### Workflow 3: Direct Save
```
User: "Get One Piece 1080p eps 1000-1005 and save to onepiece.txt"
→ nyaa_search
→ LLM filters to range
→ nyaa_save(outputPath: "onepiece.txt")
→ User confirms in UI
→ Done
```

---

## Technical Details

### RSS Parsing
Endpoint: `https://nyaa.si/?page=rss&q={query}&c={category}&f={filter}&u={user}`

Custom namespaces to parse:
- `nyaa:seeders`
- `nyaa:leechers`  
- `nyaa:downloads`
- `nyaa:infoHash` (for magnet link construction)
- `nyaa:category`
- `nyaa:size`

Magnet link format:
```
magnet:?xt=urn:btih:{infoHash}&dn={title}&tr=http://nyaa.tracker.wf:7777/announce
```

### UI Component Structure
```
┌─ Confirm Download Selection ──────────────┐
│ Episodes 5-15 from filtered results       │
│ ↑↓ navigate • space toggle • enter save   │
│                                           │
│ > [✓] [Erai-raws] One Piece - 05 ...      │
│   [✓] [Erai-raws] One Piece - 06 ...      │
│   [✓] [Erai-raws] One Piece - 07 ...      │
│   [ ] [Some-Other] One Piece - 12 ...     │
│                                           │
│ Selected: 10/11                           │
└───────────────────────────────────────────┘
```

### State Reconstruction
On `session_start`, rebuild `lastResults` from most recent `nyaa_search` tool result in session history.

---

## File Structure

```
~/.pi/agent/extensions/
└── nyaa/
    ├── index.ts          # Main extension entry
    ├── types.ts          # Interfaces (NyaaItem, etc.)
    ├── rss.ts            # RSS fetching and parsing
    ├── tools/
    │   ├── search.ts     # nyaa_search tool
    │   └── save.ts       # nyaa_save tool
    └── components/
        └── selector.ts   # Interactive UI component
```

## Dependencies
- `@mariozechner/pi-coding-agent` - Extension API
- `@mariozechner/pi-tui` - UI components
- `@sinclair/typebox` - Parameter schemas
- `fast-xml-parser` or native XML parsing for RSS

## Edge Cases

1. **No results**: `nyaa_search` returns empty array, LLM informs user
2. **Empty state on save**: `nyaa_save` returns error "No search results available"
3. **Cancel in UI**: Returns normally with `saved: 0`, no file written
4. **All items deselected**: Same as cancel
5. **Large result sets**: Cap UI display to ~50 items with "...and X more" indicator
6. **File write errors**: Return `isError: true` with message

## Future Enhancements
- Support for `.torrent` file downloads (not just magnet links)
- Integration with transmission/deluge for direct adding
- Search history persistence
- Category quick-select shortcuts
