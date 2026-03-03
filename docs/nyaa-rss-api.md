# Nyaa.si RSS API Specification

> RSS feed API for nyaa.si - BitTorrent anime/media tracker

## Overview

Nyaa.si provides an RSS 2.0 feed endpoint with custom namespace extensions for torrent metadata. The API allows filtering by category, search query, and uploader.

**Base URL:** `https://nyaa.si/?page=rss`

**Format:** RSS 2.0 with custom `nyaa:` namespace (`xmlns:nyaa="https://nyaa.si/xmlns/nyaa"`)

---

## Query Parameters

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `q` | string | Search query (URL-encoded) | `q=horriblesubs` |
| `c` | string | Category ID (see categories below) | `c=1_2` |
| `u` | string | Filter by uploader username | `u=seri` |
| `f` | integer | Filter level (0=no filter, 1=trusted only, 2=remakes) | `f=0` |

### Parameter Combinations

Parameters can be combined:

```
?q=one+piece&c=1_2&f=1          # Search "one piece", English anime, trusted only
?c=1_2&u=horriblesubs           # Horriblesubs' English anime uploads
?q=1080p&f=0                    # All 1080p releases (no filter)
```

---

## Categories

Categories use a hierarchical ID format: `{main}_{sub}`

### Main Categories

| Main ID | Name |
|---------|------|
| `1` | Anime |
| `2` | Audio |
| `3` | Literature |
| `4` | Live Action |
| `5` | Pictures |
| `6` | Software |

### Full Category IDs

| ID | Category |
|----|----------|
| `1_0` | All Anime |
| `1_1` | Anime - AMV |
| `1_2` | Anime - English-translated |
| `1_3` | Anime - Non-English-translated |
| `1_4` | Anime - Raw |
| `2_0` | All Audio |
| `2_1` | Audio - Lossless |
| `2_2` | Audio - Lossy |
| `3_0` | All Literature |
| `3_1` | Literature - English-translated |
| `3_2` | Literature - Non-English-translated |
| `3_3` | Literature - Raw |
| `4_0` | All Live Action |
| `4_1` | Live Action - English-translated |
| `4_2` | Live Action - Idol/Promotional Video |
| `4_3` | Live Action - Non-English-translated |
| `4_4` | Live Action - Raw |
| `5_0` | All Pictures |
| `5_1` | Pictures - Graphics |
| `5_2` | Pictures - Photos |
| `6_0` | All Software |
| `6_1` | Software - Applications |
| `6_2` | Software - Games |

---

## Filter Levels

| Value | Description |
|-------|-------------|
| `0` | No filter (show all) |
| `1` | Trusted only (green entries) |
| `2` | Remakes (red entries) |

---

## Response Format

### RSS Channel Structure

```xml
<?xml version="1.0" encoding="UTF-8"?>
<rss xmlns:atom="http://www.w3.org/2005/Atom" 
     xmlns:nyaa="https://nyaa.si/xmlns/nyaa" 
     version="2.0">
  <channel>
    <title>Nyaa - {search} - Torrent File RSS</title>
    <description>RSS Feed for {search}</description>
    <link>https://nyaa.si/</link>
    <atom:link href="https://nyaa.si/?page=rss" rel="self" type="application/rss+xml" />
    <item>...</item>
    <item>...</item>
    ...
  </channel>
</rss>
```

### RSS Item Structure

Each `<item>` represents one torrent:

```xml
<item>
  <title>[Group] Series Name - Episode [Quality][Hash]</title>
  <link>https://nyaa.si/download/{torrent_id}.torrent</link>
  <guid isPermaLink="true">https://nyaa.si/view/{torrent_id}</guid>
  <pubDate>Tue, 03 Mar 2026 02:53:00 -0000</pubDate>
  
  <!-- Nyaa custom elements -->
  <nyaa:seeders>42</nyaa:seeders>
  <nyaa:leechers>5</nyaa:leechers>
  <nyaa:downloads>123</nyaa:downloads>
  <nyaa:infoHash>abc123...</nyaa:infoHash>
  <nyaa:categoryId>1_2</nyaa:categoryId>
  <nyaa:category>Anime - English-translated</nyaa:category>
  <nyaa:size>410.1 MiB</nyaa:size>
  <nyaa:comments>0</nyaa:comments>
  <nyaa:trusted>Yes</nyaa:trusted>
  <nyaa:remake>No</nyaa:remake>
  
  <description><![CDATA[
    <a href="https://nyaa.si/view/{id}">#{id} | {title}</a> | {size} | {category} | {infohash}
  ]]></description>
</item>
```

### Field Reference

#### Standard RSS Fields

| Field | Type | Description |
|-------|------|-------------|
| `title` | string | Torrent name/release title |
| `link` | string | Direct download URL for .torrent file |
| `guid` | string | Permalink to the view page |
| `pubDate` | string | Upload date (RFC 822 format) |
| `description` | string | HTML summary (CDATA) |

#### Nyaa Custom Fields (`nyaa:*`)

| Field | Type | Description |
|-------|------|-------------|
| `nyaa:seeders` | integer | Number of seeders |
| `nyaa:leechers` | integer | Number of leechers |
| `nyaa:downloads` | integer | Download count |
| `nyaa:infoHash` | string | Torrent info hash (hex) - use to build magnet links |
| `nyaa:categoryId` | string | Category ID (e.g., `1_2`) |
| `nyaa:category` | string | Category name (e.g., "Anime - English-translated") |
| `nyaa:size` | string | File size (e.g., "410.1 MiB", "2.3 GiB") |
| `nyaa:comments` | integer | Number of comments |
| `nyaa:trusted` | string | "Yes" or "No" - trusted uploader status |
| `nyaa:remake` | string | "Yes" or "No" - remake/reencode flag |

---

## Magnet Links

The RSS feed does **not** include magnet links directly. However, you can construct them from the `nyaa:infoHash` field:

### Magnet Link Format

```
magnet:?xt=urn:btih:{info_hash}&dn={encoded_title}
```

### Example

Given RSS item:
```xml
<title>[EiGo] Kamen Rider Eins Extras</title>
<nyaa:infoHash>11663f715aa03e308672aae6eb0b77902b6a837d</nyaa:infoHash>
```

Construct magnet link:
```
magnet:?xt=urn:btih:11663f715aa03e308672aae6eb0b77902b6a837d&dn=%5BEiGo%5D+Kamen+Rider+Eins+Extras
```

### Implementation

```typescript
function buildMagnetLink(title: string, infoHash: string): string {
  const encodedTitle = encodeURIComponent(title);
  return `magnet:?xt=urn:btih:${infoHash}&dn=${encodedTitle}`;
}
```

---

## Example Requests

### Get Latest Torrents

```bash
curl "https://nyaa.si/?page=rss"
```

### Search by Query

```bash
curl "https://nyaa.si/?page=rss&q=attack+on+titan"
```

### Filter by Category

```bash
curl "https://nyaa.si/?page=rss&c=1_2"  # English-translated anime
```

### Filter by Uploader

```bash
curl "https://nyaa.si/?page=rss&u=seri"
```

### Trusted Uploads Only

```bash
curl "https://nyaa.si/?page=rss&f=1"
```

### Combined Filters

```bash
# Search "one piece", English anime, trusted only
curl "https://nyaa.si/?page=rss&q=one+piece&c=1_2&f=1"

# Specific uploader's English anime
curl "https://nyaa.si/?page=rss&u=horriblesubs&c=1_2"
```

---

## Entry Types (Visual Indicators)

| Type | Color | Description |
|------|-------|-------------|
| Trusted | Green | Uploaded by trusted user |
| Remake | Red | Reencode/remux/reupload of another release |
| Batch | Orange | Complete series batch |
| Hidden | Grey | Hidden torrent |

---

## Error Responses

The API returns HTTP status codes:

| Status | Description |
|--------|-------------|
| `200 OK` | Successful response |
| `404 Not Found` | Invalid uploader or category |
| `500 Internal Server Error` | Server error |

---

## Rate Limiting

No documented rate limits, but be respectful:
- Cache responses when possible
- Add delays between requests if polling
- Consider using the view page for detailed info instead of repeatedly hitting RSS

---

## Related Resources

- **Main site:** https://nyaa.si/
- **View page:** https://nyaa.si/view/{torrent_id}
- **Download:** https://nyaa.si/download/{torrent_id}.torrent
- **User profile:** https://nyaa.si/user/{username}

---

## Implementation Notes for Extensions

When building a pi extension for nyaa.si:

1. **Parse XML** with a proper RSS parser (fast-xml-parser, xml2js, etc.)
2. **Handle namespaces** - the `nyaa:` prefix is required for custom fields
3. **Size parsing** - sizes are human-readable (MiB, GiB, KiB)
4. **Date parsing** - use RFC 822 date parsing
5. **URL construction** - torrent files use `/download/{id}.torrent`
6. **Error handling** - 404 means invalid user/category, not empty results
