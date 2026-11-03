extends SceneTree

func _initialize() -> void:
    call_deferred("run")

func run() -> void:
    var game = root.get_node("GameState")
    game.new_game("Heroi", "Normal")
    game.choose_oath(true)
    var scene = load("res://scenes/world.tscn").instantiate()
    root.add_child(scene)
    await process_frame
    assert(scene._is_blocked(Vector3(9, 0, -17)))
    assert(not scene._is_blocked(Vector3(0, 0, 13)))
    scene.player.position = Vector3(-4.4, 0, -17)
    assert(not scene._nearest_building().is_empty())
    scene._interact()
    assert(scene.active_interior == "Taverna")
    assert(scene.interior_node.visible)
    scene._interact()
    assert(scene.active_interior == "")
    scene._toggle_map()
    assert(scene.map_open)
    scene._travel_to("Porto Cinzento")
    assert(game.energy == 35)
    assert(game.current_region == "Porto Cinzento")
    assert(not scene.map_open)
    print("TEST_EXPLORATION_PASS")
    quit()
