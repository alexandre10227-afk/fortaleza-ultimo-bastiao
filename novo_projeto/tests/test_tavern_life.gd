extends SceneTree

func _initialize() -> void:
    call_deferred("run_tests")

func run_tests() -> void:
    var g = root.get_node("GameState")
    var town = load("res://scripts/town_system.gd")
    g.new_game("Viajante", "Normal")
    g.choose_oath(true)
    assert(g.npc_lives["doran"]["arrival_day"] == 1)
    assert(g.npc_lives["doran"]["departure_day"] == 5)
    for expected_day in range(1, 5):
        assert(g.day == expected_day)
        var guests: Array[Dictionary] = town.tavern_visitors("Fortaleza", g.day, g.npc_lives)
        var found := false
        for npc in guests:
            if npc.get("id", "") == "doran":
                found = true
        assert(found)
        if expected_day < 4:
            g.advance_days(1)
    assert(g.save_game())
    var expected: Dictionary = g.npc_lives["doran"].duplicate(true)
    g.npc_lives.clear()
    assert(g.load_game())
    assert(g.npc_lives["doran"] == expected)
    g.advance_days(1)
    assert(g.day == 5)
    assert(g.npc_lives["doran"]["status"] == "village")
    assert(town.town_residents("Fortaleza", g.npc_lives).size() > 0)
    assert(not town.tavern_visitors("Fortaleza", g.day, g.npc_lives).any(func(npc): return npc.get("id", "") == "doran"))
    assert(g.npc_lives["elira"]["status"] == "travelling")
    g.advance_days(8)
    assert(g.day == 13)
    assert(g.npc_lives["elira"]["status"] == "tavern")
    assert(g.npc_lives["elira"]["region"] == "Fortaleza")
    assert(g.npc_lives["elira"]["departure_day"] == 17)
    # Story progression controls whether someone settles instead of leaving.
    g.set_npc_story_disposition("elira", "village")
    g.advance_days(4)
    assert(g.npc_lives["elira"]["status"] == "village")
    assert(g.npc_lives["elira"]["region"] == "Porto Cinzento")
    # Affinity persists across movement and needs the highest rank.
    assert(g.friendship_level("elira") == "Indiferente")
    assert(not g.recruit_visitor(town.VISITORS[0]))
    assert(g.gain_friendship("elira", 80, "test"))
    assert(g.recruit_visitor(town.VISITORS[0]))
    assert(g.save_game())
    g.new_game("Reset", "Facil")
    assert(g.load_game())
    assert(g.recruited.has("elira"))
    assert(g.npc_lives["elira"]["status"] == "village")
    print("TEST_TAVERN_LIFE_PASS")
    quit(0)
