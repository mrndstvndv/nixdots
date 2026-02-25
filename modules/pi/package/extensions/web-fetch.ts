import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";
import { Type } from "@sinclair/typebox";

const MARKDOWN_NEW_URL = "https://markdown.new/";

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "web_fetch",
    label: "Web Fetch",
    description: "Fetch a webpage and convert it to clean Markdown using markdown.new. Reduces tokens by ~80% compared to raw HTML. Use when the user wants to read a webpage, extract content from a URL, or when HTML would be too verbose.",
    parameters: Type.Object({
      url: Type.String({ description: "The URL to fetch and convert to markdown" }),
      method: Type.Optional(Type.Union([
        Type.Literal("auto"),
        Type.Literal("ai"),
        Type.Literal("browser")
      ], { description: "Conversion method: auto (default), ai (Workers AI), or browser (headless browser for JS-heavy sites)" })),
      retain_images: Type.Optional(Type.Boolean({ description: "Keep image references in the markdown (default: false)" })),
    }),

    async execute(toolCallId, params, signal, onUpdate, ctx) {
      const { url, method = "auto", retain_images = false } = params;

      onUpdate?.({ content: [{ type: "text", text: `Fetching ${url}...` }] });

      try {
        const response = await fetch(MARKDOWN_NEW_URL, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ url, method, retain_images }),
          signal,
        });

        if (!response.ok) {
          const rateLimitRemaining = response.headers.get("x-rate-limit-remaining");
          if (response.status === 429) {
            throw new Error("Rate limit exceeded (500 requests/day). Try again tomorrow.");
          }
          throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        const markdown = await response.text();
        const tokens = response.headers.get("x-markdown-tokens");

        const content = tokens
          ? `[Fetched ${url} - ${tokens} tokens]\n\n${markdown}`
          : `[Fetched ${url}]\n\n${markdown}`;

        return {
          content: [{ type: "text", text: content }],
          details: { url, method, tokens: tokens ? parseInt(tokens, 10) : undefined },
        };
      } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        return {
          content: [{ type: "text", text: `Failed to fetch ${url}: ${message}` }],
          details: { url, error: message },
          isError: true,
        };
      }
    },
  });

  pi.registerCommand("markdown", {
    description: "Fetch a URL and convert to markdown via markdown.new",
    handler: async (args, ctx) => {
      const url = args.trim();
      if (!url) {
        ctx.ui.notify("Usage: /markdown <url>", "error");
        return;
      }

      ctx.ui.notify(`Fetching ${url}...`, "info");

      try {
        const response = await fetch(MARKDOWN_NEW_URL, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ url, method: "auto", retain_images: false }),
        });

        if (!response.ok) {
          if (response.status === 429) {
            ctx.ui.notify("Rate limit exceeded (500 requests/day)", "error");
          } else {
            ctx.ui.notify(`Failed: HTTP ${response.status}`, "error");
          }
          return;
        }

        const markdown = await response.text();
        const tokens = response.headers.get("x-markdown-tokens");

        // Copy to clipboard if available, otherwise show preview
        const preview = markdown.slice(0, 500) + (markdown.length > 500 ? "..." : "");
        const tokenInfo = tokens ? ` (${tokens} tokens)` : "";

        ctx.ui.notify(`Fetched${tokenInfo}! Preview in console.`, "success");
        console.log(`\n--- ${url}${tokenInfo} ---\n${preview}\n`);
      } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        ctx.ui.notify(`Error: ${message}`, "error");
      }
    },
  });
}
