extends RefCounted
## Catalogo comerciavel. Itens unicos/armas especiais ficam em unique_weapons.gd.
const RARITIES := ["Comum", "Raro", "Epico", "Lendario"]
const CATEGORIES := ["Arte", "Comestiveis", "Estudos", "Minerios", "Armas", "Armaduras"]
const ITEMS := {
    # Arte: presentes para colecionadores, nobres e estudiosos.
    "estatua_argila": {"name":"Estatua de argila", "category":"Arte", "rarity":"Comum", "price":18},
    "xicara_antiga": {"name":"Xicara antiga", "category":"Arte", "rarity":"Raro", "price":75},
    "pintura_tinta": {"name":"Pintura a tinta", "category":"Arte", "rarity":"Epico", "price":260},
    "estatua_jade": {"name":"Estatua de jade", "category":"Arte", "rarity":"Lendario", "price":1200},
    # Comestiveis: presentes OU refeicoes que aplicam bonus temporarios.
    "pocao_vida": {"name":"Pocao de vida", "category":"Comestiveis", "rarity":"Comum", "price":22, "bonus":{}, "duration":1},
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
    # Novos equipamentos vendaveis e de forja. Exclusivos nao sao comerciaveis.
    "guerreiro_weapon_raro": {"name": "Arma magistral de Guerreiro", "category": "Armas", "rarity": "Raro", "price": 420},
    "guerreiro_chest_epico": {"name": "Armadura superior de Guerreiro", "category": "Armaduras", "rarity": "Epico", "price": 1150},
    "cavaleiro_weapon_raro": {"name": "Arma magistral de Cavaleiro", "category": "Armas", "rarity": "Raro", "price": 420},
    "cavaleiro_chest_epico": {"name": "Armadura superior de Cavaleiro", "category": "Armaduras", "rarity": "Epico", "price": 1150},
    "mago_weapon_raro": {"name": "Arma magistral de Mago", "category": "Armas", "rarity": "Raro", "price": 420},
    "mago_chest_epico": {"name": "Armadura superior de Mago", "category": "Armaduras", "rarity": "Epico", "price": 1150},
    "sacerdote_weapon_raro": {"name": "Arma magistral de Sacerdote", "category": "Armas", "rarity": "Raro", "price": 420},
    "sacerdote_chest_epico": {"name": "Armadura superior de Sacerdote", "category": "Armaduras", "rarity": "Epico", "price": 1150},
    "guerreiro_arma_comum_1": {"name": "Espada do Soldado — Comum", "category": "Armas", "rarity": "Comum", "price": 90},
    "guerreiro_arma_comum_2": {"name": "Machado de Campanha — Comum", "category": "Armas", "rarity": "Comum", "price": 135},
    "guerreiro_arma_comum_3": {"name": "Montante do Vanguardeiro — Comum", "category": "Armas", "rarity": "Comum", "price": 180},
    "guerreiro_arma_raro_1": {"name": "Espada do Soldado — Raro", "category": "Armas", "rarity": "Raro", "price": 340},
    "guerreiro_arma_raro_2": {"name": "Machado de Campanha — Raro", "category": "Armas", "rarity": "Raro", "price": 385},
    "guerreiro_arma_raro_3": {"name": "Montante do Vanguardeiro — Raro", "category": "Armas", "rarity": "Raro", "price": 430},
    "guerreiro_arma_epico_1": {"name": "Espada do Soldado — Epico", "category": "Armas", "rarity": "Epico", "price": 1100},
    "guerreiro_arma_epico_2": {"name": "Machado de Campanha — Epico", "category": "Armas", "rarity": "Epico", "price": 1145},
    "guerreiro_arma_epico_3": {"name": "Montante do Vanguardeiro — Epico", "category": "Armas", "rarity": "Epico", "price": 1190},
    "guerreiro_armadura_head_linha_1": {"name": "Elmo de Lamina Rubra", "category": "Armaduras", "rarity": "Raro", "price": 400},
    "guerreiro_armadura_chest_linha_1": {"name": "Peitoral de Lamina Rubra", "category": "Armaduras", "rarity": "Raro", "price": 436},
    "guerreiro_armadura_feet_linha_1": {"name": "Botas de Lamina Rubra", "category": "Armaduras", "rarity": "Raro", "price": 388},
    "guerreiro_armadura_head_linha_2": {"name": "Elmo de Escudo de Ferro", "category": "Armaduras", "rarity": "Epico", "price": 1220},
    "guerreiro_armadura_chest_linha_2": {"name": "Peitoral de Escudo de Ferro", "category": "Armaduras", "rarity": "Epico", "price": 1292},
    "guerreiro_armadura_feet_linha_2": {"name": "Botas de Escudo de Ferro", "category": "Armaduras", "rarity": "Epico", "price": 1196},
    "cavaleiro_arma_comum_1": {"name": "Lanca do Juramento — Comum", "category": "Armas", "rarity": "Comum", "price": 90},
    "cavaleiro_arma_comum_2": {"name": "Espada da Guarda — Comum", "category": "Armas", "rarity": "Comum", "price": 135},
    "cavaleiro_arma_comum_3": {"name": "Maça da Fortaleza — Comum", "category": "Armas", "rarity": "Comum", "price": 180},
    "cavaleiro_arma_raro_1": {"name": "Lanca do Juramento — Raro", "category": "Armas", "rarity": "Raro", "price": 340},
    "cavaleiro_arma_raro_2": {"name": "Espada da Guarda — Raro", "category": "Armas", "rarity": "Raro", "price": 385},
    "cavaleiro_arma_raro_3": {"name": "Maça da Fortaleza — Raro", "category": "Armas", "rarity": "Raro", "price": 430},
    "cavaleiro_arma_epico_1": {"name": "Lanca do Juramento — Epico", "category": "Armas", "rarity": "Epico", "price": 1100},
    "cavaleiro_arma_epico_2": {"name": "Espada da Guarda — Epico", "category": "Armas", "rarity": "Epico", "price": 1145},
    "cavaleiro_arma_epico_3": {"name": "Maça da Fortaleza — Epico", "category": "Armas", "rarity": "Epico", "price": 1190},
    "cavaleiro_armadura_head_linha_1": {"name": "Elmo de Bastiao", "category": "Armaduras", "rarity": "Raro", "price": 400},
    "cavaleiro_armadura_chest_linha_1": {"name": "Peitoral de Bastiao", "category": "Armaduras", "rarity": "Raro", "price": 436},
    "cavaleiro_armadura_feet_linha_1": {"name": "Botas de Bastiao", "category": "Armaduras", "rarity": "Raro", "price": 388},
    "cavaleiro_armadura_head_linha_2": {"name": "Elmo de Sentinela", "category": "Armaduras", "rarity": "Epico", "price": 1220},
    "cavaleiro_armadura_chest_linha_2": {"name": "Peitoral de Sentinela", "category": "Armaduras", "rarity": "Epico", "price": 1292},
    "cavaleiro_armadura_feet_linha_2": {"name": "Botas de Sentinela", "category": "Armaduras", "rarity": "Epico", "price": 1196},
    "mago_arma_comum_1": {"name": "Cajado das Runas — Comum", "category": "Armas", "rarity": "Comum", "price": 90},
    "mago_arma_comum_2": {"name": "Orbe das Brumas — Comum", "category": "Armas", "rarity": "Comum", "price": 135},
    "mago_arma_comum_3": {"name": "Livro de Centelhas — Comum", "category": "Armas", "rarity": "Comum", "price": 180},
    "mago_arma_raro_1": {"name": "Cajado das Runas — Raro", "category": "Armas", "rarity": "Raro", "price": 340},
    "mago_arma_raro_2": {"name": "Orbe das Brumas — Raro", "category": "Armas", "rarity": "Raro", "price": 385},
    "mago_arma_raro_3": {"name": "Livro de Centelhas — Raro", "category": "Armas", "rarity": "Raro", "price": 430},
    "mago_arma_epico_1": {"name": "Cajado das Runas — Epico", "category": "Armas", "rarity": "Epico", "price": 1100},
    "mago_arma_epico_2": {"name": "Orbe das Brumas — Epico", "category": "Armas", "rarity": "Epico", "price": 1145},
    "mago_arma_epico_3": {"name": "Livro de Centelhas — Epico", "category": "Armas", "rarity": "Epico", "price": 1190},
    "mago_armadura_head_linha_1": {"name": "Elmo de Sabedoria", "category": "Armaduras", "rarity": "Raro", "price": 400},
    "mago_armadura_chest_linha_1": {"name": "Peitoral de Sabedoria", "category": "Armaduras", "rarity": "Raro", "price": 436},
    "mago_armadura_feet_linha_1": {"name": "Botas de Sabedoria", "category": "Armaduras", "rarity": "Raro", "price": 388},
    "mago_armadura_head_linha_2": {"name": "Elmo de Quatro Ventos", "category": "Armaduras", "rarity": "Epico", "price": 1220},
    "mago_armadura_chest_linha_2": {"name": "Peitoral de Quatro Ventos", "category": "Armaduras", "rarity": "Epico", "price": 1292},
    "mago_armadura_feet_linha_2": {"name": "Botas de Quatro Ventos", "category": "Armaduras", "rarity": "Epico", "price": 1196},
    "sacerdote_arma_comum_1": {"name": "Cetro da Aurora — Comum", "category": "Armas", "rarity": "Comum", "price": 90},
    "sacerdote_arma_comum_2": {"name": "Livro das Preces — Comum", "category": "Armas", "rarity": "Comum", "price": 135},
    "sacerdote_arma_comum_3": {"name": "Bastao da Clemencia — Comum", "category": "Armas", "rarity": "Comum", "price": 180},
    "sacerdote_arma_raro_1": {"name": "Cetro da Aurora — Raro", "category": "Armas", "rarity": "Raro", "price": 340},
    "sacerdote_arma_raro_2": {"name": "Livro das Preces — Raro", "category": "Armas", "rarity": "Raro", "price": 385},
    "sacerdote_arma_raro_3": {"name": "Bastao da Clemencia — Raro", "category": "Armas", "rarity": "Raro", "price": 430},
    "sacerdote_arma_epico_1": {"name": "Cetro da Aurora — Epico", "category": "Armas", "rarity": "Epico", "price": 1100},
    "sacerdote_arma_epico_2": {"name": "Livro das Preces — Epico", "category": "Armas", "rarity": "Epico", "price": 1145},
    "sacerdote_arma_epico_3": {"name": "Bastao da Clemencia — Epico", "category": "Armas", "rarity": "Epico", "price": 1190},
    "sacerdote_armadura_head_linha_1": {"name": "Elmo de Aurora", "category": "Armaduras", "rarity": "Raro", "price": 400},
    "sacerdote_armadura_chest_linha_1": {"name": "Peitoral de Aurora", "category": "Armaduras", "rarity": "Raro", "price": 436},
    "sacerdote_armadura_feet_linha_1": {"name": "Botas de Aurora", "category": "Armaduras", "rarity": "Raro", "price": 388},
    "sacerdote_armadura_head_linha_2": {"name": "Elmo de Peregrino", "category": "Armaduras", "rarity": "Epico", "price": 1220},
    "sacerdote_armadura_chest_linha_2": {"name": "Peitoral de Peregrino", "category": "Armaduras", "rarity": "Epico", "price": 1292},
    "sacerdote_armadura_feet_linha_2": {"name": "Botas de Peregrino", "category": "Armaduras", "rarity": "Epico", "price": 1196},
    # Equipamentos regulares por classe, slots independentes.
    "guerreiro_weapon_comum": {"name":"Espada de ferro", "category":"Armas", "rarity":"Comum", "price":70},
    "guerreiro_head_comum": {"name":"Capacete de guerreiro", "category":"Armas", "rarity":"Comum", "price":48},
    "guerreiro_chest_comum": {"name":"Peitoral de guerreiro", "category":"Armas", "rarity":"Comum", "price":85},
    "guerreiro_feet_comum": {"name":"Botas de guerreiro", "category":"Armas", "rarity":"Comum", "price":42},
    "guerreiro_weapon_raro": {"name":"Arma magistral de Guerreiro", "category":"Armas", "rarity":"Raro", "price":420},
    "guerreiro_chest_epico": {"name":"Armadura superior de Guerreiro", "category":"Armas", "rarity":"Epico", "price":1150},
    "cavaleiro_weapon_comum": {"name":"Lanca de guarda", "category":"Armas", "rarity":"Comum", "price":70},
    "cavaleiro_head_comum": {"name":"Capacete de cavaleiro", "category":"Armas", "rarity":"Comum", "price":48},
    "cavaleiro_chest_comum": {"name":"Peitoral de cavaleiro", "category":"Armas", "rarity":"Comum", "price":85},
    "cavaleiro_feet_comum": {"name":"Botas de cavaleiro", "category":"Armas", "rarity":"Comum", "price":42},
    "cavaleiro_weapon_raro": {"name":"Arma magistral de Cavaleiro", "category":"Armas", "rarity":"Raro", "price":420},
    "cavaleiro_chest_epico": {"name":"Armadura superior de Cavaleiro", "category":"Armas", "rarity":"Epico", "price":1150},
    "mago_weapon_comum": {"name":"Cajado de freixo", "category":"Armas", "rarity":"Comum", "price":70},
    "mago_head_comum": {"name":"Capacete de mago", "category":"Armas", "rarity":"Comum", "price":48},
    "mago_chest_comum": {"name":"Peitoral de mago", "category":"Armas", "rarity":"Comum", "price":85},
    "mago_feet_comum": {"name":"Botas de mago", "category":"Armas", "rarity":"Comum", "price":42},
    "mago_weapon_raro": {"name":"Arma magistral de Mago", "category":"Armas", "rarity":"Raro", "price":420},
    "mago_chest_epico": {"name":"Armadura superior de Mago", "category":"Armas", "rarity":"Epico", "price":1150},
    "sacerdote_weapon_comum": {"name":"Cetro de carvalho", "category":"Armas", "rarity":"Comum", "price":70},
    "sacerdote_head_comum": {"name":"Capacete de sacerdote", "category":"Armas", "rarity":"Comum", "price":48},
    "sacerdote_chest_comum": {"name":"Peitoral de sacerdote", "category":"Armas", "rarity":"Comum", "price":85},
    "sacerdote_feet_comum": {"name":"Botas de sacerdote", "category":"Armas", "rarity":"Comum", "price":42},
    "sacerdote_weapon_raro": {"name":"Arma magistral de Sacerdote", "category":"Armas", "rarity":"Raro", "price":420},
    "sacerdote_chest_epico": {"name":"Armadura superior de Sacerdote", "category":"Armas", "rarity":"Epico", "price":1150},
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
    "mercador_marcial": "Armas",
    "mercador_arcano": "Estudos",
    "mercador_sagrado": "Arte",
    "iris_feirante": "Arte",
    "bento_agricultor": "Comestiveis",
    "lia_moradora": "Estudos",
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
    "Feirante": "Arte",
    "Agricultor": "Comestiveis",
    "Moradora": "Estudos",
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
