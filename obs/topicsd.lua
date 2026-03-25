local obs = obslua
local topicsd_path = "topicsd"

function script_description()
    return "Starts topicsd when OBS opens and stops it when OBS closes."
end

function script_properties()
    local props = obs.obs_properties_create()
    obs.obs_properties_add_text(
        props, "topicsd_path", "Path to topicsd", obs.OBS_TEXT_DEFAULT)
    return props
end

function script_defaults(settings)
    obs.obs_data_set_default_string(settings, "topicsd_path", "topicsd")
end

function script_update(settings)
    topicsd_path = obs.obs_data_get_string(settings, "topicsd_path")
    if topicsd_path == "" then topicsd_path = "topicsd" end
end

function script_load(settings)
    topicsd_path = obs.obs_data_get_string(settings, "topicsd_path")
    if topicsd_path == "" then topicsd_path = "topicsd" end

    local cmd = string.format(
        "pgrep -f '%s' >/dev/null 2>&1 || '%s' &",
        topicsd_path, topicsd_path)
    os.execute(cmd)
end

function script_unload()
    os.execute(string.format("pkill -f '%s' 2>/dev/null", topicsd_path))
end
