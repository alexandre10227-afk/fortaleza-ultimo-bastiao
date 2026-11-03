extends RefCounted
## Trilhas do protagonista separadas das subclasses e raridades dos NPCs.
## Quatro classes iniciais; tecnicas novas exigem mestre ou livro de chefe.
const BASE_CLASSES := ["Guerreiro", "Cavaleiro", "Mago", "Sacerdote"]
const STARTING_SKILLS := {
    "Guerreiro": "Postura de Batalha",
    "Cavaleiro": "Guarda Firme",
    "Mago": "Centelha Arcana",
    "Sacerdote": "Prece de Amparo"
}
const SPECIALIZATIONS := {
    "Espada e Escudo": {"base":["Guerreiro","Cavaleiro"], "skill":"Postura Defensiva"},
    "Samurai": {"base":["Guerreiro"], "skill":"Corte Preciso"},
    "Mestre Espadachim": {"base":["Guerreiro"], "skill":"Dominio da Lamina"},
    "Guardiao": {"base":["Cavaleiro"], "skill":"Escudo dos Aliados"},
    "Bastiao Vivo": {"base":["Cavaleiro"], "skill":"Muralha Viva"},
    "Mago de Fogo": {"base":["Mago"], "skill":"Chama Crescente"},
    "Mago de Agua": {"base":["Mago"], "skill":"Corrente Serena"},
    "Mago de Terra": {"base":["Mago"], "skill":"Parede de Rocha"},
    "Mago de Vento": {"base":["Mago"], "skill":"Rajada Cortante"},
    "Mago do Trovao": {"base":["Mago"], "skill":"Arco Eletrico"},
    "Mago Verde": {"base":["Mago"], "skill":"Raizes Vivas"},
    "Elementalista": {"base":["Mago"], "skill":"Convergencia Elemental"},
    "Herbalista": {"base":["Sacerdote"], "skill":"Cura de Ervas"},
    "Guardiao da Vida": {"base":["Sacerdote"], "skill":"Bencao de Protecao"}
}
const MASTER_TEACHERS := {
    "doran": ["Espada e Escudo"],
    "elira": ["Samurai"],
    "mira": ["Herbalista"],
    "kael": ["Guardiao"],
    "selene": ["Mago de Vento"],
    "general_vaelor": ["Bastiao Vivo"]
}
const BOSS_BOOKS := {
    "livro_chamas_ancestrais": "Mago de Fogo",
    "livro_ondas_antigas": "Mago de Agua",
    "livro_rocha_viva": "Mago de Terra",
    "livro_relampago": "Mago do Trovao",
    "livro_sementes_vivas": "Mago Verde",
    "livro_quatro_elementos": "Elementalista",
    "livro_mestre_lamina": "Mestre Espadachim",
    "livro_muralha_viva": "Bastiao Vivo"
}
const TEACHER_MIN_FRIENDSHIP := 60

static func starting_track(base_class: String) -> Dictionary:
    if not BASE_CLASSES.has(base_class):
        return {}
    return {"base_class":base_class,"specializations":[],"skills":[STARTING_SKILLS[base_class]],"learned_sources":{}}

static func valid_track(track: Dictionary) -> bool:
    var base := str(track.get("base_class", ""))
    if not BASE_CLASSES.has(base):
        return false
    var specializations: Array = track.get("specializations", [])
    var unique: Dictionary = {}
    for specialization in specializations:
        var title := str(specialization)
        if unique.has(title) or not SPECIALIZATIONS.has(title) or not SPECIALIZATIONS[title]["base"].has(base):
            return false
        unique[title] = true
    return true

static func can_learn(track: Dictionary, specialization: String) -> bool:
    return valid_track(track) and SPECIALIZATIONS.has(specialization) and SPECIALIZATIONS[specialization]["base"].has(track["base_class"]) and not track["specializations"].has(specialization)

static func learn(track: Dictionary, specialization: String, source: String) -> Dictionary:
    if not can_learn(track, specialization) or source.is_empty():
        return {}
    var result := track.duplicate(true)
    result["specializations"].append(specialization)
    var ability := str(SPECIALIZATIONS[specialization]["skill"])
    if not result["skills"].has(ability):
        result["skills"].append(ability)
    result["learned_sources"][specialization] = source
    return result

static func teacher_can_teach(teacher_id: String, friendship: int, specialization: String) -> bool:
    return friendship >= TEACHER_MIN_FRIENDSHIP and MASTER_TEACHERS.get(teacher_id, []).has(specialization)

static func specialization_from_book(book_id: String) -> String:
    return str(BOSS_BOOKS.get(book_id, ""))
