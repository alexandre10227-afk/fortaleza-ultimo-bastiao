extends RefCounted
## Escala de relacionamento geral; especiais possuem requisitos de recrutamento proprios.
const RECRUIT_THRESHOLD := 80
const LEVELS := [
    {"min": 0, "label": "Indiferente"},
    {"min": 20, "label": "Conhecido"},
    {"min": 40, "label": "Amigos"},
    {"min": 60, "label": "Confidente"},
    {"min": 80, "label": "Leal ate a Morte"},
]

static func level_name(points: int) -> String:
    var score := clampi(points, 0, 100)
    for i in range(LEVELS.size() - 1, -1, -1):
        if score >= int(LEVELS[i]["min"]):
            return str(LEVELS[i]["label"])
    return "Indiferente"

static func can_recruit(points: int) -> bool:
    return points >= RECRUIT_THRESHOLD

static func adjust(points: int, delta: int) -> int:
    return clampi(points + delta, 0, 100)
