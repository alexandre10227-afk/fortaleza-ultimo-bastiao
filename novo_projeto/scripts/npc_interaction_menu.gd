extends Control
## Click-only contextual NPC interaction and portraitless profile panel.
## Existing Godot theme is reused. No per-action keyboard shortcut required.
signal action_selected(action: String, npc: Dictionary)
signal gift_selected(npc: Dictionary, item_id: String)
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
    card.custom_minimum_size = Vector2(525, 0)
    UI.apply_panel(card)
    center.add_child(card)
    var scroll := ScrollContainer.new()
    scroll.custom_minimum_size = Vector2(520, 390)
    scroll.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    card.add_child(scroll)
    content = VBoxContainer.new()
    content.custom_minimum_size.x = 470
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
    _line("Amizade: %d/100 — %s" % [friendship, level])
    _line("Presentes preferidos: " + preferred)
    _choice("Conversar", "talk")
    _choice("Consultar cadastro de NPCs", "directory")
    if is_merchant:
        _choice("Abrir loja", "shop")
    _choice("Presentear", "gifts")
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
    _heading("Presentear: %s" % npc.get("name", "Morador"))
    var preferred := ITEMS.preferred_category(str(npc.get("id", "")), str(npc.get("profession", "")))
    _line("Categoria aceita: %s" % preferred)
    _line("Clique em um item. Recusas nao gastam o item.")
    var found := false
    for id in inventory.keys():
        var key := str(id)
        var amount := int(inventory[id])
        if amount < 1 or not ITEMS.is_tradeable(key):
            continue
        found = true
        var data: Dictionary = ITEMS.get_item(key)
        var accepted := ITEMS.accepts_gift(str(npc.get("id", "")), str(npc.get("profession", "")), key)
        var suffix := "ACEITO" if accepted else "RECUSADO"
        var button := _button("%s x%d | %s | %s" % [data["name"], amount, data["rarity"], suffix])
        button.disabled = not accepted
        button.pressed.connect(_on_gift_click.bind(key))
    if not found:
        _line("Nao ha itens de presente no inventario.")
    var back := _button("Voltar")
    back.pressed.connect(_on_action.bind("back"))
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
