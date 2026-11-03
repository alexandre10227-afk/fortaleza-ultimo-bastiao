extends Control
## Mapa de viagem original: desenho vetorial leve, nenhuma textura comercial.
signal destination_selected(region: String)
const INK := Color("#3d342a")
const PARCHMENT := Color("#c9bb94")
const ROAD := Color("#9b7450")
var current_region := "Fortaleza"
var clickable_regions: Dictionary = {
    "Fortaleza": Vector2(0.30, 0.44),
    "Porto Cinzento": Vector2(0.74, 0.68)
}
var hover_region := ""

func _ready() -> void:
    custom_minimum_size = Vector2(540, 305)
    mouse_filter = Control.MOUSE_FILTER_STOP

func configure(region: String) -> void:
    current_region = region
    queue_redraw()

func _draw() -> void:
    var bounds := Rect2(Vector2.ZERO, size)
    draw_rect(bounds, PARCHMENT)
    # Continuous mainland, not a floating island.
    draw_colored_polygon(PackedVector2Array([
        Vector2(0,size.y*.42), Vector2(size.x*.09,0),
        Vector2(size.x*.70,0), Vector2(size.x*.80,size.y*.22),
        Vector2(size.x*.92,size.y*.38), Vector2(size.x,size.y*.56),
        Vector2(size.x,size.y), Vector2(0,size.y)
    ]),Color("#82936a"))
    draw_rect(Rect2(Vector2(size.x*.81,0),Vector2(size.x*.19,size.y)),Color("#719daf"))
    for i in range(7):
        var x := size.x * (0.12 + i * 0.103)
        draw_circle(Vector2(x,size.y*.2), 19.0,Color("#607b54"))
    draw_polyline(PackedVector2Array([
        _point("Fortaleza"), Vector2(size.x*.48,size.y*.52),
        Vector2(size.x*.60,size.y*.58), _point("Porto Cinzento")
    ]),ROAD,7.0,true)
    # Bridges on the shore and visible connection to the harbor.
    for idx in range(4):
        var x := size.x*(0.70+idx*.045)
        draw_line(Vector2(x,size.y*.63),Vector2(x,size.y*.71),Color("#736049"),4.0,true)
    for region in clickable_regions:
        var pos := _point(region)
        var selected: bool = region == current_region
        var hovered: bool = region == hover_region
        draw_circle(pos,19 if selected or hovered else 15,Color("#3e362b"))
        draw_circle(pos,14 if selected or hovered else 10,Color("#d0af69") if selected else Color("#dcc895"))
        var label := str(region)
        var font := ThemeDB.fallback_font
        draw_string(font,pos+Vector2(-55,-26),label,HORIZONTAL_ALIGNMENT_LEFT,-1,17,INK)
    draw_rect(bounds,Color("#5b412c"),false,4)

func _point(region: String) -> Vector2:
    var norm: Vector2 = clickable_regions[region]
    return Vector2(norm.x*size.x,norm.y*size.y)

func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        var nearest := ""
        for region in clickable_regions:
            if _point(region).distance_to(event.position) < 32:
                nearest = str(region)
                break
        if nearest != hover_region:
            hover_region = nearest
            queue_redraw()
    elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        for region in clickable_regions:
            if _point(region).distance_to(event.position) <= 34:
                destination_selected.emit(str(region))
                accept_event()
                return
