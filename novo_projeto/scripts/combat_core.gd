extends RefCounted
## Combate tatico por turnos da Fase 2. Nao interfere nas ondas de defesa.
const HERO_CLASSES := ["Guerreiro", "Cavaleiro", "Mago", "Sacerdote"]
const CLASS_SKILLS := {
    "Guerreiro": {"name":"Golpe Poderoso","power":9,"mana":4,"type":"attack"},
    "Cavaleiro": {"name":"Postura de Guarda","power":8,"mana":3,"type":"guard"},
    "Mago": {"name":"Centelha Arcana","power":13,"mana":6,"type":"attack"},
    "Sacerdote": {"name":"Prece de Amparo","power":13,"mana":5,"type":"heal"}
}
const ENEMIES := {
    "lobo_cinzento": {"name":"Lobo Cinzento","hp":38,"attack":8,"defense":2,"xp":18,"gold":10},
    "saqueador": {"name":"Saqueador","hp":52,"attack":11,"defense":4,"xp":26,"gold":16},
    "guardiao_de_pedra": {"name":"Guardiao de Pedra","hp":78,"attack":14,"defense":8,"xp":45,"gold":24}
}

static func hero_max_hp(stats: Dictionary, level: int) -> int:
    return 55 + int(stats.get("Constituicao",1)) * 9 + (maxi(1,level)-1)*5

static func hero_max_mp(stats: Dictionary, level: int) -> int:
    return 17 + int(stats.get("Inteligencia",1))*5 + (maxi(1,level)-1)*2

static func hero_attack(stats: Dictionary, gear: Dictionary) -> int:
    return 5 + int(stats.get("Forca",1))*2 + int(gear.get("attack",0))

static func hero_defense(stats: Dictionary, gear: Dictionary) -> int:
    return 2 + int(stats.get("Constituicao",1)) + int(gear.get("defense",0))

static func xp_for_next_level(level: int) -> int:
    return 35 + maxi(1,level)*25

static func enemy_stats(enemy_id: String, difficulty: String = "Normal") -> Dictionary:
    if not ENEMIES.has(enemy_id):
        return {}
    var enemy: Dictionary = ENEMIES[enemy_id].duplicate(true)
    var factor := 1.0
    match difficulty:
        "Facil": factor = .75
        "Dificil": factor = 1.35
        "Impossivel": factor = 1.8
    enemy["hp"] = maxi(1, roundi(float(enemy["hp"])*factor))
    enemy["attack"] = maxi(1, roundi(float(enemy["attack"])*factor))
    enemy["max_hp"] = enemy["hp"]
    enemy["id"] = enemy_id
    return enemy

static func damage(attack: int, defense: int, bonus: int = 0) -> int:
    return maxi(1, attack + bonus - floori(float(defense)*0.55))

static func start(hero_stats: Dictionary, gear: Dictionary, hero_class: String, level: int, hp: int, mp: int, enemy_id: String, difficulty: String) -> Dictionary:
    if not HERO_CLASSES.has(hero_class) or not ENEMIES.has(enemy_id):
        return {}
    var enemy := enemy_stats(enemy_id, difficulty)
    var max_hp := hero_max_hp(hero_stats,level)
    var max_mp := hero_max_mp(hero_stats,level)
    if hp <= 0:
        return {}
    return {"state":"active","turn":1,"hero_class":hero_class,"hero_hp":mini(hp,max_hp),"hero_mp":clampi(mp,0,max_mp),"max_hp":max_hp,"max_mp":max_mp,"attack":hero_attack(hero_stats,gear),"defense":hero_defense(hero_stats,gear),"guard":false,"enemy":enemy,"log":["Uma criatura se aproxima."],"result":""}

static func act(battle: Dictionary, action: String) -> Dictionary:
    if battle.get("state","") != "active":
        return battle.duplicate(true)
    if not ["attack","skill","defend","potion"].has(action):
        return battle.duplicate(true)
    var output: Dictionary = battle.duplicate(true)
    var enemy: Dictionary = output["enemy"]
    var messages: Array = output["log"]
    var hero_class := str(output["hero_class"])
    var spell: Dictionary = CLASS_SKILLS[hero_class]
    var mana_cost := int(spell["mana"])
    if action == "skill" and int(output["hero_mp"]) < mana_cost:
        return output
    match action:
        "attack":
            var hit := damage(int(output["attack"]),int(enemy["defense"]))
            enemy["hp"] = maxi(0,int(enemy["hp"])-hit)
            messages.append("Voce causou %d de dano." % hit)
        "skill":
            output["hero_mp"] = int(output["hero_mp"])-mana_cost
            match spell["type"]:
                "attack":
                    var hit := damage(int(output["attack"]),int(enemy["defense"]),int(spell["power"]))
                    enemy["hp"] = maxi(0,int(enemy["hp"])-hit)
                    messages.append("%s: %d de dano." % [spell["name"],hit])
                "guard":
                    output["guard"] = true
                    messages.append("Postura de Guarda: defesa preparada.")
                "heal":
                    var recovery := mini(int(spell["power"])+floori(float(output["max_hp"])*.08),int(output["max_hp"])-int(output["hero_hp"]))
                    output["hero_hp"] = int(output["hero_hp"])+recovery
                    messages.append("Prece de Amparo: +%d PV." % recovery)
        "defend":
            output["guard"] = true
            output["hero_mp"] = mini(int(output["max_mp"]),int(output["hero_mp"])+2)
            messages.append("Defesa reforcada; recuperou 2 PM.")
        "potion":
            var recovery := mini(24,int(output["max_hp"])-int(output["hero_hp"]))
            output["hero_hp"] = int(output["hero_hp"])+recovery
            messages.append("Pocao: +%d PV." % recovery)
    if int(enemy["hp"]) <= 0:
        output["state"] = "won"
        output["result"] = "victory"
        messages.append("Vitoria! A criatura foi derrotada.")
    else:
        var response := damage(int(enemy["attack"]),int(output["defense"]))
        if bool(output["guard"]):
            response = maxi(1,ceili(float(response)*.35))
        output["guard"] = false
        output["hero_hp"] = maxi(0,int(output["hero_hp"])-response)
        messages.append("%s atacou: -%d PV." % [enemy["name"],response])
        if int(output["hero_hp"]) <= 0:
            output["state"] = "lost"
            output["result"] = "defeat"
            messages.append("Voce caiu em combate.")
    output["turn"] = int(output["turn"])+1
    while messages.size() > 6:
        messages.remove_at(0)
    return output

static func reward_xp(base_xp: int, difficulty: String) -> int:
    var ratio := 1.0
    match difficulty:
        "Facil": ratio = 1.25
        "Normal": ratio = 1.1
        "Dificil": ratio = 1.75
        "Impossivel": ratio = 3.0
    return maxi(1,roundi(float(base_xp)*ratio))
