extends Node
const DUKE = preload("res://scripts/duke_event.gd")
const FRIENDSHIP = preload("res://scripts/friendship_system.gd")
const TOWN = preload("res://scripts/town_system.gd")
const ITEMS = preload("res://scripts/item_catalog.gd")
const ECONOMY = preload("res://scripts/economy_system.gd")
const NPC_REGISTRY = preload("res://scripts/npc_registry.gd")
const CHARACTER = preload("res://scripts/character_profile.gd")
const HERO_CLASSES = preload("res://scripts/hero_classes.gd")
const PLAYER_CLASSES = preload("res://scripts/protagonist_progression.gd")
const WORLD_RECORDS = preload("res://scripts/stage1_records.gd")
const SIM = preload("res://scripts/simulation_foundations.gd")
const GEAR = preload("res://scripts/equipment_catalog.gd")
const COMBAT = preload("res://scripts/combat_core.gd")
const PARTY = preload("res://scripts/party_combat.gd")
const ARMORY = preload("res://scripts/city_armory_economy.gd")
const TERRITORY = preload("res://scripts/territory_economy.gd")

const SAVE_PATH := "user://fortaleza_stage1_v1.json"
const DIFFICULTIES := {
    "Facil": {"xp": 1.25, "damage": 0.8, "resources": 1.25, "enemies": 0.8, "rare": 1.0},
    "Normal": {"xp": 1.1, "damage": 1.0, "resources": 1.1, "enemies": 1.0, "rare": 1.0},
    "Dificil": {"xp": 1.75, "damage": 1.35, "resources": 0.8, "enemies": 1.4, "rare": 1.25},
    "Impossivel": {"xp": 3.0, "damage": 1.8, "resources": 0.55, "enemies": 1.8, "rare": 1.6},
}
var character_name := ""
var character_origin := "Andarilho"
var character_stats: Dictionary = CHARACTER.default_stats()
var character_appearance := 0
var region_positions: Dictionary = {"Fortaleza":[0.0, 0.0, 13.0],"Porto Cinzento":[0.0, 0.0, 13.0]}
var hero_build: Dictionary = HERO_CLASSES.starter("Guerreiro")
var protagonist_track: Dictionary = PLAYER_CLASSES.starting_track("Guerreiro")
var npc_hero_builds: Dictionary = {}
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
var expeditions: Array = []
var memorial: Array = []
var military_intel: Dictionary = SIM.initial_intelligence()
var legacy_records: Dictionary = SIM.initial_legacy()
var nemesis_records: Dictionary = SIM.initial_nemeses()
var migration_history: Array = []
var money := 60
var inventory: Dictionary = {"pao": 2}
var equipped: Dictionary = GEAR.equip_slots()
var hero_level := 1
var hero_xp := 0
var hero_hp := 0
var hero_mp := 0
var active_battle: Dictionary = {}
var defeated_field_enemies: Dictionary = {}
var equipment_reward_claims: Dictionary = {}
var city_armory: Dictionary = ARMORY.initial_state()
var national_economy: Dictionary = TERRITORY.initial_state()
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
    character_origin = "Andarilho"
    character_stats = CHARACTER.default_stats()
    character_appearance = 0
    region_positions = {"Fortaleza":[0.0,0.0,13.0],"Porto Cinzento":[0.0,0.0,13.0]}
    hero_build = HERO_CLASSES.starter("Guerreiro")
    protagonist_track = PLAYER_CLASSES.starting_track("Guerreiro")
    npc_hero_builds = HERO_CLASSES.default_npc_builds()
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
    military_intel = SIM.initial_intelligence()
    legacy_records = SIM.initial_legacy()
    nemesis_records = SIM.initial_nemeses()
    migration_history.clear()
    building_levels = {"Ferraria":1,"Oficina":1,"Cozinha":1,"Escritorio":1,"Muralha":1}
    npc_lives = TOWN.initial_lives()
    _advance_npc_lives(day)
    region_reputation = {"Fortaleza": 0, "Porto Cinzento": 0}
    wave_number = 0
    dungeon_unlocked = false
    money = 60
    inventory = {"pao": 2}
    equipped = GEAR.equip_slots()
    hero_level = 1
    hero_xp = 0
    hero_hp = COMBAT.hero_max_hp(character_stats, hero_level)
    hero_mp = COMBAT.hero_max_mp(character_stats, hero_level)
    active_battle.clear()
    defeated_field_enemies.clear()
    equipment_reward_claims.clear()
    city_armory = ARMORY.initial_state()
    national_economy = TERRITORY.initial_state()
    recruited.clear()
    discovered_bestiary.clear()
    expeditions.clear()
    memorial.clear()
    quest_progress.clear()
    collected_nodes.clear()
    narrative_flags.clear()
    duke_state = DUKE.initial_state()
    record_event("character_created", "Palacio", [character_name], "Criacao do protagonista")

func configure_character(origin: String, stats: Dictionary, appearance: int = 0) -> bool:
    if not CHARACTER.valid(stats, origin) or not oath.is_empty() or appearance < 0 or appearance > 3:
        return false
    character_origin = origin
    character_stats = CHARACTER.final_stats(stats, origin)
    hero_hp = COMBAT.hero_max_hp(character_stats, hero_level)
    hero_mp = COMBAT.hero_max_mp(character_stats, hero_level)
    character_appearance = appearance
    record_event("character_profile", "Palacio", [character_name], origin)
    save_game()
    return true

func choose_starting_class(base_class: String, _element: String = "") -> bool:
    # O protagonista NAO usa a raridade de subclasses dos NPCs.
    if not oath.is_empty():
        return false
    var track := PLAYER_CLASSES.starting_track(base_class)
    if track.is_empty():
        return false
    protagonist_track = track
    record_event("protagonist_class", "Palacio", [character_name], base_class)
    save_game()
    return true

func learn_from_master(teacher_id: String, specialization: String) -> bool:
    if not PLAYER_CLASSES.teacher_can_teach(teacher_id, friendship_points(teacher_id), specialization):
        return false
    if not npc_lives.has(teacher_id) and not recruited.has(teacher_id):
        return false
    var present := recruited.has(teacher_id)
    if npc_lives.has(teacher_id):
        var life: Dictionary = npc_lives[teacher_id]
        present = present or (str(life.get("region", "")) == current_region and str(life.get("status", "")) in ["tavern", "village"])
    if not present:
        return false
    var upgraded := PLAYER_CLASSES.learn(protagonist_track, specialization, "mestre:" + teacher_id)
    if upgraded.is_empty():
        return false
    protagonist_track = upgraded
    remember(teacher_id, "ensinou_" + specialization)
    record_event("specialization_learned", current_region, [character_name, teacher_id], specialization)
    save_game()
    return true

func learn_from_boss_book(book_id: String) -> bool:
    var specialization := PLAYER_CLASSES.specialization_from_book(book_id)
    if specialization.is_empty() or int(inventory.get(book_id, 0)) < 1:
        return false
    var upgraded := PLAYER_CLASSES.learn(protagonist_track, specialization, "livro:" + book_id)
    if upgraded.is_empty():
        return false
    inventory[book_id] = int(inventory[book_id]) - 1
    protagonist_track = upgraded
    record_event("specialization_learned", current_region, [character_name], specialization + " via livro do chefe")
    save_game()
    return true

func set_npc_hero_class(npc_id: String, build: Dictionary) -> bool:
    # Registra a subclasse separada do rank de recrutamento A/S/SS.
    if not NPC_REGISTRY.PROFILES.has(npc_id) or not HERO_CLASSES.valid(build):
        return false
    npc_hero_builds[npc_id] = build.duplicate(true)
    save_game()
    return true

func evolve_npc_subclass(npc_id: String, next_rarity: String) -> bool:
    if not npc_hero_builds.has(npc_id):
        return false
    var upgrade := HERO_CLASSES.evolve(npc_hero_builds[npc_id], next_rarity)
    if upgrade.is_empty():
        return false
    npc_hero_builds[npc_id] = upgrade
    record_event("subclass_evolution", current_region, [npc_id], next_rarity)
    save_game()
    return true

func record_narrative_choice(key: String, value: String) -> bool:
    if narrative_flags.has(key):
        return false
    narrative_flags[key] = value
    record_event("narrative_choice", "Palacio", [character_name], key + ": " + value)
    save_game()
    return true

func resolve_town_dilemma(npc_id: String, answer: int) -> bool:
    var region := "Fortaleza" if npc_id == "doran" else "Porto Cinzento" if npc_id == "elira" else ""
    if region.is_empty() or current_region != region or answer < 0 or answer > 1:
        return false
    var flag := "dilema_" + npc_id
    if narrative_flags.has(flag):
        return false
    narrative_flags[flag] = "civis" if answer == 0 else "defesa_ou_trabalho"
    var reputation_gain := 5 if answer == 0 else 2
    region_reputation[region] = int(region_reputation.get(region, 0)) + reputation_gain
    gain_friendship(npc_id, 8 if answer == 0 else 4, "dilema")
    remember(npc_id, "dilema_" + str(answer))
    record_event("town_dilemma", region, [npc_id], flag + ": " + str(narrative_flags[flag]))
    save_game()
    return true

func choose_oath(protect: bool) -> void:
    if not oath.is_empty():
        return
    oath = "guardian" if protect else "exile"
    current_region = "Fortaleza" if protect else "Porto Cinzento"
    military_intel["garrison"]["Fortaleza"]["commander"] = character_name if protect else "general_vaelor"
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
        if str(movement["kind"]) == "npc_departed_tavern" and str(movement["status"]) == "travelling":
            var old_region := "Porto Cinzento" if new_region == "Fortaleza" else "Fortaleza"
            SIM.register_migration(migration_history, id, old_region, new_region, target_day)
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
        TERRITORY.settle_day(national_economy,day)
        for receipt in TERRITORY.settle_sales(national_economy,day):
            money += int(receipt["player"])
            record_event("consignment_sold",str(receipt["region"]),[character_name],"Venda de %s: %d moedas; tributo: %d" % [receipt["item"],int(receipt["player"]),int(receipt["tax"])])
        for returned_id in WORLD_RECORDS.update_expeditions(expeditions, day):
            SIM.add_report(military_intel, day, current_region if current_region in ["Fortaleza","Porto Cinzento"] else "Fortaleza", "Reconhecimento concluido; ameaças ainda nao verificadas")
            record_event("expedition_return", current_region, [character_name], "Expedicao %s retornou sem combate" % returned_id)
        if (day - 1) % 5 == 0:
            wave_number += 1
            if wave_number == DUKE.DEADLINE_WAVE:
                var duke_outcome := DUKE.resolve_tenth_wave(duke_state)
                if duke_outcome == "extra_boss":
                    record_event("duke_extra_boss", "Fortaleza", ["duque"], "O Carrasco do Juramento aparece na onda 10")
                elif duke_outcome == "died_at_home":
                    record_event("duke_death", "Mansao do Duque", ["duque"], "O Duque morreu em casa; a armadura nao foi obtida")
            record_event("wave", "Fortaleza", ["General Vaelor" if oath == "exile" else character_name], "Onda %d" % wave_number)
            # Ciclo economico simplificado de pos-defesa. Batalhas taticas das
            # ondas serao simuladas integralmente na fase de estrategia.
            settle_city_defense("onda_%d" % wave_number)
            if wave_number == 20:
                dungeon_unlocked = true
                record_event("dungeon_unlocked", "Lago Antigo", [], "Masmorra descoberta")
    save_game()

func settle_city_defense(battle_id: String) -> Dictionary:
    var receipt := ARMORY.settle_defense(city_armory,battle_id,int(building_levels.get("Ferraria",1)),day)
    if not receipt.is_empty():
        record_event("city_armory", "Fortaleza", ["soldados","ferraria"], "Ouro %d; trocas %d; reparos %d; faltas %d" % [int(receipt["paid_to_forge"]),int(receipt["replacements"]),int(receipt["repairs"]),int(receipt["unmet"])])
    return receipt

func register_apprenticeship(master_id: String, apprentice_id: String) -> bool:
    if not SIM.register_apprentice(legacy_records, master_id, apprentice_id):
        return false
    record_event("apprenticeship", current_region, [master_id, apprentice_id], "Vinculo mestre e aprendiz registrado")
    save_game()
    return true

func register_nemesis(enemy_id: String, reason: String) -> bool:
    if not SIM.remember_enemy(nemesis_records, enemy_id, day, reason):
        return false
    record_event("nemesis", current_region, [enemy_id], reason)
    save_game()
    return true

func launch_reconnaissance(destination: String) -> bool:
    if energy < WORLD_RECORDS.EXPEDITION_COST_ENERGY or money < WORLD_RECORDS.EXPEDITION_COST_MONEY:
        return false
    var expedition := WORLD_RECORDS.create_expedition(destination, day, expeditions.size() + 1)
    if expedition.is_empty():
        return false
    # Uma expedicao ativa por destino: evita repeticao sem beneficio.
    for existing in expeditions:
        if existing is Dictionary and existing.get("destination", "") == destination and existing.get("status", "") == "active":
            return false
    energy -= WORLD_RECORDS.EXPEDITION_COST_ENERGY
    money -= WORLD_RECORDS.EXPEDITION_COST_MONEY
    expeditions.append(expedition)
    record_event("expedition_started", current_region, [character_name], destination)
    save_game()
    return true

func observe_creature(creature_id: String, location: String) -> bool:
    if not WORLD_RECORDS.remember_creature(discovered_bestiary, creature_id, location, day):
        return false
    record_event("bestiary", current_region, [character_name], "Observou: %s" % creature_id)
    save_game()
    return true

func remember_fallen(npc_id: String, name: String, cause: String) -> bool:
    var entry := WORLD_RECORDS.memorial_entry(npc_id, name, day, cause)
    if entry.is_empty():
        return false
    for other in memorial:
        if other is Dictionary and other.get("id", "") == npc_id:
            return false
    memorial.append(entry)
    recruited.erase(npc_id)
    record_event("memorial", current_region, [npc_id], "Registrou perda de %s" % name)
    save_game()
    return true

func set_region_position(position: Vector3) -> void:
    if current_region in ["Fortaleza", "Porto Cinzento"]:
        # Store as array: JSON-compatible and safe after loading a save.
        region_positions[current_region] = [clampf(position.x, -26, 26), 0.0, clampf(position.z, -29, 29)]

func get_region_position() -> Vector3:
    var values: Array = region_positions.get(current_region, [0.0, 0.0, 13.0])
    if values.size() != 3:
        return Vector3(0, 0, 13)
    return Vector3(float(values[0]), 0.0, float(values[2]))

func travel(destination: String, distance: float) -> bool:
    if energy < 5 or destination == current_region or not ["Fortaleza", "Porto Cinzento"].has(destination):
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
    if id.is_empty() or not NPC_REGISTRY.base_recruitable(id) or id == "duque" or id == DUKE.DAUGHTER_ID:
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
    # Equipamento de combate: apenas forja ou comerciante de arquetipo.
    if GEAR.is_equipment(item_id):
        return false
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
    if equipped.values().has(item_id) and amount <= 1:
        return false
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

func hero_combat_stats() -> Dictionary:
    return {"level":hero_level,"xp":hero_xp,"next_xp":COMBAT.xp_for_next_level(hero_level),"hp":hero_hp,"max_hp":COMBAT.hero_max_hp(character_stats,hero_level,equipment_stats()),"mp":hero_mp,"max_mp":COMBAT.hero_max_mp(character_stats,hero_level,equipment_stats()),"attack":COMBAT.hero_attack(character_stats,equipment_stats()),"defense":COMBAT.hero_defense(character_stats,equipment_stats())}

func begin_field_battle(enemy_id: String, encounter_id: String) -> bool:
    if not active_battle.is_empty() or encounter_id.is_empty() or COMBAT.ENEMIES.get(enemy_id, {}).is_empty():
        return false
    if int(defeated_field_enemies.get(encounter_id,-1)) == day or hero_hp <= 0:
        return false
    var candidate := COMBAT.start(character_stats,equipment_stats(),str(protagonist_track.get("base_class","Guerreiro")),hero_level,hero_hp,hero_mp,enemy_id,difficulty,PARTY.form_party(recruited))
    if candidate.is_empty():
        return false
    candidate["encounter_id"] = encounter_id
    active_battle = candidate
    record_event("battle_started",current_region,[character_name],enemy_id)
    save_game()
    return true

func play_battle_turn(action: String) -> bool:
    if active_battle.get("state","") != "active":
        return false
    if not ["attack","skill","defend","potion"].has(action):
        return false
    if action == "potion" and int(inventory.get("pocao_vida",0)) < 1:
        return false
    var previous_turn := int(active_battle["turn"])
    var updated: Dictionary = COMBAT.act(active_battle,action)
    if int(updated.get("turn",previous_turn)) <= previous_turn:
        return false
    active_battle = updated
    if action == "potion":
        inventory["pocao_vida"] = int(inventory.get("pocao_vida",0)) - 1
    hero_hp = int(active_battle["hero_hp"])
    hero_mp = int(active_battle["hero_mp"])
    if active_battle["state"] == "won":
        var enemy: Dictionary = active_battle["enemy"]
        var earned_xp := COMBAT.reward_xp(int(enemy["xp"]),difficulty)
        hero_xp += earned_xp
        money += int(enemy["gold"])
        while hero_xp >= COMBAT.xp_for_next_level(hero_level):
            hero_xp -= COMBAT.xp_for_next_level(hero_level)
            hero_level += 1
            hero_hp = mini(COMBAT.hero_max_hp(character_stats,hero_level,equipment_stats()),hero_hp + 15)
            hero_mp = mini(COMBAT.hero_max_mp(character_stats,hero_level,equipment_stats()),hero_mp + 8)
        defeated_field_enemies[str(active_battle.get("encounter_id",""))] = day
        observe_creature(str(enemy["id"]),current_region)
        record_event("battle_victory",current_region,[character_name],"%s +%d XP" % [enemy["name"],earned_xp])
    elif active_battle["state"] == "lost":
        # Prototipo de combate: retorno seguro, sem apagar o save do jogador.
        # Morte permanente sera introduzida junto com as regras de sucessao.
        hero_hp = maxi(1,floori(float(COMBAT.hero_max_hp(character_stats,hero_level,equipment_stats()))/3.0))
        hero_mp = maxi(0,floori(float(COMBAT.hero_max_mp(character_stats,hero_level,equipment_stats()))/3.0))
        money = maxi(0,money - 12)
        record_event("battle_defeat",current_region,[character_name],"Derrotado; recuperacao na cidade")
    save_game()
    return true

func close_battle_result() -> bool:
    if active_battle.is_empty() or active_battle.get("state","") == "active":
        return false
    active_battle.clear()
    save_game()
    return true


func _deliver_equipment_reward(item_id: String, claim_key: String) -> bool:
    if item_id.is_empty() or not GEAR.is_special(item_id) or equipment_reward_claims.has(claim_key):
        return false
    equipment_reward_claims[claim_key] = true
    inventory[item_id] = int(inventory.get(item_id,0)) + 1
    record_event("rare_equipment_reward", current_region, [character_name], item_id)
    save_game()
    return true

func claim_dungeon_equipment(chamber_id: String) -> bool:
    # A masmorra abre apenas apos a onda 20.
    if not dungeon_unlocked or not active_battle.is_empty():
        return false
    var item_id := GEAR.reward_for("dungeon",chamber_id)
    return _deliver_equipment_reward(item_id,"dungeon:" + chamber_id)

func claim_quest_equipment(quest_id: String) -> bool:
    # Requer conclusao real da missao; nunca aceita so o nome do item.
    if str(quest_progress.get(quest_id,"")) != "complete":
        return false
    if quest_id == "evento_duque":
        return false # Exclusivamente pela funcao original do evento.
    var item_id := GEAR.reward_for("quest",quest_id)
    return _deliver_equipment_reward(item_id,"quest:" + quest_id)

func claim_boss_equipment(boss_id: String) -> bool:
    if str(active_battle.get("state","")) != "won":
        return false
    var enemy: Dictionary = active_battle.get("enemy",{})
    if str(enemy.get("id","")) != boss_id:
        return false
    var item_id := GEAR.reward_for("boss",boss_id)
    return _deliver_equipment_reward(item_id,"boss:" + boss_id)

func equip_item(item_id: String) -> bool:
    if not GEAR.can_equip(item_id, str(protagonist_track.get("base_class", ""))):
        return false
    if int(inventory.get(item_id, 0)) < 1:
        return false
    var slot := GEAR.slot_for(item_id)
    if not GEAR.SLOTS.has(slot):
        return false
    var old_max_hp := COMBAT.hero_max_hp(character_stats,hero_level,equipment_stats())
    var old_max_mp := COMBAT.hero_max_mp(character_stats,hero_level,equipment_stats())
    equipped[slot] = item_id
    var new_max_hp := COMBAT.hero_max_hp(character_stats,hero_level,equipment_stats())
    var new_max_mp := COMBAT.hero_max_mp(character_stats,hero_level,equipment_stats())
    hero_hp = clampi(hero_hp + maxi(0,new_max_hp-old_max_hp),1,new_max_hp)
    hero_mp = clampi(hero_mp + maxi(0,new_max_mp-old_max_mp),0,new_max_mp)
    record_event("equip", current_region, [character_name], item_id)
    save_game()
    return true

func equipment_stats() -> Dictionary:
    return GEAR.totals(equipped)

func buy_from_merchant(merchant_id: String, item_id: String) -> bool:
    if not GEAR.vendor_inventory(merchant_id).has(item_id):
        return false
    if not ITEMS.is_tradeable(item_id):
        return false
    if current_region == "Fortaleza" and oath == "exile":
        # Mantem a penalidade de preco ja definida para exilados.
        pass
    var cost := ITEMS.price(item_id, current_region, oath)
    if cost < 1 or money < cost:
        return false
    money -= cost
    inventory[item_id] = int(inventory.get(item_id, 0)) + 1
    record_event("merchant_equipment", current_region, [merchant_id, character_name], "Comprou: " + item_id)
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

func national_treasury(region: String) -> Dictionary:
    return national_economy.get("territories",{}).get(region,{})

func upgrade_public_building(building: String) -> bool:
    if current_region != "Fortaleza" or oath != "guardian":
        return false
    var level := int(building_levels.get(building,0))
    if not TERRITORY.build(national_economy,current_region,building,level):
        return false
    building_levels[building] = level+1
    record_event("public_building",current_region,[character_name],"%s nivel %d com Tesouro Nacional" % [building,level+1])
    save_game()
    return true

func consign_player_item(item_id: String, quantity: int = 1) -> bool:
    if not TERRITORY.valid_region(current_region) or not ITEMS.is_tradeable(item_id):
        return false
    # Equipamentos especiais permanecem fora das prateleiras publicas.
    if GEAR.is_special(item_id):
        return false
    if not TERRITORY.list_item(national_economy,item_id,ITEMS.get_item(item_id),quantity,current_region,day,inventory,equipped):
        return false
    record_event("consignment",current_region,[character_name],"Anunciou %s x%d no mercado" % [item_id,quantity])
    save_game()
    return true

func cancel_consignment(listing_id: int) -> bool:
    if not TERRITORY.withdraw_listing(national_economy,listing_id,inventory):
        return false
    record_event("consignment_withdrawn",current_region,[character_name],"Retirou anuncio %d" % listing_id)
    save_game()
    return true

func negotiate_territory_trade(destination: String, item_id: String, quantity: int) -> bool:
    if oath != "guardian" or current_region != "Fortaleza" or destination != "Porto Cinzento":
        return false
    var invoice := TERRITORY.trade_for_alliance(national_economy,current_region,destination,item_id,quantity)
    if invoice.is_empty():
        return false
    if bool(invoice["alliance"]):
        region_reputation[destination] = mini(100,int(region_reputation.get(destination,0))+15)
    record_event("territory_trade",current_region,[character_name],"%s x%d para %s; confianca %d" % [item_id,quantity,destination,int(invoice["relation"])])
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
    if not ["ferro", "ervas", "madeira", "pedra"].has(item_id):
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
    var roll: int = absi(hash("duke_daughter:%d" % day)) % 100
    var present := DUKE.tavern_roll(duke_state, day, wave_number, roll)
    if present:
        save_game()
    return present

func save_game() -> bool:
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        return false
    var data := {"schema": 1, "name": character_name, "character_origin": character_origin, "character_stats": character_stats, "character_appearance": character_appearance, "region_positions": region_positions, "hero_build": hero_build, "protagonist_track": protagonist_track, "npc_hero_builds": npc_hero_builds, "difficulty": difficulty, "oath": oath, "region": current_region, "day": day, "energy": energy, "agility_xp": agility_xp, "events": events, "npc_memory": npc_memory, "npc_friendship": npc_friendship, "friendship_days": last_friendship_interaction, "npc_lives": npc_lives, "npc_story_flags": npc_story_flags, "last_gift_day": last_gift_day, "food_bonuses": active_food_bonuses, "building_levels": building_levels, "reputation": region_reputation, "wave": wave_number, "dungeon": dungeon_unlocked, "money": money, "inventory": inventory, "equipped": equipped, "hero_level": hero_level, "hero_xp": hero_xp, "hero_hp": hero_hp, "hero_mp": hero_mp, "active_battle": active_battle, "defeated_field_enemies": defeated_field_enemies, "equipment_reward_claims": equipment_reward_claims, "city_armory": city_armory, "national_economy": national_economy, "recruited": recruited, "bestiary": discovered_bestiary, "expeditions": expeditions, "memorial": memorial, "military_intel": military_intel, "legacy_records": legacy_records, "nemesis_records": nemesis_records, "migration_history": migration_history, "quests": quest_progress, "collected_nodes": collected_nodes, "narrative_flags": narrative_flags, "duke_state": duke_state}
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
    character_origin = str(parsed.get("character_origin", "Andarilho"))
    character_stats = parsed.get("character_stats", CHARACTER.default_stats())
    character_appearance = int(parsed.get("character_appearance", 0))
    region_positions = {"Fortaleza":[0.0,0.0,13.0],"Porto Cinzento":[0.0,0.0,13.0]}
    var loaded_positions: Dictionary = parsed.get("region_positions", {})
    for region_key in region_positions:
        if loaded_positions.has(region_key) and loaded_positions[region_key] is Array and loaded_positions[region_key].size() == 3:
            region_positions[region_key] = loaded_positions[region_key]
    protagonist_track = parsed.get("protagonist_track", PLAYER_CLASSES.starting_track("Guerreiro"))
    if not PLAYER_CLASSES.valid_track(protagonist_track):
        protagonist_track = PLAYER_CLASSES.starting_track("Guerreiro")
    hero_build = parsed.get("hero_build", HERO_CLASSES.starter("Guerreiro"))
    if not HERO_CLASSES.valid(hero_build):
        hero_build = HERO_CLASSES.starter("Guerreiro")
    npc_hero_builds = HERO_CLASSES.default_npc_builds()
    var loaded_builds: Dictionary = parsed.get("npc_hero_builds", {})
    for npc_id in loaded_builds:
        if HERO_CLASSES.valid(loaded_builds[npc_id]):
            npc_hero_builds[npc_id] = loaded_builds[npc_id]
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
    # JSON devolve numeros como float; normalizar IDs de calendário para
    # manter comparacoes e rotinas deterministas apos carregar o save.
    for npc_id in npc_lives:
        if npc_lives[npc_id] is Dictionary:
            var itinerary: Dictionary = npc_lives[npc_id]
            for numeric_key in ["arrival_day", "departure_day", "next_arrival_day", "visits"]:
                if itinerary.has(numeric_key):
                    itinerary[numeric_key] = int(itinerary[numeric_key])
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
    hero_level = maxi(1,int(parsed.get("hero_level",1)))
    hero_xp = maxi(0,int(parsed.get("hero_xp",0)))
    hero_hp = clampi(int(parsed.get("hero_hp",COMBAT.hero_max_hp(character_stats,hero_level))),1,COMBAT.hero_max_hp(character_stats,hero_level))
    hero_mp = clampi(int(parsed.get("hero_mp",COMBAT.hero_max_mp(character_stats,hero_level))),0,COMBAT.hero_max_mp(character_stats,hero_level))
    active_battle = parsed.get("active_battle", {})
    if not active_battle is Dictionary or (not active_battle.is_empty() and not ["active","won","lost"].has(str(active_battle.get("state","")))):
        active_battle = {}
    defeated_field_enemies = parsed.get("defeated_field_enemies", {})
    equipment_reward_claims = parsed.get("equipment_reward_claims", {})
    city_armory = parsed.get("city_armory", ARMORY.initial_state())
    national_economy = parsed.get("national_economy", TERRITORY.initial_state())
    inventory = parsed.get("inventory", {"pao": 2})
    equipped = GEAR.equip_slots()
    var saved_equipment: Dictionary = parsed.get("equipped", {})
    for slot in GEAR.SLOTS:
        var item_id := str(saved_equipment.get(slot, ""))
        if GEAR.can_equip(item_id, str(protagonist_track.get("base_class", ""))) and int(inventory.get(item_id, 0)) > 0 and GEAR.slot_for(item_id) == slot:
            equipped[slot] = item_id
    hero_hp = clampi(hero_hp,1,COMBAT.hero_max_hp(character_stats,hero_level,equipment_stats()))
    hero_mp = clampi(hero_mp,0,COMBAT.hero_max_mp(character_stats,hero_level,equipment_stats()))
    recruited.clear()
    for id in parsed.get("recruited", []):
        recruited.append(str(id))
    discovered_bestiary = parsed.get("bestiary", {})
    expeditions = parsed.get("expeditions", [])
    memorial = parsed.get("memorial", [])
    military_intel = parsed.get("military_intel", SIM.initial_intelligence())
    legacy_records = parsed.get("legacy_records", SIM.initial_legacy())
    nemesis_records = parsed.get("nemesis_records", SIM.initial_nemeses())
    migration_history = parsed.get("migration_history", [])
    quest_progress = parsed.get("quests", {})
    collected_nodes = parsed.get("collected_nodes", {})
    narrative_flags = parsed.get("narrative_flags", {})
    duke_state = DUKE.initial_state()
    var persisted_duke: Variant = parsed.get("duke_state", {})
    if persisted_duke is Dictionary:
        duke_state.merge(persisted_duke, true)
    return true
