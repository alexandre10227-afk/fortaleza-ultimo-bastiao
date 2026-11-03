extends RefCounted
## Original character creation; a visible, persistent starting distribution.
const ATTRIBUTES := ["Forca", "Constituicao", "Destreza", "Inteligencia", "Sorte"]
const STARTING_POINTS := 10
const MIN_STAT := 1
const MAX_STAT := 10
const ORIGINS := {
    "Campones": {"description": "Conhece a terra e o custo de sustentar uma cidade.", "bonus": {"Constituicao": 1}},
    "Aprendiz de Ferreiro": {"description": "Aprendeu a trabalhar metal antes de empunhar uma arma.", "bonus": {"Forca": 1}},
    "Escriba": {"description": "Aprendeu historia e politica por meio de livros.", "bonus": {"Inteligencia": 1}},
    "Andarilho": {"description": "Viveu nas estradas, sem bandeira nem senhor.", "bonus": {"Destreza": 1}}
}

static func default_stats() -> Dictionary:
    var stats := {}
    for key in ATTRIBUTES:
        stats[key] = MIN_STAT
    return stats

static func points_remaining(stats: Dictionary) -> int:
    var spent := 0
    for key in ATTRIBUTES:
        spent += maxi(0, int(stats.get(key, MIN_STAT)) - MIN_STAT)
    return STARTING_POINTS - spent

static func valid(stats: Dictionary, origin: String) -> bool:
    if not ORIGINS.has(origin):
        return false
    for key in ATTRIBUTES:
        if not stats.has(key) or int(stats[key]) < MIN_STAT or int(stats[key]) > MAX_STAT:
            return false
    return points_remaining(stats) >= 0

static func final_stats(stats: Dictionary, origin: String) -> Dictionary:
    var output := stats.duplicate(true)
    for key in ORIGINS.get(origin, {}).get("bonus", {}):
        output[key] = mini(MAX_STAT, int(output.get(key, MIN_STAT)) + int(ORIGINS[origin]["bonus"][key]))
    return output
