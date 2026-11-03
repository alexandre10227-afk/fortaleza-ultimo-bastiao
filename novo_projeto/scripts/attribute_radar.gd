extends Control
## Radar pentagonal autoral, desenhado apenas quando os atributos mudam.
const PROFILE = preload("res://scripts/character_profile.gd")
const GOLD := Color("#c7a367")
const GRID := Color("#695849")
const FILLED := Color(0.78, 0.46, 0.22, 0.38)
var stats: Dictionary = PROFILE.default_stats()

func _ready() -> void:
    custom_minimum_size = Vector2(220, 210)
    mouse_filter = Control.MOUSE_FILTER_IGNORE

func set_stats(values: Dictionary) -> void:
    stats = values.duplicate(true)
    queue_redraw()

func _draw() -> void:
    var center := Vector2(size.x / 2.0, size.y / 2.0)
    var radius := minf(size.x, size.y) * .36
    var count := PROFILE.ATTRIBUTES.size()
    for ring in range(1, 6):
        var points := PackedVector2Array()
        for idx in range(count):
            var theta := float(idx) * TAU / float(count) - PI / 2.0
            points.append(center + Vector2(cos(theta), sin(theta)) * radius * float(ring) / 5.0)
        points.append(points[0])
        draw_polyline(points, GRID, 1.2, true)
    var values := PackedVector2Array()
    for idx in range(count):
        var theta := float(idx) * TAU / float(count) - PI / 2.0
        var direction := Vector2(cos(theta), sin(theta))
        draw_line(center, center + direction * radius, GRID, 1.0, true)
        var score := clampf(float(stats.get(PROFILE.ATTRIBUTES[idx], 1)), 0.0, 10.0)
        values.append(center + direction * radius * score / 10.0)
    draw_colored_polygon(values, FILLED)
    var outline := values.duplicate()
    outline.append(values[0])
    draw_polyline(outline, GOLD, 2.0, true)
    for dot in values:
        draw_circle(dot, 3.0, GOLD)
