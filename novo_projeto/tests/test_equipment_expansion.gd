extends SceneTree
const GEAR = preload("res://scripts/equipment_catalog.gd")
const ITEMS = preload("res://scripts/item_catalog.gd")
const ECONOMY = preload("res://scripts/economy_system.gd")

func _initialize() -> void:
    call_deferred("run")

func run() -> void:
    assert(GEAR.validate_catalog())
    assert(GEAR.GEAR.size() == 134)
    var rarities := ["Comum","Raro","Epico","Lendario","Mitico"]
    for archetype in GEAR.CLASS_ORDER:
        for rarity in rarities:
            var tier_weapons := 0
            for id in GEAR.equipment_for(archetype,"weapon",rarity):
                if str(id).contains("_arma_"):
                    tier_weapons += 1
                    var item: Dictionary = GEAR.GEAR[id]
                    assert(item["class"] == archetype)
                    if rarity == "Comum":
                        assert(ECONOMY.RECIPES.has(id))
                        assert(ITEMS.is_tradeable(id))
                    elif rarity in ["Raro","Epico"]:
                        assert(ITEMS.is_tradeable(id))
                        assert(ECONOMY.RECIPES.has(id))
                        assert(int(ECONOMY.RECIPES[id]["level"]) >= 2)
                    else:
                        assert(not ITEMS.is_tradeable(id))
                        assert(not ECONOMY.RECIPES.has(id))
            assert(tier_weapons == 3)
        for line_id in [1,2,3]:
            var pieces := 0
            for item_id in GEAR.equipment_for(archetype):
                if item_id.contains("_armadura_") and item_id.ends_with("_linha_%d" % line_id):
                    pieces += 1
                    var armor: Dictionary = GEAR.GEAR[item_id]
                    assert(["head","chest","feet"].has(armor["slot"]))
                    if line_id == 3:
                        assert(not ECONOMY.RECIPES.has(item_id))
                    else:
                        assert(ECONOMY.RECIPES.has(item_id))
                        assert(int(ECONOMY.RECIPES[item_id]["level"]) >= 3)
            assert(pieces == 3)
    assert(GEAR.vendor_inventory("doran").size() == 14)
    assert(GEAR.reward_for("boss","rei_lobos") == "machado_rei_lobos")
    assert(GEAR.reward_for("dungeon","sala_aurora") == "manto_primeira_luz")
    assert(GEAR.reward_for("quest","evento_duque") == "armadura_duque")
    for kind in GEAR.REWARDS:
        for key in GEAR.REWARDS[kind]:
            var item_id := str(GEAR.REWARDS[kind][key])
            assert(GEAR.is_special(item_id))
            assert(not ITEMS.is_tradeable(item_id))
            assert(not ECONOMY.RECIPES.has(item_id))
    var state = root.get_node("GameState")
    state.new_game("Tesouro","Normal")
    state.choose_oath(true)
    assert(not state.claim_dungeon_equipment("sala_aurora"))
    state.dungeon_unlocked = true
    assert(state.claim_dungeon_equipment("sala_aurora"))
    assert(not state.claim_dungeon_equipment("sala_aurora"))
    assert(state.inventory.get("manto_primeira_luz",0) == 1)
    assert(not state.market_buy("manto_primeira_luz"))
    assert(not state.craft_item("manto_primeira_luz"))
    assert(not state.market_sell("manto_primeira_luz"))
    assert(not state.claim_quest_equipment("juramento_do_ferreiro"))
    state.quest_progress["juramento_do_ferreiro"] = "complete"
    assert(state.claim_quest_equipment("juramento_do_ferreiro"))
    assert(not state.claim_quest_equipment("juramento_do_ferreiro"))
    assert(state.save_game())
    state.new_game("Reset","Facil")
    assert(state.load_game())
    assert(state.inventory.get("manto_primeira_luz",0) == 1)
    assert(state.equipment_reward_claims.get("dungeon:sala_aurora",false))
    assert(not state.claim_dungeon_equipment("sala_aurora"))
    assert(state.equipment_reward_claims.get("quest:juramento_do_ferreiro",false))
    var sheet = load("res://scripts/character_sheet.gd").new()
    root.add_child(sheet)
    await process_frame
    sheet.open_sheet("Catalogo")
    assert(sheet.page == "Catalogo")
    sheet._catalog_change_class("Mago")
    sheet._catalog_change_rarity("Mitico")
    assert(sheet._catalog_rarity == "Mitico")
    sheet.queue_free()
    await process_frame
    print("TEST_EQUIPMENT_EXPANSION_PASS")
    quit(0)
