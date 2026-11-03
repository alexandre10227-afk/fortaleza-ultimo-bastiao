extends SceneTree

func _initialize() -> void:
    call_deferred("run")

func run() -> void:
    var profile = load("res://scripts/character_profile.gd")
    var state = root.get_node("GameState")
    var stats: Dictionary = profile.default_stats()
    assert(profile.points_remaining(stats) == 10)
    stats["Forca"] = 5
    stats["Destreza"] = 7
    assert(profile.points_remaining(stats) == 0)
    assert(profile.valid(stats, "Campones"))
    stats["Forca"] = 6
    assert(not profile.valid(stats, "Campones"))
    stats["Forca"] = 5
    assert(profile.final_stats(stats, "Campones")["Constituicao"] == 2)
    var start = load("res://scenes/start.tscn").instantiate()
    root.add_child(start)
    await process_frame
    assert(start.origin_input.item_count == 4)
    assert(start.appearance_input.item_count == 4)
    start.name_input.text = "Protagonista"
    start._stats = stats.duplicate(true)
    start._refresh_stats()
    start._create_character()
    assert(state.character_name == "Protagonista")
    assert(state.character_stats["Forca"] == 5)
    assert(state.character_origin in profile.ORIGINS.keys())
    assert(state.save_game())
    state.new_game("Reset", "Facil")
    assert(state.load_game())
    assert(state.character_name == "Protagonista")
    assert(state.character_stats["Destreza"] == 7)
    var sheet = load("res://scripts/character_sheet.gd").new()
    root.add_child(sheet)
    await process_frame
    sheet.open_sheet("Inventario")
    assert(sheet.visible)
    assert(sheet.page == "Inventario")
    sheet.show_page("Relacoes")
    assert(sheet.page == "Relacoes")
    sheet.show_page("Diario")
    assert(sheet.page == "Diario")
    sheet.hide_sheet()
    assert(not sheet.visible)
    sheet.queue_free()
    start.queue_free()
    await process_frame
    print("TEST_CHARACTER_PROFILE_PASS")
    quit(0)
