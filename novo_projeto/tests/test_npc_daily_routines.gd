extends SceneTree
func _initialize() -> void:
    call_deferred("run")

func run() -> void:
    var r = load("res://scripts/npc_daily_routines.gd")
    var regions = load("res://scripts/region_system.gd")
    var registry = load("res://scripts/npc_registry.gd")
    var items = load("res://scripts/item_catalog.gd")
    var fortress: Array = regions.residents("Fortaleza")
    var port: Array = regions.residents("Porto Cinzento")
    assert(fortress.size() == 4)
    assert(port.size() == 3)
    var ids: Dictionary = {}
    for entry in fortress + port:
        var id := str(entry["id"])
        assert(not ids.has(id))
        ids[id] = true
        assert(registry.PROFILES.has(id))
        assert(r.has_post(id))
        assert(items.NPC_GIFT_CATEGORY.has(id))
        assert(items.CATEGORIES.has(items.preferred_category(id, str(entry["profession"]))))
        assert(r.position_for(id, 1) == r.position_for(id, 1))
        assert(r.position_for(id, 1) != r.position_for(id, 3))
        assert(r.activity_for(id, 1) != r.activity_for(id, 3))
        var position: Vector3 = r.position_for(id, 1)
        assert(absf(position.x) <= 26)
        assert(absf(position.z) <= 29)
    assert(registry.profile("iris_feirante")["vendor"])
    assert(registry.profile("bento_agricultor")["category"] == "Fazendeiros")
    assert(not registry.base_recruitable("lia_moradora"))
    print("TEST_NPC_DAILY_ROUTINES_PASS")
    quit(0)
