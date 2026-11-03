extends SceneTree

func _initialize() -> void:
    call_deferred("run")

func run() -> void:
    var registry = load("res://scripts/npc_registry.gd")
    var g = root.get_node("GameState")
    assert(registry.CATEGORIES.size() == 6)
    for id in registry.PROFILES:
        var profile: Dictionary = registry.profile(id)
        assert(registry.CATEGORIES.has(profile["category"]))
        assert(profile.has("recruitable") and profile.has("important"))
        var type_list: Array[Dictionary] = registry.list_filtered(profile["category"])
        assert(not type_list.is_empty())
    assert(registry.profile("doran")["category"] == "Ferreiros")
    assert(registry.profile("bento_agricultor")["category"] == "Fazendeiros")
    assert(registry.profile("duque")["category"] == "Nobres")
    assert(registry.profile("elira")["category"] == "Soldados")
    assert(registry.profile("mercador_viajante")["category"] == "Comerciantes")
    assert(registry.profile("lia_moradora")["category"] == "Cidadaos comuns")
    assert(not registry.base_recruitable("rei_aldric"))
    assert(not registry.base_recruitable("bento_agricultor"))
    assert(registry.base_recruitable("doran"))
    assert(registry.is_vendor("doran"))
    assert(not registry.is_vendor("mira"))
    var important_nobles: Array[Dictionary] = registry.list_filtered("Nobres", -1, 1)
    assert(important_nobles.size() >= 2)
    assert(registry.list_filtered("Fazendeiros", 1).is_empty())
    assert(registry.list_filtered("Fazendeiros", 0).size() == 1)
    g.new_game("Teste", "Normal")
    g.choose_oath(true)
    assert(not g.recruit_visitor({"id":"bento_agricultor","name":"Bento","home":"Fortaleza"}))
    var ui = load("res://scripts/npc_interaction_menu.gd").new()
    root.add_child(ui)
    await process_frame
    ui.show_directory()
    assert(ui.is_open())
    ui.show_directory_group("Nobres")
    ui._filter_directory("Nobres", "Importantes para a historia")
    assert(ui.content.get_child_count() > 2)
    ui.show_npc({"id":"doran","name":"Doran","profession":"Ferreiro"}, 40, "Amigos", "Minerios", false, true)
    var found_group := false
    for child in ui.content.get_children():
        if child is Label and child.text.contains("Ferreiros"):
            found_group = true
    assert(found_group)
    ui.hide_menu()
    ui.queue_free()
    await process_frame
    print("TEST_NPC_REGISTRY_PASS")
    quit(0)
