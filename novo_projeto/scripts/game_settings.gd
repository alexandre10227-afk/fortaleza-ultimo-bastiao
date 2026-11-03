extends RefCounted
const SETTINGS_FILE := "user://fortaleza_options.json"
const RESOLUTIONS := ["1200x720", "1280x720", "1600x900"]
static func defaults() -> Dictionary:
    return {"resolution":"1200x720","fullscreen":false,"muted":false}

static func is_valid(options: Dictionary) -> bool:
    return RESOLUTIONS.has(str(options.get("resolution",""))) and options.get("fullscreen", null) is bool and options.get("muted", null) is bool

static func read() -> Dictionary:
    if not FileAccess.file_exists(SETTINGS_FILE):
        return defaults()
    var file := FileAccess.open(SETTINGS_FILE,FileAccess.READ)
    if file == null:
        return defaults()
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    return parsed if parsed is Dictionary and is_valid(parsed) else defaults()

static func write(options: Dictionary) -> bool:
    if not is_valid(options):
        return false
    var file := FileAccess.open(SETTINGS_FILE,FileAccess.WRITE)
    if file == null:
        return false
    file.store_string(JSON.stringify(options))
    return true

static func apply(options: Dictionary) -> bool:
    if not is_valid(options):
        return false
    var parts := str(options["resolution"]).split("x")
    DisplayServer.window_set_size(Vector2i(int(parts[0]), int(parts[1])))
    DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if bool(options["fullscreen"]) else DisplayServer.WINDOW_MODE_WINDOWED)
    AudioServer.set_bus_mute(0, bool(options["muted"]))
    return true
