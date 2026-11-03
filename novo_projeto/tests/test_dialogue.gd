extends SceneTree

func _initialize() -> void:
    call_deferred("run")

func run() -> void:
    var ui = load("res://scripts/dialogue_panel.gd").new()
    root.add_child(ui)
    await process_frame
    ui.show_dialogue("Rei Aldric", "Escolha seu destino.", ["Defender", "Exilio"])
    assert(ui.visible)
    assert(ui.speaker_label.text == "Rei Aldric")
    assert(ui.body_label.visible_characters == 0)
    assert(ui._options.size() == 2)
    ui.advance()
    assert(not ui._revealing)
    assert(ui.choice_column.visible)
    assert(ui.choice_column.get_child_count() == 2)
    var result := [-1]
    ui.choice_selected.connect(func(index): result[0] = index)
    ui._select_choice(1)
    assert(result[0] == 1)
    ui.show_dialogue("Doran", "A forja esta acesa.")
    assert(ui._revealing)
    ui.advance()
    assert(ui.continue_button.visible)
    ui.advance()
    assert(not ui.visible)
    print("TEST_DIALOGUE_PASS")
    quit(0)
