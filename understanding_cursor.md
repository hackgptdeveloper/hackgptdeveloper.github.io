
Cursor Agent
  v2026.07.09-a3815c0
  Tip: Use /config to customize Cursor settings and behavior.

                                                                                                                                                                                                                                                                                                                     
  give a good detail explanation of every files in this directory and its subdirectories.                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                                                                                     

  Exploring the workspace directory structure and reading key files to produce a detailed explanation of each one.

    Globbed "**/*" in .
    Found 148 files

  $ find /home/ubuntu/.cursor -type f 2>/dev/null | head -500 | sort 1.3s
    … 186 output lines hidden · ctrl+o to expand
    /home/ubuntu/.cursor/skills-cursor/update-cursor-settings/SKILL.md
    /home/ubuntu/.cursor/statsig-cache.json

  Reading representative files from each major section to explain their purpose and structure.

    Read 8 files
    … 5 earlier items hidden
    Read .../2da7b294-0888-4db6-bb49-8aff431c9089/meta.json
    Read ...0888-4db6-bb49-8aff431c9089/prompt_history.json
    Read projects/home-ubuntu-cursor/.workspace-trusted

  $ find /home/ubuntu/.cursor -type d | sort && echo "---" && find /home/ubuntu/.cursor -type f | wc -l 420ms
    … 105 output lines hidden · ctrl+o to expand
    ---
    188

    Read 4 files
    Read ...9089/2da7b294-0888-4db6-bb49-8aff431c9089.jsonl
    Read projects/home-ubuntu-cursor/worker.log
    Read ...vault-PoC-dotnet-hashicorp/terminals/938586.txt
    Read statsig-cache.json

  $ sqlite3 /home/ubuntu/.cursor/ai-tracking/ai-code-tracking.db ".schema" 2>/dev/null | head -50 530ms

    Grepped, read 1 grep, 4 files
    … 2 earlier items hidden
    Used sdk
    Used create-hook
    Read tool output

  $ head -c 500 /home/ubuntu/.cursor/statsig-cache.json && echo "" && ls -la /home/ubuntu/.cursor/ai-tracking/ && file /home/ubuntu/.cursor/ai-tracking/ai-code-tracking.db && sqlite3 /home/ubuntu/.cursor/chats/5ffc83748f14b6c02cd2340bde70b055/2da7b294-0888-4db6-bb49-8aff431c9089/store.db ".tables"
    2>/dev/null exit 127 • 503ms
    … 4 output lines hidden · ctrl+o to expand
    -rw-r--r-- 1 ubuntu ubuntu 3399680 Jul 19 02:46 ai-code-tracking.db
    /home/ubuntu/.cursor/ai-tracking/ai-code-tracking.db: SQLite 3.x database, last written using SQLite version 3044002, file counter 565, database pages 830, 1st free page 203, free pages 64, cookie 0x19, schema 4, UTF-8, version-valid-for 565

    Globbed "**/*" in skills-cursor
    Found 18 files

  $ python3 -c "
    import sqlite3 396ms
    … 10 input + 8 output lines hidden · ctrl+o to expand
     table: blobs
     table: meta

    Read 13 files
    … 10 earlier items hidden
    Used review
    Used update-cursor-settings
    Read projects/home-ubuntu-tthvault/repo.json

  This is ~/.cursor — Cursor’s local data directory on your machine. It holds CLI/IDE configuration, synced built-in skills, chat session storage, per-workspace agent state, and analytics. There are 188 files total; many follow repeating patterns (UUID-named sessions, SQLite databases, logs). Below is a
  full breakdown by area.

  ────────────────────────────────────────

  High-level layout

  ~/.cursor/
  ├── cli-config.json              # CLI user settings & auth cache
  ├── agent-cli-state.json         # One-time CLI UI flags
  ├── statsig-cache.json           # Feature-flag cache (Statsig)
  ├── ai-tracking/                 # AI code attribution tracking DB
  ├── chats/                       # Chat UI state (per workspace)
  ├── projects/                    # Agent runtime state (per opened folder)
  └── skills-cursor/               # Built-in Cursor Agent Skills (synced from server)

  ┌──────────────────────────────────────────────────────────────────────────────┐ ┌──────────────────────────────────────────────────────┬───────────────────────────────────────────────────────────────────────────────────────────────────────┐
  │                                 Root config                                  │ │                       chats/                         │                   projects/                                                                           │
  │                                                                              │ │                                                      │                                                                                                       │
  │                                                                              │ │                                                      │                                                                                                       │
  │ ┌─────────────────┐   ┌───────────────────────────┐   ┌────────────────────┐ │ ├───────────┐   ┌─────────────────────┐   ┌──────────┐ │ ┌───────────┐   ┌────────────────────┐   ┌────────────┐   ┌─────────────────┐   ┌───────────────────┐ │ ┌───────┐
  │ │                 │   │                           │   │                    │ │ │           │   │                     │   │          │ │ │           │   │                    │   │            │   │                 │   │                   │ │ │       │
  │ │ cli-config.json │   │    agent-cli-state.json   │   │ statsig-cache.json │ │ │ meta.json │   │ prompt_history.json │   │ store.db │ │ │ repo.json │   │ .workspace-trusted │   │ worker.log │   │ terminals/*.txt │   │ agent-tools/*.txt │ │ │ chats │
  │ │                 │   │                           │   │                    │ │ │           │   │                     │   │          │ │ │           │   │                    │   │            │   │                 │   │                   │ │ │       │
  │ └────────┬────────┘   └───────────────────────────┘   └────────────────────┘ │ ├───────────┘   └─────────────────────┘   └──────────┘ │ └───────────┘   └────────────────────┘   └────────────┘   └─────────────────┘   └───────────────────┘ │ └───┬───┘
  │          │                                                                   │ │                                                      │                                                                                                       │     │
  └──────────┼───────────────────────────────────────────────────────────────────┘ ├──────────────────────────────────────────────────────┘                                                                                                       │     │
             │                                                                     │                                                                                                                                                              │     │
             │                                                                     │                                                                                                                                                              │     │
             ▼                                                                     │                                                                                                                                                              │     │
    ┌─────────────────┐   ┌───────────────────────────┐                            │                                                                                                                                                              │     │
    │                 │   │                           │                            │                                                                                                                                                              │     │
    │     projects    │   │ agent-transcripts/*.jsonl │◄───────────────────────────┼──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┼─────┘
    │                 │   │                           │                            │                                                                                                                                                              │
    └─────────────────┘   └───────────────────────────┘                            │                                                                                                                                                              │
                                                                                   │                                                                                                                                                              │
                                                                                   └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
  ctrl+o to show source

  ────────────────────────────────────────

  Root-level files

  cli-config.json

  Main Cursor CLI configuration. Controls how the agent behaves on the command line.

  ┌──────────────────────────┬───────────────────────────────────────────────────────────────┐
  │ Section                  │ Purpose                                                       │
  ├──────────────────────────┼───────────────────────────────────────────────────────────────┤
  │ permissions.allow / deny │ Which shell commands the agent may run without extra approval │
  ├──────────────────────────┼───────────────────────────────────────────────────────────────┤
  │ editor.vimMode           │ Vim keybindings in the CLI                                    │
  ├──────────────────────────┼───────────────────────────────────────────────────────────────┤
  │ display.*                │ UI toggles (line numbers, thinking blocks, status line, etc.) │
  ├──────────────────────────┼───────────────────────────────────────────────────────────────┤
  │ model / selectedModel    │ Default AI model (e.g. Composer 2.5 Fast) and parameters      │
  ├──────────────────────────┼───────────────────────────────────────────────────────────────┤
  │ approvalMode             │ How strictly tool use is gated (unrestricted, etc.)           │
  ├──────────────────────────┼───────────────────────────────────────────────────────────────┤
  │ sandbox                  │ Sandbox mode for isolated command execution                   │
  ├──────────────────────────┼───────────────────────────────────────────────────────────────┤
  │ authInfo                 │ Cached login identity (email, display name, user ID)          │
  ├──────────────────────────┼───────────────────────────────────────────────────────────────┤
  │ privacyCache             │ Privacy/ghost mode settings                                   │
  ├──────────────────────────┼───────────────────────────────────────────────────────────────┤
  │ serverConfigCache        │ Cached backend URLs (api2.cursor.sh, agent endpoints)         │
  ├──────────────────────────┼───────────────────────────────────────────────────────────────┤
  │ attribution              │ Whether commits/PRs are attributed to the agent               │
  └──────────────────────────┴───────────────────────────────────────────────────────────────┘

  This is the file the update-cli-config skill edits.

  agent-cli-state.json

  Small CLI onboarding / migration flags, not general settings:

  • hasShownAgentCommandTip — whether the agent-command tip was shown
  • hasClearedLegacyStatsigFields — migration flag for old config fields

  statsig-cache.json

  Large (~537 KB) cached feature flags and experiments from Statsig (https://statsig.com). Cursor uses this to decide which features are enabled (experiments, dynamic configs, etc.) without hitting the network every time. Contains JSON like dynamic_configs, can_record_session, experiment groups, etc. Safe
  to treat as opaque cache; Cursor refreshes it periodically.

  ────────────────────────────────────────

  ai-tracking/

  ai-code-tracking.db

  SQLite database for AI code attribution / tracking — which code was AI-generated vs human-written.

  Tables:

  ┌────────────────────────┬────────────────────────────────────────────┐
  │ Table                  │ Likely purpose                             │
  ├────────────────────────┼────────────────────────────────────────────┤
  │ ai_code_hashes         │ Hashes of AI-generated code chunks         │
  ├────────────────────────┼────────────────────────────────────────────┤
  │ tracked_file_content   │ Snapshots/hashes of tracked file content   │
  ├────────────────────────┼────────────────────────────────────────────┤
  │ ai_deleted_files       │ Files removed that were previously tracked │
  ├────────────────────────┼────────────────────────────────────────────┤
  │ scored_commits         │ Commits scored for AI contribution         │
  ├────────────────────────┼────────────────────────────────────────────┤
  │ conversation_summaries │ Summaries linked to coding sessions        │
  ├────────────────────────┼────────────────────────────────────────────┤
  │ tracking_state         │ Internal sync/cursor state for the tracker │
  └────────────────────────┴────────────────────────────────────────────┘

  Used for analytics, attribution, and related product features — not something you normally edit by hand.

  ────────────────────────────────────────

  chats/ — chat session storage

  Organized as:

  chats/<workspace-hash>/<session-uuid>/
  ├── meta.json
  ├── prompt_history.json
  ├── store.db
  ├── store.db-shm    (optional, SQLite WAL)
  └── store.db-wal    (optional, SQLite WAL)

  The workspace hash (e.g. 5ffc83748f14b6c02cd2340bde70b055) identifies which folder you had open. The session UUID is one chat/conversation.

  Workspace folders in your tree

  ┌──────────────────────────────────┬──────────────────────────────────────────────────────┐
  │ Hash folder                      │ Associated workspace (inferred)                      │
  ├──────────────────────────────────┼──────────────────────────────────────────────────────┤
  │ 5ffc83748f14b6c02cd2340bde70b055 │ /home/ubuntu/.cursor (current)                       │
  ├──────────────────────────────────┼──────────────────────────────────────────────────────┤
  │ 7f7140f9ab86684b40aa95373a3bce0a │ /home/ubuntu/tthvault/PoC_dotnet_hashicorp           │
  ├──────────────────────────────────┼──────────────────────────────────────────────────────┤
  │ cdd2143e17dbaf8601c198b5900289d6 │ /home/ubuntu/tthvault/PoC_dotnet                     │
  ├──────────────────────────────────┼──────────────────────────────────────────────────────┤
  │ 96d7b0b89e83553e20e2e4a101bfa5e2 │ /home/ubuntu/tthvault/PoC_go                         │
  ├──────────────────────────────────┼──────────────────────────────────────────────────────┤
  │ e7a81946e3a063bdc2d9ffe2591cfacc │ /home/ubuntu/tthvault                                │
  ├──────────────────────────────────┼──────────────────────────────────────────────────────┤
  │ 0f55e2131922b905fb663eebc9baa90d │ (PoC dotnet hashicorp — alternate workspace binding) │
  ├──────────────────────────────────┼──────────────────────────────────────────────────────┤
  │ 8c74903ded871a6ec848c2b39eaca4e3 │ vault-cluster project                                │
  ├──────────────────────────────────┼──────────────────────────────────────────────────────┤
  │ dcf1cb88564cab74bbfd120b64688e93 │ partial/abandoned session (meta only)                │
  └──────────────────────────────────┴──────────────────────────────────────────────────────┘

  Per-session files

  meta.json — session metadata, e.g.:

  {
    "schemaVersion": 1,
    "createdAtMs": ...,
    "title": "Explain All Files",
    "cwd": "/home/ubuntu/.cursor",
    "hasConversation": true,
    "updatedAtMs": ...
  }

  prompt_history.json — array of user prompt strings for that session (command history / rewind).

  store.db — SQLite blob store for the chat UI (blobs, meta tables). Holds message content, attachments, and UI state in a structured way.

  store.db-shm / store.db-wal — SQLite Write-Ahead Log sidecar files when a session DB is actively open. Normal; do not delete while Cursor is running.

  ────────────────────────────────────────

  projects/ — agent runtime per workspace

  Each subfolder name encodes the workspace path: slashes become hyphens, e.g. home-ubuntu-tthvault-PoC-dotnet-hashicorp → /home/ubuntu/tthvault/PoC_dotnet_hashicorp.

  Your project folders

  ┌─────────────────────────────────────────────────────────┬────────────────────────────┐
  │ Folder                                                  │ Workspace                  │
  ├─────────────────────────────────────────────────────────┼────────────────────────────┤
  │ home-ubuntu                                             │ /home/ubuntu               │
  ├─────────────────────────────────────────────────────────┼────────────────────────────┤
  │ home-ubuntu-cursor                                      │ /home/ubuntu/.cursor       │
  ├─────────────────────────────────────────────────────────┼────────────────────────────┤
  │ home-ubuntu-tthvault                                    │ /home/ubuntu/tthvault      │
  ├─────────────────────────────────────────────────────────┼────────────────────────────┤
  │ home-ubuntu-tthvault-PoC-dotnet                         │ PoC .NET project           │
  ├─────────────────────────────────────────────────────────┼────────────────────────────┤
  │ home-ubuntu-tthvault-PoC-dotnet-hashicorp               │ PoC .NET + HashiCorp Vault │
  ├─────────────────────────────────────────────────────────┼────────────────────────────┤
  │ home-ubuntu-tthvault-PoC-dotnet-hashicorp-vault-cluster │ Vault cluster variant      │
  ├─────────────────────────────────────────────────────────┼────────────────────────────┤
  │ home-ubuntu-tthvault-PoC-go                             │ PoC Go project             │
  └─────────────────────────────────────────────────────────┴────────────────────────────┘

  Common files in each project

  repo.json — stable UUID for this workspace in Cursor’s indexing/sync system, e.g. {"id": "4df72b6c-6704-4e37-aab7-e63346182015"}.

  .workspace-trusted — records that you approved agent access to this folder:

  {
    "trustedAt": "2026-07-19T02:46:38.943Z",
    "workspacePath": "/home/ubuntu/.cursor"
  }

  worker.log — log from Cursor’s background indexing worker for that workspace: Merkle tree sync, file indexing, socket path (worker.sock), errors (e.g. npx not found). Useful for debugging indexing issues.

  agent-transcripts/<session-uuid>/<uuid>.jsonl — line-delimited JSON transcript of agent turns: user messages, assistant text, tool calls (Glob, Shell, Read, etc.). One file per agent session; this is what agents (and you) use to resume context. Format:

  {"role":"user","message":{"content":[{"type":"text","text":"..."}]}}
  {"role":"assistant","message":{"content":[{"type":"text","text":"..."},{"type":"tool_use","name":"Shell",...}]}}

  terminals/<id>.txt — snapshot of a shell session the agent started or monitored:

  ---
  pid: 87012
  cwd: "/home/ubuntu/tthvault/PoC_dotnet_hashicorp"
  command: "docker compose run --rm test 2>&1"
  started_at: 2026-07-13T09:45:30.822Z
  running_for_ms: 911214
  ---
  <terminal output>

  agent-tools/<uuid>.txt — captured output from long-running tool commands (e.g. full Docker/Vault test logs). Only present when output was too large or needed persistence beyond the terminal snapshot.

  ────────────────────────────────────────

  skills-cursor/ — built-in Agent Skills

  Synced from Cursor’s servers. Each skill is a folder with SKILL.md (YAML frontmatter + instructions). .sync-manifest.json tracks last sync time per skill.

  .sync-manifest.json

  Maps skill name → lastSyncedAt timestamp. Cursor uses this to know when to re-pull skills from the cloud.

  Individual skills

  ┌─────────────────────────┬─────────────────────────────────────────────────────────────────────────────────────┐
  │ Skill folder            │ What it does                                                                        │
  ├─────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────┤
  │ babysit/                │ Keeps a PR merge-ready: resolve conflicts, triage Bugbot/comments, fix CI in a loop │
  ├─────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────┤
  │ canvas/                 │ Builds interactive .canvas.tsx UIs beside the chat (IDE surface)                    │
  ├─────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────┤
  │ create-hook/            │ Creates Cursor hooks (hooks.json, scripts on agent events)                          │
  ├─────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────┤
  │ create-rule/            │ Creates Cursor rules (.cursor/rules/, AGENTS.md, coding standards)                  │
  ├─────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────┤
  │ create-skill/           │ Authoring guide for new SKILL.md files                                              │
  ├─────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────┤
  │ create-subagent/        │ Defines custom subagents (reviewers, debuggers, domain experts)                     │
  ├─────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────┤
  │ loop/                   │ Runs a prompt/skill on an interval (e.g. /loop 5m /foo); disabled in cloud          │
  ├─────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────┤
  │ migrate-to-skills/      │ Converts old .mdc rules and slash commands → skills format                          │
  ├─────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────┤
  │ review/                 │ Entry point to choose Bugbot vs Security Review                                     │
  ├─────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────┤
  │ review-bugbot/          │ Runs Bugbot-style code review subagent                                              │
  ├─────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────┤
  │ review-security/        │ Runs security-focused review subagent                                               │
  ├─────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────┤
  │ sdk/                    │ Guide for Cursor SDK (@cursor/sdk, cursor-sdk) — programmatic agents                │
  ├─────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────┤
  │ shell/                  │ Executes text after /shell as a literal shell command                               │
  ├─────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────┤
  │ split-to-prs/           │ Splits a large change into smaller reviewable PRs                                   │
  ├─────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────┤
  │ statusline/             │ Configures custom CLI status line above the prompt                                  │
  ├─────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────┤
  │ update-cli-config/      │ Edits cli-config.json (permissions, sandbox, model, etc.)                           │
  ├─────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────┤
  │ update-cursor-settings/ │ Edits VS Code/Cursor settings.json (themes, format on save, etc.)                   │
  └─────────────────────────┴─────────────────────────────────────────────────────────────────────────────────────┘

  Each SKILL.md is markdown with frontmatter (name, description, sometimes disable-model-invocation, metadata.surfaces) plus step-by-step instructions the agent follows when the skill is triggered.

  ────────────────────────────────────────

  How the pieces connect

  1. You open a folder → Cursor creates projects/<encoded-path>/ with repo.json, starts worker.log indexing.
  2. You start a chat → chats/<hash>/<uuid>/ stores UI state; projects/.../agent-transcripts/ stores the agent log.
  3. The agent runs shell commands → output goes to terminals/*.txt (and sometimes agent-tools/*.txt).
  4. Skills in skills-cursor/ are loaded into the agent context when relevant.
  5. cli-config.json drives CLI behavior; ai-tracking/ and statsig-cache.json support product/analytics features.

  ────────────────────────────────────────

  What you can safely touch vs leave alone

  ┌────────────────────────────────────────────────────────────────────┬──────────────────────────────────────────────────────┐
  │ Safe to edit (with care)                                           │ Leave alone (managed by Cursor)                      │
  ├────────────────────────────────────────────────────────────────────┼──────────────────────────────────────────────────────┤
  │ cli-config.json (via CLI or skill)                                 │ statsig-cache.json                                   │
  ├────────────────────────────────────────────────────────────────────┼──────────────────────────────────────────────────────┤
  │ Custom skills you add under ~/.cursor/skills/ (not skills-cursor/) │ store.db, ai-code-tracking.db                        │
  ├────────────────────────────────────────────────────────────────────┼──────────────────────────────────────────────────────┤
  │ Rules in your project’s .cursor/rules/                             │ store.db-wal, store.db-shm while running             │
  ├────────────────────────────────────────────────────────────────────┼──────────────────────────────────────────────────────┤
  │                                                                    │ Most of chats/ and agent-transcripts/ (session data) │
  └────────────────────────────────────────────────────────────────────┴──────────────────────────────────────────────────────┘

  Note: skills-cursor/ is Cursor-managed — edits may be overwritten on sync. User-authored skills typically live in ~/.cursor/skills/ (not present in this tree yet).

  ────────────────────────────────────────

  Summary by file type (for the ~188 files)

  ┌──────────────────────┬─────────────────┬────────────────────────────────┐
  │ File pattern         │ Count (approx.) │ Role                           │
  ├──────────────────────┼─────────────────┼────────────────────────────────┤
  │ SKILL.md             │ 17              │ Built-in skill definitions     │
  ├──────────────────────┼─────────────────┼────────────────────────────────┤
  │ *.jsonl              │ ~25             │ Agent conversation transcripts │
  ├──────────────────────┼─────────────────┼────────────────────────────────┤
  │ meta.json            │ ~30             │ Chat session metadata          │
  ├──────────────────────┼─────────────────┼────────────────────────────────┤
  │ prompt_history.json  │ ~28             │ User prompt history per chat   │
  ├──────────────────────┼─────────────────┼────────────────────────────────┤
  │ store.db (+ WAL/SHM) │ ~30+            │ Chat blob storage              │
  ├──────────────────────┼─────────────────┼────────────────────────────────┤
  │ terminals/*.txt      │ ~20             │ Shell session captures         │
  ├──────────────────────┼─────────────────┼────────────────────────────────┤
  │ worker.log           │ 8               │ Per-workspace indexer logs     │
  ├──────────────────────┼─────────────────┼────────────────────────────────┤
  │ repo.json            │ 8               │ Workspace IDs                  │
  ├──────────────────────┼─────────────────┼────────────────────────────────┤
  │ .workspace-trusted   │ 5               │ Trust approvals                │
  ├──────────────────────┼─────────────────┼────────────────────────────────┤
  │ Root JSON + 1 DB     │ 4               │ Global config & tracking       │
  └──────────────────────┴─────────────────┴────────────────────────────────┘

  If you want, I can go deeper on one area — for example every session under PoC_dotnet_hashicorp, or the full schema inside store.db / ai-code-tracking.db.


