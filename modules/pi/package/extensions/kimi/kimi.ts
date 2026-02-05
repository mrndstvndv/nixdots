import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import type { OAuthCredentials, OAuthLoginCallbacks } from "@mariozechner/pi-ai";

const DEFAULT_BASE_URL = "https://api.kimi.com/coding/v1";
const DEFAULT_USER_AGENT = "KimiCLI/1.8.0";

function normalizeBaseUrl(rawUrl?: string): string {
  if (!rawUrl) return DEFAULT_BASE_URL;
  let baseUrl = rawUrl.trim();
  if (baseUrl.endsWith("/coding")) {
    baseUrl += "/v1";
  } else if (baseUrl.endsWith("/coding/")) {
    baseUrl += "v1";
  }
  return baseUrl;
}

export default function (pi: ExtensionAPI) {
  const kimiBaseUrl = process.env.KIMI_BASE_URL || process.env.MOONSHOT_BASE_URL;
  const anthropicBaseUrl = process.env.ANTHROPIC_BASE_URL;
  const baseUrl = normalizeBaseUrl(
    kimiBaseUrl || (anthropicBaseUrl?.includes("api.kimi.com/coding") ? anthropicBaseUrl : undefined)
  );
  const userAgent = (process.env.KIMI_USER_AGENT || DEFAULT_USER_AGENT).trim();

  pi.registerProvider("kimi", {
    baseUrl,
    api: "openai-completions",
    
    oauth: {
      name: "Kimi Code",
      
      async login(callbacks: OAuthLoginCallbacks): Promise<OAuthCredentials> {
        const apiKey = await callbacks.onPrompt({ 
          message: "Enter your Kimi Code API Key (starts with sk-kimi-):" 
        });

        return {
          refresh: apiKey,
          access: apiKey,
          expires: Date.now() + 1000 * 60 * 60 * 24 * 365 * 10
        };
      },

      async refreshToken(credentials: OAuthCredentials): Promise<OAuthCredentials> {
        return {
          refresh: credentials.refresh,
          access: credentials.refresh,
          expires: Date.now() + 1000 * 60 * 60 * 24 * 365 * 10
        };
      },

      getApiKey(credentials: OAuthCredentials): string {
        return credentials.access;
      }
    },

    headers: userAgent ? {
      "User-Agent": userAgent,
      "x-kimi-agent": "kimi-cli"
    } : undefined,

    models: [
      {
        id: "kimi-for-coding",
        name: "Kimi for Coding",
        reasoning: true,
        input: ["text"],
        cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
        contextWindow: 262144,
        maxTokens: 32768,
        compat: {
          maxTokensField: "max_tokens",
          supportsDeveloperRole: false,
          supportsStore: false
        }
      },
      {
        id: "kimi-k2.5",
        name: "Kimi K2.5",
        reasoning: true,
        input: ["text", "image"],
        cost: { input: 0.6, output: 3.0, cacheRead: 0.1, cacheWrite: 0.6 },
        contextWindow: 262144,
        maxTokens: 32768,
        compat: {
          thinkingFormat: "zai",
          maxTokensField: "max_tokens",
          supportsDeveloperRole: false,
          supportsStore: false
        }
      },
      {
        id: "kimi-latest",
        name: "Kimi Latest",
        reasoning: false,
        input: ["text", "image"],
        cost: { input: 1.0, output: 3.0, cacheRead: 0.15, cacheWrite: 1.0 },
        contextWindow: 131072,
        maxTokens: 131072,
        compat: {
          maxTokensField: "max_tokens",
          supportsDeveloperRole: false,
          supportsStore: false
        }
      },
      {
        id: "kimi-k2-turbo-preview",
        name: "Kimi K2 Turbo",
        reasoning: false,
        input: ["text"],
        cost: { input: 1.15, output: 8.0, cacheRead: 0.15, cacheWrite: 1.15 },
        contextWindow: 262144,
        maxTokens: 32768,
        compat: {
          maxTokensField: "max_tokens",
          supportsDeveloperRole: false,
          supportsStore: false
        }
      },
      {
        id: "kimi-k2-thinking",
        name: "Kimi K2 Thinking",
        reasoning: true,
        input: ["text"],
        cost: { input: 0.6, output: 2.5, cacheRead: 0.15, cacheWrite: 0.6 },
        contextWindow: 262144,
        maxTokens: 32768,
        compat: {
          thinkingFormat: "zai",
          maxTokensField: "max_tokens",
          supportsDeveloperRole: false,
          supportsStore: false
        }
      },
      {
        id: "moonshot-v1-8k",
        name: "Moonshot V1 8K",
        reasoning: false,
        input: ["text"],
        cost: { input: 0.2, output: 2.0, cacheRead: 0.2, cacheWrite: 0.2 },
        contextWindow: 8192,
        maxTokens: 8192,
        compat: {
          maxTokensField: "max_tokens",
          supportsDeveloperRole: false,
          supportsStore: false
        }
      },
      {
        id: "moonshot-v1-32k",
        name: "Moonshot V1 32K",
        reasoning: false,
        input: ["text"],
        cost: { input: 1.0, output: 3.0, cacheRead: 1.0, cacheWrite: 1.0 },
        contextWindow: 32768,
        maxTokens: 32768,
        compat: {
          maxTokensField: "max_tokens",
          supportsDeveloperRole: false,
          supportsStore: false
        }
      },
      {
        id: "moonshot-v1-128k",
        name: "Moonshot V1 128K",
        reasoning: false,
        input: ["text"],
        cost: { input: 2.0, output: 5.0, cacheRead: 2.0, cacheWrite: 2.0 },
        contextWindow: 131072,
        maxTokens: 131072,
        compat: {
          maxTokensField: "max_tokens",
          supportsDeveloperRole: false,
          supportsStore: false
        }
      }
    ]
  });
}
