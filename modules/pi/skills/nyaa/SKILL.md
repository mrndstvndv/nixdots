---
name: nyaa
description: Search nyaa.si for anime torrents and extract magnet links. Use when user wants to find anime torrents, browse results, or get magnet links for torrent clients.
---

# Nyaa Skill

Search nyaa.si for anime.

## Usage

```bash
# Search (default: English-translated, seeders_desc)
./nyaa "frieren"

# Extract magnets (comma-separated or 'all')
./nyaa "frieren" --indices 0,1,2

# Save results to JSON
./nyaa "frieren" --format json > results.json
```

**Options:**
- `-c <code>` - Category (default `1_2` - English subs/dubs)
- `-s <sort>` - seeders_desc, date_desc, size_desc
- `-l <n>` - Limit results (default 10)
- `--indices <0,1,2|all>` - Get magnet links (auto-switches to magnets format)
- `-L` - List category codes

## Common Categories

| Code | Usage |
|------|-------|
| 1_2  | **English subs/dubs** |
| 1_4  | Japanese RAW |
| 3_0  | Manga / LNs |
| 0_0  | All |

**Tip:** Default sort is `seeders_desc` (best for healthy torrents). Use `-L` for full code list.

Save magnets: `./nyaa "query" --indices <all|0,1,2> > file.txt`