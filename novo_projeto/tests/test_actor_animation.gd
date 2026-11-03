extends SceneTree
const ACTOR = preload("res://scripts/actor_animation.gd")
func _initialize() -> void:
    call_deferred("run")

func run() -> void:
    var frames: Dictionary = ACTOR.make_frames(2)
    assert(frames.size() == 24)
    for direction in ACTOR.DIRECTIONS:
        for step in range(3):
            var texture: Texture2D = frames["%s:%d" % [direction, step]]
            assert(texture.get_width() == 24)
            assert(texture.get_height() == 40)
    assert(ACTOR.direction_from_vector(Vector3.ZERO, "up") == "up")
    assert(ACTOR.direction_from_vector(Vector3(1,0,0), "up") == "right")
    assert(ACTOR.direction_from_vector(Vector3(0,0,-1), "down") == "up")
    assert(ACTOR.direction_from_vector(Vector3(1,0,-1).normalized(), "down") == "up-right")
    var hero = load("res://scenes/world.tscn").instantiate()
    var g = root.get_node("GameState")
    g.new_game("Testador", "Normal")
    g.choose_oath(true)
    root.add_child(hero)
    await process_frame
    assert(hero._player_walk_frames.size() == 24)
    assert(hero._player_sprite.texture == hero._player_walk_frames["down:0"])
    hero._animate_player(0.2, Vector3(1,0,0))
    assert(hero._player_sprite.texture == hero._player_walk_frames["right:1"])
    hero._animate_player(0.2, Vector3.ZERO)
    assert(hero._player_sprite.texture == hero._player_walk_frames["right:0"])
    print("TEST_ACTOR_ANIMATION_PASS")
    hero.queue_free()
    await process_frame
    quit(0)
