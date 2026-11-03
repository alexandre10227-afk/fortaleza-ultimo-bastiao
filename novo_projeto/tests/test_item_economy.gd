extends SceneTree

func _initialize() -> void:
    call_deferred("run_tests")

func run_tests() -> void:
    var g = root.get_node("GameState")
    var catalog = load("res://scripts/item_catalog.gd")
    var unique = load("res://scripts/unique_weapons.gd")
    var economy = load("res://scripts/economy_system.gd")
    assert(catalog.is_valid_catalog())
    for npc_id in catalog.NPC_GIFT_CATEGORY:
        var only_category := str(catalog.NPC_GIFT_CATEGORY[npc_id])
        assert(catalog.CATEGORIES.has(only_category))
        for item_id in catalog.ITEMS:
            var should_accept := str(catalog.ITEMS[item_id]["category"]) == only_category
            assert(catalog.accepts_gift(str(npc_id), "Nobre", str(item_id)) == should_accept)
            if not should_accept:
                assert(catalog.gift_affection(str(npc_id), "Nobre", str(item_id)) == 0)
    assert(catalog.ITEMS.size() >= 20)
    assert(catalog.RARITIES.size() == 4)
    assert(catalog.preferred_category("doran", "Ferreiro") == "Minerios")
    assert(catalog.preferred_category("mira", "Curandeira") == "Comestiveis")
    assert(catalog.preferred_category("selene", "Estrategista") == "Estudos")
    assert(catalog.preferred_category("duque", "Nobre") == "Arte")
    assert(catalog.preferred_category("elira", "Mercenaria") == "Armas")
    assert(catalog.accepts_gift("doran", "Ferreiro", "meteorito"))
    assert(not catalog.accepts_gift("doran", "Ferreiro", "maca"))
    assert(catalog.gift_affection("doran", "Ferreiro", "maca") == 0)
    assert(catalog.gift_affection("doran", "Ferreiro", "meteorito") > catalog.gift_affection("doran", "Ferreiro", "ferro"))
    assert(unique.is_unique("espada_heroi"))
    assert(unique.is_unique("armadura_duque"))
    assert(not catalog.is_tradeable("espada_heroi"))
    assert(not catalog.is_tradeable("armadura_duque"))
    g.new_game("Mercador", "Normal")
    g.choose_oath(true)
    g.inventory["maca"] = 2
    g.inventory["meteorito"] = 2
    var old_money: int = g.money
    assert(not g.give_gift("doran", "Ferreiro", "maca"))
    assert(int(g.inventory["maca"]) == 2)
    assert(g.friendship_points("doran") == 0)
    assert(g.give_gift("doran", "Ferreiro", "meteorito"))
    assert(int(g.inventory["meteorito"]) == 1)
    var old_affinity: int = g.friendship_points("doran")
    assert(old_affinity > 0)
    assert(not g.give_gift("doran", "Ferreiro", "meteorito"))
    assert(int(g.inventory["meteorito"]) == 1)
    g.advance_days(1)
    assert(g.give_gift("doran", "Ferreiro", "meteorito"))
    assert(g.friendship_points("doran") > old_affinity)
    assert(g.market_buy("maca"))
    assert(g.money == old_money - catalog.price("maca", "Fortaleza", "guardian"))
    assert(not g.market_buy("espada_heroi"))
    assert(not g.market_sell("armadura_duque"))
    assert(g.market_sell("maca"))
    assert(g.eat_food("maca"))
    assert(int(g.active_food_bonuses["vigor"]["amount"]) >= 1)
    assert(not g.eat_food("meteorito"))
    g.inventory["madeira"] = 2
    g.money = 100
    assert(g.craft_item("espada_madeira"))
    assert(int(g.inventory["espada_madeira"]) == 1)
    assert(int(g.inventory["madeira"]) == 0)
    assert(not g.craft_item("espada_madeira"))
    g.inventory["ferro"] = 3
    g.money = 500
    assert(g.upgrade_building("Ferraria"))
    assert(g.building_levels["Ferraria"] == 2)
    assert(not g.upgrade_building("Cidade inexistente"))
    assert(economy.upgrade_cost("Ferraria", 5).is_empty())
    assert(g.save_game())
    g.new_game("Reset", "Facil")
    assert(g.load_game())
    assert(g.friendship_points("doran") > 0)
    assert(g.building_levels["Ferraria"] == 2)
    assert(g.active_food_bonuses.has("vigor"))
    assert(not g.give_gift("doran", "Ferreiro", "maca"))
    print("TEST_ITEM_ECONOMY_PASS")
    quit(0)
