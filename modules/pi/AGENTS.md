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

## Tool Preferences
- Use `uv` instead of `python` (e.g., `uv run script.py`)
- Use `bun` instead of `node` or `npm`
- Use `bunx` instead of `npx`
