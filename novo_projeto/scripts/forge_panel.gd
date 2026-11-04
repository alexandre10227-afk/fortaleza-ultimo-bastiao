extends Control
## Forja de equipamentos comuns, dividida por classe e por peça.
signal craft_requested(item_id: String)
signal closed
const GEAR = preload("res://scripts/equipment_catalog.gd")
const ECONOMY = preload("res://scripts/economy_system.gd")
const UI = preload("res://scripts/ui_theme.gd")
const ICONS = preload("res://scripts/item_icon_factory.gd")
var _inventory: Dictionary = {}
var _gold := 0
var _buildings: Dictionary = {}
var _archetype := "Guerreiro"
var _list: VBoxContainer
var _headline: Label

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    visible = false
    mouse_filter = Control.MOUSE_FILTER_STOP
    var shade := ColorRect.new()
    shade.color = Color(0.025,0.02,0.018,.76)
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(shade)
    var aligner := CenterContainer.new()
    aligner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(aligner)
    var frame := PanelContainer.new()
    frame.custom_minimum_size = Vector2(800, 0)
    UI.apply_panel(frame)
    aligner.add_child(frame)
    var content := VBoxContainer.new()
    content.add_theme_constant_override("separation",9)
    frame.add_child(content)
    _headline = Label.new()
    UI.apply_title(_headline)
    content.add_child(_headline)
    var hint := Label.new()
    hint.text = "Ferraria I: Comum | II-III: Raro | IV-V: Epico. Lendarios, miticos e itens de evento nao podem ser fabricados."
    hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    UI.apply_text(hint)
    content.add_child(hint)
    var class_tabs := HBoxContainer.new()
    class_tabs.add_theme_constant_override("separation",8)
    content.add_child(class_tabs)
    for group in GEAR.CLASS_ORDER:
        var tab := Button.new()
        tab.text = str(group)
        UI.apply_button(tab)
        tab.pressed.connect(_choose_class.bind(str(group)))
        class_tabs.add_child(tab)
    var scroll := ScrollContainer.new()
    scroll.custom_minimum_size = Vector2(745, 360)
    content.add_child(scroll)
    _list = VBoxContainer.new()
    _list.custom_minimum_size.x = 714
    _list.add_theme_constant_override("separation",10)
    scroll.add_child(_list)
    var close_button := Button.new()
    close_button.text = "Fechar forja (Esc)"
    UI.apply_button(close_button)
    close_button.pressed.connect(hide_forge)
    content.add_child(close_button)

func open_forge(inventory: Dictionary, money: int, buildings: Dictionary, preferred_class: String) -> void:
    _archetype = preferred_class if GEAR.CLASS_ORDER.has(preferred_class) else "Guerreiro"
    refresh_forge(inventory,money,buildings)
    visible = true

func refresh_forge(inventory: Dictionary, money: int, buildings: Dictionary) -> void:
    _inventory = inventory.duplicate(true)
    _gold = money
    _buildings = buildings.duplicate(true)
    _headline.text = "FERRARIA | %s | %d moedas" % [_archetype, money]
    for old in _list.get_children():
        _list.remove_child(old)
        old.queue_free()
    for slot in GEAR.SLOTS:
        for item_id in GEAR.GEAR:
            var item: Dictionary = GEAR.GEAR[item_id]
            if item["class"] != _archetype or item["slot"] != slot or GEAR.is_special(str(item_id)):
                continue
            if not ECONOMY.RECIPES.has(item_id):
                continue
            var recipe: Dictionary = ECONOMY.RECIPES[item_id]
            var requirements: Array[String] = []
            for material_id in recipe["materials"]:
                requirements.append("%s %d/%d" % [material_id, int(_inventory.get(material_id,0)), int(recipe["materials"][material_id])])
            var row := HBoxContainer.new()
            row.add_theme_constant_override("separation", 12)
            _list.add_child(row)
            var icon := TextureRect.new()
            icon.texture = ICONS.icon_for("Armas")
            icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
            icon.custom_minimum_size = Vector2(42,42)
            icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
            icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
            row.add_child(icon)
            var description := Label.new()
            description.custom_minimum_size.x = 490
            description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
            description.text = "%s [%s] (%s) | Nivel %d | Foco: %s | %s" % [item["name"],str(item["rarity"]),str(slot).capitalize(),int(recipe["level"]),str(item.get("focus","Geral")),", ".join(requirements)]
            UI.apply_text(description)
            row.add_child(description)
            var make := Button.new()
            make.text = "Fabricar: %d" % int(recipe["money"])
            make.disabled = int(_buildings.get("Ferraria",0)) < int(recipe["level"]) or not ECONOMY.can_pay(_inventory, _gold, recipe["materials"], int(recipe["money"]))
            UI.apply_button(make)
            make.pressed.connect(_request_craft.bind(str(item_id)))
            row.add_child(make)

func _choose_class(group: String) -> void:
    if GEAR.CLASS_ORDER.has(group):
        _archetype = group
        refresh_forge(_inventory, _gold, _buildings)

func _request_craft(item_id: String) -> void:
    craft_requested.emit(item_id)

func hide_forge() -> void:
    if visible:
        visible = false
        closed.emit()
