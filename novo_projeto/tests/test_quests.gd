extends SceneTree

func _initialize() -> void:
    call_deferred("run")

func run() -> void:
    var g = root.get_node("GameState")
    g.new_game("Mineradora", "Normal")
    g.choose_oath(true)
    assert(g.start_quest("doran"))
    assert(not g.start_quest("doran"))
    assert(not g.complete_quest("doran"))
    var first_money: int = g.money
    for n in range(3):
        var node_id := "Fortaleza_ferro_%d" % n
        assert(g.collect_resource(node_id, "ferro"))
        assert(not g.collect_resource(node_id, "ferro"))
    assert(int(g.inventory.get("ferro", 0)) == 3)
    assert(g.complete_quest("doran"))
    assert(not g.complete_quest("doran"))
    assert(g.money == first_money + 35)
    assert(int(g.inventory.get("ferro", 0)) == 0)
    assert(g.save_game())
    g.new_game("Outro", "Facil")
    assert(g.load_game())
    assert(g.quest_progress.get("doran") == "complete")
    assert(not g.collect_resource("Fortaleza_ferro_0", "ferro"))
    g.advance_days(1)
    assert(g.collect_resource("Fortaleza_ferro_0", "ferro"))
    assert(g.start_quest("elira"))
    print("TEST_QUESTS_PASS")
    quit(0)
