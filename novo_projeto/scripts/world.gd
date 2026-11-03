extends Node3D

var player: Node3D
var hud: Label
var news: RichTextLabel
var camera: Camera3D
const WALK_SPEED := 5.0

func _ready() -> void:
    _generate_world()
    _generate_ui()
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
    add_child(layer)
    var frame := Control.new()
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
    var direction := Vector3.ZERO
    if Input.is_key_pressed(KEY_W): direction.z -= 1.0
    if Input.is_key_pressed(KEY_S): direction.z += 1.0
    if Input.is_key_pressed(KEY_A): direction.x -= 1.0
    if Input.is_key_pressed(KEY_D): direction.x += 1.0
    if direction.length_squared() > 0:
        var target := player.position + direction.normalized() * WALK_SPEED * delta
        target.x = clampf(target.x, -26, 26)
        target.z = clampf(target.z, -29, 29)
        player.position = target
        camera.position = player.position + Vector3(16, 19, 23)

func _unhandled_key_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo:
        return
    match event.keycode:
        KEY_N:
            GameState.advance_days(1)
            _refresh_hud()
        KEY_T:
            var destination := "Porto Cinzento" if GameState.current_region == "Fortaleza" else "Fortaleza"
            GameState.travel(destination, 210.0)
            _refresh_hud()
        KEY_C:
            news.visible = not news.visible
            _refresh_news()
        KEY_V:
            town_panel.visible = not town_panel.visible
            _refresh_tavern()
        KEY_B:
            last_message = "Compra de pao concluida" if GameState.buy_item("pao") else "Moedas insuficientes"
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
