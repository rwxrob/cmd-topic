# cmd-topic

Live streaming automation suite. Sets the current topic across Twitch,
YouTube, Restream, and GitHub status simultaneously. Serves the current
topic as an OBS browser overlay and renames recordings to topic slugs.

## Scripts

| Script | Description |
|--------|-------------|
| `topic` | Set current topic, sync to all platforms |
| `topicsd` | Daemon: HTTP topic overlay + OBS recording renamer + Twitch EventSub |
| `cache-twitch-token` | OAuth token cache for Twitch CLI |
| `cache-yt-token` | OAuth token cache for YouTube Data API |
| `cache-restream-token` | OAuth token cache for Restream.io API |

## Requirements

- [`fzf`](https://github.com/junegunn/fzf)
- [`twitch` CLI](https://github.com/twitchdev/twitch-cli)
- [`gh`](https://cli.github.com)
- [`websocat`](https://github.com/vi/websocat)
- `jq`, `curl`, `nc`, `openssl`, `perl`

## Setup

### Twitch

Find your broadcaster ID:

```sh
twitch api get users | jq -r '.data[0].id'
export TWITCH_BROADCASTER_ID=12345678
```

Cache credentials (opens browser on first run):

```sh
cache-twitch-token
```

Optionally configure category auto-set by copying and editing the sample:

```sh
cp categories.sample ~/.config/twitch/categories
```

The file is tab-separated `regex<TAB>category name` pairs matched
case-insensitively against the topic text.

### YouTube

Place your OAuth client secret at `~/.config/youtube/client_secret.json`
(downloaded from Google Cloud Console), then:

```sh
cache-yt-token
```

### Restream

Place your OAuth client secret at `~/.config/restream/client_secret.json`
(`{"client_id":"...","client_secret":"..."}`), then:

```sh
cache-restream-token
```

### OBS

Add a browser source pointing to `obs/index.html` (local file). Start
`topicsd` before going live — it serves the topic on port 8080 and
connects to OBS WebSocket to rename recordings.

Set your OBS WebSocket password:

```sh
echo 'yourpassword' > ~/.config/obs-websocket/password
```

## Usage

```sh
topic                  # interactive fzf menu from topic history
topic <words...>       # set a new topic
topic -                # switch back to previous topic
topic <issue-number>   # use a GitHub issue title from the current repo
```

Saves to `~/.topics` (full history, most recent first, deduped) and
syncs to Twitch, YouTube live broadcast, Restream channels, and GitHub
user status.

## topicsd

Single daemon replacing the two former services. Start it before going live:

```sh
topicsd &
```

- Serves current topic as plain text on `http://localhost:8080`
- Subscribes to Twitch EventSub `channel.update` via WebSocket — calls
  `topic` when the stream title changes externally (e.g. from Twitch dashboard)
- Connects to OBS WebSocket and renames completed recordings to a slug
  of the current topic

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `TOPICS` | `~/.topics` | Path to topics history file |
| `PORT` | `8080` | HTTP port for topic overlay |
| `TWITCH_BROADCASTER_ID` | (required) | Your Twitch broadcaster ID |
| `TWITCH_CATEGORIES_FILE` | `~/.config/twitch/categories` | Regex-to-category map |
| `OBS_WS_URL` | `ws://127.0.0.1:4455` | OBS WebSocket URL |
| `OBS_WS_PASSWORD_FILE` | `~/.config/obs-websocket/password` | OBS WebSocket password |
| `YOUTUBE_BROADCAST_ID` | (auto-detected) | Override YouTube broadcast ID |
| `YOUTUBE_BROADCAST_STATUS` | `active` | Lifecycle status to prefer when searching |
| `YOUTUBE_TOKEN_FILE` | `~/.config/youtube/token.json` | YouTube token cache |
| `RESTREAM_TOKEN_FILE` | `~/.config/restream/token.json` | Restream token cache |
