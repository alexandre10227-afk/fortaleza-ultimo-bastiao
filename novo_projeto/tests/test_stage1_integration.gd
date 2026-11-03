extends SceneTree
const RECORDS = preload("res://scripts/stage1_records.gd")
func _initialize() -> void:
    call_deferred("run")

func run() -> void:
    var g = root.get_node("GameState")
    g.new_game("Integracao", "Normal")
    assert(g.choose_starting_class("Cavaleiro"))
    g.choose_oath(true)
    g.set_region_position(Vector3(2.5, 0, 11.5))
    assert(g.save_game())
    assert(g.load_game())
    assert(g.get_region_position() == Vector3(2.5, 0, 11.5))
    assert(not g.travel("Regiao Inexistente", 100.0))
    var scene = load("res://scenes/world.tscn").instantiate()
    root.add_child(scene)
    await process_frame
    assert(scene.settlement != null)
    assert(scene.settlement.name == "RegionSettlement")
    assert(scene.player.position == Vector3(2.5, 0, 11.5))
    assert(scene.travel_map_canvas != null)
    assert(scene.travel_map_canvas.clickable_regions.size() == 2)
    assert(scene._player_walk_frames.size() == 12)
    assert(scene._active_city_residents().size() > 0)
    scene._build_interior("Ferraria")
    scene._set_interior_collision(true)
    var wall_count := 0
    for node in scene.interior_node.get_children():
        if node is StaticBody3D:
            wall_count += 1
            assert(node.collision_layer == 1)
    assert(wall_count >= 8)
    scene._set_interior_collision(false)
    for node in scene.interior_node.get_children():
        if node is StaticBody3D:
            assert(node.collision_layer == 0)
    assert(g.launch_reconnaissance("Estrada da Fortaleza"))
    assert(not g.launch_reconnaissance("Estrada da Fortaleza"))
    g.advance_days(2)
    assert(g.expeditions[0]["status"] == "returned")
    assert(g.observe_creature("lobo_cinzento", "Estrada da Fortaleza"))
    assert(g.discovered_bestiary["lobo_cinzento"]["sightings"] == 1)
    assert(g.remember_fallen("companheiro_teste", "Companheiro Teste", "Evento de teste"))
    assert(not g.remember_fallen("companheiro_teste", "Companheiro Teste", "Repetido"))
    assert(g.save_game())
    g.new_game("Reset", "Facil")
    assert(g.load_game())
    assert(g.memorial.size() == 1)
    assert(g.expeditions.size() == 1)
    assert(g.discovered_bestiary.has("lobo_cinzento"))
    assert(g.protagonist_track["base_class"] == "Cavaleiro")
    print("TEST_STAGE1_INTEGRATION_PASS")
    scene.queue_free()
    await process_frame
    quit(0)
