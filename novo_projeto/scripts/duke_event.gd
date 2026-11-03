extends RefCounted
## Evento original: seis enigmas em seis dias, amizade e o destino do Duque.
## As perguntas sao textos originais deste projeto, sem copiar obras externas.
const REQUIRED_FRIENDSHIP := 75
const DEADLINE_WAVE := 10
const DAUGHTER_TAVERN_WAVE := 30
const DAUGHTER_TAVERN_CHANCE := 1 # percentual por renovacao diaria elegivel

const QUESTIONS := [
    {"question": "Um comandante tem cem espadas e um saco de sementes. Qual protege o reino depois do inverno?", "options": ["As espadas.", "As sementes.", "O ouro."], "answer": 1},
    {"question": "Dois guardas contam a mesma batalha de formas diferentes. Como encontrar a verdade?", "options": ["Ouvir os dois e buscar vestigios.", "Punir o mais jovem.", "Acreditar no mais antigo."], "answer": 0},
    {"question": "Uma ponte suporta apenas uma carroca. Chegam remedios e armaduras. O que passa primeiro?", "options": ["As armaduras.", "O ouro do tesouro.", "Os remedios."], "answer": 2},
    {"question": "Um aliado errou, confessou e deseja reparar o dano. O que restaura a confianca?", "options": ["Esquecer tudo.", "Uma reparacao demonstrada em atos.", "Dar-lhe outra patente."], "answer": 1},
    {"question": "O ultimo saco de farinha alimenta soldados ou criancas. Como decidir sem abandonar ninguem?", "options": ["Dividir, buscar reservas e assumir o custo.", "Esconder a farinha.", "Vender ao maior lance."], "answer": 0},
    {"question": "Quando as muralhas cairem, o que permanece de um governante?", "options": ["Seu titulo.", "Seu tesouro.", "As pessoas e os atos que o recordam."], "answer": 2},
]
const DAUGHTER_ID := "herdeira_duque"
const ARMOR_ID := "armadura_duque"
const BOSS_ID := "carrasco_do_juramento"

static func initial_state() -> Dictionary:
    return {
        "status": "available", "question_index": 0, "last_question_day": -1,
        "friendship": 0, "recruited": false, "duke_alive": true,
        "boss_pending": false, "boss_defeated": false,
        "cutscene_seen": false, "daughter_unlocked": false,
        "armor_claimed": false, "daughter_recruited": false,
        "daughter_rank": "S", "daughter_evolved": false,
        "daughter_quest_complete": false, "daughter_tavern_checks": {},
    }

static func can_visit_for_question(state: Dictionary, day: int, wave: int) -> bool:
    return wave < DEADLINE_WAVE and bool(state.get("duke_alive", true)) and int(state.get("question_index", 0)) < QUESTIONS.size() and int(state.get("last_question_day", -1)) != day

static func answer_question(state: Dictionary, day: int, wave: int, selected: int) -> Dictionary:
    if not can_visit_for_question(state, day, wave):
        return {"accepted": false, "correct": false}
    var idx := int(state["question_index"])
    if selected < 0 or selected >= QUESTIONS[idx]["options"].size():
        return {"accepted": false, "correct": false}
    var correct := selected == int(QUESTIONS[idx]["answer"])
    state["last_question_day"] = day
    state["question_index"] = idx + 1
    # Uma resposta correta rende 15 pontos: seis acertos = 90 pontos.
    # Uma incorreta rende 5: a exigencia de 75 ainda requer acertos consistentes.
    state["friendship"] = mini(100, int(state["friendship"]) + (15 if correct else 5))
    state["status"] = "bonded" if state["question_index"] == QUESTIONS.size() else "in_progress"
    return {"accepted": true, "correct": correct, "friendship": state["friendship"], "finished": state["question_index"] == QUESTIONS.size()}

static func can_recruit_duke(state: Dictionary, wave: int) -> bool:
    return wave < DEADLINE_WAVE and bool(state.get("duke_alive", false)) and int(state.get("question_index", 0)) == QUESTIONS.size() and int(state.get("friendship", 0)) >= REQUIRED_FRIENDSHIP and not bool(state.get("recruited", false))

static func recruit_duke(state: Dictionary, wave: int) -> bool:
    if not can_recruit_duke(state, wave):
        return false
    state["recruited"] = true
    state["status"] = "recruited"
    return true

static func resolve_tenth_wave(state: Dictionary) -> String:
    if not bool(state.get("duke_alive", false)) or str(state.get("status", "")) in ["event_pending", "event_complete", "died_at_home"]:
        return "already_resolved"
    if bool(state.get("recruited", false)):
        state["status"] = "event_pending"
        state["boss_pending"] = true
        return "extra_boss"
    state["duke_alive"] = false
    state["status"] = "died_at_home"
    return "died_at_home"

static func defeat_extra_boss(state: Dictionary) -> bool:
    if not bool(state.get("boss_pending", false)) or bool(state.get("boss_defeated", false)):
        return false
    state["boss_pending"] = false
    state["boss_defeated"] = true
    # Cutscene do falecimento sera exibida com o sistema de batalha da Etapa 3.
    state["status"] = "cutscene_pending"
    return true

static func finish_death_cutscene(state: Dictionary) -> bool:
    if str(state.get("status", "")) != "cutscene_pending":
        return false
    state["duke_alive"] = false
    state["cutscene_seen"] = true
    state["status"] = "event_complete"
    state["daughter_unlocked"] = true
    state["armor_claimed"] = true
    return true

static func daughter_at_manor(state: Dictionary) -> bool:
    return bool(state.get("daughter_unlocked", false)) and bool(state.get("cutscene_seen", false))

static func tavern_roll(state: Dictionary, day: int, wave: int, roll_0_to_99: int) -> bool:
    if wave <= DAUGHTER_TAVERN_WAVE or str(state.get("status", "")) != "died_at_home":
        return false
    var checks: Dictionary = state.get("daughter_tavern_checks", {})
    if checks.has(str(day)):
        return bool(checks[str(day)])
    var appeared := roll_0_to_99 >= 0 and roll_0_to_99 < DAUGHTER_TAVERN_CHANCE
    checks[str(day)] = appeared
    state["daughter_tavern_checks"] = checks
    if appeared:
        state["daughter_unlocked"] = true
    return appeared

static func can_evolve_daughter(state: Dictionary, materials: Dictionary) -> bool:
    return bool(state.get("daughter_recruited", false)) and bool(state.get("daughter_quest_complete", false)) and bool(state.get("armor_claimed", false)) and int(materials.get("cristal_do_lago", 0)) >= 3 and int(materials.get("nucleo_ancestral", 0)) >= 1 and not bool(state.get("daughter_evolved", false))

static func finish_daughter_quest(state: Dictionary, has_armor: bool) -> bool:
    if not bool(state.get("daughter_recruited", false)) or not has_armor or bool(state.get("daughter_quest_complete", false)):
        return false
    state["daughter_quest_complete"] = true
    return true

static func evolve_daughter(state: Dictionary, materials: Dictionary) -> bool:
    if not can_evolve_daughter(state, materials):
        return false
    materials["cristal_do_lago"] = int(materials["cristal_do_lago"]) - 3
    materials["nucleo_ancestral"] = int(materials["nucleo_ancestral"]) - 1
    state["daughter_evolved"] = true
    state["daughter_rank"] = "SS"
    return true
