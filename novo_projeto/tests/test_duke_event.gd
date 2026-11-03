extends SceneTree

func _initialize() -> void:
    call_deferred("run_tests")

func run_tests() -> void:
    var g = root.get_node("GameState")
    var duke = load("res://scripts/duke_event.gd")
    # Camino completo: seis perguntas, dias separados, 75 pontos e onda 10
    g.new_game("Protetor", "Normal")
    g.choose_oath(true)
    for i in range(6):
        var answer: int = int(duke.QUESTIONS[i]["answer"])
        assert(g.duke_answer(answer)["accepted"])
        assert(not g.duke_answer(answer)["accepted"])
        if i < 5:
            g.advance_days(1)
    assert(g.duke_state["friendship"] == 90)
    assert(g.duke_state["question_index"] == 6)
    assert(g.duke_recruit())
    assert(not g.duke_recruit())
    assert(g.recruited.has("duque"))
    assert(g.save_game())
    g.new_game("Outro", "Facil")
    assert(g.load_game())
    assert(g.duke_state["recruited"])
    g.advance_days(45)
    assert(g.wave_number == 10)
    assert(g.duke_state["boss_pending"])
    assert(g.duke_state["duke_alive"])
    assert(not g.duke_state["armor_claimed"])
    assert(g.duke_boss_defeated())
    assert(not g.duke_boss_defeated())
    assert(g.duke_finish_cutscene())
    assert(not g.duke_finish_cutscene())
    assert(not g.duke_state["duke_alive"])
    assert(g.duke_state["daughter_unlocked"])
    assert(g.inventory.get("armadura_duque", 0) == 1)
    assert(not g.recruited.has("duque"))
    assert(g.duke_daughter_recruit())
    assert(g.duke_daughter_quest())
    assert(not g.duke_daughter_evolve())
    g.inventory["cristal_do_lago"] = 3
    g.inventory["nucleo_ancestral"] = 1
    assert(g.duke_daughter_evolve())
    assert(not g.duke_daughter_evolve())
    assert(g.duke_state["daughter_rank"] == "SS")
    assert(g.inventory["cristal_do_lago"] == 0)
    assert(g.inventory["nucleo_ancestral"] == 0)
    # Falha: morre em casa, armadura nunca pode ser dada e herdeira 1% so apos onda 30
    g.new_game("Atrasado", "Normal")
    g.choose_oath(true)
    g.advance_days(50)
    assert(g.wave_number == 10)
    assert(g.duke_state["status"] == "died_at_home")
    assert(not g.duke_state["armor_claimed"])
    assert(not g.duke_recruit())
    assert(not g.duke_boss_defeated())
    assert(not duke.tavern_roll(g.duke_state, g.day, 30, 0))
    assert(duke.tavern_roll(g.duke_state, g.day, 31, 0))
    assert(duke.tavern_roll(g.duke_state, g.day, 31, 99))
    assert(duke.tavern_roll(g.duke_state, g.day + 1, 31, 99))
    assert(duke.tavern_roll(g.duke_state, g.day + 3, 31, 99))
    assert(not duke.tavern_roll(g.duke_state, g.day + 4, 31, 99))
    # A herdeira rank S da taverna nao pode evoluir sem armadura
    assert(g.duke_daughter_recruit())
    g.inventory["cristal_do_lago"] = 3
    g.inventory["nucleo_ancestral"] = 1
    assert(not g.duke_daughter_quest())
    assert(not g.duke_daughter_evolve())
    # Amizade 70 nunca basta, mesmo com seis perguntas
    var state: Dictionary = duke.initial_state()
    for i in range(6):
        var wrong := (int(duke.QUESTIONS[i]["answer"]) + (1 if i < 2 else 0)) % 3
        assert(duke.answer_question(state, i + 1, 0, wrong)["accepted"])
    assert(state["friendship"] == 70)
    assert(not duke.can_recruit_duke(state, 9))
    # Exilado nao recruta morador da fortaleza
    g.new_game("Exilado", "Normal")
    g.choose_oath(false)
    assert(not g.duke_recruit())
    print("TEST_DUKE_EVENT_PASS")
    quit(0)
