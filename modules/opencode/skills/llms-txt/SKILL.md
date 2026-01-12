---
name: llms-txt
description: Generate llms.txt files for documentation following the llmstxt.org specification. Creates LLM-friendly markdown summaries with curated links and optional .md versions of key pages. Use when documenting projects, libraries, APIs, or websites for AI consumption.
license: MIT
compatibility: opencode
metadata:
  author: steven
  version: "1.0"
---

# llms.txt Generator

Generate LLM-friendly documentation files following the [llmstxt.org](https://llmstxt.org) specification.

## When to Use This Skill

Invoke this skill when you need to:
- Create an `llms.txt` file for a project, library, or website
- Make documentation more accessible to LLMs and AI coding assistants
- Generate `.md` versions of key documentation pages
- Curate and organize documentation for context window efficiency

## The llms.txt Format

The file must follow this exact structure:

```markdown
# Project Name

> Brief summary describing the project and key information needed to understand the rest of the file.

Optional detailed notes, caveats, or important context (paragraphs, lists, etc. - NO headings).

## Section Name

- [Link Title](https://url): Optional description of what this link contains

## Another Section

- [Another Link](https://url)

## Optional

- [Secondary Resource](https://url): Less critical information that can be skipped for shorter context
```

### Format Rules

1. **H1 (Required)**: Project or site name - only one, at the top
2. **Blockquote (Optional)**: Short summary with key information
3. **Body Content (Optional)**: Additional context, NO headings allowed here
4. **H2 Sections**: Each contains a file list with markdown links
5. **Optional Section**: Special section for secondary information that can be skipped

### Link Format

```markdown
- [Display Name](url): Optional description
```

- The URL is required
- The colon and description are optional
- Each link must be a list item

## Workflow

### Step 1: Analyze the Source

**For Web Documentation:**
1. Fetch the main documentation URL
2. Identify the site structure (navigation, sections, key pages)
3. Find the most important pages for understanding the project

**For Local Files:**
1. Explore the repository structure
2. Look for existing docs (`docs/`, `README.md`, etc.)
3. Identify key source files, examples, and configuration

### Step 2: Create the H1 and Summary

```markdown
# FastHTML

> FastHTML is a python library which brings together Starlette, Uvicorn, HTMX, and fastcore's `FT` "FastTags" into a library for creating server-rendered hypermedia applications.
```

- Use the official project name
- Summary should be 1-3 sentences
- Include the most critical information for understanding context

### Step 3: Add Important Notes

After the blockquote, add any critical caveats or notes:

```markdown
Important notes:

- Although parts of its API are inspired by FastAPI, it is *not* compatible with FastAPI syntax
- FastHTML is compatible with JS-native web components but not with React, Vue, or Svelte
```

### Step 4: Organize into Sections

Common section names:
- `## Docs` - Main documentation
- `## API` - API reference
- `## Examples` - Code examples and tutorials
- `## Guides` - How-to guides
- `## Reference` - Technical reference material

### Step 5: Curate Links

For each section, select the most valuable resources:

```markdown
## Docs

- [Quick Start Guide](https://example.com/docs/quickstart.html.md): Overview of core features and basic usage
- [Configuration Reference](https://example.com/docs/config.html.md): All configuration options explained
```

**Best Practices:**
- Prefer `.md` URLs when available (append `.html.md` to HTML pages)
- Include descriptions for complex or non-obvious resources
- Limit to 5-10 links per section for context efficiency
- Order by importance (most critical first)

### Step 6: Add Optional Section

Place secondary resources in the `## Optional` section:

```markdown
## Optional

- [Full API Reference](https://example.com/api-full.md): Complete API documentation (large)
- [Changelog](https://example.com/changelog.md): Version history
- [Contributing Guide](https://example.com/contributing.md)
```

These can be skipped when a shorter context is needed.

## Creating .md Versions of Pages

When the source doesn't provide `.md` versions, create them:

1. Fetch the HTML page content
2. Convert to clean markdown (remove nav, ads, scripts)
3. Save at the same URL path with `.md` appended

Example: `quickstart.html` -> `quickstart.html.md`

For URLs without file extensions, append `index.html.md`:
- `https://example.com/docs/` -> `docs/index.html.md`

## Output Checklist

Before finalizing, verify:

- [ ] H1 contains the project name
- [ ] Blockquote summary is concise and informative
- [ ] No headings in the body content (before first H2)
- [ ] All H2 sections contain file lists
- [ ] Links use proper markdown format: `[name](url)`
- [ ] Optional section contains secondary resources
- [ ] Total context fits reasonably in an LLM context window

## Example Output

```markdown
# Anthropic API

> The Anthropic API provides access to Claude, a family of large language models optimized for safety and helpfulness.

Key information:
- Base URL: https://api.anthropic.com
- Authentication: API key via `x-api-key` header
- Current models: claude-3-opus, claude-3-sonnet, claude-3-haiku

## Docs

- [Getting Started](https://docs.anthropic.com/getting-started.html.md): API setup and first request
- [Messages API](https://docs.anthropic.com/messages.html.md): Core API for conversations
- [Vision](https://docs.anthropic.com/vision.html.md): Using images with Claude

## Examples

- [Python SDK](https://github.com/anthropics/anthropic-sdk-python): Official Python client with examples
- [Cookbook](https://github.com/anthropics/anthropic-cookbook): Practical implementation patterns

## Optional

- [Rate Limits](https://docs.anthropic.com/rate-limits.html.md): API rate limiting details
- [Error Codes](https://docs.anthropic.com/errors.html.md): Error handling reference
```

## Tips

1. **Be Selective**: LLMs work better with curated, high-quality content than exhaustive lists
2. **Frontload Value**: Put the most important information and links first
3. **Use Descriptions**: Help the LLM understand what each resource contains
4. **Test It**: Try using the generated llms.txt with an LLM to verify it provides useful context
5. **Keep It Updated**: Regenerate when documentation changes significantly
