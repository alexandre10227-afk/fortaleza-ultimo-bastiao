extends SceneTree

func _initialize() -> void:
    call_deferred("run")

func run() -> void:
    var game = root.get_node("GameState")
    game.new_game("Teste", "Normal")
    game.choose_oath(true)
    var world = load("res://scenes/world.tscn").instantiate()
    root.add_child(world)
    await process_frame
    assert(world.player is CharacterBody3D)
    assert(world.player.get_child(0) is CollisionShape3D)
    var bodies := 0
    var sprites: Array[Sprite3D] = []
    for node in world.settlement.get_children():
        if node is StaticBody3D:
            bodies += 1
        if node is Sprite3D:
            sprites.append(node)
    assert(bodies == 10)
    assert(sprites.size() == 2)
    for npc in sprites:
        assert(npc.texture == world._sprite_texture)
    assert(world._shared_materials.size() < 24)
    var previous_pos: Vector3 = world.player.position
    world._interact()
    assert(world.player.position == previous_pos)
    print("TEST_OPTIMIZATION_PASS; static_bodies=%d; reused_materials=%d" % [bodies, world._shared_materials.size()])
    quit(0)
