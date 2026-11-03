extends RefCounted
## Equipamentos basicos por classe do protagonista: quatro slots independentes.
## Itens de evento (armadura do duque / espada do heroi) NAO estao neste catalogo.
const SLOTS := ["weapon", "head", "chest", "feet"]
const CLASS_ORDER := ["Guerreiro", "Cavaleiro", "Mago", "Sacerdote"]
const GEAR := {"guerreiro_weapon_comum":{"name":"Espada de ferro","class":"Guerreiro","slot":"weapon","rarity":"Comum","price":70,"stats":{"attack":5,"defense":0}},"guerreiro_head_comum":{"name":"Capacete de guerreiro","class":"Guerreiro","slot":"head","rarity":"Comum","price":48,"stats":{"attack":0,"defense":3}},"guerreiro_chest_comum":{"name":"Peitoral de guerreiro","class":"Guerreiro","slot":"chest","rarity":"Comum","price":85,"stats":{"attack":0,"defense":5}},"guerreiro_feet_comum":{"name":"Botas de guerreiro","class":"Guerreiro","slot":"feet","rarity":"Comum","price":42,"stats":{"attack":0,"defense":2}},"guerreiro_weapon_raro":{"name":"Arma magistral de Guerreiro","class":"Guerreiro","slot":"weapon","rarity":"Raro","price":420,"stats":{"attack":16,"defense":0}},"guerreiro_chest_epico":{"name":"Armadura superior de Guerreiro","class":"Guerreiro","slot":"chest","rarity":"Epico","price":1150,"stats":{"attack":0,"defense":22}},"cavaleiro_weapon_comum":{"name":"Lanca de guarda","class":"Cavaleiro","slot":"weapon","rarity":"Comum","price":70,"stats":{"attack":5,"defense":0}},"cavaleiro_head_comum":{"name":"Capacete de cavaleiro","class":"Cavaleiro","slot":"head","rarity":"Comum","price":48,"stats":{"attack":0,"defense":3}},"cavaleiro_chest_comum":{"name":"Peitoral de cavaleiro","class":"Cavaleiro","slot":"chest","rarity":"Comum","price":85,"stats":{"attack":0,"defense":5}},"cavaleiro_feet_comum":{"name":"Botas de cavaleiro","class":"Cavaleiro","slot":"feet","rarity":"Comum","price":42,"stats":{"attack":0,"defense":2}},"cavaleiro_weapon_raro":{"name":"Arma magistral de Cavaleiro","class":"Cavaleiro","slot":"weapon","rarity":"Raro","price":420,"stats":{"attack":16,"defense":0}},"cavaleiro_chest_epico":{"name":"Armadura superior de Cavaleiro","class":"Cavaleiro","slot":"chest","rarity":"Epico","price":1150,"stats":{"attack":0,"defense":22}},"mago_weapon_comum":{"name":"Cajado de freixo","class":"Mago","slot":"weapon","rarity":"Comum","price":70,"stats":{"attack":5,"defense":0}},"mago_head_comum":{"name":"Capacete de mago","class":"Mago","slot":"head","rarity":"Comum","price":48,"stats":{"attack":0,"defense":3}},"mago_chest_comum":{"name":"Peitoral de mago","class":"Mago","slot":"chest","rarity":"Comum","price":85,"stats":{"attack":0,"defense":5}},"mago_feet_comum":{"name":"Botas de mago","class":"Mago","slot":"feet","rarity":"Comum","price":42,"stats":{"attack":0,"defense":2}},"mago_weapon_raro":{"name":"Arma magistral de Mago","class":"Mago","slot":"weapon","rarity":"Raro","price":420,"stats":{"attack":16,"defense":0}},"mago_chest_epico":{"name":"Armadura superior de Mago","class":"Mago","slot":"chest","rarity":"Epico","price":1150,"stats":{"attack":0,"defense":22}},"sacerdote_weapon_comum":{"name":"Cetro de carvalho","class":"Sacerdote","slot":"weapon","rarity":"Comum","price":70,"stats":{"attack":5,"defense":0}},"sacerdote_head_comum":{"name":"Capacete de sacerdote","class":"Sacerdote","slot":"head","rarity":"Comum","price":48,"stats":{"attack":0,"defense":3}},"sacerdote_chest_comum":{"name":"Peitoral de sacerdote","class":"Sacerdote","slot":"chest","rarity":"Comum","price":85,"stats":{"attack":0,"defense":5}},"sacerdote_feet_comum":{"name":"Botas de sacerdote","class":"Sacerdote","slot":"feet","rarity":"Comum","price":42,"stats":{"attack":0,"defense":2}},"sacerdote_weapon_raro":{"name":"Arma magistral de Sacerdote","class":"Sacerdote","slot":"weapon","rarity":"Raro","price":420,"stats":{"attack":16,"defense":0}},"sacerdote_chest_epico":{"name":"Armadura superior de Sacerdote","class":"Sacerdote","slot":"chest","rarity":"Epico","price":1150,"stats":{"attack":0,"defense":22}}}
const FORGE_RECIPES := {"guerreiro_weapon_comum":{"building":"Ferraria","level":1,"money":25,"materials":{"ferro":2,"madeira":1}},"guerreiro_head_comum":{"building":"Ferraria","level":1,"money":15,"materials":{"ferro":2,"madeira":1}},"guerreiro_chest_comum":{"building":"Ferraria","level":1,"money":30,"materials":{"ferro":3,"madeira":1}},"guerreiro_feet_comum":{"building":"Ferraria","level":1,"money":15,"materials":{"ferro":2,"madeira":1}},"cavaleiro_weapon_comum":{"building":"Ferraria","level":1,"money":25,"materials":{"ferro":2,"madeira":1}},"cavaleiro_head_comum":{"building":"Ferraria","level":1,"money":15,"materials":{"ferro":2,"madeira":1}},"cavaleiro_chest_comum":{"building":"Ferraria","level":1,"money":30,"materials":{"ferro":3,"madeira":1}},"cavaleiro_feet_comum":{"building":"Ferraria","level":1,"money":15,"materials":{"ferro":2,"madeira":1}},"mago_weapon_comum":{"building":"Ferraria","level":1,"money":25,"materials":{"ferro":2,"madeira":1}},"mago_head_comum":{"building":"Ferraria","level":1,"money":15,"materials":{"ferro":2,"madeira":1}},"mago_chest_comum":{"building":"Ferraria","level":1,"money":30,"materials":{"ferro":3,"madeira":1}},"mago_feet_comum":{"building":"Ferraria","level":1,"money":15,"materials":{"ferro":2,"madeira":1}},"sacerdote_weapon_comum":{"building":"Ferraria","level":1,"money":25,"materials":{"ferro":2,"madeira":1}},"sacerdote_head_comum":{"building":"Ferraria","level":1,"money":15,"materials":{"ferro":2,"madeira":1}},"sacerdote_chest_comum":{"building":"Ferraria","level":1,"money":30,"materials":{"ferro":3,"madeira":1}},"sacerdote_feet_comum":{"building":"Ferraria","level":1,"money":15,"materials":{"ferro":2,"madeira":1}}}
const MERCHANT_ARCHETYPES := {"doran":"Guerreiro","mercador_marcial":"Cavaleiro","mercador_arcano":"Mago","mercador_sagrado":"Sacerdote"}

static func is_equipment(id: String) -> bool:
    return GEAR.has(id)

static func can_equip(id: String, hero_class: String) -> bool:
    return GEAR.has(id) and str(GEAR[id]["class"]) == hero_class

static func slot_for(id: String) -> String:
    return str(GEAR[id]["slot"]) if GEAR.has(id) else ""

static func vendor_inventory(npc_id: String) -> Array[String]:
    var answer: Array[String] = []
    var archetype := str(MERCHANT_ARCHETYPES.get(npc_id, ""))
    for id in GEAR:
        if GEAR[id]["class"] == archetype and GEAR[id]["rarity"] in ["Raro", "Epico"]:
            answer.append(str(id))
    answer.sort()
    return answer

static func equip_slots() -> Dictionary:
    return {"weapon":"","head":"","chest":"","feet":""}

static func totals(equipped: Dictionary) -> Dictionary:
    var result := {"attack":0,"defense":0}
    for slot in SLOTS:
        var id := str(equipped.get(slot, ""))
        if GEAR.has(id) and str(GEAR[id]["slot"]) == slot:
            result["attack"] += int(GEAR[id]["stats"].get("attack",0))
            result["defense"] += int(GEAR[id]["stats"].get("defense",0))
    return result
