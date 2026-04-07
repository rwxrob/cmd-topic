# AGENTS.md

Live streaming automation scripts for rwxrob. All scripts are plain bash
(`set -euo pipefail`). No build system, no tests, no dependencies to install.

## Purpose

Keeps a "current topic" in sync across Twitch stream title, YouTube live
title, GitHub user status, OBS overlay, and OBS recording filenames.

## State file

`~/.topics` (overridden by `TOPICS` or `TOPIC` env vars):

- Line 1: current topic
- Line 2: previous topic (used by `topic -` to toggle back)

## Scripts

| Script | What it does |
|--------|-------------|
| `topic` | Sets current topic, syncs to Twitch, YouTube, GitHub status |
| `topicsd` | Daemon: HTTP server + Twitch EventSub + OBS watcher + clips syncer |
| `category` | fzf-based Twitch category picker; sets category and updates local cache |
| `clips` | sqlite3 wrapper for `clips.db`; always regenerates weighted-shuffled `clips.m3u` |
| `sync-clips` | Fetches all Twitch clips, downloads MP4s, manages `clips.db` and `clips.m3u` |
| `what` | Prints current topic + live Twitch category; pbcopy of topic |
| `setup-categories` | Symlinks `~/.config/twitch/categories` to `categories.sample` in repo |
| `service-current-topic` | HTTP server (default port 8080) serving line 1 of `~/.topics`; background poller syncs Twitch title changes into the file |
| `service-rename-recording` | Watches OBS via WebSocket; renames recordings to a slug of the current topic when recording stops |
| `cache-twitch-token` | Refreshes/caches Twitch OAuth token via `twitch` CLI |
| `cache-yt-token` | Refreshes/caches YouTube OAuth token; opens browser for first-time auth |
| `test-yt-lookup` | Manual test: dumps live YouTube broadcasts as JSON |

## OBS overlay

`obs/index.html` — browser source that polls `http://127.0.0.1:8080` every
second and displays the topic in a top bar alongside a clock and logo.

## Environment variables

| Variable | Default | Used by |
|----------|---------|---------|
| `TOPICS` / `TOPIC` | `~/.topics` | all scripts |
| `PORT` | `8080` | `topicsd` |
| `TWITCH_POLL` | `60` | `topicsd` |
| `TWITCH_BROADCASTER_ID` | (required) | `topic`, `topicsd`, `sync-clips` |
| `YOUTUBE_BROADCAST_ID` | (auto-detected) | `topic` |
| `YOUTUBE_BROADCAST_STATUS` | `active` | `topic` |
| `YOUTUBE_TOKEN_FILE` | `~/.config/youtube/token.json` | `topic`, `cache-yt-token` |
| `YT_LOOPBACK_PORT` | `53682` | `cache-yt-token` |
| `OBS_WS_URL` | `ws://127.0.0.1:4455` | `topicsd` |
| `OBS_WS_PASSWORD_FILE` | `~/.config/obs-websocket/password` | `topicsd` |
| `CLIPS_DIR` | `~/.clips` | `sync-clips`, `clips`, `topicsd` |
| `CLIPS_SYNC_INTERVAL` | `3600` | `topicsd` |
| `OBS_CLIPS_SCENE` | `Clips` | `topicsd` |
| `OBS_BELABOX_SOURCE` | `belabox` | `topicsd` |
| `OBS_VLC_SOURCE` | `clips` | `topicsd` |
| `OBS_CLIPS_REWARD` | `play clip` | `topicsd` |

## External tool dependencies

`twitch` CLI, `gh`, `jq`, `curl`, `nc`, `websocat`, `openssl`, `perl`, `git`, `sqlite3` (pre-installed on macOS), `fzf`

## Conventions

- `need cmd` — hard dependency check, exits with error if missing
- `have cmd` / `command -v cmd` — optional/soft check
- `mktemp` + `mv` for atomic file writes
- Coproc pattern (`coproc NETCAT { nc -l "$port"; }`) for the HTTP server loop
- Topic truncated to 140 chars when sent to Twitch
- `clips.db` SQLite schema uses `INSERT OR IGNORE` on `twitch_id` to preserve stable integer `id`
- Weighted shuffle: `perl -MList::Util=shuffle` (not `shuf`, which is GNU-only)
- OBS clips scene auto-switch: `eventSubscriptions:324` (64=Outputs + 256=MediaInputs + 4=Scenes)
- Clip request IPC: `$CLIPS_DIR/clip-request` temp file written by EventSub, read by OBS watcher

## Commit style

Conventional commits (`feat:`, `fix:`, `add`, etc.), short imperative subject
line. No Claude, Copilot, or AI attribution anywhere in commits, code, or issues.
