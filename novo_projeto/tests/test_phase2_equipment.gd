extends SceneTree
const GEAR = preload("res://scripts/equipment_catalog.gd")
const ECONOMY = preload("res://scripts/economy_system.gd")
const ITEMS = preload("res://scripts/item_catalog.gd")
func _initialize() -> void:
    call_deferred("run")
func run() -> void:
    assert(GEAR.GEAR.size() == 134)
    assert(GEAR.CLASS_ORDER.size() == 4)
    assert(GEAR.SLOTS == ["weapon","head","chest","feet"])
    for id in GEAR.GEAR:
        var item: Dictionary = GEAR.GEAR[id]
        assert(ITEMS.is_tradeable(id) or GEAR.is_special(id))
        assert(GEAR.can_equip(id, str(item["class"])))
        assert(not GEAR.can_equip(id, "Invalido"))
        if item.get("source","") == "forge":
            assert(ECONOMY.RECIPES.has(id))
            assert(ECONOMY.RECIPES[id]["building"] == "Ferraria")
        else:
            assert(not ECONOMY.RECIPES.has(id))
    assert(GEAR.is_special("armadura_duque"))
    assert(GEAR.is_special("espada_heroi"))
    for npc in GEAR.MERCHANT_ARCHETYPES:
        var vendor_stock: Array[String] = GEAR.vendor_inventory(npc)
        assert(vendor_stock.size() == 14)
        for id in vendor_stock:
            assert(GEAR.GEAR[id]["class"] == GEAR.MERCHANT_ARCHETYPES[npc])
    var g = root.get_node("GameState")
    g.new_game("Teste", "Normal")
    g.choose_oath(true)
    var sword := "guerreiro_weapon_comum"
    var armor := "guerreiro_chest_comum"
    g.inventory["ferro"] = 20
    g.inventory["madeira"] = 20
    g.money = 1000
    assert(g.craft_item(sword))
    assert(g.craft_item(armor))
    assert(g.equip_item(sword))
    assert(g.equip_item(armor))
    assert(g.equipment_stats()["attack"] == 5)
    assert(g.equipment_stats()["defense"] == 5)
    assert(not g.equip_item("mago_weapon_comum"))
    assert(not g.buy_from_merchant("doran", "mago_weapon_raro"))
    assert(g.buy_from_merchant("doran", "guerreiro_weapon_raro"))
    assert(g.save_game())
    g.new_game("Recarregar", "Facil")
    assert(g.load_game())
    assert(g.equipped["weapon"] == sword)
    assert(g.equipped["chest"] == armor)
    assert(g.inventory.get("guerreiro_weapon_raro", 0) == 1)
    var start = load("res://scenes/start.tscn").instantiate()
    root.add_child(start)
    await process_frame
    start._show_difficulty()
    start._select_difficulty("Impossivel")
    assert(start._selected_difficulty == "Impossivel")
    assert(start.name_input != null)
    assert(start.difficulty_input == null)
    start.queue_free()
    await process_frame
    print("TEST_PHASE2_EQUIPMENT_PASS")
    quit(0)
