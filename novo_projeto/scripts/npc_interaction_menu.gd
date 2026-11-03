extends Control
## Click-only contextual NPC interaction and portraitless profile panel.
## Existing Godot theme is reused. No per-action keyboard shortcut required.
signal action_selected(action: String, npc: Dictionary)
signal gift_selected(npc: Dictionary, item_id: String)
signal visitor_selected(npc: Dictionary)
signal closed

const UI = preload("res://scripts/ui_theme.gd")
const ITEMS = preload("res://scripts/item_catalog.gd")
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
    scroll.custom_minimum_size = Vector2(520, 230)
    scroll.custom_minimum_size.y = 0
    scroll.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    card.add_child(scroll)
    content = VBoxContainer.new()
    content.custom_minimum_size.x = 470
    content.add_theme_constant_override("separation", 9)
    scroll.add_child(content)

func is_open() -> bool:
    return visible

func show_npc(npc: Dictionary, friendship: int, level: String, preferred: String, recruitable: bool, is_merchant: bool) -> void:
    selected_npc = npc.duplicate(true)
    _clear()
    _heading(str(npc.get("name", "Morador")))
    _line("Profissao: %s | Raridade: %s" % [npc.get("profession", "Morador"), npc.get("rarity", "Comum")])
    _line("Amizade: %d/100 — %s" % [friendship, level])
    _line("Presentes preferidos: " + preferred)
    _choice("Conversar", "talk")
    if is_merchant:
        _choice("Abrir loja", "shop")
    _choice("Presentear", "gifts")
    if recruitable:
        _choice("Recrutar", "recruit")
    _choice("Pedir passagem (sem penalidade)", "step_aside")
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
