extends RefCounted

const CATALOG := {
    "pao": {"name": "Pao de viagem", "price": 8},
    "ervas": {"name": "Ervas medicinais", "price": 12},
    "ferro": {"name": "Minerio de ferro", "price": 20},
}
const VISITORS := [
    {"id": "elira", "name": "Elira", "rarity": "Raro", "home": "Porto Cinzento", "profession": "Mercenaria"},
    {"id": "doran", "name": "Doran", "rarity": "Comum", "home": "Fortaleza", "profession": "Ferreiro"},
    {"id": "mira", "name": "Mira", "rarity": "Incomum", "home": "Porto Cinzento", "profession": "Curandeira"},
    {"id": "kael", "name": "Kael", "rarity": "Epico", "home": "Fortaleza", "profession": "Explorador"},
    {"id": "selene", "name": "Selene", "rarity": "Lendario", "home": "Porto Cinzento", "profession": "Estrategista"},
]

static func tavern_visitors(region: String, day: int) -> Array[Dictionary]:
    var available: Array[Dictionary] = []
    for index in range(VISITORS.size()):
        var npc: Dictionary = VISITORS[index]
        if ((day + index * 3 + (0 if region == "Fortaleza" else 1)) % 4) < 2:
            available.append(npc.duplicate(true))
    return available

static func price(item_id: String, region: String, oath: String) -> int:
    if not CATALOG.has(item_id):
        return -1
    var cost: int = CATALOG[item_id]["price"]
    return cost * (3 if oath == "exile" and region == "Fortaleza" else 1)

static func can_recruit(npc: Dictionary, oath: String) -> bool:
    return not (oath == "exile" and npc.get("home", "") == "Fortaleza")
