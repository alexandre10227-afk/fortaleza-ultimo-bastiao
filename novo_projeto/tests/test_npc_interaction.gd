extends SceneTree

func _initialize() -> void:
    call_deferred("run")

func run() -> void:
    var g = root.get_node("GameState")
    g.new_game("Testador", "Normal")
    g.choose_oath(true)
    var ui = load("res://scripts/npc_interaction_menu.gd").new()
    root.add_child(ui)
    await process_frame
    var doran := {"id":"doran","name":"Doran","profession":"Ferreiro","rarity":"Comum","home":"Fortaleza"}
    ui.show_npc(doran, 0, "Indiferente", "Minerios", false, true)
    assert(ui.is_open())
    var titles := []
    for child in ui.content.get_children():
        if child is Button:
            titles.append(child.text)
    assert(titles.has("Conversar"))
    assert(titles.has("Abrir loja"))
    assert(titles.has("Presentear"))
    assert(titles.has("Pedir passagem (sem penalidade)"))
    assert(not titles.has("Recrutar"))
    ui.show_npc(doran, 80, "Leal ate a Morte", "Minerios", true, true)
    var has_recruit := false
    for child in ui.content.get_children():
        if child is Button and child.text == "Recrutar":
            has_recruit = true
    assert(has_recruit)
    var gifts := {"ferro":2, "maca":1, "espada_heroi":1}
    ui.show_gifts(doran, gifts)
    var allowed := 0
    var rejected := 0
    for child in ui.content.get_children():
        if child is Button:
            if child.text.begins_with("Minerio de ferro"):
                assert(not child.disabled)
                allowed += 1
            elif child.text.begins_with("Maca fresca"):
                assert(child.disabled)
                rejected += 1
            elif child.text.contains("Espada do Heroi"):
                assert(false)
    assert(allowed == 1 and rejected == 1)
    var selected := [""]
    ui.gift_selected.connect(func(_npc, item_id): selected[0] = item_id)
    ui._on_gift_click("ferro")
    assert(selected[0] == "ferro")
    var action := [""]
    ui.action_selected.connect(func(name, _npc): action[0] = name)
    ui._on_action("step_aside")
    assert(action[0] == "step_aside")
    ui.hide_menu()
    assert(not ui.is_open())
    ui.queue_free()
    await process_frame
    print("TEST_NPC_INTERACTION_PASS")
    quit(0)
