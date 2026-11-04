extends RefCounted
## Assistencia de companheiros recrutados; sem mortes permanentes neste modulo.
## Nao convoca NPCs nao recrutados e nao altera a progressao social.
const PROFILES := {
    "elira": {"name":"Elira","role":"striker","max_hp":64,"attack":15,"defense":5},
    "doran": {"name":"Doran","role":"guardian","max_hp":82,"attack":10,"defense":11},
    "mira": {"name":"Mira","role":"healer","max_hp":52,"attack":7,"defense":5},
    "kael": {"name":"Kael","role":"striker","max_hp":62,"attack":17,"defense":6},
    "selene": {"name":"Selene","role":"support","max_hp":58,"attack":10,"defense":7}
}
const MAX_PARTY := 2

static func form_party(recruited: Array) -> Array:
    var result: Array = []
    for id in recruited:
        var key := str(id)
        if not PROFILES.has(key):
            continue
        if result.any(func(member: Dictionary) -> bool: return str(member.get("id","")) == key):
            continue
        var member: Dictionary = PROFILES[key].duplicate(true)
        member["id"] = key
        member["hp"] = int(member["max_hp"])
        member["guard"] = false
        result.append(member)
        if result.size() == MAX_PARTY:
            break
    return result

static func assist(battle: Dictionary) -> void:
    var allies: Array = battle.get("allies",[])
    var enemy: Dictionary = battle.get("enemy",{})
    var messages: Array = battle.get("log",[])
    for member in allies:
        if not member is Dictionary or int(member.get("hp",0)) <= 0 or int(enemy.get("hp",0)) <= 0:
            continue
        var role := str(member.get("role","striker"))
        var label := str(member.get("name","Companheiro"))
        if role == "healer" and int(battle.get("hero_hp",0)) < int(battle.get("max_hp",0))*0.68:
            var healed := mini(12, int(battle["max_hp"])-int(battle["hero_hp"]))
            battle["hero_hp"] = int(battle["hero_hp"])+healed
            messages.append("%s curou %d PV do heroi." % [label,healed])
        elif role == "guardian":
            member["guard"] = true
            var hit := maxi(1,int(member["attack"])-floori(float(enemy.get("defense",0))*.5))
            enemy["hp"] = maxi(0,int(enemy["hp"])-hit)
            messages.append("%s protege o grupo e causa %d de dano." % [label,hit])
        elif role == "support":
            battle["hero_mp"] = mini(int(battle["max_mp"]),int(battle["hero_mp"])+2)
            var hit := maxi(1,int(member["attack"])-floori(float(enemy.get("defense",0))*.5))
            enemy["hp"] = maxi(0,int(enemy["hp"])-hit)
            messages.append("%s recupera 2 PM e causa %d de dano." % [label,hit])
        else:
            var hit := maxi(1,int(member["attack"])-floori(float(enemy.get("defense",0))*.5))
            enemy["hp"] = maxi(0,int(enemy["hp"])-hit)
            messages.append("%s causa %d de dano." % [label,hit])

static func enemy_target(battle: Dictionary, incoming: int) -> bool:
    # Um golpe a cada tres turnos e direcionado a um aliado; alvo previsivel
    # e legivel pelo jogador, sem RNG por quadro.
    var turn := int(battle.get("turn",1))
    if turn % 3 != 0:
        return false
    var allies: Array = battle.get("allies",[])
    var alive: Array = []
    for member in allies:
        if member is Dictionary and int(member.get("hp",0)) > 0:
            alive.append(member)
    if alive.is_empty():
        return false
    var target: Dictionary = alive[(int(turn / 3) - 1) % alive.size()]
    var reduced := maxi(1,incoming - floori(float(target.get("defense",0))*.45))
    if bool(target.get("guard",false)):
        reduced = maxi(1,ceili(float(reduced)*.55))
    target["hp"] = maxi(0,int(target["hp"])-reduced)
    target["guard"] = false
    var line := "%s recebeu %d de dano." % [target.get("name","Companheiro"),reduced]
    if int(target["hp"]) <= 0:
        line += " Caiu, mas podera se recuperar apos a luta."
    battle["log"].append(line)
    return true
