extends SceneTree
const COMBAT = preload("res://scripts/combat_core.gd")
const PARTY = preload("res://scripts/party_combat.gd")
const GEAR = preload("res://scripts/equipment_catalog.gd")

func _initialize() -> void:
    call_deferred("run")

func run() -> void:
    assert(PARTY.form_party([]).is_empty())
    var allies: Array = PARTY.form_party(["elira","mira","kael","elira","duque"])
    assert(allies.size() == 2)
    assert(allies[0]["id"] == "elira")
    assert(allies[1]["id"] == "mira")
    assert(PARTY.form_party(["duque","desconhecido"]).is_empty())
    var stats := {"Forca":7,"Constituicao":6,"Inteligencia":8,"Destreza":5,"Sorte":3}
    var gear := {"attack":3,"defense":4,"life":70,"mana":28,"healing":14,"critical":12,"agility":2}
    assert(COMBAT.hero_max_hp(stats,1,gear) == COMBAT.hero_max_hp(stats,1)+70)
    assert(COMBAT.hero_max_mp(stats,1,gear) == COMBAT.hero_max_mp(stats,1)+28)
    var battle := COMBAT.start(stats,gear,"Sacerdote",1,90,48,"guardiao_de_pedra","Normal",allies)
    assert(battle["allies"].size() == 2)
    assert(int(battle["max_hp"]) > COMBAT.hero_max_hp(stats,1))
    var hp_before := int(battle["hero_hp"])
    var used := COMBAT.act(battle,"skill")
    assert(int(used["hero_mp"]) == 43)
    assert(int(used["hero_hp"]) >= hp_before)
    assert(int(used["turn"]) == 2)
    assert(battle["allies"][0]["hp"] == allies[0]["hp"]) # deep copy
    # No terceiro turno, o inimigo pode atingir um aliado em vez do protagonista.
    var second := COMBAT.act(used,"defend")
    var hero_before := int(second["hero_hp"])
    var third := COMBAT.act(second,"defend")
    assert(int(third["turn"]) == 4)
    assert(int(third["hero_hp"]) == hero_before)
    assert(int(third["allies"][0]["hp"]) < int(third["allies"][0]["max_hp"]))
    # Testa equipamentos reais e preservacao apos save/load.
    var state = root.get_node("GameState")
    state.new_game("Equipamento","Normal")
    assert(state.choose_starting_class("Mago"))
    state.choose_oath(true)
    var item_id := "mago_armadura_head_linha_1"
    assert(GEAR.can_equip(item_id,"Mago"))
    var original_hp := state.hero_hp
    var original_mp := state.hero_mp
    state.inventory[item_id] = 1
    assert(state.equip_item(item_id))
    assert(state.hero_hp == original_hp)
    assert(state.hero_mp > original_mp)
    assert(state.hero_combat_stats()["max_mp"] == COMBAT.hero_max_mp(state.character_stats,state.hero_level,state.equipment_stats()))
    state.recruited.append("elira")
    state.recruited.append("mira")
    assert(state.begin_field_battle("saqueador","companheiros_teste"))
    assert(state.active_battle["allies"].size() == 2)
    assert(state.active_battle["allies"][0]["id"] == "elira")
    assert(state.save_game())
    state.active_battle.clear()
    state.recruited.clear()
    assert(state.load_game())
    assert(state.active_battle["allies"].size() == 2)
    assert(state.recruited.size() == 2)
    assert(state.equipped["head"] == item_id)
    print("TEST_PARTY_COMBAT_PASS")
    quit(0)
