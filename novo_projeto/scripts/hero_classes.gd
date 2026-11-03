extends RefCounted
## Subclasses independentes de raridade dos itens e rank de herois A/S/SS.
const RARITIES := ["Raro", "Epico", "Lendario", "Mitico"]
const ELEMENTS := ["Terra", "Agua", "Fogo", "Vento"]
const CLASSES := {
    "Guerreiro": {"Espada e Escudo":["Raro","Epico"],"Samurai":["Raro","Epico"],"Mestre Espadachim":["Lendario","Mitico"]},
    "Arqueiro": {"Atirador":["Raro","Epico"],"Cacador":["Raro","Epico"],"Arqueiro Celestial":["Lendario","Mitico"]},
    "Assassino": {"Batedor":["Raro","Epico"],"Lamina Sombria":["Raro","Epico"],"Mestre das Sombras":["Lendario","Mitico"]},
    "Defensor": {"Escudeiro":["Raro","Epico"],"Guardiao":["Raro","Epico"],"Bastiao Vivo":["Lendario","Mitico"]},
    "Curandeiro": {"Herbalista":["Raro","Epico"],"Sacerdote":["Raro","Epico"],"Sabio da Vida":["Lendario","Mitico"]},
    "Mago": {"Mago Elemental":["Raro","Epico","Lendario"],"Mago do Trovao":["Epico"],"Mago Verde":["Epico"],"Elementalista":["Lendario","Mitico"]}
}
const STARTERS := {"Guerreiro":"Espada e Escudo","Arqueiro":"Atirador","Assassino":"Batedor","Defensor":"Escudeiro","Curandeiro":"Herbalista","Mago":"Mago Elemental"}
const POWER := {"Raro":1.0,"Epico":1.25,"Lendario":1.6,"Mitico":2.0}

static func starter(archetype: String) -> Dictionary:
    if not STARTERS.has(archetype):
        return {}
    return {"class":archetype,"subclass":STARTERS[archetype],"rarity":"Raro","elements":["Terra"] if archetype == "Mago" else [],"evolved":false}

static func permitted(archetype: String, subclass: String, elements: Array = []) -> Array:
    if not CLASSES.has(archetype) or not CLASSES[archetype].has(subclass):
        return []
    if archetype != "Mago":
        return CLASSES[archetype][subclass]
    var unique := []
    for element in elements:
        if unique.has(element):
            return []
        unique.append(element)
    if subclass == "Mago do Trovao":
        return ["Epico"] if unique == ["Trovao"] else []
    if subclass == "Mago Verde":
        return ["Epico"] if unique == ["Verde"] else []
    for element in unique:
        if not ELEMENTS.has(element):
            return []
    if subclass == "Elementalista":
        return ["Lendario","Mitico"] if unique.size() == 4 else []
    if subclass == "Mago Elemental":
        match unique.size():
            1: return ["Raro"]
            2: return ["Epico"]
            3: return ["Lendario"]
    return []

static func valid(build: Dictionary) -> bool:
    var tiers := permitted(str(build.get("class","")),str(build.get("subclass","")),build.get("elements",[]))
    return tiers.has(str(build.get("rarity",""))) and (str(build.get("rarity","")) != "Mitico" or bool(build.get("evolved",false)))

static func make(archetype: String, subclass: String, elements: Array = [], tier: String = "", evolved: bool = false) -> Dictionary:
    var tiers := permitted(archetype,subclass,elements)
    if tiers.is_empty():
        return {}
    var rarity := tier if not tier.is_empty() else str(tiers[0])
    var build := {"class":archetype,"subclass":subclass,"rarity":rarity,"elements":elements.duplicate(),"evolved":evolved}
    return build if valid(build) else {}

static func evolve(build: Dictionary, tier: String) -> Dictionary:
    if not valid(build):
        return {}
    if RARITIES.find(tier) != RARITIES.find(str(build["rarity"])) + 1:
        return {}
    var result := build.duplicate(true)
    result["rarity"] = tier
    result["evolved"] = true
    return result if valid(result) else {}

static func become_elementalist(build: Dictionary) -> Dictionary:
    if not valid(build) or build["class"] != "Mago" or build["subclass"] != "Mago Elemental" or build["rarity"] != "Lendario":
        return {}
    return make("Mago","Elementalista",ELEMENTS,"Lendario",true)

static func multiplier(build: Dictionary) -> float:
    return float(POWER.get(str(build.get("rarity","")),0)) if valid(build) else 0.0

static func learn_element(build: Dictionary, element: String) -> Dictionary:
    if not valid(build) or build["class"] != "Mago" or build["subclass"] != "Mago Elemental":
        return {}
    if not ELEMENTS.has(element) or build["elements"].has(element) or build["elements"].size() >= 3:
        return {}
    var known: Array = build["elements"].duplicate()
    known.append(element)
    var tiers := permitted("Mago","Mago Elemental",known)
    if tiers.is_empty():
        return {}
    return make("Mago","Mago Elemental",known,str(tiers[0]),true)

static func promote_specialist(build: Dictionary, next_subclass: String) -> Dictionary:
    if not valid(build) or build["class"] == "Mago" or build["rarity"] != "Epico":
        return {}
    var archetype_name := str(build["class"])
    if not CLASSES[archetype_name].has(next_subclass):
        return {}
    if not CLASSES[archetype_name][next_subclass].has("Lendario"):
        return {}
    return make(archetype_name,next_subclass,[],"Lendario",true)

static func default_npc_builds() -> Dictionary:
    # Rank A/S/SS permanece independente da raridade de subclasse.
    return {
        "doran": make("Guerreiro", "Espada e Escudo", [], "Raro"),
        "elira": make("Guerreiro", "Samurai", [], "Raro"),
        "kael": make("Arqueiro", "Cacador", [], "Raro"),
        "mira": make("Curandeiro", "Herbalista", [], "Raro"),
        "duque": make("Guerreiro", "Espada e Escudo", [], "Epico"),
        "herdeira_duque": make("Guerreiro", "Mestre Espadachim", [], "Lendario"),
        "general_vaelor": make("Defensor", "Bastiao Vivo", [], "Lendario")
    }
