extends Control
## Title screen drawing by original vector scenery; no web textures or per-frame allocations.
func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
    var w := size.x
    var h := size.y
    for band in range(24):
        var y := h * float(band) / 24.0
        var t := float(band) / 24.0
        draw_rect(Rect2(0,y,w,h/24.0+1), Color("#151a24").lerp(Color("#4c3931"),t))
    # Moonlit clouds and mountain profiles.
    draw_circle(Vector2(w*.77,h*.20), 48, Color("#b4a88b"))
    draw_circle(Vector2(w*.77,h*.20), 35, Color("#d6c6a3"))
    draw_colored_polygon(PackedVector2Array([
        Vector2(0,h*.77),Vector2(w*.12,h*.49),Vector2(w*.27,h*.71),
        Vector2(w*.39,h*.43),Vector2(w*.58,h*.75),Vector2(w*.73,h*.50),
        Vector2(w,h*.74),Vector2(w,h),Vector2(0,h)
    ]),Color("#252b2c"))
    draw_colored_polygon(PackedVector2Array([
        Vector2(0,h*.88),Vector2(w*.2,h*.72),Vector2(w*.39,h*.90),
        Vector2(w*.67,h*.67),Vector2(w,h*.84),Vector2(w,h),Vector2(0,h)
    ]),Color("#1d2325"))
    # Fortification silhouette: towers, gate and defensive crenels.
    var tower_color := Color("#201d1e")
    draw_rect(Rect2(w*.05,h*.56,w*.28,h*.38),tower_color)
    draw_rect(Rect2(w*.11,h*.45,w*.07,h*.49),tower_color)
    draw_rect(Rect2(w*.25,h*.48,w*.06,h*.46),tower_color)
    for index in range(6):
        draw_rect(Rect2(w*(.05+float(index)*.046), h*.525, w*.025, h*.04), tower_color)
    draw_rect(Rect2(w*.37,h*.65,w*.22,h*.32),tower_color)
    draw_rect(Rect2(w*.45,h*.48,w*.065,h*.49),tower_color)
    # Gate in a warm restrained glow.
    draw_rect(Rect2(w*.44,h*.76,w*.08,h*.21),Color("#6a4935"))
    draw_rect(Rect2(w*.455,h*.79,w*.05,h*.18),Color("#af7c45"))
    draw_rect(Rect2(0,h*.94,w,h*.06),Color("#151518"))
    for index in range(17):
        var x := w * (float(index)+.5) / 17.0
        draw_line(Vector2(x,h*.90),Vector2(x+w*.02,h),Color("#332923"),2.0)
