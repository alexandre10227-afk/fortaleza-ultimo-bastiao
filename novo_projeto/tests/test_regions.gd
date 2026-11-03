extends SceneTree

func _initialize() -> void:
    call_deferred("run_tests")

func run_tests() -> void:
    var state = root.get_node("GameState")
    state.new_game("Explorador", "Normal")
    state.choose_oath(true)
    var scene = load("res://scenes/world.tscn").instantiate()
    root.add_child(scene)
    await process_frame
    assert(scene.REGION_SYSTEM.region_data("Fortaleza")["type"] == "frontier")
    assert(scene.npc_visuals.has("doran"))
    assert(scene.npc_visuals.has("kael"))
    assert(scene.regional_details.get_child_count() == 10)
    scene.player.position = Vector3(4.7, 0, -13.0 + float(state.day % 3) * 1.5)
    var npc: Dictionary = scene._nearest_npc()
    assert(npc.get("id") == "doran")
    scene._talk_to_nearest_npc()
    assert(state.npc_memory.has("doran"))
    assert(state.save_game())
    state.npc_memory.clear()
    assert(state.load_game())
    assert(state.npc_memory.has("doran"))
    scene._travel_to("Porto Cinzento")
    assert(scene.npc_visuals.has("elira"))
    assert(not scene.npc_visuals.has("doran"))
    assert(scene.regional_details.get_child_count() == 9)
    assert(scene.REGION_SYSTEM.region_data(state.current_region)["type"] == "harbor")
    print("TEST_REGIONS_PASS")
    quit(0)
