extends Control
## Painel original de comércio: catalogo clicavel, icones em cache e preços claros.
signal purchase_requested(item_id: String)
signal closed
const UI = preload("res://scripts/ui_theme.gd")
const ICONS = preload("res://scripts/item_icon_factory.gd")
var main_panel: PanelContainer
var list: VBoxContainer
var title_label: Label

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_STOP
    visible = false
    var scrim := ColorRect.new()
    scrim.color = Color(0.03, 0.02, 0.02, 0.73)
    scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(scrim)
    var aligner := CenterContainer.new()
    aligner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(aligner)
    main_panel = PanelContainer.new()
    main_panel.custom_minimum_size = Vector2(750, 0)
    UI.apply_panel(main_panel)
    aligner.add_child(main_panel)
    var root_col := VBoxContainer.new()
    root_col.add_theme_constant_override("separation", 10)
    main_panel.add_child(root_col)
    title_label = Label.new()
    UI.apply_title(title_label)
    root_col.add_child(title_label)
    var hint := Label.new()
    hint.text = "Cada comerciante oferece seu arquetipo. Clique no item para comprar."
    UI.apply_text(hint)
    root_col.add_child(hint)
    var scroller := ScrollContainer.new()
    scroller.custom_minimum_size = Vector2(700, 390)
    root_col.add_child(scroller)
    list = VBoxContainer.new()
    list.custom_minimum_size.x = 672
    list.add_theme_constant_override("separation", 7)
    scroller.add_child(list)
    var close_button := Button.new()
    close_button.text = "Fechar mercado (Esc)"
    UI.apply_button(close_button)
    close_button.pressed.connect(hide_store)
    root_col.add_child(close_button)

func show_inventory(label: String, entries: Array[Dictionary], money: int) -> void:
    title_label.text = "%s  |  %d moedas" % [label, money]
    for child in list.get_children():
        list.remove_child(child)
        child.queue_free()
    if entries.is_empty():
        var empty := Label.new()
        empty.text = "Nenhum produto disponivel nesta categoria."
        UI.apply_text(empty)
        list.add_child(empty)
    for data in entries:
        var row := HBoxContainer.new()
        row.add_theme_constant_override("separation", 13)
        list.add_child(row)
        var icon := TextureRect.new()
        icon.custom_minimum_size = Vector2(43, 43)
        icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        icon.texture = ICONS.icon_for(str(data.get("category", "")))
        icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        row.add_child(icon)
        var description := Label.new()
        description.custom_minimum_size.x = 415
        description.text = "%s | %s | %s" % [data.get("name","Item"), data.get("rarity","Comum"), data.get("slot","")]
        description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        UI.apply_text(description)
        row.add_child(description)
        var buy := Button.new()
        buy.text = "%d moedas" % int(data.get("price",0))
        buy.disabled = money < int(data.get("price",0))
        UI.apply_button(buy)
        buy.pressed.connect(_buy_click.bind(str(data["id"])))
        row.add_child(buy)
    visible = true

func _buy_click(item_id: String) -> void:
    purchase_requested.emit(item_id)

func hide_store() -> void:
    if not visible:
        return
    visible = false
    closed.emit()
