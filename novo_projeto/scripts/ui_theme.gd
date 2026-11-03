extends RefCounted
## Fortaleza original GUI: parchment, ink, aged bronze, dark wood.
## No imported commercial assets; reusable Godot-native styles.
const INK := Color("#352719")
const PARCHMENT := Color("#ead9b7")
const DARK_WOOD := Color("#30241e")
const BRONZE := Color("#b89459")
const MUTED_GOLD := Color("#d6bc83")
const LIGHT_TEXT := Color("#f0e4cf")
const HOVER_WOOD := Color("#60452f")
const SELECTED := Color("#76522f")

static func panel_style(dark: bool = true) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = DARK_WOOD if dark else PARCHMENT
    style.border_color = BRONZE
    style.set_border_width_all(3)
    style.set_corner_radius_all(7)
    style.corner_detail = 3
    style.shadow_color = Color(0, 0, 0, .35)
    style.shadow_size = 7
    style.content_margin_left = 22
    style.content_margin_right = 22
    style.content_margin_top = 21
    style.content_margin_bottom = 21
    return style

static func button_style(kind: String = "normal") -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = DARK_WOOD if kind == "normal" else HOVER_WOOD if kind == "hover" else SELECTED if kind == "pressed" else Color("#302d2a")
    style.border_color = BRONZE if kind != "disabled" else Color("#685c4d")
    style.set_border_width_all(2)
    style.set_corner_radius_all(5)
    style.content_margin_left = 17
    style.content_margin_right = 17
    style.content_margin_top = 10
    style.content_margin_bottom = 10
    return style

static func apply_button(button: Button) -> void:
    for name in ["normal", "hover", "pressed", "disabled", "focus"]:
        button.add_theme_stylebox_override(name, button_style(name if name != "focus" else "hover"))
    button.add_theme_color_override("font_color", LIGHT_TEXT)
    button.add_theme_color_override("font_hover_color", Color("#fff1bd"))
    button.add_theme_color_override("font_pressed_color", LIGHT_TEXT)
    button.add_theme_color_override("font_disabled_color", Color("#ad9b7f"))
    button.add_theme_font_size_override("font_size", 17)
    button.custom_minimum_size.y = maxf(42, button.custom_minimum_size.y)

static func apply_panel(panel: PanelContainer, dark: bool = true) -> void:
    panel.add_theme_stylebox_override("panel", panel_style(dark))

static func apply_title(label: Label, dark_background: bool = true) -> void:
    label.add_theme_color_override("font_color", MUTED_GOLD if dark_background else INK)
    label.add_theme_font_size_override("font_size", 27)

static func apply_text(label: Label, dark_background: bool = true) -> void:
    label.add_theme_color_override("font_color", LIGHT_TEXT if dark_background else INK)

static func apply_input(line: LineEdit) -> void:
    line.add_theme_stylebox_override("normal", panel_style(false))
    line.add_theme_stylebox_override("focus", panel_style(false))
    line.add_theme_color_override("font_color", INK)
    line.add_theme_color_override("font_placeholder_color", Color("#80715f"))

static func make_rarity_color(rarity: String) -> Color:
    match rarity:
        "Comum": return Color("#9e9b91")
        "Incomum": return Color("#6db889")
        "Raro": return Color("#659dd8")
        "Epico": return Color("#ac80d9")
        "Lendario": return Color("#e0b75a")
        "Mitico": return Color("#e07870")
        _: return Color.WHITE
