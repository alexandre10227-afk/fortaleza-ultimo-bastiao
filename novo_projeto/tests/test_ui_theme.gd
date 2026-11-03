extends SceneTree

func _initialize() -> void:
    call_deferred("run")

func run() -> void:
    var ui = load("res://scripts/ui_theme.gd")
    var button := Button.new()
    ui.apply_button(button)
    assert(button.has_theme_stylebox_override("normal"))
    assert(button.has_theme_stylebox_override("hover"))
    assert(button.has_theme_stylebox_override("pressed"))
    assert(button.custom_minimum_size.y >= 42)
    var panel := PanelContainer.new()
    ui.apply_panel(panel)
    assert(panel.has_theme_stylebox_override("panel"))
    assert(ui.make_rarity_color("Mitico") != ui.make_rarity_color("Comum"))
    var entry := LineEdit.new()
    ui.apply_input(entry)
    assert(entry.has_theme_stylebox_override("normal"))
    var start = load("res://scenes/start.tscn").instantiate()
    root.add_child(start)
    await process_frame
    assert(start.get_child_count() >= 2)
    var dialogue = load("res://scripts/dialogue_panel.gd").new()
    root.add_child(dialogue)
    await process_frame
    dialogue.show_dialogue("Mestre da Forja", "Bem-vindo.", ["Abrir a forja", "Sair"])
    dialogue.advance()
    assert(dialogue.choice_column.get_child_count() == 2)
    print("TEST_UI_THEME_PASS")
    quit(0)
