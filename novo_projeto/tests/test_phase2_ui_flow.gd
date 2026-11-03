extends SceneTree
func _initialize() -> void:
    call_deferred("run")

func run() -> void:
    var state = root.get_node("GameState")
    state.new_game("TesteUX", "Normal")
    state.choose_oath(true)
    var scene = load("res://scenes/world.tscn").instantiate()
    root.add_child(scene)
    await process_frame
    scene._toggle_map()
    assert(scene.map_open)
    scene._close_top_window()
    assert(not scene.map_open)
    scene._open_character_sheet("Inventario")
    assert(scene.character_sheet.visible)
    scene._close_top_window()
    assert(not scene.character_sheet.visible)
    scene._open_craft_menu()
    assert(scene.forge_panel.visible)
    scene._close_top_window()
    assert(not scene.forge_panel.visible)
    scene._market_vendor_id = "mercador_marcial"
    scene._market_selling = false
    scene._market_page = 0
    scene._market_mode = true
    scene._refresh_market()
    assert(scene.equipment_market.visible)
    assert(scene._market_ids.size() == 2)
    scene._close_top_window()
    assert(not scene.equipment_market.visible)
    var entrance: Dictionary = scene._nearest_building()
    assert(entrance.is_empty())
    scene.player.position = Vector3(-4.2, 0, -17)
    scene._door_armed = true
    scene._door_cooldown = 0.0
    scene._physics_process(0.016)
    assert(not scene.active_interior.is_empty())
    assert(scene._door_cooldown > 0.0)
    scene._close_top_window()
    assert(scene.active_interior.is_empty())
    assert(not scene._door_armed)
    scene._physics_process(0.016)
    assert(scene.active_interior.is_empty())
    scene.queue_free()
    await process_frame
    print("TEST_PHASE2_UI_FLOW_PASS")
    quit(0)
