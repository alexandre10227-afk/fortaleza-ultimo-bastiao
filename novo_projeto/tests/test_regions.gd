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
    assert(scene.npc_visuals.has("iris_feirante"))
    assert(scene.npc_visuals.has("bento_agricultor"))
    assert(not scene.npc_visuals.has("doran")) # Esta hospedado na taverna.
    assert(scene.regional_details.get_child_count() >= 15)
    scene.player.position = scene.ROUTINES.position_for("iris_feirante", state.day)
    var npc: Dictionary = scene._nearest_npc()
    assert(npc.get("id") == "iris_feirante")
    scene._talk_to_nearest_npc()
    assert(state.npc_memory.has("iris_feirante"))
    assert(state.save_game())
    state.npc_memory.clear()
    assert(state.load_game())
    assert(state.npc_memory.has("iris_feirante"))
    scene._travel_to("Porto Cinzento")
    assert(scene.npc_visuals.has("lia_moradora"))
    assert(not scene.npc_visuals.has("elira")) # Esta na taverna, nao na rua.
    assert(not scene.npc_visuals.has("doran"))
    assert(scene.regional_details.get_child_count() >= 11)
    assert(scene.REGION_SYSTEM.region_data(state.current_region)["type"] == "harbor")
    print("TEST_REGIONS_PASS")
    quit(0)
