extends Node3D

var player: Node3D
var hud: Label
var news: RichTextLabel
var town_panel: RichTextLabel
var last_message := ""
var active_interior := ""
var interior_node: Node3D
var map_dialog: PanelContainer
var map_open := false
var interact_hint: Label
var settlement: Node3D
var camera: Camera3D
const WALK_SPEED := 5.0

func _ready() -> void:
    _generate_world()
    _generate_ui()
    _generate_map_dialog()
    _refresh_hud()

func _make_box(parent: Node3D, location: Vector3, dimensions: Vector3, tint: Color) -> void:
    var mesh := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = dimensions
    mesh.mesh = box
    mesh.position = location
    var mat := StandardMaterial3D.new()
    mat.albedo_color = tint
    mesh.material_override = mat
    parent.add_child(mesh)

func _generate_world() -> void:
    var light := DirectionalLight3D.new()
    light.rotation_degrees = Vector3(-50, -35, 0)
    add_child(light)
    var world_env := WorldEnvironment.new()
    world_env.environment = Environment.new()
    world_env.environment.background_mode = Environment.BG_COLOR
    world_env.environment.background_color = Color("#9cb4ad")
    add_child(world_env)
    var settlement := Node3D.new()
    add_child(settlement)
    _make_terrain_texture(settlement)
    interior_node = Node3D.new()
    interior_node.visible = false
    add_child(interior_node)
    _make_box(settlement, Vector3(0, -0.65, 0), Vector3(80, 1.1, 80), Color("#667d4c"))
    _make_box(settlement, Vector3(0, -0.07, 0), Vector3(4, .08, 48), Color("#a99a7b"))
    for i in range(5):
        var z := -17.0 + i * 8.0
        _make_box(settlement, Vector3(-9, 1.4, z), Vector3(6, 2.8, 5), Color("#8b7259"))
        _make_box(settlement, Vector3(9, 1.4, z), Vector3(6, 2.8, 5), Color("#88735a"))
        _make_box(settlement, Vector3(-9, 3.2, z), Vector3(7, .9, 6), Color("#655044"))
        _make_box(settlement, Vector3(9, 3.2, z), Vector3(7, .9, 6), Color("#655044"))
    for i in range(16):
        var z := -28.0 + i * 4.0
        _make_box(settlement, Vector3(-30, 1.0, z), Vector3(1.5, 2.0, 2), Color("#526a48"))
        _make_box(settlement, Vector3(30, 1.0, z), Vector3(1.5, 2.0, 2), Color("#526a48"))
    for visitor in range(4):
        var npc := Sprite3D.new()
        npc.texture = _make_sprite_texture()
        npc.pixel_size = 0.026
        npc.billboard = BaseMaterial3D.BILLBOARD_ENABLED
        npc.shaded = false
        npc.position = Vector3(4.7 + float(visitor % 2) * 2.0, 1.0, -13.0 + float(visitor / 2) * 6.0)
        settlement.add_child(npc)
    player = Node3D.new()
    player.position = Vector3(0, 0, 13)
    add_child(player)
    var character := Sprite3D.new()
    character.texture = _make_sprite_texture()
    character.pixel_size = 0.028
    character.position.y = 0.82
    character.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    character.shaded = false
    player.add_child(character)
    camera = Camera3D.new()
    camera.projection = Camera3D.PROJECTION_ORTHOGONAL
    camera.size = 22.0
    camera.position = Vector3(16, 19, 23)
    camera.rotation_degrees = Vector3(-43, 35, 0)
    camera.current = true
    add_child(camera)

func _make_sprite_texture() -> Texture2D:
    var picture := Image.create(24, 40, false, Image.FORMAT_RGBA8)
    picture.fill(Color.TRANSPARENT)
    for x in range(7, 17):
        for y in range(12, 35):
            picture.set_pixel(x, y, Color("#395679"))
    for x in range(8, 16):
        for y in range(3, 13):
            picture.set_pixel(x, y, Color("#e9b58e"))
    for x in range(7, 17):
        for y in range(1, 6):
            picture.set_pixel(x, y, Color("#352c2a"))
    return ImageTexture.create_from_image(picture)

func _generate_ui() -> void:
    var layer := CanvasLayer.new()
    layer.name = "CanvasLayer"
    add_child(layer)
    var frame := Control.new()
    frame.name = "Control"
    frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layer.add_child(frame)
    var column := VBoxContainer.new()
    column.position = Vector2(15, 12)
    column.custom_minimum_size = Vector2(530, 0)
    frame.add_child(column)
    hud = Label.new()
    hud.add_theme_font_size_override("font_size", 19)
    column.add_child(hud)
    var help := Label.new()
    help.add_theme_font_size_override("font_size", 15)
    help.text = "WASD: explorar | N: avancar dia | T: viajar | C: cronicas | F5: salvar"
    column.add_child(help)
    help.text = "WASD mover | E entrar/sair | M mapa | N dia | V taverna | B comprar | I itens"
    interact_hint = Label.new()
    column.add_child(interact_hint)
    news = RichTextLabel.new()
    news.position = Vector2(15, 100)
    news.size = Vector2(490, 230)
    news.visible = false
    news.mouse_filter = Control.MOUSE_FILTER_IGNORE
    frame.add_child(news)
    town_panel = RichTextLabel.new()
    town_panel.position = Vector2(665, 90)
    town_panel.size = Vector2(500, 350)
    town_panel.visible = false
    town_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    frame.add_child(town_panel)

func _process(delta: float) -> void:
    if map_open:
        return
    var direction := Vector3.ZERO
    if Input.is_key_pressed(KEY_W): direction.z -= 1.0
    if Input.is_key_pressed(KEY_S): direction.z += 1.0
    if Input.is_key_pressed(KEY_A): direction.x -= 1.0
    if Input.is_key_pressed(KEY_D): direction.x += 1.0
    if direction.length_squared() > 0:
        var target := player.position + direction.normalized() * WALK_SPEED * delta
        target.x = clampf(target.x, -26, 26)
        target.z = clampf(target.z, -29, 29)
        if active_interior.is_empty():
            if not _is_blocked(target):
                player.position = target
        else:
            player.position = Vector3(clampf(target.x, -5.2, 5.2), 0, clampf(target.z, -4.5, 4.5))
        camera.position = player.position + Vector3(16, 19, 23)
    _update_hint()

func _unhandled_key_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo:
        return
    match event.keycode:
        KEY_N:
            GameState.advance_days(1)
            _refresh_hud()
        KEY_T, KEY_M:
            _toggle_map()
        KEY_E:
            _interact()
        KEY_C:
            news.visible = not news.visible
            _refresh_news()
        KEY_V:
            if active_interior == "Taverna":
                town_panel.visible = not town_panel.visible
                _refresh_tavern()
            else:
                last_message = "Visite a taverna para recrutar."
                _refresh_hud()
        KEY_B:
            if active_interior == "Taverna" or active_interior == "Ferraria":
                last_message = "Compra de pao concluida" if GameState.buy_item("pao") else "Moedas insuficientes"
            else:
                last_message = "Entre no estabelecimento para comprar."
            _refresh_hud()
        KEY_I:
            town_panel.visible = not town_panel.visible
            town_panel.text = "INVENTARIO\n" + str(GameState.inventory) + "\nCompanheiros: " + str(GameState.recruited)
        KEY_1, KEY_2, KEY_3, KEY_4, KEY_5:
            var visitors := preload("res://scripts/town_system.gd").tavern_visitors(GameState.current_region, GameState.day)
            var selected: int = event.keycode - KEY_1
            if town_panel.visible and selected < visitors.size():
                var npc: Dictionary = visitors[selected]
                var success := GameState.recruit_visitor(npc)
                last_message = ("Recrutado: " if success else "Recrutamento bloqueado: ") + str(npc["name"])
                _refresh_tavern()
                _refresh_hud()
        KEY_F5:
            GameState.save_game()
            _refresh_hud()

func _refresh_hud() -> void:
    hud.text = "%s | %s | %s | Dia %d | Energia %d | Onda %d | Moedas %d" % [GameState.character_name, GameState.difficulty, GameState.current_region, GameState.day, GameState.energy, GameState.wave_number, GameState.money]
    _refresh_news()
    if not last_message.is_empty():
        hud.text += "\n" + last_message

func _refresh_tavern() -> void:
    if town_panel == null:
        return
    var lines: Array[String] = ["TAVERNA - visitantes do dia %d" % GameState.day]
    var visitors := preload("res://scripts/town_system.gd").tavern_visitors(GameState.current_region, GameState.day)
    for i in range(visitors.size()):
        var npc: Dictionary = visitors[i]
        var can_join: bool = preload("res://scripts/town_system.gd").can_recruit(npc, GameState.oath)
        lines.append("[%d] %s (%s) / %s %s" % [i + 1, npc["name"], npc["rarity"], npc["profession"], "" if can_join else "[NAO RECRUTAVEL]"])
    lines.append("Teclas 1-5: tentar recrutar | V: fechar")
    lines.append("Pao: %d moedas | B: comprar" % preload("res://scripts/town_system.gd").price("pao", GameState.current_region, GameState.oath))
    town_panel.text = "\n".join(lines)

func _refresh_news() -> void:
    var lines: Array[String] = ["CRONICAS DO MUNDO (eventos salvos):"]
    for i in range(maxi(0, GameState.events.size() - 7), GameState.events.size()):
        var e := GameState.events[i]
        lines.append("Dia %d / %s: %s" % [e.get("day", 0), e.get("region", ""), e.get("description", "")])
    if GameState.dungeon_unlocked:
        lines.append("A Masmorra Antiga do Lago foi descoberta.")
    news.text = "\n".join(lines)

func _is_blocked(pos: Vector3) -> bool:
    for side in [-9.0, 9.0]:
        for i in range(5):
            var z := -17.0 + float(i) * 8.0
            if absf(pos.x - side) < 3.9 and absf(pos.z - z) < 3.35:
                return true
    return false

func _nearest_building() -> Dictionary:
    var best: Dictionary = {}
    var best_dist := 3.4
    for side in [-9.0, 9.0]:
        for i in range(5):
            var z := -17.0 + float(i) * 8.0
            var entrance := Vector3(side + (4.7 if side < 0.0 else -4.7), 0, z)
            var distance := player.position.distance_to(entrance)
            if distance < best_dist:
                best_dist = distance
                best = {"room": ("Taverna" if i == 0 else "Ferraria" if i == 1 else "Quarto" if i == 2 else "Salao"), "entrance": entrance}
    return best

func _update_hint() -> void:
    if interact_hint == null:
        return
    if not active_interior.is_empty():
        interact_hint.text = "Interior: %s | E: sair" % active_interior
    else:
        var nearby := _nearest_building()
        interact_hint.text = "E: entrar em %s" % nearby["room"] if not nearby.is_empty() else "Explore a vila; aproxime-se das portas"

func _interact() -> void:
    if map_open:
        return
    if not active_interior.is_empty():
        active_interior = ""
        settlement.visible = true
        interior_node.visible = false
        player.position = Vector3(0, 0, 13)
        town_panel.visible = false
        last_message = "Voce voltou para a vila."
    else:
        var target := _nearest_building()
        if target.is_empty():
            last_message = "Nao ha entrada perto de voce."
        else:
            active_interior = str(target["room"])
            settlement.visible = false
            interior_node.visible = true
            _build_interior(active_interior)
            player.position = Vector3(0, 0, 3)
            last_message = "Voce entrou em %s." % active_interior
    camera.position = player.position + Vector3(16, 19, 23)
    _refresh_hud()

func _build_interior(room_name: String) -> void:
    for obj in interior_node.get_children():
        obj.queue_free()
    _make_box(interior_node, Vector3(0, -0.35, 0), Vector3(14, .6, 12), Color("#b3946b"))
    _make_box(interior_node, Vector3(-6.6, 1.6, 0), Vector3(.6, 3.2, 12), Color("#6e503b"))
    _make_box(interior_node, Vector3(6.6, 1.6, 0), Vector3(.6, 3.2, 12), Color("#6e503b"))
    _make_box(interior_node, Vector3(0, 1.6, -5.7), Vector3(14, 3.2, .6), Color("#6e503b"))
    if room_name == "Ferraria":
        _make_box(interior_node, Vector3(-2.0, .7, -2), Vector3(2.5, 1.4, 2), Color("#a94f28"))
        _make_box(interior_node, Vector3(2.5, .65, -2), Vector3(1.6, 1.3, 1.6), Color("#454545"))
    elif room_name == "Quarto":
        _make_box(interior_node, Vector3(-2, .36, -2), Vector3(2, .7, 3), Color("#653a38"))
    elif room_name == "Taverna":
        for n in range(3):
            _make_box(interior_node, Vector3(-3 + n * 3, .8, -2), Vector3(2, .4, 2), Color("#624632"))
    else:
        _make_box(interior_node, Vector3(0, .85, -2), Vector3(4, .4, 2), Color("#624632"))

func _make_terrain_texture(parent: Node3D) -> void:
    var img := Image.create(64, 64, false, Image.FORMAT_RGB8)
    for y in range(64):
        for x in range(64):
            var n := (x * 71 + y * 43 + x * y * 3) % 19
            img.set_pixel(x, y, Color.from_hsv(.27, .34, .33 + float(n) * .009))
    var mat := StandardMaterial3D.new()
    mat.albedo_texture = ImageTexture.create_from_image(img)
    mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
    var tile := MeshInstance3D.new()
    var mesh := PlaneMesh.new()
    mesh.size = Vector2(79, 79)
    tile.mesh = mesh
    tile.material_override = mat
    tile.position.y = -.08
    parent.add_child(tile)

func _generate_map_dialog() -> void:
    map_dialog = PanelContainer.new()
    map_dialog.position = Vector2(370, 165)
    map_dialog.custom_minimum_size = Vector2(450, 260)
    var layout := VBoxContainer.new()
    map_dialog.add_child(layout)
    var title := Label.new()
    title.text = "MAPA MUNDIAL | viagem: 5 energia"
    layout.add_child(title)
    for destination in ["Fortaleza", "Porto Cinzento"]:
        var button := Button.new()
        button.text = "Viajar para " + destination
        button.pressed.connect(_travel_to.bind(destination))
        layout.add_child(button)
    var close := Button.new()
    close.text = "Fechar mapa"
    close.pressed.connect(_toggle_map)
    layout.add_child(close)
    get_node("CanvasLayer/Control").add_child(map_dialog)
    map_dialog.visible = false

func _toggle_map() -> void:
    map_open = not map_open
    map_dialog.visible = map_open

func _travel_to(destination: String) -> void:
    if not GameState.travel(destination, 210):
        last_message = "Viagem bloqueada: regiao atual ou energia insuficiente."
    else:
        active_interior = ""
        settlement.visible = true
        interior_node.visible = false
        player.position = Vector3(0, 0, 13)
        last_message = "Viagem concluida: -5 energia e XP de Agilidade."
    map_open = false
    map_dialog.visible = false
    _refresh_hud()
