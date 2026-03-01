/**
 * Git Undo Extension
 *
 * Automatically creates git checkpoints before each turn and provides undo functionality.
 * When you undo, it navigates back to the previous state and restores your code.
 *
 * Usage:
 *   /undo              - Undo the last turn (with confirmation)
 *   /undo --hard       - Undo without confirmation
 *   /undo-status       - Show checkpoint status
 */

import type { ExtensionAPI, SessionEntry } from "@mariozechner/pi-coding-agent";

interface Checkpoint {
	entryId: string;
	stashRef: string;
	message: string;
	timestamp: number;
}

const checkpoints = new Map<string, Checkpoint>();
let lastUserMessageId: string | undefined;

function findPreviousUserMessageEntry(
	sm: ExtensionAPI["sessionManager"],
	fromEntryId: string,
): SessionEntry | undefined {
	const entries = sm.getBranch();
	let foundCurrent = false;

	for (let i = entries.length - 1; i >= 0; i--) {
		const entry = entries[i];

		if (!foundCurrent) {
			if (entry.id === fromEntryId) {
				foundCurrent = true;
			}
			continue;
		}

		if (entry.type === "message" && entry.message.role === "user") {
			return entry;
		}
	}

	return undefined;
}

function getTurnDescription(sm: ExtensionAPI["sessionManager"], fromEntryId: string): string {
	const entries = sm.getBranch();
	let foundCurrent = false;
	const parts: string[] = [];

	for (let i = entries.length - 1; i >= 0; i--) {
		const entry = entries[i];

		if (!foundCurrent) {
			if (entry.id === fromEntryId) {
				foundCurrent = true;
			}
			continue;
		}

		if (entry.type === "message") {
			if (entry.message.role === "user") {
				const content =
					typeof entry.message.content === "string"
						? entry.message.content
						: entry.message.content.find((c) => c.type === "text")?.text || "(image)";
				parts.push(`User: ${content.slice(0, 60)}${content.length > 60 ? "..." : ""}`);
				break;
			} else if (entry.message.role === "assistant" && parts.length === 0) {
				const textContent = entry.message.content.find((c) => c.type === "text");
				if (textContent) {
					parts.push(`Assistant: ${textContent.text.slice(0, 60)}${textContent.text.length > 60 ? "..." : ""}`);
				}
			}
		}
	}

	return parts.join(" → ") || "last turn";
}

async function hasUncommittedChanges(): Promise<boolean> {
	try {
		const { stdout } = await pi.exec("git", ["status", "--porcelain"]);
		return stdout.trim().length > 0;
	} catch {
		return false;
	}
}

async function createCheckpoint(entryId: string, message: string): Promise<string | undefined> {
	try {
		const { stdout } = await pi.exec("git", ["stash", "create", "-m", `pi-checkpoint: ${message}`]);
		const ref = stdout.trim();
		if (ref) {
			checkpoints.set(entryId, {
				entryId,
				stashRef: ref,
				message,
				timestamp: Date.now(),
			});
			return ref;
		}
	} catch (error) {
		console.error("Failed to create checkpoint:", error);
	}
	return undefined;
}

export default function (pi: ExtensionAPI) {
	// Create checkpoint before each turn starts (before LLM can make changes)
	pi.on("turn_start", async (_event, ctx) => {
		if (!(await hasUncommittedChanges())) {
			return;
		}

		const leaf = ctx.sessionManager.getLeafEntry();
		if (!leaf) return;

		const checkpointMessage = `Before turn at ${new Date().toISOString()}`;
		await createCheckpoint(leaf.id, checkpointMessage);
	});

	// Track user messages for better undo descriptions
	pi.on("message_end", async (event, ctx) => {
		if (event.message.role === "user") {
			lastUserMessageId = ctx.sessionManager.getLeafEntry()?.id;
		}
	});

	// Undo command - navigate back and restore git state
	pi.registerCommand("undo", {
		description: "Undo last turn and restore git state",
		handler: async (args, ctx) => {
			const sm = ctx.sessionManager;
			const currentLeaf = sm.getLeafEntry();

			if (!currentLeaf) {
				ctx.ui.notify("No session to undo", "warning");
				return;
			}

			// Find the previous user message
			const previousUserEntry = findPreviousUserMessageEntry(sm, currentLeaf.id);

			if (!previousUserEntry) {
				ctx.ui.notify("Nothing to undo - at start of conversation", "warning");
				return;
			}

			// Get the parent of that user message (where we'll navigate to)
			const targetId = previousUserEntry.parentId;
			if (!targetId) {
				ctx.ui.notify("Cannot undo - no previous state", "warning");
				return;
			}

			// Describe what will be undone
			const turnDesc = getTurnDescription(sm, currentLeaf.id);

			// Check if we have a checkpoint for restoration
			const checkpoint = checkpoints.get(previousUserEntry.id);
			const hasCheckpoint = !!checkpoint?.stashRef;

			const hardMode = args.trim() === "--hard";

			// Only ask for confirmation if there are git changes to restore
			if (hasCheckpoint && !hardMode && ctx.hasUI) {
				const confirmed = await ctx.ui.confirm(
					"Confirm Undo",
					`Undo "${turnDesc}"?\n\nGit changes will be restored to before this turn.`,
				);

				if (!confirmed) {
					ctx.ui.notify("Undo cancelled", "info");
					return;
				}
			}

			// First, restore git state if we have a checkpoint
			if (hasCheckpoint) {
				try {
					// Check if there are uncommitted changes
					if (await hasUncommittedChanges()) {
						// Stash current changes first
						await pi.exec("git", ["stash", "push", "-m", "pi-undo-autostash"]);
					}

					// Apply the checkpoint stash
					const result = await pi.exec("git", ["stash", "store", checkpoint!.stashRef, "-m", "restored-by-pi-undo"]);
					if (result.code === 0) {
						await pi.exec("git", ["stash", "apply", checkpoint!.stashRef]);
					}
				} catch (error) {
					ctx.ui.notify(`Git restore warning: ${error}`, "warning");
				}
			}

			// Navigate to the target entry
			const result = await ctx.navigateTree(targetId, {
				summarize: false,
			});

			if (result.cancelled) {
				ctx.ui.notify("Undo cancelled", "info");
				return;
			}

			// Clean up checkpoints that are now in the future
			const targetEntry = sm.getEntry(targetId);
			if (targetEntry) {
				const targetTime = new Date(targetEntry.timestamp).getTime();
				for (const [id, cp] of checkpoints) {
					if (cp.timestamp > targetTime) {
						checkpoints.delete(id);
					}
				}
			}

			const msg = hasCheckpoint ? `Undone with git restore: ${turnDesc}` : `Undone: ${turnDesc}`;
			ctx.ui.notify(msg, "success");
		},
	});

	// Show checkpoint status
	pi.registerCommand("undo-status", {
		description: "Show git checkpoint status",
		handler: async (_args, ctx) => {
			const hasChanges = await hasUncommittedChanges();
			const cpCount = checkpoints.size;

			const lines = [
				`Uncommitted changes: ${hasChanges ? "yes" : "no"}`,
				`Checkpoints stored: ${cpCount}`,
				"",
				"Recent checkpoints:",
			];

			const sorted = Array.from(checkpoints.values())
				.sort((a, b) => b.timestamp - a.timestamp)
				.slice(0, 5);

			if (sorted.length === 0) {
				lines.push("  (none)");
			} else {
				for (const cp of sorted) {
					const time = new Date(cp.timestamp).toLocaleTimeString();
					lines.push(`  ${time} - ${cp.message.slice(0, 50)}`);
				}
			}

			if (ctx.hasUI) {
				ctx.ui.notify(lines.join("\n"), "info");
			} else {
				console.log(lines.join("\n"));
			}
		},
	});

	// Clear checkpoints on session shutdown
	pi.on("session_shutdown", async () => {
		checkpoints.clear();
		lastUserMessageId = undefined;
	});
}
