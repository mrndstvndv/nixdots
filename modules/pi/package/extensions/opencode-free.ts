/**
 * OpenCode Zen — Free MiniMax M2.5 Access
 *
 * Registers the OpenCode Zen provider with the free MiniMax M2.5 model.
 * Uses public anonymous access when OPENCODE_API_KEY is not set (free models only).
 * Set OPENCODE_API_KEY to unlock paid models on the same endpoint.
 *
 * Usage: /model → opencode-zen/minimax-m2.5-free
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent"

export default function (pi: ExtensionAPI) {
  // Mirrors OpenCode's own auth logic: fall back to "public" for free-tier access
  const apiKey = process.env.OPENCODE_API_KEY ?? "public"

  pi.registerProvider("opencode-zen", {
    baseUrl: "https://opencode.ai/zen/v1",
    apiKey,
    api: "openai-completions",
    models: [
      {
        id: "minimax-m2.5-free",
        name: "MiniMax M2.5 Free",
        reasoning: false,
        input: ["text"],
        cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
        contextWindow: 204800,
        maxTokens: 16384,
        compat: {
          supportsDeveloperRole: false,
          maxTokensField: "max_tokens",
        },
      },
    ],
  })
}
