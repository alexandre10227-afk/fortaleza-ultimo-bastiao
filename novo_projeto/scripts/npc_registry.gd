extends RefCounted
const CATEGORIES := ["Comerciantes", "Soldados", "Ferreiros", "Cidadaos comuns", "Fazendeiros", "Nobres"]
const PROFILES := {
    "doran": {"category":"Ferreiros", "recruitable":true, "important":true, "vendor":true},
    "elira": {"category":"Soldados", "recruitable":true, "important":true, "vendor":false},
    "mira": {"category":"Cidadaos comuns", "recruitable":true, "important":true, "vendor":false},
    "kael": {"category":"Soldados", "recruitable":true, "important":true, "vendor":false},
    "selene": {"category":"Soldados", "recruitable":true, "important":true, "vendor":false},
    "duque": {"category":"Nobres", "recruitable":true, "important":true, "vendor":false, "special":true},
    "herdeira_duque": {"category":"Nobres", "recruitable":true, "important":true, "vendor":false, "special":true},
    "rei_aldric": {"category":"Nobres", "recruitable":false, "important":true, "vendor":false},
    "general_vaelor": {"category":"Soldados", "recruitable":false, "important":true, "vendor":false},
    "mercador_viajante": {"category":"Comerciantes", "recruitable":false, "important":false, "vendor":true},
    "iris_feirante": {"category":"Comerciantes", "recruitable":false, "important":false, "vendor":true},
    "bento_agricultor": {"category":"Fazendeiros", "recruitable":false, "important":false, "vendor":false},
    "lia_moradora": {"category":"Cidadaos comuns", "recruitable":false, "important":false, "vendor":false},
}
static func profile(id: String) -> Dictionary:
    return PROFILES.get(id, {"category":"Cidadaos comuns", "recruitable":false, "important":false, "vendor":false}).duplicate(true)

static func base_recruitable(id: String) -> bool:
    return bool(profile(id).get("recruitable", false))

static func is_vendor(id: String) -> bool:
    return bool(profile(id).get("vendor", false))

static func list_filtered(category: String = "", recruitable: int = -1, important: int = -1) -> Array[Dictionary]:
    var out: Array[Dictionary] = []
    for id in PROFILES:
        var p: Dictionary = PROFILES[id]
        if not category.is_empty() and p["category"] != category:
            continue
        if recruitable != -1 and bool(p["recruitable"]) != (recruitable == 1):
            continue
        if important != -1 and bool(p["important"]) != (important == 1):
            continue
        var entry := p.duplicate(true)
        entry["id"] = id
        out.append(entry)
    return out
