/**
 * Single Ctrl+C Exit Extension
 * 
 * Allows exiting pi with a single Ctrl+C when the editor is empty,
 * instead of requiring double Ctrl+C. When the editor has content,
 * Ctrl+C clears the text as normal.
 */

import { type ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.registerShortcut("ctrl+c", {
    description: "Exit if empty, else clear line",
    handler: async (ctx) => {
      const text = ctx.ui.getEditorText();
      if (!text.trim()) {
        // Buffer is empty -> Exit
        // We use shutdown() which is equivalent to the exit signal
        ctx.shutdown();
      } else {
        // Buffer has text -> Clear it
        ctx.ui.setEditorText("");
      }
    },
  });
}

/*
// Previous implementation using CustomEditor (broke autocomplete)
import { CustomEditor, type ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { matchesKey } from "@mariozechner/pi-tui";

class SingleCtrlCEditor extends CustomEditor {
  handleInput(data: string): void {
    if (matchesKey(data, "ctrl+c")) {
      const isEmpty = !this.getText().trim();
      super.handleInput(isEmpty ? "\x04" : data); // ctrl+d if empty, else clear
      if (!isEmpty) this.setText("");
      return;
    }
    super.handleInput(data);
  }
}

export default function (pi: ExtensionAPI) {
  pi.on("session_start", (_event, ctx) => {
    ctx.ui.setEditorComponent((tui, theme, kb) => new SingleCtrlCEditor(tui, theme, kb));
  });
}
*/
