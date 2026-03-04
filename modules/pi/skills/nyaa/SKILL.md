---
name: nyaa
description: Search nyaa.si for anime torrents and extract magnet links. Use when user wants to find anime torrents, browse results, or get magnet links for torrent clients.
---

# Nyaa Skill

Search nyaa.si RSS and extract magnet links.

## Usage

```bash
# Search (shows indexed results)
./nyaa "frieren" -c 1_2 -s seeders_desc -l 25

# Extract magnets
./nyaa "frieren" -c 1_2 --format magnets --indices 0,1,2
./nyaa "frieren" --format magnets --indices all

# Save and reload
./nyaa "frieren" -c 1_2 -o results.json
./nyaa --from results.json --format magnets --indices 0,5,10
```

**Options:**
- `-c, --category <code>` - Category filter (default: 0_0)
- `-f, --filter <filter>` - trusted, remakes, no-filter
- `-s, --sort <sort>` - seeders_desc, date_desc, size_desc, etc
- `-l, --limit <n>` - Results to show (default: 10)
- `-o, --output <file>` - Save JSON to file
- `--from <file>` - Load from JSON
- `--format <table|magnets|json>` - Output format (default: table)
- `--indices <0,1,2|all>` - Indices for magnets format
- `-L, --list-categories` - Show all category codes

## Categories

**Use `-L` to see all codes. Common ones:**

| Code | Use When |
|------|----------|
| 1_2 | **Default.** English subs/dubs (most common) |
| 1_4 | Japanese RAW, no subs (for archiving) |
| 1_3 | Non-English (Spanish, French, etc.) |
| 2_0 | Soundtracks, music |
| 3_0 | Light novels, manga |

**Logic:** User wants English → `1_2`. RAW/no subs → `1_4`. Other language → `1_3`. Uncertain → `0_0` (all).

## Workflow

1. Search: `./nyaa "query" [options]`
2. Note indices from output
3. Extract: `./nyaa "query" --format magnets --indices 0,1,2 > links.txt`

Or save to JSON first, then extract from file with `--from`.

**Tip:** Default sort is `seeders_desc` (most seeders first). Good default for finding healthy torrents.