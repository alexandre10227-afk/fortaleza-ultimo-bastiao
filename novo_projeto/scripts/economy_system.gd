extends RefCounted
## Regras economicas. Custos, receitas e melhorias nao alteram relacoes sociais.
const RECIPES := {
    "espada_madeira": {"building":"Oficina", "level":1, "money":12, "materials":{"madeira":2}},
    "bainha_medida": {"building":"Ferraria", "level":2, "money":45, "materials":{"madeira":1,"ferro":2}},
    "espada_cerimonia": {"building":"Ferraria", "level":3, "money":170, "materials":{"ferro":4,"pedra_incomum":1}},
    "sopa_ervas": {"building":"Cozinha", "level":1, "money":10, "materials":{"ervas":2}},
    "tratado_estrategia": {"building":"Escritorio", "level":3, "money":120, "materials":{"pergaminho":3,"pena_tinteiro":1}},
}
const BUILDING_UPGRADE_BASE := {
    "Ferraria": {"money": 110, "materials": {"ferro":3}},
    "Oficina": {"money": 80, "materials": {"madeira":3}},
    "Cozinha": {"money": 70, "materials": {"madeira":2}},
    "Escritorio": {"money": 120, "materials": {"madeira":2,"pergaminho":1}},
    "Muralha": {"money": 160, "materials": {"ferro":4,"madeira":2}},
}
const MAX_BUILDING_LEVEL := 5

static func can_pay(inventory: Dictionary, money: int, materials: Dictionary, cost: int) -> bool:
    if cost < 0 or money < cost:
        return false
    for item_id in materials:
        if int(inventory.get(item_id, 0)) < int(materials[item_id]):
            return false
    return true

static func remove_materials(inventory: Dictionary, materials: Dictionary) -> void:
    for item_id in materials:
        inventory[item_id] = int(inventory.get(item_id, 0)) - int(materials[item_id])

static func upgrade_cost(building: String, current_level: int) -> Dictionary:
    if not BUILDING_UPGRADE_BASE.has(building) or current_level < 1 or current_level >= MAX_BUILDING_LEVEL:
        return {}
    var base: Dictionary = BUILDING_UPGRADE_BASE[building]
    var materials: Dictionary = {}
    for id in base["materials"]:
        materials[id] = int(base["materials"][id]) * current_level
    return {"money": int(base["money"]) * current_level, "materials": materials}

static func craft_cost(item_id: String, buildings: Dictionary) -> Dictionary:
    if not RECIPES.has(item_id):
        return {}
    var data: Dictionary = RECIPES[item_id]
    if int(buildings.get(data["building"], 0)) < int(data["level"]):
        return {}
    return data
