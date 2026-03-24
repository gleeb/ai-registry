import type { Plugin } from "@opencode-ai/plugin"
import { writeFileSync, appendFileSync, mkdirSync, existsSync } from "fs"
import { join } from "path"

export const SdlcLogger: Plugin = async ({ directory, worktree }) => {
  const sdlcDir = join(worktree || directory, ".sdlc")
  const logFile = join(sdlcDir, "dispatch.log")

  const ensureLogDir = () => {
    if (!existsSync(sdlcDir)) {
      mkdirSync(sdlcDir, { recursive: true })
    }
  }

  const appendLog = (entry: Record<string, unknown>) => {
    ensureLogDir()
    const line = JSON.stringify({ ...entry, timestamp: new Date().toISOString() })
    appendFileSync(logFile, line + "\n")
  }

  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool === "task") {
        appendLog({
          event: "dispatch",
          agent: output.args?.agent || output.args?.type || "unknown",
          prompt_length: typeof output.args?.prompt === "string"
            ? output.args.prompt.length
            : 0,
          prompt_preview: typeof output.args?.prompt === "string"
            ? output.args.prompt.slice(0, 200)
            : "",
        })
      }
    },

    "tool.execute.after": async (input, output) => {
      if (input.tool === "task") {
        appendLog({
          event: "dispatch_complete",
          agent: input.args?.agent || input.args?.type || "unknown",
          result_length: typeof output === "string" ? output.length : 0,
          result_preview: typeof output === "string" ? output.slice(0, 200) : "",
        })
      }
    },

    event: async ({ event }) => {
      if (event.type === "session.idle") {
        appendLog({
          event: "session_idle",
          session_id: (event as any).properties?.sessionID || "unknown",
        })
      }
    },
  }
}
