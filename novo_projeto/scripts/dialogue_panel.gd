extends Control
const UI = preload("res://scripts/ui_theme.gd")
## Componente original, reutilizavel: 9-slice, nome, revelacao e escolhas.
signal choice_selected(index: int)
signal dialogue_closed
const CHARACTER_INTERVAL := 0.025
var speaker_label: Label
var portrait_letter: Label
var body_label: RichTextLabel
var choice_column: VBoxContainer
var continue_button: Button
var _elapsed := 0.0
var _visible_characters := 0
var _full_length := 0
var _revealing := false
var _options: Array[String] = []

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_STOP
    visible = false
    var shade := ColorRect.new()
    shade.color = Color(0.02, 0.02, 0.02, .38)
    shade.mouse_filter = Control.MOUSE_FILTER_STOP
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(shade)

    var panel := PanelContainer.new()
    panel.name = "ParchmentDialogue"
    panel.anchor_left = .13
    panel.anchor_right = .87
    panel.anchor_top = 1.0
    panel.anchor_bottom = 1.0
    panel.offset_top = -264.0
    panel.offset_bottom = -26.0
    panel.add_theme_stylebox_override("panel", _make_nine_slice())
    add_child(panel)
    var content_box := VBoxContainer.new()
    content_box.add_theme_constant_override("separation", 9)
    panel.add_child(content_box)
    body_label = RichTextLabel.new()
    body_label.name = "TypedText"
    body_label.bbcode_enabled = false
    body_label.scroll_active = false
    body_label.custom_minimum_size.y = 80
    body_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
    body_label.add_theme_color_override("default_color", Color("#34271d"))
    body_label.add_theme_font_size_override("normal_font_size", 22)
    body_label.visible_characters = 0
    content_box.add_child(body_label)
    choice_column = VBoxContainer.new()
    choice_column.name = "Choices"
    choice_column.add_theme_constant_override("separation", 5)
    content_box.add_child(choice_column)
    continue_button = Button.new()
    continue_button.text = "Continuar ▶"
    UI.apply_button(continue_button)
    continue_button.pressed.connect(advance)
    content_box.add_child(continue_button)

    var name_frame := PanelContainer.new()
    name_frame.name = "NameBox"
    name_frame.anchor_left = .16
    name_frame.anchor_right = .49
    name_frame.anchor_top = 1.0
    name_frame.anchor_bottom = 1.0
    name_frame.offset_top = -300
    name_frame.offset_bottom = -257
    var name_style := StyleBoxFlat.new()
    name_style.bg_color = Color("#483222")
    name_style.border_color = Color("#c9a76b")
    name_style.set_border_width_all(2)
    name_style.set_corner_radius_all(6)
    name_style.content_margin_left = 12
    name_style.content_margin_right = 12
    name_frame.add_theme_stylebox_override("panel", name_style)
    add_child(name_frame)
    var portrait_panel := PanelContainer.new()
    portrait_panel.name = "OriginalPortraitFrame"
    portrait_panel.anchor_left = .025
    portrait_panel.anchor_right = .118
    portrait_panel.anchor_top = 1.0
    portrait_panel.anchor_bottom = 1.0
    portrait_panel.offset_top = -248
    portrait_panel.offset_bottom = -70
    UI.apply_panel(portrait_panel)
    add_child(portrait_panel)
    portrait_letter = Label.new()
    portrait_letter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    portrait_letter.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    portrait_letter.add_theme_font_size_override("font_size", 53)
    portrait_letter.add_theme_color_override("font_color", UI.MUTED_GOLD)
    portrait_panel.add_child(portrait_letter)
    speaker_label = Label.new()
    speaker_label.name = "Speaker"
    speaker_label.add_theme_font_size_override("font_size", 21)
    speaker_label.add_theme_color_override("font_color", Color("#f8e1b5"))
    speaker_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
    name_frame.add_child(speaker_label)
    set_process(false)

func _make_nine_slice() -> StyleBoxTexture:
    var img := Image.create(48, 48, false, Image.FORMAT_RGBA8)
    var parchment := Color("#e9d5ac")
    for y in range(48):
        for x in range(48):
            var edge_dist: int = mini(mini(x, y), mini(47 - x, 47 - y))
            var color := parchment
            if edge_dist < 5:
                color = Color("#5a3824")
            elif edge_dist < 9:
                color = Color("#b98b48")
            elif edge_dist < 12:
                color = Color("#785033")
            else:
                color = parchment.darkened(float((x * 11 + y * 17) % 9) / 400.0)
            if (x < 13 and y < 13) or (x >= 35 and y < 13) or (x < 13 and y >= 35) or (x >= 35 and y >= 35):
                if x % 5 == 0 and y % 5 == 0:
                    color = Color("#e5be74")
            img.set_pixel(x, y, color)
    var style := StyleBoxTexture.new()
    style.texture = ImageTexture.create_from_image(img)
    style.texture_margin_left = 16
    style.texture_margin_right = 16
    style.texture_margin_top = 16
    style.texture_margin_bottom = 16
    style.content_margin_left = 28
    style.content_margin_right = 28
    style.content_margin_top = 24
    style.content_margin_bottom = 15
    style.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
    style.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
    return style

func show_dialogue(speaker: String, message: String, choices: Array = []) -> void:
    speaker_label.text = speaker
    portrait_letter.text = speaker.substr(0, 1).to_upper()
    body_label.text = message
    body_label.visible_characters = 0
    _full_length = message.length()
    _visible_characters = 0
    _elapsed = 0.0
    _revealing = true
    _options.clear()
    for choice in choices:
        _options.append(str(choice))
    for old in choice_column.get_children():
        choice_column.remove_child(old)
        old.queue_free()
    choice_column.visible = false
    continue_button.visible = false
    visible = true
    set_process(true)

func _process(delta: float) -> void:
    if not _revealing:
        return
    _elapsed += delta
    var count := int(_elapsed / CHARACTER_INTERVAL)
    if count > 0:
        _elapsed -= float(count) * CHARACTER_INTERVAL
        _visible_characters = mini(_full_length, _visible_characters + count)
        body_label.visible_characters = _visible_characters
    if _visible_characters >= _full_length:
        _finish_typing()

func _finish_typing() -> void:
    _revealing = false
    set_process(false)
    body_label.visible_characters = -1
    if _options.is_empty():
        continue_button.visible = true
        return
    choice_column.visible = true
    for i in range(_options.size()):
        var button := Button.new()
        button.text = _options[i]
        button.alignment = HORIZONTAL_ALIGNMENT_LEFT
        UI.apply_button(button)
        button.pressed.connect(_select_choice.bind(i))
        choice_column.add_child(button)

func advance() -> void:
    if not visible:
        return
    if _revealing:
        _finish_typing()
    elif _options.is_empty():
        close_dialogue()

func _select_choice(index: int) -> void:
    if not _revealing:
        choice_selected.emit(index)

func close_dialogue() -> void:
    visible = false
    set_process(false)
    dialogue_closed.emit()

func _unhandled_key_input(event: InputEvent) -> void:
    if not visible or not event is InputEventKey or not event.pressed or event.echo:
        return
    if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
        advance()
        get_viewport().set_input_as_handled()
