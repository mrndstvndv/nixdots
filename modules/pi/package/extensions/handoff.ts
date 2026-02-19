/**
 * Handoff extension - transfer context to a new focused session
 *
 * Instead of compacting (which is lossy), handoff extracts what matters
 * for your next task and creates a new session with a generated prompt.
 *
 * Usage:
 *   /handoff now implement this for teams as well
 *   /handoff execute phase one of the plan
 *   /handoff check other places that need this fix
 *
 * The generated prompt appears as a draft in the editor for review/editing.
 */

import { spawn } from "child_process";
import type { ExtensionAPI, SessionEntry } from "@mariozechner/pi-coding-agent";
import { BorderedLoader, convertToLlm, serializeConversation } from "@mariozechner/pi-coding-agent";

const SYSTEM_PROMPT = `You are a context transfer assistant. Given a conversation history and the user's goal for a new thread, generate a focused prompt that:

1. Summarizes relevant context from the conversation (decisions made, approaches taken, key findings)
2. Lists any relevant files that were discussed or modified
3. Clearly states the next task based on the user's goal
4. Is self-contained - the new thread should be able to proceed without the old conversation

Format your response as a prompt the user can send to start the new thread. Be concise but include all necessary context. Do not include any preamble like "Here's the prompt" - just output the prompt itself.

Example output format:
## Context
We've been working on X. Key decisions:
- Decision 1
- Decision 2

Files involved:
- path/to/file1.ts
- path/to/file2.ts

## Task
[Clear description of what to do next based on user's goal]`;

export default function (pi: ExtensionAPI) {
	pi.registerCommand("handoff", {
		description: "Transfer context to a new focused session",
		handler: async (args, ctx) => {
			if (!ctx.hasUI) {
				ctx.ui.notify("handoff requires interactive mode", "error");
				return;
			}

			const goal = args.trim();
			if (!goal) {
				ctx.ui.notify("Usage: /handoff <goal for new thread>", "error");
				return;
			}

			// Gather conversation context from current branch
			const branch = ctx.sessionManager.getBranch();
			const messages = branch
				.filter((entry): entry is SessionEntry & { type: "message" } => entry.type === "message")
				.map((entry) => entry.message);

			if (messages.length === 0) {
				ctx.ui.notify("No conversation to hand off", "error");
				return;
			}

			// Convert to LLM format and serialize
			const llmMessages = convertToLlm(messages);
			const conversationText = serializeConversation(llmMessages);
			const currentSessionFile = ctx.sessionManager.getSessionFile();

			// Generate the handoff prompt with loader UI
			const result = await ctx.ui.custom<string | null>((tui, theme, _kb, done) => {
				const loader = new BorderedLoader(tui, theme, "Starting Gemini CLI...");
				loader.onAbort = () => done(null);

				// Access the internal loader to update message dynamically
				const updateMessage = (msg: string) => {
					(loader as unknown as { loader: { setMessage: (m: string) => void } }).loader.setMessage(msg);
				};

				const doGenerate = async () => {
					const combinedPrompt = `${SYSTEM_PROMPT}\n\n## Conversation History\n\n${conversationText}\n\n## User's Goal for New Thread\n\n${goal}`;

					// Spawn gemini CLI with fixed model - use stdin for long prompt
					return new Promise<string>((resolve, reject) => {
						const child = spawn("gemini", ["-m", "gemini-3-flash-preview"], {
							stdio: ["pipe", "pipe", "pipe"],
						});

						let stdout = "";
						let stderr = "";

						// Update status: CLI started, now sending context
						updateMessage("Sending context...");

						// Kill child if loader is aborted
						if (loader.signal) {
							loader.signal.addEventListener("abort", () => child.kill());
						}

						child.stdout.on("data", (chunk: Buffer) => {
							stdout += chunk.toString();
						});

						child.stderr.on("data", (chunk: Buffer) => {
							stderr += chunk.toString();
						});

						child.on("error", (err: NodeJS.ErrnoException) => {
							if (err.code === "ENOENT") {
								reject(new Error("gemini CLI not found. Install from https://github.com/google-gemini/gemini-cli"));
								return;
							}
							reject(err);
						});

						child.on("close", (code) => {
							// Check for auth errors in stderr
							if (stderr && /auth|authenticate|not authenticated|unauthoriz|login/i.test(stderr)) {
								reject(new Error("Not authenticated. Run 'gemini auth login' first."));
								return;
							}

							if (code && code !== 0) {
								reject(new Error(stderr || `gemini exited with code ${code}`));
								return;
							}

							resolve(stdout.trim());
						});

						// Write prompt to stdin instead of using -p flag
						// This avoids ARG_MAX limits for long conversations
						child.stdin.write(combinedPrompt);
						child.stdin.end();

						// Update status: Context sent, now generating
						updateMessage("Generating handoff prompt...");
					});
				};

				doGenerate()
					.then(done)
					.catch((err) => {
						console.error("Handoff generation failed:", err);
						done(null);
					});

				return loader;
			});

			if (result === null) {
				ctx.ui.notify("Cancelled", "info");
				return;
			}

			// Let user edit the generated prompt
			const editedPrompt = await ctx.ui.editor("Edit handoff prompt", result);

			if (editedPrompt === undefined) {
				ctx.ui.notify("Cancelled", "info");
				return;
			}

			// Create new session with parent tracking
			const newSessionResult = await ctx.newSession({
				parentSession: currentSessionFile,
			});

			if (newSessionResult.cancelled) {
				ctx.ui.notify("New session cancelled", "info");
				return;
			}

			// Set the edited prompt in the main editor for submission
			ctx.ui.setEditorText(editedPrompt);
			ctx.ui.notify("Handoff ready. Submit when ready.", "info");
		},
	});
}
