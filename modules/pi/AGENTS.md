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
