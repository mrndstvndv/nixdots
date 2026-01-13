import type { Plugin } from "@opencode-ai/plugin"

const NTFY_URL = "http://localhost:80/oc"

const notify = async (title: string, message: string, tags?: string) => {
  await fetch(NTFY_URL, {
    method: "POST",
    body: message,
    headers: {
      Title: title,
      ...(tags && { Tags: tags }),
    },
  })
}

export const NotifyPlugin: Plugin = async () => {
  return {
    event: async ({ event }) => {
      switch (event.type) {
        case "session.idle":
          await notify("OpenCode", "Session completed", "heavy_check_mark")
          break

        case "session.error":
          await notify("OpenCode", "Session error", "warning")
          break

        case "permission.asked":
          const perm = event.properties as { permission: string; patterns: string[] }
          await notify(
            "OpenCode",
            `Permission: ${perm.permission} for ${perm.patterns[0] || "unknown"}`,
            "lock"
          )
          break
      }
    },
  }
}
