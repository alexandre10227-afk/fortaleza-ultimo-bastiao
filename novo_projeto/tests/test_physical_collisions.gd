extends SceneTree
func _initialize() -> void:
    call_deferred("run")
func run() -> void:
    var g = root.get_node("GameState")
    g.new_game("Fisica", "Normal")
    g.choose_oath(true)
    var scene = load("res://scenes/world.tscn").instantiate()
    root.add_child(scene)
    await physics_frame
    scene._build_interior("Ferraria")
    scene._set_interior_collision(true)
    await physics_frame
    var space: PhysicsDirectSpaceState3D = scene.get_world_3d().direct_space_state
    var ray := PhysicsRayQueryParameters3D.create(Vector3(-5.0,1.6,0), Vector3(5.0,1.6,0))
    ray.collision_mask = 1
    ray.exclude = [scene.player.get_rid()]
    var wall_hit: Dictionary = space.intersect_ray(ray)
    assert(not wall_hit.is_empty())
    assert(wall_hit["collider"] is StaticBody3D)
    scene._set_interior_collision(false)
    await physics_frame
    var after: Dictionary = space.intersect_ray(ray)
    assert(after.is_empty())
    scene.queue_free()
    await process_frame
    print("TEST_PHYSICAL_COLLISIONS_PASS")
    quit(0)
