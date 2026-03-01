# Code Principles

## Philosophy
Sacrifice grammar for accuracy + conciseness. Context bloat matters. Be direct.

## Rules
- Guard clauses over if-else. Early returns. Avoid nesting.
- One function = one thing. Keep small.
- Names reveal intent. No abbreviations.
- DRY. Extract patterns.
- Fail fast. Clear errors.
- No `any`. Use proper types or `unknown`.
- Guard nulls early. Use `?.` and `??`.
- Self-documenting code. Comments explain "why" only.
- Test edge cases.
- Dont implement stuff or write code without the user explicitly saying you are allowed to. The default state is planning, after we make a plan ask the user if it's safe to procceed to writing code
- If you need to inspect a repo, clone it to ~/.pi/gh/ with --depth 1 if it doesn't already exist. Use the local clone for all subsequent searching and inspection.

## Example
```typescript
// Good
function process(user: User | null) {
  if (!user) return;
  if (!user.active) throw new Error("Inactive");
  if (user.age < 18) return handleMinor(user);
  
  processAdult(user);
}

// Bad - nested
function process(user: User | null) {
  if (user) {
    if (user.active) {
      if (user.age >= 18) {
        processAdult(user);
      }
    }
  }
}
```

## GitHub CLI
- Search: `gh search code --repo owner/repo "query"`
- Read: `gh api -H "Accept: application/vnd.github.v3.raw" /repos/owner/repo/contents/path/to/file`

## Search
- Web Search: `ddgr --json "query"`

## Tool Preferences
- Use `uv` instead of `python` (e.g., `uv run script.py`)
- Use `bun` instead of `node` or `npm`
- Use `bunx` instead of `npx`
- When moving or renaming files, prefer the shell mv command (via bash) instead of reading and rewriting files with tool calls — it saves tokens and preserves file metadata. Use read/edit/write only for content edits.

## Token Efficiency
- Never re-read files you just wrote or edited. You know the contents.
- Never re-run commands to "verify" unless the outcome was uncertain.
- Don't echo back large blocks of code or file contents unless asked.
- Batch related edits into single operations. Don't make 5 edits when 1 handles it.
- Skip confirmations like "I'll continue..."  Lust do it.
- If a task needs 1 tool call, don't use 3. Plan before acting.
- Do not summarize what you just did unless the result is ambiguous or you need additional input.
