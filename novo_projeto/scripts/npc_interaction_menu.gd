extends Control
## Click-only contextual NPC interaction and portraitless profile panel.
## Existing Godot theme is reused. No per-action keyboard shortcut required.
signal action_selected(action: String, npc: Dictionary)
signal gift_selected(npc: Dictionary, item_id: String)
signal training_selected(npc: Dictionary, specialization: String)
signal visitor_selected(npc: Dictionary)
signal closed

const UI = preload("res://scripts/ui_theme.gd")
const ITEMS = preload("res://scripts/item_catalog.gd")
const NPCS = preload("res://scripts/npc_registry.gd")
var backdrop: ColorRect
var card: PanelContainer
var content: VBoxContainer
var selected_npc: Dictionary = {}

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    visible = false
    backdrop = ColorRect.new()
    backdrop.color = Color(0, 0, 0, 0.46)
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
    backdrop.gui_input.connect(_on_backdrop_input)
    add_child(backdrop)
    var center := CenterContainer.new()
    center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    center.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(center)
    card = PanelContainer.new()
    card.custom_minimum_size = Vector2(820, 0)
    UI.apply_panel(card)
    center.add_child(card)
    var scroll := ScrollContainer.new()
    scroll.custom_minimum_size = Vector2(790, 460)
    scroll.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    card.add_child(scroll)
    content = VBoxContainer.new()
    content.custom_minimum_size.x = 755
    content.add_theme_constant_override("separation", 9)
    scroll.add_child(content)

func is_open() -> bool:
    return visible

func show_npc(npc: Dictionary, friendship: int, level: String, preferred: String, recruitable: bool, is_merchant: bool, inside_building: bool = false) -> void:
    selected_npc = npc.duplicate(true)
    _clear()
    _heading(str(npc.get("name", "Morador")))
    _line("Profissao: %s | Raridade: %s" % [npc.get("profession", "Morador"), npc.get("rarity", "Comum")])
    if npc.has("activity"):
        _line("Atividade: " + str(npc["activity"]))
    var classification: Dictionary = NPCS.profile(str(npc.get("id", "")))
    _line("Grupo: %s | %s" % [classification["category"], "Importante para a historia" if classification["important"] else "Personagem comum"])
    _line("Cadastro: " + ("Recrutavel" if classification["recruitable"] else "Nao recrutavel"))
    var class_build: Dictionary = GameState.npc_hero_builds.get(str(npc.get("id", "")), {})
    if not class_build.is_empty():
        _line("Combate: %s / %s | Subclasse %s" % [class_build.get("class", ""), class_build.get("subclass", ""), class_build.get("rarity", "")])
        if not class_build.get("elements", []).is_empty():
            _line("Elementos: " + ", ".join(class_build["elements"]))
    _line("Amizade: %d/100 — %s" % [friendship, level])
    _line("Presentes preferidos: " + preferred)
    _choice("Conversar", "talk")
    _choice("Consultar cadastro de NPCs", "directory")
    if is_merchant:
        _choice("Abrir loja", "shop")
    _choice("Presentear", "gifts")
    var available_lessons: Array = GameState.PLAYER_CLASSES.MASTER_TEACHERS.get(str(npc.get("id", "")), [])
    if not available_lessons.is_empty():
        _choice("Treinar com mestre", "training")
    if recruitable:
        _choice("Recrutar", "recruit")
    _choice("Pedir passagem (sem penalidade)", "step_aside")
    if inside_building:
        _choice("Sair do predio", "exit")
    _choice("Fechar", "close")
    visible = true

func show_gifts(npc: Dictionary, inventory: Dictionary) -> void:
    selected_npc = npc.duplicate(true)
    _clear()
    _heading("PRESENTES E RELACIONAMENTO")
    var columns := HBoxContainer.new()
    columns.add_theme_constant_override("separation", 22)
    content.add_child(columns)
    var details := VBoxContainer.new()
    details.custom_minimum_size.x = 300
    details.add_theme_constant_override("separation", 11)
    columns.add_child(details)
    var portrait := PanelContainer.new()
    portrait.custom_minimum_size = Vector2(160, 130)
    UI.apply_panel(portrait)
    details.add_child(portrait)
    var portrait_text := Label.new()
    portrait_text.text = str(npc.get("name", "?")).substr(0, 1).to_upper()
    portrait_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    portrait_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    portrait_text.add_theme_font_size_override("font_size", 70)
    portrait_text.add_theme_color_override("font_color", UI.MUTED_GOLD)
    portrait.add_child(portrait_text)
    var preferred := ITEMS.preferred_category(str(npc.get("id", "")), str(npc.get("profession", "")))
    var info := Label.new()
    info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    info.text = "%s\nProfissao: %s\nCategoria aceita: %s\nAmizade: %d/100" % [npc.get("name", "Morador"), npc.get("profession", "Morador"), preferred, GameState.friendship_points(str(npc.get("id", "")))]
    UI.apply_text(info)
    details.add_child(info)
    var items_column := VBoxContainer.new()
    items_column.custom_minimum_size.x = 410
    columns.add_child(items_column)
    var heading := Label.new()
    heading.text = "SELECIONE UM PRESENTE"
    UI.apply_title(heading)
    items_column.add_child(heading)
    var grid := GridContainer.new()
    grid.columns = 3
    grid.add_theme_constant_override("h_separation", 8)
    grid.add_theme_constant_override("v_separation", 8)
    items_column.add_child(grid)
    var found := false
    for id in inventory.keys():
        var key := str(id)
        var amount := int(inventory[id])
        if amount < 1 or not ITEMS.is_tradeable(key):
            continue
        found = true
        var data: Dictionary = ITEMS.get_item(key)
        var accepted := ITEMS.accepts_gift(str(npc.get("id", "")), str(npc.get("profession", "")), key)
        var button := Button.new()
        button.text = "%s\nx%d | %s" % [data["name"], amount, "ACEITO" if accepted else "RECUSADO"]
        button.custom_minimum_size = Vector2(128, 76)
        button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        button.disabled = not accepted
        UI.apply_button(button)
        grid.add_child(button)
        button.pressed.connect(_on_gift_click.bind(key))
    if not found:
        var empty := Label.new()
        empty.text = "Nenhum presente no inventario."
        items_column.add_child(empty)
    _line("Apenas presentes da categoria preferida podem ser entregues. O item recusado nao e consumido.")
    var back := _button("Voltar ao personagem")
    back.pressed.connect(_on_action.bind("back"))
    visible = true

func show_training(npc: Dictionary) -> void:
    selected_npc = npc.duplicate(true)
    _clear()
    _heading("Treinamento com %s" % str(npc.get("name", "Mestre")))
    _line("Afinidade exigida: Confidente (60 pontos).")
    _line("A tecnica precisa ser compativel com a classe inicial do protagonista.")
    var known: Array = GameState.PLAYER_CLASSES.MASTER_TEACHERS.get(str(npc.get("id", "")), [])
    for specialization in known:
        var option := _button(str(specialization))
        var is_eligible := GameState.friendship_points(str(npc.get("id", ""))) >= 60 and GameState.PLAYER_CLASSES.can_learn(GameState.protagonist_track, str(specialization))
        option.disabled = not is_eligible
        option.pressed.connect(_on_training_click.bind(str(specialization)))
    var back := _button("Voltar")
    back.pressed.connect(_on_action.bind("back"))
    visible = true

func _on_training_click(specialization: String) -> void:
    training_selected.emit(selected_npc.duplicate(true), specialization)

func show_services(service: String) -> void:
    selected_npc = {"id": "_service_forge", "name": service, "profession": "Servicos"}
    _clear()
    _heading(service)
    _line("Selecione um servico pelo mouse.")
    if service == "Ferraria":
        _choice("Abrir loja de armas e minerios", "service_shop")
        _choice("Fabricar itens (receitas)", "service_craft")
        _choice("Melhorar a ferraria", "service_upgrade")
    elif service == "Salao":
        _choice("Consultar ficha e diario", "service_sheet")
    else:
        _line("Servicos deste local serao ampliados com as missoes.")
    _choice("Sair do predio", "exit")
    _choice("Fechar", "close")
    visible = true

func show_visitors(visitors: Array[Dictionary]) -> void:
    selected_npc.clear()
    _clear()
    _heading("Visitantes da Taverna")
    if visitors.is_empty():
        _line("Nenhum aventureiro hospedado hoje.")
    for npc in visitors:
        var button := _button("%s — %s" % [npc.get("name", "Viajante"), npc.get("profession", "")])
        button.pressed.connect(_on_visitor.bind(npc))
    _choice("Sair da taverna", "exit")
    var close_button := _button("Fechar")
    close_button.pressed.connect(hide_menu)
    visible = true

func hide_menu() -> void:
    if not visible:
        return
    visible = false
    selected_npc.clear()
    closed.emit()

func _clear() -> void:
    for child in content.get_children():
        content.remove_child(child)
        child.queue_free()

func _heading(value: String) -> void:
    var label := Label.new()
    label.text = value
    UI.apply_title(label)
    content.add_child(label)

func _line(value: String) -> void:
    var label := Label.new()
    label.text = value
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    UI.apply_text(label)
    content.add_child(label)

func _button(label: String) -> Button:
    var button := Button.new()
    button.text = label
    UI.apply_button(button)
    content.add_child(button)
    return button

func _choice(label: String, action: String) -> void:
    var button := _button(label)
    button.pressed.connect(_on_action.bind(action))

func _on_action(action: String) -> void:
    if action == "close":
        hide_menu()
    else:
        action_selected.emit(action, selected_npc.duplicate(true))

func _on_visitor(npc: Dictionary) -> void:
    visitor_selected.emit(npc.duplicate(true))

func _on_gift_click(item_id: String) -> void:
    gift_selected.emit(selected_npc.duplicate(true), item_id)

func _on_backdrop_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed:
        hide_menu()

func show_directory() -> void:
    selected_npc.clear()
    _clear()
    _heading("Cadastro de NPCs")
    _line("Escolha uma categoria. Os filtros de historia e recrutamento sao independentes.")
    for group_name in NPCS.CATEGORIES:
        var button := _button(group_name)
        button.pressed.connect(show_directory_group.bind(group_name))
    var close_button := _button("Fechar")
    close_button.pressed.connect(hide_menu)
    visible = true

func show_directory_group(group_name: String) -> void:
    _clear()
    _heading(group_name)
    _line("Subtopicos de recrutamento e importancia narrativa")
    for category in ["Todos", "Recrutaveis", "Nao recrutaveis", "Importantes para a historia", "Personagens comuns"]:
        var filter_button := _button(category)
        filter_button.pressed.connect(_filter_directory.bind(group_name, category))
    var back_button := _button("Voltar as categorias")
    back_button.pressed.connect(show_directory)
    visible = true

func _filter_directory(group_name: String, filter_name: String) -> void:
    var recruit_filter := -1
    var story_filter := -1
    match filter_name:
        "Recrutaveis":
            recruit_filter = 1
        "Nao recrutaveis":
            recruit_filter = 0
        "Importantes para a historia":
            story_filter = 1
        "Personagens comuns":
            story_filter = 0
    var results: Array[Dictionary] = NPCS.list_filtered(group_name, recruit_filter, story_filter)
    _clear()
    _heading(group_name + " / " + filter_name)
    if results.is_empty():
        _line("Nenhum NPC cadastrado neste subtopico.")
    for entry in results:
        var label := "%s | %s | %s" % [
            str(entry["id"]).replace("_", " ").capitalize(),
            "Recrutavel" if entry["recruitable"] else "Nao recrutavel",
            "Importante" if entry["important"] else "Comum"
        ]
        _line(label)
    var back := _button("Voltar aos filtros")
    back.pressed.connect(show_directory_group.bind(group_name))
    visible = true
