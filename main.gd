extends Node2D

const WIDTH := 1100.0
const HEIGHT := 680.0
const SPEED := 230.0
const REGIONS := [
    {"name": "Fortaleza", "position": Vector2(180, 235)},
    {"name": "Vila", "position": Vector2(510, 190)},
    {"name": "Mina", "position": Vector2(850, 280)},
    {"name": "Porto", "position": Vector2(650, 515)}
]
var hero := Vector2(530, 410)
var room := ""
var location := 0
var energy := 40
var agility_xp := 0
var show_map := false
var message := "WASD: andar | E: entrar/sair | M: mapa | R: descansar"
var doors := [
    {"name": "Salao principal", "rect": Rect2(245, 190, 155, 120)},
    {"name": "Quarto", "rect": Rect2(425, 190, 155, 120)},
    {"name": "Ferraria", "rect": Rect2(605, 190, 155, 120)}
]
var font: Font

func _ready() -> void:
    font = ThemeDB.fallback_font
    set_process(true)
    set_process_unhandled_input(true)
    queue_redraw()

func _process(delta: float) -> void:
    if show_map:
        return
    var axis := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    if Input.is_key_pressed(KEY_A):
        axis.x -= 1.0
    if Input.is_key_pressed(KEY_D):
        axis.x += 1.0
    if Input.is_key_pressed(KEY_W):
        axis.y -= 1.0
    if Input.is_key_pressed(KEY_S):
        axis.y += 1.0
    axis = axis.limit_length(1.0)
    if axis.length() > 0.0:
        var next := hero + axis * SPEED * delta
        next = next.clamp(Vector2(30, 115), Vector2(WIDTH - 30, HEIGHT - 35))
        if room == "":
            var blocked := false
            for door in doors:
                var wall: Rect2 = door["rect"]
                if wall.grow(17).has_point(next):
                    blocked = true
            if not blocked:
                hero = next
        else:
            hero = next.clamp(Vector2(260, 350), Vector2(840, 590))
        queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_M:
            show_map = not show_map
            message = "Mapa mundial" if show_map else "Explorando"
            queue_redraw()
        elif event.keycode == KEY_R:
            energy = 40
            message = "Energia recuperada (funcao de diagnostico)."
            queue_redraw()
        elif event.keycode == KEY_E and not show_map:
            if room != "":
                room = ""
                hero = Vector2(530, 410)
                message = "Voce saiu para o patio."
            else:
                for door in doors:
                    var target: Rect2 = door["rect"]
                    var entry := Vector2(target.position.x + target.size.x / 2.0, target.end.y + 25.0)
                    if hero.distance_to(entry) < 78.0:
                        room = str(door["name"])
                        hero = Vector2(550, 515)
                        message = "Interior: " + room + " | E: sair"
                        break
            queue_redraw()
    elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and show_map:
        for idx in range(REGIONS.size()):
            var point: Vector2 = REGIONS[idx]["position"]
            if event.position.distance_to(point) <= 48.0:
                travel_to(idx)
                break

func travel_to(idx: int) -> void:
    if idx == location:
        message = "Voce ja esta nessa regiao."
    elif energy < 5:
        message = "Energia insuficiente: viagem exige 5."
    else:
        var start: Vector2 = REGIONS[location]["position"]
        var goal: Vector2 = REGIONS[idx]["position"]
        var xp := mini(15, maxi(1, ceili(start.distance_to(goal) / 35.0)))
        energy -= 5
        agility_xp += xp
        location = idx
        room = ""
        hero = Vector2(530, 410)
        message = "Viagem concluida (-5 energia, +%d XP Agilidade)." % xp
        show_map = false
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(0, 0, WIDTH, HEIGHT), Color("#314b36"))
    draw_rect(Rect2(0, 0, WIDTH, 96), Color("#1c251e"))
    draw_text("FORTALEZA: ULTIMO BASTIAO - TESTE DE ENTREGA", Vector2(22, 35), 24, Color("#f5e1ad"))
    draw_text("Local: %s    Energia: %d    XP Agilidade: %d" % [REGIONS[location]["name"], energy, agility_xp], Vector2(22, 71), 19, Color.WHITE)
    if show_map:
        draw_world_map()
    elif room != "":
        draw_interior()
    else:
        draw_courtyard()
    draw_rect(Rect2(0, HEIGHT - 38, WIDTH, 38), Color("#1c251e"))
    draw_text(message, Vector2(18, HEIGHT - 13), 17, Color("#f5e1ad"))

func draw_courtyard() -> void:
    draw_rect(Rect2(38, 112, WIDTH - 76, 510), Color("#557449"))
    for n in range(14):
        var x := 80.0 + n * 71.0
        draw_rect(Rect2(x, 145, 28, 28), Color("#456b35"))
    draw_rect(Rect2(460, 310, 150, 300), Color("#b3a07b"))
    for door in doors:
        var rect: Rect2 = door["rect"]
        draw_rect(rect, Color("#6a5440"))
        draw_rect(Rect2(rect.position + Vector2(7, 7), rect.size - Vector2(14, 14)), Color("#a28a5b"))
        draw_rect(Rect2(rect.position.x + rect.size.x / 2.0 - 15.0, rect.end.y - 25.0, 30, 25), Color("#342a24"))
        draw_text(str(door["name"]), rect.position + Vector2(10, 52), 17, Color.WHITE)
    draw_text("Aproxime-se de uma porta e pressione E", Vector2(338, 605), 18, Color("#fff0c4"))
    draw_hero()

func draw_interior() -> void:
    draw_rect(Rect2(235, 125, 635, 480), Color("#6c5441"))
    draw_rect(Rect2(255, 145, 595, 440), Color("#b29365"))
    draw_text(room.to_upper(), Vector2(445, 180), 26, Color("#2c211b"))
    if room == "Quarto":
        draw_rect(Rect2(320, 260, 175, 115), Color("#6a382f"))
        draw_rect(Rect2(331, 270, 150, 55), Color("#e2c9a7"))
    elif room == "Ferraria":
        draw_rect(Rect2(320, 275, 180, 110), Color("#473c35"))
        draw_rect(Rect2(350, 297, 125, 62), Color("#df7732"))
        draw_text("FORJA", Vector2(357, 408), 20, Color("#f3e1cb"))
    else:
        draw_rect(Rect2(315, 280, 340, 85), Color("#654537"))
        draw_text("MESA DO SALAO", Vector2(378, 330), 20, Color.WHITE)
    draw_text("Pressione E para sair", Vector2(410, 590), 20, Color("#2c211b"))
    draw_hero()

func draw_world_map() -> void:
    draw_rect(Rect2(45, 105, 1010, 527), Color("#dcc79a"))
    draw_text("MAPA MUNDIAL - CLIQUE NUM DESTINO | M PARA FECHAR", Vector2(145, 145), 23, Color("#3c3223"))
    for i in range(REGIONS.size()):
        var a: Vector2 = REGIONS[i]["position"]
        var b: Vector2 = REGIONS[(i + 1) % REGIONS.size()]["position"]
        draw_line(a, b, Color("#836c48"), 6.0, true)
    for i in range(REGIONS.size()):
        var pos: Vector2 = REGIONS[i]["position"]
        var color := Color("#3f783b") if location == i else Color("#8a4d2d")
        draw_circle(pos, 27.0, color)
        draw_text(str(REGIONS[i]["name"]), pos + Vector2(-35, 50), 20, Color("#2d261c"))
    draw_text("Toda viagem custa 5 energia; XP por distancia (maximo 15).", Vector2(155, 610), 18, Color("#3c3223"))

func draw_hero() -> void:
    draw_circle(hero + Vector2(0, 15), 17, Color("#25342b"))
    draw_rect(Rect2(hero - Vector2(13, 13), Vector2(26, 32)), Color("#375c80"))
    draw_circle(hero - Vector2(0, 18), 13, Color("#ecc69a"))

func draw_text(text: String, position: Vector2, font_size: int, color: Color) -> void:
    draw_string(font, position, text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, color)
