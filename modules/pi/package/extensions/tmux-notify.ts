import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.on("agent_end", async (_event, ctx) => {
    // Only run if we are inside a tmux session
    if (!process.env.TMUX) return;

    const entries = ctx.sessionManager.getBranch();
    let lastUserMessage = "Task completed";

    // Find the last user message that started this agent run
    for (let i = entries.length - 1; i >= 0; i--) {
      const entry = entries[i];
      if (entry.type === "message" && entry.message.role === "user") {
        const content = entry.message.content;
        if (Array.isArray(content)) {
          const textPart = content.find((p) => p.type === "text");
          if (textPart && "text" in textPart) {
            lastUserMessage = textPart.text;
          }
        } else if (typeof content === "string") {
          lastUserMessage = content;
        }
        break;
      }
    }

    // Clean and truncate message for the tmux status line
    const maxLength = 60;
    const cleanMessage = lastUserMessage.replace(/\n/g, " ").trim();
    const displayMessage = cleanMessage.length > maxLength 
      ? cleanMessage.substring(0, maxLength - 3) + "..." 
      : cleanMessage;

    try {
      // Show message in tmux status bar (non-intrusive)
      await pi.exec("tmux", ["display-message", "-d", "2500", `Pi: ${displayMessage}`]);
      
      // Also send a bell character
      process.stdout.write("\x07");
    } catch (e) {
      // Silently fail if tmux command is not available
    }
  });
}
