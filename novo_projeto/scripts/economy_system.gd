extends RefCounted
## Regras economicas. Custos, receitas e melhorias nao alteram relacoes sociais.
const RECIPES := {
    "guerreiro_weapon_raro": {"building":"Ferraria", "level":2, "money":150, "materials":{"ferro":4,"pedra_incomum":1}},
    "guerreiro_chest_epico": {"building":"Ferraria", "level":4, "money":540, "materials":{"ferro":9,"cristal_azul":2,"pedra_incomum":3}},
    "cavaleiro_weapon_raro": {"building":"Ferraria", "level":2, "money":150, "materials":{"ferro":4,"pedra_incomum":1}},
    "cavaleiro_chest_epico": {"building":"Ferraria", "level":4, "money":540, "materials":{"ferro":9,"cristal_azul":2,"pedra_incomum":3}},
    "mago_weapon_raro": {"building":"Ferraria", "level":2, "money":150, "materials":{"ferro":4,"pedra_incomum":1}},
    "mago_chest_epico": {"building":"Ferraria", "level":4, "money":540, "materials":{"ferro":9,"cristal_azul":2,"pedra_incomum":3}},
    "sacerdote_weapon_raro": {"building":"Ferraria", "level":2, "money":150, "materials":{"ferro":4,"pedra_incomum":1}},
    "sacerdote_chest_epico": {"building":"Ferraria", "level":4, "money":540, "materials":{"ferro":9,"cristal_azul":2,"pedra_incomum":3}},
    "guerreiro_arma_raro_1": {"building":"Ferraria", "level":2, "money":150, "materials":{"ferro":4,"pedra_incomum":1}},
    "guerreiro_arma_raro_2": {"building":"Ferraria", "level":2, "money":150, "materials":{"ferro":4,"pedra_incomum":1}},
    "guerreiro_arma_raro_3": {"building":"Ferraria", "level":3, "money":150, "materials":{"ferro":4,"pedra_incomum":1}},
    "guerreiro_arma_epico_1": {"building":"Ferraria", "level":4, "money":540, "materials":{"ferro":7,"cristal_azul":2,"pedra_incomum":3}},
    "guerreiro_arma_epico_2": {"building":"Ferraria", "level":4, "money":540, "materials":{"ferro":7,"cristal_azul":2,"pedra_incomum":3}},
    "guerreiro_arma_epico_3": {"building":"Ferraria", "level":5, "money":540, "materials":{"ferro":7,"cristal_azul":2,"pedra_incomum":3}},
    "guerreiro_armadura_head_linha_1": {"building":"Ferraria", "level":3, "money":175, "materials":{"ferro":4,"pedra_incomum":2}},
    "guerreiro_armadura_chest_linha_1": {"building":"Ferraria", "level":3, "money":175, "materials":{"ferro":5,"pedra_incomum":2}},
    "guerreiro_armadura_feet_linha_1": {"building":"Ferraria", "level":3, "money":175, "materials":{"ferro":4,"pedra_incomum":2}},
    "guerreiro_armadura_head_linha_2": {"building":"Ferraria", "level":4, "money":540, "materials":{"ferro":7,"cristal_azul":2,"pedra_incomum":3}},
    "guerreiro_armadura_chest_linha_2": {"building":"Ferraria", "level":4, "money":540, "materials":{"ferro":9,"cristal_azul":2,"pedra_incomum":3}},
    "guerreiro_armadura_feet_linha_2": {"building":"Ferraria", "level":4, "money":540, "materials":{"ferro":7,"cristal_azul":2,"pedra_incomum":3}},
    "cavaleiro_arma_raro_1": {"building":"Ferraria", "level":2, "money":150, "materials":{"ferro":4,"pedra_incomum":1}},
    "cavaleiro_arma_raro_2": {"building":"Ferraria", "level":2, "money":150, "materials":{"ferro":4,"pedra_incomum":1}},
    "cavaleiro_arma_raro_3": {"building":"Ferraria", "level":3, "money":150, "materials":{"ferro":4,"pedra_incomum":1}},
    "cavaleiro_arma_epico_1": {"building":"Ferraria", "level":4, "money":540, "materials":{"ferro":7,"cristal_azul":2,"pedra_incomum":3}},
    "cavaleiro_arma_epico_2": {"building":"Ferraria", "level":4, "money":540, "materials":{"ferro":7,"cristal_azul":2,"pedra_incomum":3}},
    "cavaleiro_arma_epico_3": {"building":"Ferraria", "level":5, "money":540, "materials":{"ferro":7,"cristal_azul":2,"pedra_incomum":3}},
    "cavaleiro_armadura_head_linha_1": {"building":"Ferraria", "level":3, "money":175, "materials":{"ferro":4,"pedra_incomum":2}},
    "cavaleiro_armadura_chest_linha_1": {"building":"Ferraria", "level":3, "money":175, "materials":{"ferro":5,"pedra_incomum":2}},
    "cavaleiro_armadura_feet_linha_1": {"building":"Ferraria", "level":3, "money":175, "materials":{"ferro":4,"pedra_incomum":2}},
    "cavaleiro_armadura_head_linha_2": {"building":"Ferraria", "level":4, "money":540, "materials":{"ferro":7,"cristal_azul":2,"pedra_incomum":3}},
    "cavaleiro_armadura_chest_linha_2": {"building":"Ferraria", "level":4, "money":540, "materials":{"ferro":9,"cristal_azul":2,"pedra_incomum":3}},
    "cavaleiro_armadura_feet_linha_2": {"building":"Ferraria", "level":4, "money":540, "materials":{"ferro":7,"cristal_azul":2,"pedra_incomum":3}},
    "mago_arma_raro_1": {"building":"Ferraria", "level":2, "money":150, "materials":{"ferro":4,"pedra_incomum":1}},
    "mago_arma_raro_2": {"building":"Ferraria", "level":2, "money":150, "materials":{"ferro":4,"pedra_incomum":1}},
    "mago_arma_raro_3": {"building":"Ferraria", "level":3, "money":150, "materials":{"ferro":4,"pedra_incomum":1}},
    "mago_arma_epico_1": {"building":"Ferraria", "level":4, "money":540, "materials":{"ferro":7,"cristal_azul":2,"pedra_incomum":3}},
    "mago_arma_epico_2": {"building":"Ferraria", "level":4, "money":540, "materials":{"ferro":7,"cristal_azul":2,"pedra_incomum":3}},
    "mago_arma_epico_3": {"building":"Ferraria", "level":5, "money":540, "materials":{"ferro":7,"cristal_azul":2,"pedra_incomum":3}},
    "mago_armadura_head_linha_1": {"building":"Ferraria", "level":3, "money":175, "materials":{"ferro":4,"pedra_incomum":2}},
    "mago_armadura_chest_linha_1": {"building":"Ferraria", "level":3, "money":175, "materials":{"ferro":5,"pedra_incomum":2}},
    "mago_armadura_feet_linha_1": {"building":"Ferraria", "level":3, "money":175, "materials":{"ferro":4,"pedra_incomum":2}},
    "mago_armadura_head_linha_2": {"building":"Ferraria", "level":4, "money":540, "materials":{"ferro":7,"cristal_azul":2,"pedra_incomum":3}},
    "mago_armadura_chest_linha_2": {"building":"Ferraria", "level":4, "money":540, "materials":{"ferro":9,"cristal_azul":2,"pedra_incomum":3}},
    "mago_armadura_feet_linha_2": {"building":"Ferraria", "level":4, "money":540, "materials":{"ferro":7,"cristal_azul":2,"pedra_incomum":3}},
    "sacerdote_arma_raro_1": {"building":"Ferraria", "level":2, "money":150, "materials":{"ferro":4,"pedra_incomum":1}},
    "sacerdote_arma_raro_2": {"building":"Ferraria", "level":2, "money":150, "materials":{"ferro":4,"pedra_incomum":1}},
    "sacerdote_arma_raro_3": {"building":"Ferraria", "level":3, "money":150, "materials":{"ferro":4,"pedra_incomum":1}},
    "sacerdote_arma_epico_1": {"building":"Ferraria", "level":4, "money":540, "materials":{"ferro":7,"cristal_azul":2,"pedra_incomum":3}},
    "sacerdote_arma_epico_2": {"building":"Ferraria", "level":4, "money":540, "materials":{"ferro":7,"cristal_azul":2,"pedra_incomum":3}},
    "sacerdote_arma_epico_3": {"building":"Ferraria", "level":5, "money":540, "materials":{"ferro":7,"cristal_azul":2,"pedra_incomum":3}},
    "sacerdote_armadura_head_linha_1": {"building":"Ferraria", "level":3, "money":175, "materials":{"ferro":4,"pedra_incomum":2}},
    "sacerdote_armadura_chest_linha_1": {"building":"Ferraria", "level":3, "money":175, "materials":{"ferro":5,"pedra_incomum":2}},
    "sacerdote_armadura_feet_linha_1": {"building":"Ferraria", "level":3, "money":175, "materials":{"ferro":4,"pedra_incomum":2}},
    "sacerdote_armadura_head_linha_2": {"building":"Ferraria", "level":4, "money":540, "materials":{"ferro":7,"cristal_azul":2,"pedra_incomum":3}},
    "sacerdote_armadura_chest_linha_2": {"building":"Ferraria", "level":4, "money":540, "materials":{"ferro":9,"cristal_azul":2,"pedra_incomum":3}},
    "sacerdote_armadura_feet_linha_2": {"building":"Ferraria", "level":4, "money":540, "materials":{"ferro":7,"cristal_azul":2,"pedra_incomum":3}},
    "guerreiro_arma_comum_1": {"building":"Ferraria", "level":1, "money":24, "materials":{"ferro":2,"madeira":1}},
    "guerreiro_arma_comum_2": {"building":"Ferraria", "level":1, "money":32, "materials":{"ferro":3,"madeira":1}},
    "guerreiro_arma_comum_3": {"building":"Ferraria", "level":1, "money":40, "materials":{"ferro":4,"madeira":1}},
    "cavaleiro_arma_comum_1": {"building":"Ferraria", "level":1, "money":24, "materials":{"ferro":2,"madeira":1}},
    "cavaleiro_arma_comum_2": {"building":"Ferraria", "level":1, "money":32, "materials":{"ferro":3,"madeira":1}},
    "cavaleiro_arma_comum_3": {"building":"Ferraria", "level":1, "money":40, "materials":{"ferro":4,"madeira":1}},
    "mago_arma_comum_1": {"building":"Ferraria", "level":1, "money":24, "materials":{"ferro":2,"madeira":1}},
    "mago_arma_comum_2": {"building":"Ferraria", "level":1, "money":32, "materials":{"ferro":3,"madeira":1}},
    "mago_arma_comum_3": {"building":"Ferraria", "level":1, "money":40, "materials":{"ferro":4,"madeira":1}},
    "sacerdote_arma_comum_1": {"building":"Ferraria", "level":1, "money":24, "materials":{"ferro":2,"madeira":1}},
    "sacerdote_arma_comum_2": {"building":"Ferraria", "level":1, "money":32, "materials":{"ferro":3,"madeira":1}},
    "sacerdote_arma_comum_3": {"building":"Ferraria", "level":1, "money":40, "materials":{"ferro":4,"madeira":1}},
    "guerreiro_weapon_comum": {"building":"Ferraria", "level":1, "money":25, "materials":{"ferro":2,"madeira":1}},
    "guerreiro_head_comum": {"building":"Ferraria", "level":1, "money":15, "materials":{"ferro":2,"madeira":1}},
    "guerreiro_chest_comum": {"building":"Ferraria", "level":1, "money":30, "materials":{"ferro":3,"madeira":1}},
    "guerreiro_feet_comum": {"building":"Ferraria", "level":1, "money":15, "materials":{"ferro":2,"madeira":1}},
    "cavaleiro_weapon_comum": {"building":"Ferraria", "level":1, "money":25, "materials":{"ferro":2,"madeira":1}},
    "cavaleiro_head_comum": {"building":"Ferraria", "level":1, "money":15, "materials":{"ferro":2,"madeira":1}},
    "cavaleiro_chest_comum": {"building":"Ferraria", "level":1, "money":30, "materials":{"ferro":3,"madeira":1}},
    "cavaleiro_feet_comum": {"building":"Ferraria", "level":1, "money":15, "materials":{"ferro":2,"madeira":1}},
    "mago_weapon_comum": {"building":"Ferraria", "level":1, "money":25, "materials":{"ferro":2,"madeira":1}},
    "mago_head_comum": {"building":"Ferraria", "level":1, "money":15, "materials":{"ferro":2,"madeira":1}},
    "mago_chest_comum": {"building":"Ferraria", "level":1, "money":30, "materials":{"ferro":3,"madeira":1}},
    "mago_feet_comum": {"building":"Ferraria", "level":1, "money":15, "materials":{"ferro":2,"madeira":1}},
    "sacerdote_weapon_comum": {"building":"Ferraria", "level":1, "money":25, "materials":{"ferro":2,"madeira":1}},
    "sacerdote_head_comum": {"building":"Ferraria", "level":1, "money":15, "materials":{"ferro":2,"madeira":1}},
    "sacerdote_chest_comum": {"building":"Ferraria", "level":1, "money":30, "materials":{"ferro":3,"madeira":1}},
    "sacerdote_feet_comum": {"building":"Ferraria", "level":1, "money":15, "materials":{"ferro":2,"madeira":1}},
    "espada_madeira": {"building":"Oficina", "level":1, "money":12, "materials":{"madeira":2}},
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
