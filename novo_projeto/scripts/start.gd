extends Control
const UI = preload("res://scripts/ui_theme.gd")
const STORY = preload("res://scripts/story_content.gd")
const CHARACTER = preload("res://scripts/character_profile.gd")
const PLAYER_CLASSES = preload("res://scripts/protagonist_progression.gd")
const OPTIONS = preload("res://scripts/game_settings.gd")

var panel: VBoxContainer
var name_input: LineEdit
var difficulty_input: OptionButton
var _selected_difficulty := "Normal"
var dialogue_ui: Control
var origin_input: OptionButton
var appearance_input: OptionButton
var class_input: OptionButton
var _stats: Dictionary = CHARACTER.default_stats()
var _stat_labels: Dictionary = {}
var _points_label: Label
var _radar: Control
var _prologue_step := 0

func _ready() -> void:
    if DisplayServer.get_name() != "headless":
        OPTIONS.apply(OPTIONS.read())
    var backdrop := preload("res://scripts/menu_backdrop.gd").new()
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(backdrop)
    var center := CenterContainer.new()
    center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(center)
    var frame := PanelContainer.new()
    frame.custom_minimum_size = Vector2(760, 640)
    UI.apply_panel(frame)
    center.add_child(frame)
    var scroll := ScrollContainer.new()
    scroll.custom_minimum_size = Vector2(720, 580)
    frame.add_child(scroll)
    panel = VBoxContainer.new()
    panel.custom_minimum_size.x = 685
    panel.add_theme_constant_override("separation", 10)
    scroll.add_child(panel)
    _show_main_menu()

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

func _show_main_menu() -> void:
    _clear()
    _label("FORTALEZA: ULTIMO BASTIAO", 35)
    _label("O Vale das Cinzas aguarda suas escolhas.", 19)
    _label("Uma campanha original de estrategia, exploracao e consequencias.", 16)
    _button("Novo jogo", _show_difficulty)
    if FileAccess.file_exists(GameState.SAVE_PATH):
        _button("Continuar campanha", _continue)
    _button("Configuracoes", _show_settings)
    _button("Sair do jogo", _quit_game)

func _show_settings() -> void:
    _clear()
    _label("CONFIGURACOES", 29)
    var options: Dictionary = OPTIONS.read()
    _label("Resolucao da janela")
    var resolution := OptionButton.new()
    for size in OPTIONS.RESOLUTIONS:
        resolution.add_item(str(size))
    resolution.select(maxi(0, OPTIONS.RESOLUTIONS.find(str(options["resolution"]))))
    panel.add_child(resolution)
    var fullscreen := CheckBox.new()
    fullscreen.text = "Tela cheia"
    fullscreen.button_pressed = bool(options["fullscreen"])
    panel.add_child(fullscreen)
    var mute := CheckBox.new()
    mute.text = "Silenciar audio"
    mute.button_pressed = bool(options["muted"])
    panel.add_child(mute)
    _button("Aplicar e salvar", func():
        var choice := {"resolution":resolution.get_item_text(resolution.selected),"fullscreen":fullscreen.button_pressed,"muted":mute.button_pressed}
        if OPTIONS.write(choice):
            OPTIONS.apply(choice)
            _show_main_menu()
    )
    _button("Voltar", _show_main_menu)

func _quit_game() -> void:
    get_tree().quit()

func _show_difficulty() -> void:
    _clear()
    _label("01 / DIFICULDADE DA CAMPANHA", 29)
    _label("Escolha como deseja enfrentar a defesa do Bastião.", 18)
    var details := {
        "Facil": "Mais recursos e aprendizado seguro para descobrir a historia.",
        "Normal": "Equilibrio entre perigo, recursos e progressao.",
        "Dificil": "Inimigos mais perigosos, recursos escassos e escolhas decisivas.",
        "Impossivel": "3x experiencia; inimigos brutais, menos recursos e risco permanente."
    }
    for value in ["Facil", "Normal", "Dificil", "Impossivel"]:
        var label := "%s | %s" % [value, details[value]]
        _button(label, _select_difficulty.bind(value))
    _button("Voltar ao menu principal", _show_main_menu)

func _select_difficulty(value: String) -> void:
    if not ["Facil", "Normal", "Dificil", "Impossivel"].has(value):
        return
    _selected_difficulty = value
    _show_creation()

func _show_creation() -> void:
    _clear()
    _label("FORTALEZA: ULTIMO BASTIAO", 31)
    _label("02 / CRIACAO DO PROTAGONISTA", 15)
    _label("Dificuldade selecionada: " + _selected_difficulty, 17)
    _label("Um desconhecido pode escolher seu destino. Crie seu personagem.")
    name_input = LineEdit.new()
    name_input.placeholder_text = "Nome do protagonista"
    UI.apply_input(name_input)
    name_input.max_length = 24
    panel.add_child(name_input)
    _label("Origem do aventureiro", 18)
    origin_input = OptionButton.new()
    for origin in CHARACTER.ORIGINS:
        origin_input.add_item(str(origin))
    origin_input.add_theme_stylebox_override("normal", UI.button_style())
    origin_input.add_theme_color_override("font_color", UI.LIGHT_TEXT)
    panel.add_child(origin_input)
    _label("A origem concede um bonus fixo; nao substitui a escolha do juramento.", 15)
    _label("Classe inicial do heroi", 18)
    class_input = OptionButton.new()
    for archetype_name in PLAYER_CLASSES.BASE_CLASSES:
        class_input.add_item(str(archetype_name))
    panel.add_child(class_input)
    _label("Especializacoes sao aprendidas durante a campanha.", 15)
    _label("Aparencia inicial", 18)
    appearance_input = OptionButton.new()
    for style_name in ["Viajante de manto", "Guarda sem brasao", "Aprendiz de oficina", "Explorador"]:
        appearance_input.add_item(style_name)
    panel.add_child(appearance_input)
    _label("Distribua 10 pontos iniciais", 18)
    _stats = CHARACTER.default_stats()
    _radar = preload("res://scripts/attribute_radar.gd").new()
    panel.add_child(_radar)
    _stat_labels.clear()
    _points_label = Label.new()
    UI.apply_text(_points_label)
    panel.add_child(_points_label)
    for stat in CHARACTER.ATTRIBUTES:
        var row := HBoxContainer.new()
        row.add_theme_constant_override("separation", 8)
        panel.add_child(row)
        var name_label := Label.new()
        name_label.text = str(stat)
        name_label.custom_minimum_size.x = 140
        UI.apply_text(name_label)
        row.add_child(name_label)
        var minus := Button.new()
        minus.text = "-"
        UI.apply_button(minus)
        minus.pressed.connect(_edit_stat.bind(str(stat), -1))
        row.add_child(minus)
        var value_label := Label.new()
        value_label.custom_minimum_size.x = 35
        UI.apply_text(value_label)
        row.add_child(value_label)
        _stat_labels[stat] = value_label
        var plus := Button.new()
        plus.text = "+"
        UI.apply_button(plus)
        plus.pressed.connect(_edit_stat.bind(str(stat), 1))
        row.add_child(plus)
    _refresh_stats()
    _button("Comecar: audiencia com o rei", _create_character)
    _button("Voltar a dificuldade", _show_difficulty)
    if FileAccess.file_exists(GameState.SAVE_PATH):
        _button("Continuar campanha salva", _continue)

func _create_character() -> void:
    GameState.new_game(name_input.text, _selected_difficulty)
    var selected_origin := origin_input.get_item_text(origin_input.selected)
    if not GameState.configure_character(selected_origin, _stats, appearance_input.selected):
        _label("Verifique a origem e os pontos de atributos.", 15)
        return
    var archetype_name := class_input.get_item_text(class_input.selected)
    if not GameState.choose_starting_class(archetype_name):
        _label("Classe e afinidade selecionadas nao sao validas.", 15)
        return
    _show_audience()

func _edit_stat(stat: String, amount: int) -> void:
    var updated := int(_stats.get(stat, 1)) + amount
    if updated < CHARACTER.MIN_STAT or updated > CHARACTER.MAX_STAT:
        return
    if amount > 0 and CHARACTER.points_remaining(_stats) <= 0:
        return
    _stats[stat] = updated
    _refresh_stats()

func _refresh_stats() -> void:
    for key in _stat_labels:
        var label: Label = _stat_labels[key]
        label.text = str(_stats[key])
    _points_label.text = "Pontos restantes: %d" % CHARACTER.points_remaining(_stats)
    if _radar != null:
        _radar.set_stats(_stats)

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
