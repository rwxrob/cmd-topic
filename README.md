# 🟥 Simple Current Topic OBS Overlay

Vibe coded simple OBS browser overlay. I use this because I am frequently changing the title of the stream based on topic and make recordings to be uploaded.

- left: logo and link
- right: date and time
- center: current topic

Quick start:

1. Update `index.html` to have your link
2. Update the image
3. Add a browser source in OBS and center
4. Start `service-current-topic` to serve topic to OBS browser overlay
5. Start `service-rename-recording` rename recordings to current topic as slug
6. Change current topic with `topic` command (perhaps aliased to `t`)
7. Optionally record a video for that topic (renames video when stopped)
8. Upload video to YouTube

## Requirements

- [`twitch` CLI](https://github.com/twitchdev/twitch-cli)
- [`gh`](https://cli.github.com) authenticated with `gh auth login`
- [`websocat`](https://github.com/vi/websocat)
- `jq`, `curl`, `nc`, `openssl`, `perl`

## Setup

### Twitch

Find your broadcaster ID with `twitch api get users`, then export it:

```sh
export TWITCH_BROADCASTER_ID=12345678
```

Cache your token (opens browser for first-time auth):

```sh
cache-twitch-token
```

### YouTube

Place your OAuth client secret at `~/.config/youtube/client_secret.json`
(downloaded from Google Cloud Console), then:

```sh
cache-yt-token
```

Re-run whenever the token expires — it refreshes automatically if a valid
refresh token exists.

## Usage

```sh
topic <words...>       # set a new topic
topic -                # toggle back to previous topic
topic <issue-number>   # pull title from a GitHub issue in the current repo
```

Sets `~/.topics` and immediately syncs to Twitch title, YouTube live title,
and GitHub user status.

## Services

### service-current-topic

Serves the current topic as plain text on port 8080 (override with `PORT`).
Also subscribes to Twitch EventSub `channel.update` via WebSocket and
calls `topic` when the title changes, propagating it to all platforms.

Requires `TWITCH_BROADCASTER_ID` for Twitch polling.

### service-rename-recording

Connects to OBS via WebSocket and renames completed recordings to a slug of
the current topic. Reconnects automatically on disconnect.

Connects to `ws://127.0.0.1:4455` by default (`OBS_WS_URL` to override).
Reads password from `~/.config/obs-websocket/password`
(`OBS_WS_PASSWORD_FILE` to override).

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `TOPICS` | `~/.topics` | Path to topics history file |
| `PORT` | `8080` | Port for `service-current-topic` |
| `TWITCH_BROADCASTER_ID` | (required) | Your Twitch broadcaster ID |
| `YOUTUBE_BROADCAST_ID` | (auto-detected) | Override YouTube broadcast ID |
| `YOUTUBE_BROADCAST_STATUS` | `active` | Broadcast lifecycle status to prefer |
| `YOUTUBE_TOKEN_FILE` | `~/.config/youtube/token.json` | YouTube token cache |
| `OBS_WS_URL` | `ws://127.0.0.1:4455` | OBS WebSocket URL |
| `OBS_WS_PASSWORD_FILE` | `~/.config/obs-websocket/password` | OBS WebSocket password file |
