extends Control
const UI = preload("res://scripts/ui_theme.gd")
const STORY = preload("res://scripts/story_content.gd")

var panel: VBoxContainer
var name_input: LineEdit
var difficulty_input: OptionButton
var dialogue_ui: Control
var _prologue_step := 0

func _ready() -> void:
    var backdrop := ColorRect.new()
    backdrop.color = Color("#202e29")
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(backdrop)
    var center := CenterContainer.new()
    center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(center)
    var frame := PanelContainer.new()
    frame.custom_minimum_size = Vector2(580, 560)
    UI.apply_panel(frame)
    center.add_child(frame)
    panel = VBoxContainer.new()
    panel.add_theme_constant_override("separation", 17)
    frame.add_child(panel)
    _show_creation()

func _clear() -> void:
    for child in panel.get_children():
        panel.remove_child(child)
        child.queue_free()

func _label(value: String, size: int = 19) -> void:
    var l := Label.new()
    l.text = value
    l.add_theme_font_size_override("font_size", size)
    UI.apply_text(l)
    if size >= 29:
        UI.apply_title(l)
    l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    panel.add_child(l)

func _button(value: String, action: Callable) -> void:
    var b := Button.new()
    b.text = value
    b.custom_minimum_size.y = 43
    b.pressed.connect(action)
    UI.apply_button(b)
    panel.add_child(b)

func _show_creation() -> void:
    _clear()
    _label("FORTALEZA: ULTIMO BASTIAO", 31)
    _label("NOVO PROJETO | ETAPA 1 EM DESENVOLVIMENTO", 15)
    _label("Um desconhecido pode escolher seu destino. Crie seu personagem.")
    name_input = LineEdit.new()
    name_input.placeholder_text = "Nome do protagonista"
    UI.apply_input(name_input)
    name_input.max_length = 24
    panel.add_child(name_input)
    _label("Dificuldade da campanha")
    difficulty_input = OptionButton.new()
    for item in ["Facil", "Normal", "Dificil", "Impossivel"]:
        difficulty_input.add_item(item)
    difficulty_input.select(1)
    difficulty_input.add_theme_stylebox_override("normal", UI.button_style())
    difficulty_input.add_theme_stylebox_override("hover", UI.button_style("hover"))
    difficulty_input.add_theme_color_override("font_color", UI.LIGHT_TEXT)
    panel.add_child(difficulty_input)
    _label("Impossivel concede 3x XP, mas torna a sobrevivencia mais dificil.", 15)
    _button("Comecar: audiencia com o rei", _create_character)
    if FileAccess.file_exists(GameState.SAVE_PATH):
        _button("Continuar campanha salva", _continue)

func _create_character() -> void:
    GameState.new_game(name_input.text, difficulty_input.get_item_text(difficulty_input.selected))
    _show_audience()

func _show_audience() -> void:
    _clear()
    _label("O JURAMENTO DO REI", 29)
    _label("Um futuro comandante e apenas um viajante diante do trono.", 18)
    if dialogue_ui == null:
        dialogue_ui = preload("res://scripts/dialogue_panel.gd").new()
        dialogue_ui.name = "DialoguePanel"
        add_child(dialogue_ui)
        dialogue_ui.choice_selected.connect(_on_royal_choice)
        dialogue_ui.dialogue_closed.connect(_on_royal_dialogue_closed)
    _prologue_step = 0
    dialogue_ui.show_dialogue("Rei Aldric", STORY.AUDIENCE_OPENING)


func _on_royal_dialogue_closed() -> void:
    if _prologue_step == 0:
        _prologue_step = 1
        dialogue_ui.show_dialogue("Rei Aldric", STORY.AUDIENCE_QUESTION, STORY.AUDIENCE_CHOICES)
    elif _prologue_step == 2:
        _prologue_step = 3
        dialogue_ui.show_dialogue("Rei Aldric", STORY.OATH_QUESTION, STORY.OATH_CHOICES)
    elif _prologue_step == 4:
        _choose(GameState.oath == "guardian")


func _on_royal_choice(index: int) -> void:
    if _prologue_step == 1:
        GameState.record_narrative_choice("first_principle", "compassion" if index == 0 else "duty")
        _prologue_step = 2
        dialogue_ui.show_dialogue("Rei Aldric", STORY.AUDIENCE_RESPONSE[index])
    elif _prologue_step == 3:
        var protect := index == 0
        GameState.choose_oath(protect)
        _prologue_step = 4
        dialogue_ui.show_dialogue("Rei Aldric", STORY.OATH_ENDING_GUARD if protect else STORY.OATH_ENDING_EXILE)


func _choose(protect: bool) -> void:
    if GameState.oath.is_empty():
        GameState.choose_oath(protect)
    get_tree().change_scene_to_file("res://scenes/world.tscn")

func _continue() -> void:
    if GameState.load_game():
        if GameState.oath.is_empty():
            _show_audience()
        else:
            get_tree().change_scene_to_file("res://scenes/world.tscn")
