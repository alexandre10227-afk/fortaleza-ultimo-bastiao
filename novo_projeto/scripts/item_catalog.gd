extends RefCounted
## Catalogo comerciavel. Itens unicos/armas especiais ficam em unique_weapons.gd.
const RARITIES := ["Comum", "Raro", "Epico", "Lendario"]
const CATEGORIES := ["Arte", "Comestiveis", "Estudos", "Minerios", "Armas"]
const ITEMS := {
    # Arte: presentes para colecionadores, nobres e estudiosos.
    "estatua_argila": {"name":"Estatua de argila", "category":"Arte", "rarity":"Comum", "price":18},
    "xicara_antiga": {"name":"Xicara antiga", "category":"Arte", "rarity":"Raro", "price":75},
    "pintura_tinta": {"name":"Pintura a tinta", "category":"Arte", "rarity":"Epico", "price":260},
    "estatua_jade": {"name":"Estatua de jade", "category":"Arte", "rarity":"Lendario", "price":1200},
    # Comestiveis: presentes OU refeicoes que aplicam bonus temporarios.
    "maca": {"name":"Maca fresca", "category":"Comestiveis", "rarity":"Comum", "price":6, "bonus":{"vigor":1}, "duration":1},
    "ervas": {"name":"Ervas medicinais", "category":"Comestiveis", "rarity":"Comum", "price":12, "bonus":{"vigor":1}, "duration":1},
    "cenoura": {"name":"Cenoura", "category":"Comestiveis", "rarity":"Comum", "price":5, "bonus":{"vigor":1}, "duration":1},
    "carne_assada": {"name":"Carne assada", "category":"Comestiveis", "rarity":"Raro", "price":32, "bonus":{"forca":2}, "duration":1},
    "sopa_ervas": {"name":"Sopa de ervas", "category":"Comestiveis", "rarity":"Raro", "price":27, "bonus":{"vigor":2}, "duration":1},
    "sopa_imperial": {"name":"Sopa imperial", "category":"Comestiveis", "rarity":"Epico", "price":130, "bonus":{"vigor":3,"forca":1}, "duration":2},
    "banquete_ancestral": {"name":"Banquete ancestral", "category":"Comestiveis", "rarity":"Lendario", "price":700, "bonus":{"vigor":4,"forca":3}, "duration":2},
    # Estudos: presentes a estudiosos, escribas e estrategistas.
    "pena_tinteiro": {"name":"Pena e tinteiro", "category":"Estudos", "rarity":"Comum", "price":13},
    "pergaminho": {"name":"Pergaminho", "category":"Estudos", "rarity":"Comum", "price":11},
    "livro_historia": {"name":"Livro de historia", "category":"Estudos", "rarity":"Raro", "price":64},
    "tratado_estrategia": {"name":"Tratado de estrategia", "category":"Estudos", "rarity":"Epico", "price":290},
    "compendio_perdido": {"name":"Compendio perdido", "category":"Estudos", "rarity":"Lendario", "price":1350},
    # Materiais: presentes, fabricacao e melhorias de construcoes.
    "ferro": {"name":"Minerio de ferro", "category":"Minerios", "rarity":"Comum", "price":20},
    "pedra_incomum": {"name":"Pedra incomum", "category":"Minerios", "rarity":"Raro", "price":90},
    "cristal_azul": {"name":"Cristal azul", "category":"Minerios", "rarity":"Epico", "price":320},
    "meteorito": {"name":"Fragmento de meteorito", "category":"Minerios", "rarity":"Lendario", "price":1600},
    # Armas comerciaveis/cerimoniais. Sem armas narrativas unicas aqui.
    "espada_madeira": {"name":"Espada de madeira", "category":"Armas", "rarity":"Comum", "price":25},
    "bainha_medida": {"name":"Bainha feita sob medida", "category":"Armas", "rarity":"Raro", "price":95},
    "espada_cerimonia": {"name":"Espada de cerimonia", "category":"Armas", "rarity":"Epico", "price":440},
    "sabre_magistral": {"name":"Sabre magistral", "category":"Armas", "rarity":"Lendario", "price":2100},
}
const RARITY_SELL_FACTOR := .5
# Cada personagem aceita somente uma categoria de presente.
# Preferencias nao sao intercambiaveis com a raridade ou profissao.
const NPC_GIFT_CATEGORY := {
    "doran": "Minerios",
    "elira": "Armas",
    "mira": "Comestiveis",
    "kael": "Armas",
    "selene": "Estudos",
    "duque": "Arte",
    "herdeira_duque": "Arte",
}
const PROFESSION_GIFT_CATEGORY := {
    "Ferreiro": "Minerios",
    "Mineiro": "Minerios",
    "Soldado": "Armas",
    "Curandeira": "Comestiveis",
    "Estrategista": "Estudos",
    "Explorador": "Armas",
    "Mercenaria": "Armas",
    "Escriba": "Estudos",
    "Artista": "Arte",
}
const RARITY_BASE_AFFECTION := {"Comum":4,"Raro":7,"Epico":11,"Lendario":16}

static func is_tradeable(item_id: String) -> bool:
    return ITEMS.has(item_id)

static func get_item(item_id: String) -> Dictionary:
    return ITEMS.get(item_id, {})

static func price(item_id: String, region: String, oath: String, travelling_merchant: bool = false) -> int:
    if not ITEMS.has(item_id):
        return -1
    var cost := int(ITEMS[item_id]["price"])
    if oath == "exile" and region == "Fortaleza":
        cost *= 3
    if travelling_merchant:
        cost = ceili(float(cost) * 1.2)
    return cost

static func sell_price(item_id: String) -> int:
    if not ITEMS.has(item_id):
        return -1
    return maxi(1, int(floori(float(ITEMS[item_id]["price"]) * RARITY_SELL_FACTOR)))

static func preferred_category(npc_id: String, profession: String = "") -> String:
    if NPC_GIFT_CATEGORY.has(npc_id):
        return str(NPC_GIFT_CATEGORY[npc_id])
    return str(PROFESSION_GIFT_CATEGORY.get(profession, ""))

static func accepts_gift(npc_id: String, profession: String, item_id: String) -> bool:
    if not ITEMS.has(item_id):
        return false
    var preferred := preferred_category(npc_id, profession)
    return not preferred.is_empty() and str(ITEMS[item_id]["category"]) == preferred

static func gift_affection(npc_id: String, profession: String, item_id: String) -> int:
    if not accepts_gift(npc_id, profession, item_id):
        return 0
    return int(RARITY_BASE_AFFECTION[ITEMS[item_id]["rarity"]])

static func can_eat(item_id: String) -> bool:
    return ITEMS.has(item_id) and ITEMS[item_id]["category"] == "Comestiveis"

static func is_valid_catalog() -> bool:
    for item in ITEMS.values():
        if not CATEGORIES.has(item["category"]) or not RARITIES.has(item["rarity"]) or int(item["price"]) <= 0:
            return false
    return true
