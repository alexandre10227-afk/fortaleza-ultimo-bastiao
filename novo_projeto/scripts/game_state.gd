extends Node

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
    region_reputation = {"Fortaleza": 0, "Porto Cinzento": 0}
    wave_number = 0
    dungeon_unlocked = false
    money = 60
    inventory = {"pao": 2}
    recruited.clear()
    discovered_bestiary.clear()
    quest_progress.clear()
    collected_nodes.clear()
    record_event("character_created", "Palacio", [character_name], "Criacao do protagonista")

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

func advance_days(days: int) -> void:
    for _i in range(maxi(0, days)):
        day += 1
        if (day - 1) % 5 == 0:
            wave_number += 1
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
    if id.is_empty():
        return false
    recruited.append(id)
    remember(id, "recrutado")
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
    record_event("quest_completed", current_region, [npc_id], str(quest["title"]))
    save_game()
    return true

func collect_resource(node_id: String, item_id: String) -> bool:
    if not ["ferro", "ervas"].has(item_id):
        return false
    if int(collected_nodes.get(node_id, -1)) == day:
        return false
    collected_nodes[node_id] = day
    inventory[item_id] = int(inventory.get(item_id, 0)) + 1
    record_event("resource_collected", current_region, [character_name], "Coletou " + item_id)
    save_game()
    return true

func save_game() -> bool:
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        return false
    var data := {"schema": 1, "name": character_name, "difficulty": difficulty, "oath": oath, "region": current_region, "day": day, "energy": energy, "agility_xp": agility_xp, "events": events, "npc_memory": npc_memory, "reputation": region_reputation, "wave": wave_number, "dungeon": dungeon_unlocked, "money": money, "inventory": inventory, "recruited": recruited, "bestiary": discovered_bestiary, "quests": quest_progress, "collected_nodes": collected_nodes}
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
    return true
