extends Node
const DUKE = preload("res://scripts/duke_event.gd")
const FRIENDSHIP = preload("res://scripts/friendship_system.gd")
const TOWN = preload("res://scripts/town_system.gd")
const ITEMS = preload("res://scripts/item_catalog.gd")
const ECONOMY = preload("res://scripts/economy_system.gd")

const SAVE_PATH := "user://fortaleza_stage1_v1.json"
const DIFFICULTIES := {
    "Facil": {"xp": 1.25, "damage": 0.8, "resources": 1.25, "enemies": 0.8, "rare": 1.0},
    "Normal": {"xp": 1.1, "damage": 1.0, "resources": 1.1, "enemies": 1.0, "rare": 1.0},
    "Dificil": {"xp": 1.75, "damage": 1.35, "resources": 0.8, "enemies": 1.4, "rare": 1.25},
    "Impossivel": {"xp": 3.0, "damage": 1.8, "resources": 0.55, "enemies": 1.8, "rare": 1.6},
}
var character_name := ""
var difficulty := "Normal"
var oath := ""
var current_region := ""
var day := 1
var energy := 40
var agility_xp := 0
var events: Array[Dictionary] = []
var npc_memory: Dictionary = {}
var npc_friendship: Dictionary = {}
var last_friendship_interaction: Dictionary = {}
var npc_lives: Dictionary = {}
var npc_story_flags: Dictionary = {}
var last_gift_day: Dictionary = {}
var active_food_bonuses: Dictionary = {}
var building_levels: Dictionary = {"Ferraria":1,"Oficina":1,"Cozinha":1,"Escritorio":1,"Muralha":1}
var region_reputation: Dictionary = {"Fortaleza": 0, "Porto Cinzento": 0}
var wave_number := 0
var dungeon_unlocked := false
var discovered_bestiary: Dictionary = {}
var money := 60
var inventory: Dictionary = {"pao": 2}
var recruited: Array[String] = []
var discovered_regions: Array[String] = ["Fortaleza", "Porto Cinzento"]
var quest_progress: Dictionary = {}
var collected_nodes: Dictionary = {}
var narrative_flags: Dictionary = {}
var duke_state: Dictionary = DUKE.initial_state()
const OPENING_QUESTS := {
    "doran": {"item": "ferro", "amount": 3, "reward": 35, "title": "Ferro para as muralhas"},
    "elira": {"item": "ervas", "amount": 3, "reward": 35, "title": "Suprimentos do porto"},
}


func new_game(hero_name: String, mode: String) -> void:
    character_name = hero_name.strip_edges().substr(0, 24)
    if character_name.is_empty():
        character_name = "Viajante"
    difficulty = mode if DIFFICULTIES.has(mode) else "Normal"
    oath = ""
    current_region = ""
    day = 1
    energy = 40
    agility_xp = 0
    events.clear()
    npc_memory.clear()
    npc_friendship.clear()
    last_friendship_interaction.clear()
    npc_story_flags.clear()
    last_gift_day.clear()
    active_food_bonuses.clear()
    building_levels = {"Ferraria":1,"Oficina":1,"Cozinha":1,"Escritorio":1,"Muralha":1}
    npc_lives = TOWN.initial_lives()
    _advance_npc_lives(day)
    region_reputation = {"Fortaleza": 0, "Porto Cinzento": 0}
    wave_number = 0
    dungeon_unlocked = false
    money = 60
    inventory = {"pao": 2}
    recruited.clear()
    discovered_bestiary.clear()
    quest_progress.clear()
    collected_nodes.clear()
    narrative_flags.clear()
    duke_state = DUKE.initial_state()
    record_event("character_created", "Palacio", [character_name], "Criacao do protagonista")

func record_narrative_choice(key: String, value: String) -> bool:
    if narrative_flags.has(key):
        return false
    narrative_flags[key] = value
    record_event("narrative_choice", "Palacio", [character_name], key + ": " + value)
    save_game()
    return true

func choose_oath(protect: bool) -> void:
    if not oath.is_empty():
        return
    oath = "guardian" if protect else "exile"
    current_region = "Fortaleza" if protect else "Porto Cinzento"
    if not protect:
        region_reputation["Fortaleza"] = -100
        record_event("ss_defender_assigned", "Fortaleza", ["General Vaelor"], "Defesa delegada ao heroi rank SS")
    record_event("oath_chosen", "Palacio", [character_name], oath)
    save_game()

func fortress_price_multiplier() -> int:
    return 3 if oath == "exile" else 1

func can_recruit_fortress_resident() -> bool:
    return oath != "exile"

func record_event(kind: String, region: String, actors: Array, description: String) -> void:
    var key := "%s_%s_%s_%s" % [str(day), kind, region, str(events.size())]
    events.append({"id": key, "day": day, "kind": kind, "region": region, "actors": actors, "description": description})

func remember(npc_id: String, event_kind: String) -> void:
    if not npc_memory.has(npc_id):
        npc_memory[npc_id] = []
    npc_memory[npc_id].append({"day": day, "kind": event_kind})
    record_event("npc_memory", current_region, [npc_id], event_kind)

func friendship_points(npc_id: String) -> int:
    if npc_id == "duque":
        return int(duke_state.get("friendship", 0))
    if npc_id == DUKE.DAUGHTER_ID:
        return int(duke_state.get("daughter_friendship", 0))
    return int(npc_friendship.get(npc_id, 0))

func friendship_level(npc_id: String) -> String:
    if npc_id == "duque":
        return FRIENDSHIP.level_name(int(duke_state.get("friendship", 0)))
    if npc_id == DUKE.DAUGHTER_ID:
        return FRIENDSHIP.level_name(int(duke_state.get("daughter_friendship", 0)))
    return FRIENDSHIP.level_name(friendship_points(npc_id))

func gain_friendship(npc_id: String, points: int, source: String, once_per_day: bool = false) -> bool:
    if npc_id.is_empty() or points <= 0 or npc_id == "duque" or npc_id == DUKE.DAUGHTER_ID:
        return false
    var key := npc_id + ":" + source
    if once_per_day and int(last_friendship_interaction.get(key, -1)) == day:
        return false
    var previous := friendship_points(npc_id)
    var updated := FRIENDSHIP.adjust(previous, points)
    if once_per_day:
        last_friendship_interaction[key] = day
    if updated == previous:
        return false
    npc_friendship[npc_id] = updated
    if FRIENDSHIP.level_name(previous) != FRIENDSHIP.level_name(updated):
        record_event("friendship_level", current_region, [npc_id], "%s: %s" % [npc_id, FRIENDSHIP.level_name(updated)])
    save_game()
    return true

func _advance_npc_lives(target_day: int) -> void:
    for movement in TOWN.advance_lives(npc_lives, target_day, npc_story_flags):
        var id := str(movement["npc_id"])
        var new_region := str(movement["region"])
        record_event(str(movement["kind"]), new_region, [id], "%s: %s" % [id, str(movement["status"])])

func set_npc_story_disposition(npc_id: String, disposition: String) -> bool:
    if not npc_lives.has(npc_id) or not ["village", "travel"].has(disposition):
        return false
    npc_story_flags[npc_id] = disposition
    record_event("npc_story_decision", current_region, [npc_id], disposition)
    save_game()
    return true

func advance_days(days: int) -> void:
    for _i in range(maxi(0, days)):
        day += 1
        for stat in active_food_bonuses.keys():
            if int(active_food_bonuses[stat].get("until_day", 0)) <= day:
                active_food_bonuses.erase(stat)
        _advance_npc_lives(day)
        if (day - 1) % 5 == 0:
            wave_number += 1
            if wave_number == DUKE.DEADLINE_WAVE:
                var duke_outcome := DUKE.resolve_tenth_wave(duke_state)
                if duke_outcome == "extra_boss":
                    record_event("duke_extra_boss", "Fortaleza", ["duque"], "O Carrasco do Juramento aparece na onda 10")
                elif duke_outcome == "died_at_home":
                    record_event("duke_death", "Mansao do Duque", ["duque"], "O Duque morreu em casa; a armadura nao foi obtida")
            record_event("wave", "Fortaleza", ["General Vaelor" if oath == "exile" else character_name], "Onda %d" % wave_number)
            if wave_number == 20:
                dungeon_unlocked = true
                record_event("dungeon_unlocked", "Lago Antigo", [], "Masmorra descoberta")
    save_game()

func travel(destination: String, distance: float) -> bool:
    if energy < 5 or destination == current_region:
        return false
    energy -= 5
    agility_xp += mini(15, maxi(1, ceili(distance / 35.0)))
    current_region = destination
    record_event("travel", destination, [character_name], "Viagem concluida")
    save_game()
    return true

func buy_item(item_id: String) -> bool:
    var price: int = preload("res://scripts/town_system.gd").price(item_id, current_region, oath)
    if price < 0 or money < price:
        return false
    money -= price
    inventory[item_id] = int(inventory.get(item_id, 0)) + 1
    record_event("purchase", current_region, [character_name], "Compra de " + item_id)
    save_game()
    return true

func recruit_visitor(npc: Dictionary) -> bool:
    if recruited.has(str(npc.get("id", ""))) or not preload("res://scripts/town_system.gd").can_recruit(npc, oath):
        return false
    var id := str(npc.get("id", ""))
    if id.is_empty() or id == "duque" or id == DUKE.DAUGHTER_ID:
        return false
    var itinerary: Dictionary = npc_lives.get(id, {})
    if itinerary.get("status", "") != "tavern" or itinerary.get("region", "") != current_region:
        return false
    if not FRIENDSHIP.can_recruit(friendship_points(id)):
        return false
    itinerary["status"] = "recruited"
    recruited.append(id)
    remember(id, "recrutado")
    save_game()
    return true

func give_gift(npc_id: String, profession: String, item_id: String) -> bool:
    # Nenhum NPC aceita itens de outra categoria. Recusa nao consome nem pontua.
    if not ITEMS.accepts_gift(npc_id, profession, item_id):
        return false
    if npc_id == "duque" and (not bool(duke_state.get("duke_alive", false)) or current_region != "Fortaleza"):
        return false
    if npc_id == DUKE.DAUGHTER_ID and not bool(duke_state.get("daughter_unlocked", false)):
        return false
    if npc_lives.has(npc_id) and not recruited.has(npc_id):
        var life: Dictionary = npc_lives[npc_id]
        if life.get("region", "") != current_region or life.get("status", "") == "travelling":
            return false
    if int(inventory.get(item_id, 0)) <= 0 or int(last_gift_day.get(npc_id, -1)) == day:
        return false
    var affinity := ITEMS.gift_affection(npc_id, profession, item_id)
    if affinity <= 0:
        return false
    inventory[item_id] = int(inventory[item_id]) - 1
    last_gift_day[npc_id] = day
    if npc_id == "duque":
        duke_state["friendship"] = mini(100, int(duke_state.get("friendship", 0)) + affinity)
    elif npc_id == DUKE.DAUGHTER_ID:
        duke_state["daughter_friendship"] = mini(100, int(duke_state.get("daughter_friendship", 0)) + affinity)
    else:
        var old_points := friendship_points(npc_id)
        var next_points := FRIENDSHIP.adjust(old_points, affinity)
        npc_friendship[npc_id] = next_points
        if FRIENDSHIP.level_name(old_points) != FRIENDSHIP.level_name(next_points):
            record_event("friendship_level", current_region, [npc_id], "%s: %s" % [npc_id, FRIENDSHIP.level_name(next_points)])
    remember(npc_id, "presente_" + item_id)
    record_event("gift", current_region, [npc_id], "Presente aceito: %s (+%d amizade)" % [item_id, affinity])
    save_game()
    return true

func market_buy(item_id: String, travelling_merchant: bool = false) -> bool:
    var price := ITEMS.price(item_id, current_region, oath, travelling_merchant)
    if price <= 0 or money < price:
        return false
    money -= price
    inventory[item_id] = int(inventory.get(item_id, 0)) + 1
    record_event("market_buy", current_region, [character_name], "Comprou " + item_id)
    save_game()
    return true

func market_sell(item_id: String) -> bool:
    var amount := int(inventory.get(item_id, 0))
    var income := ITEMS.sell_price(item_id)
    if income < 1 or amount < 1:
        return false
    inventory[item_id] = amount - 1
    money += income
    record_event("market_sell", current_region, [character_name], "Vendeu " + item_id)
    save_game()
    return true

func eat_food(item_id: String) -> bool:
    if not ITEMS.can_eat(item_id) or int(inventory.get(item_id, 0)) < 1:
        return false
    var food: Dictionary = ITEMS.get_item(item_id)
    inventory[item_id] = int(inventory[item_id]) - 1
    for stat in food["bonus"]:
        var until_day := day + int(food.get("duration", 1))
        var existing: Dictionary = active_food_bonuses.get(stat, {})
        var amount := maxi(int(existing.get("amount", 0)), int(food["bonus"][stat]))
        var ending := maxi(int(existing.get("until_day", 0)), until_day)
        active_food_bonuses[stat] = {"amount": amount, "until_day": ending}
    record_event("eat", current_region, [character_name], "Consumiu " + item_id)
    save_game()
    return true

func craft_item(item_id: String) -> bool:
    if not ITEMS.is_tradeable(item_id):
        return false
    var recipe := ECONOMY.craft_cost(item_id, building_levels)
    if recipe.is_empty() or not ECONOMY.can_pay(inventory, money, recipe["materials"], int(recipe["money"])):
        return false
    money -= int(recipe["money"])
    ECONOMY.remove_materials(inventory, recipe["materials"])
    inventory[item_id] = int(inventory.get(item_id, 0)) + 1
    record_event("craft", current_region, [character_name], "Fabricou " + item_id)
    save_game()
    return true

func upgrade_building(building: String) -> bool:
    var current_level := int(building_levels.get(building, 0))
    var cost := ECONOMY.upgrade_cost(building, current_level)
    if cost.is_empty() or not ECONOMY.can_pay(inventory, money, cost["materials"], int(cost["money"])):
        return false
    money -= int(cost["money"])
    ECONOMY.remove_materials(inventory, cost["materials"])
    building_levels[building] = current_level + 1
    record_event("building_upgrade", current_region, [character_name], "%s nivel %d" % [building, current_level + 1])
    save_game()
    return true

func start_quest(npc_id: String) -> bool:
    if not OPENING_QUESTS.has(npc_id) or quest_progress.has(npc_id):
        return false
    quest_progress[npc_id] = "active"
    record_event("quest_started", current_region, [npc_id], str(OPENING_QUESTS[npc_id]["title"]))
    save_game()
    return true

func complete_quest(npc_id: String) -> bool:
    if quest_progress.get(npc_id, "") != "active" or not OPENING_QUESTS.has(npc_id):
        return false
    var quest: Dictionary = OPENING_QUESTS[npc_id]
    var item_id := str(quest["item"])
    var amount := int(quest["amount"])
    if int(inventory.get(item_id, 0)) < amount:
        return false
    inventory[item_id] = int(inventory[item_id]) - amount
    money += int(quest["reward"])
    quest_progress[npc_id] = "complete"
    remember(npc_id, "missao_concluida")
    gain_friendship(npc_id, 25, "missao")
    if npc_id == "elira":
        set_npc_story_disposition("elira", "village")
    record_event("quest_completed", current_region, [npc_id], str(quest["title"]))
    save_game()
    return true

func collect_resource(node_id: String, item_id: String) -> bool:
    if not ["ferro", "ervas", "madeira"].has(item_id):
        return false
    if int(collected_nodes.get(node_id, -1)) == day:
        return false
    collected_nodes[node_id] = day
    inventory[item_id] = int(inventory.get(item_id, 0)) + 1
    record_event("resource_collected", current_region, [character_name], "Coletou " + item_id)
    save_game()
    return true

func duke_answer(selected: int) -> Dictionary:
    if current_region != "Fortaleza":
        return {"accepted": false, "correct": false}
    var answer := DUKE.answer_question(duke_state, day, wave_number, selected)
    if bool(answer.get("accepted", false)):
        remember("duque", "charada_correta" if bool(answer.get("correct", false)) else "charada_errada")
        record_event("duke_riddle", "Mansao do Duque", ["duque"], "Charada %d de 6" % int(duke_state["question_index"]))
        save_game()
    return answer

func duke_recruit() -> bool:
    if current_region != "Fortaleza" or oath == "exile" or not DUKE.recruit_duke(duke_state, wave_number):
        return false
    if not recruited.has("duque"):
        recruited.append("duque")
    remember("duque", "amigo_leal")
    record_event("duke_recruited", "Mansao do Duque", ["duque"], "O Duque rank A se uniu ao grupo")
    save_game()
    return true

func duke_boss_defeated() -> bool:
    if not DUKE.defeat_extra_boss(duke_state):
        return false
    record_event("duke_boss_defeated", "Fortaleza", ["duque"], "O boss extra foi derrotado; cena de despedida pendente")
    save_game()
    return true

func duke_finish_cutscene() -> bool:
    if not DUKE.finish_death_cutscene(duke_state):
        return false
    recruited.erase("duque")
    inventory[DUKE.ARMOR_ID] = 1
    remember("duque", "morte_em_batalha")
    record_event("duke_death", "Fortaleza", ["duque"], "O duque morreu defendendo a fortaleza; armadura unica concedida")
    save_game()
    return true

func duke_daughter_recruit() -> bool:
    if not bool(duke_state.get("daughter_unlocked", false)) or bool(duke_state.get("daughter_recruited", false)):
        return false
    # Exilado nao pode recrutar residentes da Fortaleza; a herdeira que
    # surgir na taverna fora da regiao vira uma aventureira independente.
    if oath == "exile" and DUKE.daughter_at_manor(duke_state):
        return false
    duke_state["daughter_recruited"] = true
    if not recruited.has(DUKE.DAUGHTER_ID):
        recruited.append(DUKE.DAUGHTER_ID)
    record_event("daughter_recruited", current_region, [DUKE.DAUGHTER_ID], "Herdeira rank S recrutada")
    save_game()
    return true

func duke_daughter_quest() -> bool:
    if not DUKE.finish_daughter_quest(duke_state, int(inventory.get(DUKE.ARMOR_ID, 0)) > 0):
        return false
    record_event("daughter_quest", current_region, [DUKE.DAUGHTER_ID], "Armadura do Duque apresentada a herdeira")
    save_game()
    return true

func duke_daughter_evolve() -> bool:
    if not DUKE.evolve_daughter(duke_state, inventory):
        return false
    record_event("daughter_evolved", current_region, [DUKE.DAUGHTER_ID], "Herdeira evoluiu do rank S ao SS")
    save_game()
    return true

func duke_tavern_visitor() -> bool:
    if current_region != "Porto Cinzento":
        return false
    # A semente e o dia permanecem constantes; consultar a taverna
    # varias vezes no mesmo dia nao cria novas tentativas.
    var roll := abs(hash("duke_daughter:%d" % day)) % 100
    var present := DUKE.tavern_roll(duke_state, day, wave_number, roll)
    if present:
        save_game()
    return present

func save_game() -> bool:
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        return false
    var data := {"schema": 1, "name": character_name, "difficulty": difficulty, "oath": oath, "region": current_region, "day": day, "energy": energy, "agility_xp": agility_xp, "events": events, "npc_memory": npc_memory, "npc_friendship": npc_friendship, "friendship_days": last_friendship_interaction, "npc_lives": npc_lives, "npc_story_flags": npc_story_flags, "last_gift_day": last_gift_day, "food_bonuses": active_food_bonuses, "building_levels": building_levels, "reputation": region_reputation, "wave": wave_number, "dungeon": dungeon_unlocked, "money": money, "inventory": inventory, "recruited": recruited, "bestiary": discovered_bestiary, "quests": quest_progress, "collected_nodes": collected_nodes, "narrative_flags": narrative_flags, "duke_state": duke_state}
    file.store_string(JSON.stringify(data))
    return true

func load_game() -> bool:
    if not FileAccess.file_exists(SAVE_PATH):
        return false
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        return false
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if not (parsed is Dictionary) or parsed.get("schema", -1) != 1:
        return false
    character_name = str(parsed.get("name", "Viajante"))
    difficulty = str(parsed.get("difficulty", "Normal"))
    oath = str(parsed.get("oath", ""))
    current_region = str(parsed.get("region", ""))
    day = int(parsed.get("day", 1))
    energy = int(parsed.get("energy", 40))
    agility_xp = int(parsed.get("agility_xp", 0))
    events.clear()
    for event in parsed.get("events", []):
        if event is Dictionary:
            events.append(event)
    npc_memory = parsed.get("npc_memory", {})
    npc_friendship = parsed.get("npc_friendship", {})
    last_friendship_interaction = parsed.get("friendship_days", {})
    npc_lives = parsed.get("npc_lives", {})
    npc_story_flags = parsed.get("npc_story_flags", {})
    last_gift_day = parsed.get("last_gift_day", {})
    active_food_bonuses = parsed.get("food_bonuses", {})
    building_levels = parsed.get("building_levels", {"Ferraria":1,"Oficina":1,"Cozinha":1,"Escritorio":1,"Muralha":1})
    if npc_lives.is_empty():
        npc_lives = TOWN.initial_lives()
        for simulated_day in range(1, day + 1):
            TOWN.advance_lives(npc_lives, simulated_day, npc_story_flags)
    region_reputation = parsed.get("reputation", {})
    wave_number = int(parsed.get("wave", 0))
    dungeon_unlocked = bool(parsed.get("dungeon", false))
    money = int(parsed.get("money", 60))
    inventory = parsed.get("inventory", {"pao": 2})
    recruited.clear()
    for id in parsed.get("recruited", []):
        recruited.append(str(id))
    discovered_bestiary = parsed.get("bestiary", {})
    quest_progress = parsed.get("quests", {})
    collected_nodes = parsed.get("collected_nodes", {})
    narrative_flags = parsed.get("narrative_flags", {})
    duke_state = DUKE.initial_state()
    var persisted_duke: Variant = parsed.get("duke_state", {})
    if persisted_duke is Dictionary:
        duke_state.merge(persisted_duke, true)
    return true
