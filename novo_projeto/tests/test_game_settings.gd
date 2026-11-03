extends SceneTree
const SETTINGS = preload("res://scripts/game_settings.gd")
func _initialize() -> void:
    call_deferred("run")
func run() -> void:
    var options := SETTINGS.defaults()
    assert(SETTINGS.is_valid(options))
    assert(not SETTINGS.is_valid({"resolution":"320x200","fullscreen":false,"muted":false}))
    assert(SETTINGS.write({"resolution":"1280x720","fullscreen":false,"muted":true}))
    var loaded := SETTINGS.read()
    assert(loaded["resolution"] == "1280x720")
    assert(loaded["muted"])
    assert(SETTINGS.write(SETTINGS.defaults()))
    var start = load("res://scenes/start.tscn").instantiate()
    root.add_child(start)
    await process_frame
    assert(start.panel != null)
    start._show_settings()
    assert(start.panel.get_child_count() >= 5)
    start._show_creation()
    assert(start.class_input.item_count == 4)
    start.queue_free()
    await process_frame
    print("TEST_GAME_SETTINGS_PASS")
    quit(0)
