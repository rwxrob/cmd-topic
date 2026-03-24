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
| `PORT` | `8080` | `service-current-topic` |
| `TWITCH_POLL` | `60` | `service-current-topic` |
| `TWITCH_BROADCASTER_ID` | (required) | `topic`, `service-current-topic` |
| `YOUTUBE_BROADCAST_ID` | (auto-detected) | `topic` |
| `YOUTUBE_BROADCAST_STATUS` | `active` | `topic` |
| `YOUTUBE_TOKEN_FILE` | `~/.config/youtube/token.json` | `topic`, `cache-yt-token` |
| `YT_LOOPBACK_PORT` | `53682` | `cache-yt-token` |
| `OBS_WS_URL` | `ws://127.0.0.1:4455` | `service-rename-recording` |
| `OBS_WS_PASSWORD_FILE` | `~/.config/obs-websocket/password` | `service-rename-recording` |

## External tool dependencies

`twitch` CLI, `gh`, `jq`, `curl`, `nc`, `websocat`, `openssl`, `perl`, `git`

## Conventions

- `need cmd` — hard dependency check, exits with error if missing
- `have cmd` / `command -v cmd` — optional/soft check
- `mktemp` + `mv` for atomic file writes
- Coproc pattern (`coproc NETCAT { nc -l "$port"; }`) for the HTTP server loop
- Topic truncated to 140 chars when sent to Twitch

## Commit style

Conventional commits (`feat:`, `fix:`, `add`, etc.), short imperative subject
line. No Claude or AI attribution anywhere in commits, code, or issues.
