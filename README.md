# 🟥 Simple Current Topic OBS Overlay

Vibe coded simple OBS browser overlay. I use this because I am frequently changing the title of the stream based on topic and make recordings to be uploaded.

- left: logo and link
- right: date and time
- center: current topic

Quick start:

1. Update `index.html` to have your link
2. Update the image
3. Add a browser source in OBS and center
4. Start `service-current_topic` to serve topic to OBS browser overlay
5. Start `service-rename-recording` rename recordings to current topic as slug
6. Change current topic with `topic` command (perhaps aliased to `t`)
7. Optionally record a video for that topic (renames video when stopped)
8. Upload video to YouTube
