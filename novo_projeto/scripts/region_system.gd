extends RefCounted

# Original region identities; visual themes and NPC placement stay data-driven.
const REGIONS := {
    "Fortaleza": {
        "ground": Color("#647b52"), "road": Color("#a99a7b"),
        "building": Color("#806b57"), "roof": Color("#574839"),
        "sky": Color("#9cb4ad"), "type": "frontier"
    },
    "Porto Cinzento": {
        "ground": Color("#6c7566"), "road": Color("#8d9189"),
        "building": Color("#6b7b81"), "roof": Color("#405463"),
        "sky": Color("#89a9bb"), "type": "harbor"
    }
}

const RESIDENTS := {
    "Fortaleza": [
        {"id": "doran", "name": "Doran", "profession": "Ferreiro", "home": "Fortaleza", "dialogue": "A muralha so resiste se a forja continuar acesa."},
        {"id": "kael", "name": "Kael", "profession": "Explorador", "home": "Fortaleza", "dialogue": "Vigio as estradas antes que as ondas cheguem."},
        {"id": "mercador_marcial", "name": "Breno, Armeiro", "profession": "Comerciante", "home": "Fortaleza", "dialogue": "Uma boa armadura protege a pessoa, nao apenas o brasao."},
        {"id": "iris_feirante", "name": "Iris", "profession": "Feirante", "home": "Fortaleza", "dialogue": "Um mercado honesto precisa de alimentos e confianca."},
        {"id": "bento_agricultor", "name": "Bento", "profession": "Agricultor", "home": "Fortaleza", "dialogue": "As sementes nao esperam que a guerra termine."}
    ],
    "Porto Cinzento": [
        {"id": "elira", "name": "Elira", "profession": "Mercenaria", "home": "Porto Cinzento", "dialogue": "O porto sempre revela novidades a quem sabe ouvir."},
        {"id": "mira", "name": "Mira", "profession": "Curandeira", "home": "Porto Cinzento", "dialogue": "Nem toda ferida foi causada por uma espada."},
        {"id": "lia_moradora", "name": "Lia", "profession": "Moradora", "home": "Porto Cinzento", "dialogue": "Eu so quero que os navios e meus filhos voltem para casa."}
    ]
}

static func region_data(region: String) -> Dictionary:
    return REGIONS.get(region, REGIONS["Fortaleza"])

static func residents(region: String) -> Array:
    return RESIDENTS.get(region, [])

static func resident_position(index: int, day: int) -> Vector3:
    # Changes by game day, but deterministic across saving and loading.
    var shift := float(day % 3) * 1.5
    return Vector3(4.7 + float(index % 2) * 2.0, 0.0, -13.0 + float(index) * 8.0 + shift)

static func can_talk(distance: float) -> bool:
    return distance <= 2.5
