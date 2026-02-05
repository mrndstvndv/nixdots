/**
 * Single Ctrl+C Exit Extension
 * 
 * Allows exiting pi with a single Ctrl+C when the editor is empty,
 * instead of requiring double Ctrl+C. When the editor has content,
 * Ctrl+C clears the text as normal.
 */

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
