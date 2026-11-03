extends Node3D
const UI = preload("res://scripts/ui_theme.gd")
const STORY = preload("res://scripts/story_content.gd")
const ITEMS = preload("res://scripts/item_catalog.gd")
const RECIPES = preload("res://scripts/economy_system.gd")
const NPCS = preload("res://scripts/npc_registry.gd")
const ROUTINES = preload("res://scripts/npc_daily_routines.gd")

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
const REGION_SYSTEM = preload("res://scripts/region_system.gd")
var regional_details: Node3D
var npc_visuals: Dictionary = {}
var world_environment: WorldEnvironment
var dialogue_ui: Control
var _dialogue_npc: Dictionary = {}
var resource_visuals: Dictionary = {}
const DUKE = preload("res://scripts/duke_event.gd")
var _duke_riddle_mode := false
var _gift_mode := false
var _gift_target: Dictionary = {}
var _gift_ids: Array[String] = []
var _gift_option := -1
var _tavern_selected: Dictionary = {}
var _market_mode := false
var _market_selling := false
var _market_travelling := false
var _market_ids: Array[String] = []
var npc_menu: Control
var _market_page := 0
var _food_mode := false
var _food_ids: Array[String] = []
var _craft_mode := false
var _craft_ids: Array[String] = []
const HINT_REFRESH_SECONDS := 0.18
var _hint_accumulator := 0.0
var _cached_hint := ""
var _shared_materials: Dictionary = {}
var _sprite_texture: Texture2D
var _interior_return_position := Vector3(0, 0, 13)
var _active_region_label: Label


func _ready() -> void:
    _generate_world()
    _apply_region_theme()
    _generate_ui()
    _generate_map_dialog()
    _create_dialogue_ui()
    _create_npc_menu()
    _refresh_hud()

func _make_box(parent: Node3D, location: Vector3, dimensions: Vector3, tint: Color, solid: bool = false) -> void:
    var mesh := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = dimensions
    mesh.mesh = box
    mesh.position = location
    var key := tint.to_html()
    if not _shared_materials.has(key):
        var mat := StandardMaterial3D.new()
        mat.albedo_color = tint
        _shared_materials[key] = mat
    mesh.material_override = _shared_materials[key]
    parent.add_child(mesh)
    if solid:
        var body := StaticBody3D.new()
        body.position = location
        var collision := CollisionShape3D.new()
        var shape := BoxShape3D.new()
        shape.size = dimensions
        collision.shape = shape
        body.add_child(collision)
        parent.add_child(body)

func _generate_world() -> void:
    var light := DirectionalLight3D.new()
    light.rotation_degrees = Vector3(-50, -35, 0)
    add_child(light)
    var world_env := WorldEnvironment.new()
    world_environment = world_env
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
        _make_box(settlement, Vector3(-9, 1.4, z), Vector3(6, 2.8, 5), Color("#8b7259"), true)
        _make_box(settlement, Vector3(9, 1.4, z), Vector3(6, 2.8, 5), Color("#88735a"), true)
        _make_box(settlement, Vector3(-9, 3.2, z), Vector3(7, .9, 6), Color("#655044"))
        _make_box(settlement, Vector3(9, 3.2, z), Vector3(7, .9, 6), Color("#655044"))
    for i in range(16):
        var z := -28.0 + i * 4.0
        _make_box(settlement, Vector3(-30, 1.0, z), Vector3(1.5, 2.0, 2), Color("#526a48"))
        _make_box(settlement, Vector3(30, 1.0, z), Vector3(1.5, 2.0, 2), Color("#526a48"))
    _sprite_texture = _make_sprite_texture()
    regional_details = Node3D.new()
    regional_details.name = "RegionDetails"
    settlement.add_child(regional_details)
    player = CharacterBody3D.new()
    var physical_shape := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.35
    capsule.height = 1.55
    physical_shape.shape = capsule
    physical_shape.position.y = 0.78
    player.add_child(physical_shape)
    player.position = Vector3(0, 0, 13)
    add_child(player)
    var character := Sprite3D.new()
    character.texture = _sprite_texture
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
    help.text = "WASD mover | E entrar/sair | Q conversar | M mapa | N dia | V taverna | G coletar | B comprar | I itens"
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
    town_panel.add_theme_color_override("default_color", UI.LIGHT_TEXT)

func _process(delta: float) -> void:
    if map_open or (dialogue_ui != null and dialogue_ui.visible) or (npc_menu != null and npc_menu.is_open()):
        return
    _hint_accumulator += delta
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
                player.velocity = direction.normalized() * WALK_SPEED
                player.move_and_slide()
        else:
            player.position = Vector3(clampf(target.x, -5.2, 5.2), 0, clampf(target.z, -4.5, 4.5))
        camera.position = player.position + Vector3(16, 19, 23)
    if _hint_accumulator >= HINT_REFRESH_SECONDS:
        _hint_accumulator = 0.0
        _update_hint()

func _unhandled_key_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo:
        return
    if (dialogue_ui != null and dialogue_ui.visible) or (npc_menu != null and npc_menu.is_open()):
        return
    match event.keycode:
        KEY_N:
            GameState.advance_days(1)
            _refresh_resident_positions()
            _refresh_resource_visibility()
            _refresh_hud()
        KEY_Q:
            if active_interior == "Mansao do Duque":
                _talk_in_manor()
            else:
                _talk_to_nearest_npc()
        KEY_R:
            if active_interior == "Mansao do Duque":
                _recruit_at_manor()
        KEY_G:
            _gather_nearby()
        KEY_P:
            if active_interior == "Mansao do Duque":
                var special := "herdeira_duque" if GameState.DUKE.daughter_at_manor(GameState.duke_state) else "duque"
                _present_to({"id":special,"name":"Herdeira do Duque" if special == "herdeira_duque" else "Duque","profession":"Nobre"})
            elif active_interior == "Taverna" and not _tavern_selected.is_empty():
                _present_to(_tavern_selected)
            elif active_interior.is_empty():
                _present_to(_nearest_npc())
        KEY_T, KEY_M:
            _toggle_map()
        KEY_E:
            _contextual_interact()
        KEY_C:
            news.visible = not news.visible
            _refresh_news()
        KEY_V:
            _market_mode = false
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
        KEY_F:
            _open_food_menu()
        KEY_H:
            if active_interior == "Ferraria":
                _open_craft_menu()
        KEY_Y:
            if active_interior == "Ferraria":
                last_message = "Ferraria aprimorada." if GameState.upgrade_building("Ferraria") else "Faltam moedas, materiais ou nivel maximo."
                _refresh_hud()
        KEY_O:
            if active_interior == "Taverna" or active_interior == "Ferraria" or (active_interior.is_empty() and preload("res://scripts/town_system.gd").travelling_merchant_present(GameState.current_region, GameState.day)):
                _market_mode = true
                _market_page = 0
                _market_selling = false
                _market_travelling = active_interior.is_empty()
                _refresh_market()
            else:
                last_message = "Visite o mercado ou encontre a caravana viajante."
                _refresh_hud()
        KEY_Z:
            if _market_mode:
                _market_page = 0
                _market_selling = not _market_selling
                _refresh_market()
        KEY_L:
            if _market_mode:
                _market_page += 1
                _refresh_market()
        KEY_I:
            _market_mode = false
            town_panel.visible = not town_panel.visible
            town_panel.text = "INVENTARIO\n" + str(GameState.inventory) + "\nCompanheiros: " + str(GameState.recruited)
        KEY_1, KEY_2, KEY_3, KEY_4, KEY_5:
            if _market_mode:
                _market_transaction(event.keycode - KEY_1)
                return
            var visitors := _current_tavern_visitors()
            var selected: int = event.keycode - KEY_1
            if town_panel.visible and selected < visitors.size():
                var npc: Dictionary = visitors[selected]
                _tavern_selected = npc.duplicate(true)
                var npc_id := str(npc.get("id", ""))
                var success := false
                if npc_id == DUKE.DAUGHTER_ID:
                    success = GameState.duke_daughter_recruit()
                elif GameState.recruited.has(npc_id):
                    last_message = "Esse aventureiro ja integra seu grupo."
                elif not preload("res://scripts/town_system.gd").can_recruit(npc, GameState.oath):
                    last_message = "Este residente nao pode ser recrutado por um Exilado."
                elif GameState.recruit_visitor(npc):
                    success = true
                else:
                    GameState.gain_friendship(npc_id, 10, "taverna", true)
                    last_message = "Vinculo com %s: %d/100 (%s). Converse em outros dias para criar confianca." % [npc["name"], GameState.friendship_points(npc_id), GameState.friendship_level(npc_id)]
                if success:
                    last_message = "Recrutado: " + str(npc["name"])
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
    var visitors := _current_tavern_visitors()
    for i in range(visitors.size()):
        var npc: Dictionary = visitors[i]
        var can_join: bool = true if str(npc.get("id", "")) == DUKE.DAUGHTER_ID else preload("res://scripts/town_system.gd").can_recruit(npc, GameState.oath)
        var id := str(npc["id"])
        var affinity := "Especial" if id == DUKE.DAUGHTER_ID else "%d/100 (%s)" % [GameState.friendship_points(id), GameState.friendship_level(id)]
        var stay := ""
        if npc.has("departure_day"):
            stay = " | Restam %d dia(s)" % maxi(0, int(npc["departure_day"]) - GameState.day)
        lines.append("[%d] %s (%s) / %s / %s %s%s" % [i + 1, npc["name"], npc["rarity"], npc["profession"], affinity, "" if can_join else "[NAO RECRUTAVEL]", stay])
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
                var building_name := "Mansao do Duque" if GameState.current_region == "Fortaleza" and i == 4 and side < 0 else ("Taverna" if i == 0 else "Ferraria" if i == 1 else "Quarto" if i == 2 else "Salao")
                best = {"room": building_name, "entrance": entrance}
    return best

func _update_hint() -> void:
    if interact_hint == null:
        return
    var next_hint := ""
    if active_interior == "Mansao do Duque":
        next_hint = "E: interagir com o Duque ou sua herdeira"
    elif not active_interior.is_empty():
        next_hint = "Interior: %s | E: sair" % active_interior
    else:
        var npc := _nearest_npc()
        if not npc.is_empty():
            next_hint = "E: interagir com %s" % npc["name"]
        var nearby := _nearest_building()
        if npc.is_empty():
            next_hint = "E: entrar em %s" % nearby["room"] if not nearby.is_empty() else "Explore a vila; aproxime-se das portas"
    if next_hint != _cached_hint:
        _cached_hint = next_hint
        interact_hint.text = next_hint

func _interact() -> void:
    if map_open:
        return
    if not active_interior.is_empty():
        active_interior = ""
        settlement.visible = true
        interior_node.visible = false
        player.position = _interior_return_position
        town_panel.visible = false
        last_message = "Voce voltou para a vila."
    else:
        var target := _nearest_building()
        if target.is_empty():
            last_message = "Nao ha entrada perto de voce."
        else:
            _interior_return_position = player.position
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
        interior_node.remove_child(obj)
        obj.queue_free()
    _make_box(interior_node, Vector3(0, -0.35, 0), Vector3(14, .6, 12), Color("#b3946b"))
    _make_box(interior_node, Vector3(-6.6, 1.6, 0), Vector3(.6, 3.2, 12), Color("#6e503b"))
    _make_box(interior_node, Vector3(6.6, 1.6, 0), Vector3(.6, 3.2, 12), Color("#6e503b"))
    _make_box(interior_node, Vector3(0, 1.6, -5.7), Vector3(14, 3.2, .6), Color("#6e503b"))
    if room_name == "Mansao do Duque":
        _make_box(interior_node, Vector3(0, .95, -3), Vector3(4.6, 1.9, 1.8), Color("#785c3c"))
        _make_box(interior_node, Vector3(-3, .8, -2), Vector3(1.8, 1.6, 2), Color("#b09563"))
    elif room_name == "Ferraria":
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
    UI.apply_panel(map_dialog)
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
        UI.apply_button(button)
        button.pressed.connect(_travel_to.bind(destination))
        layout.add_child(button)
    var codex := Button.new()
    codex.text = "Consultar NPCs por categoria"
    UI.apply_button(codex)
    codex.pressed.connect(_open_npc_directory)
    layout.add_child(codex)
    var close := Button.new()
    close.text = "Fechar mapa"
    UI.apply_button(close)
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
        _interior_return_position = player.position
        _apply_region_theme()
        last_message = "Viagem concluida: -5 energia e XP de Agilidade."
    map_open = false
    map_dialog.visible = false
    _refresh_hud()

func _apply_region_theme() -> void:
    var region: Dictionary = REGION_SYSTEM.region_data(GameState.current_region)
    world_environment.environment.background_color = region["sky"]
    for mesh in settlement.get_children():
        if mesh is MeshInstance3D and mesh.mesh is BoxMesh:
            if mesh.position == Vector3(0, -0.65, 0):
                var ground_mat := StandardMaterial3D.new()
                ground_mat.albedo_color = region["ground"]
                mesh.material_override = ground_mat
            elif mesh.position == Vector3(0, -0.07, 0):
                var road_mat := StandardMaterial3D.new()
                road_mat.albedo_color = region["road"]
                mesh.material_override = road_mat
    for obj in regional_details.get_children():
        regional_details.remove_child(obj)
        obj.queue_free()
    if region["type"] == "harbor":
        for index in range(4):
            _make_box(regional_details, Vector3(19, -0.13, -20 + index * 12), Vector3(14, .3, 3.0), Color("#716455"))
        _make_box(regional_details, Vector3(25, -.24, 0), Vector3(14, .22, 65), Color("#407c9a"))
        for index in range(4):
            _make_box(regional_details, Vector3(23, .6, -20 + index * 12), Vector3(1.1, 1.3, 1.1), Color("#8b7459"))
    else:
        for index in range(7):
            _make_box(regional_details, Vector3(-24 + index * 8, 1.6, -33), Vector3(6, 3.2, 1.5), Color("#81857c"))
        for index in range(3):
            _make_box(regional_details, Vector3(-24 + index * 24, 3, -33), Vector3(5, 6, 5), Color("#8e9188"))
    _spawn_residents()
    _spawn_resources()

func _active_city_residents() -> Array:
    var residents: Array = []
    var seen: Dictionary = {}
    var base_residents: Array = REGION_SYSTEM.residents(GameState.current_region)
    for resident in base_residents:
        var id := str(resident["id"])
        if GameState.recruited.has(id):
            continue
        if GameState.npc_lives.has(id):
            var life: Dictionary = GameState.npc_lives[id]
            if life.get("status", "") != "village" or life.get("region", "") != GameState.current_region:
                continue
        residents.append(resident.duplicate(true))
        seen[id] = true
    for visitor in preload("res://scripts/town_system.gd").town_residents(GameState.current_region, GameState.npc_lives):
        var id := str(visitor["id"])
        if not seen.has(id) and not GameState.recruited.has(id):
            residents.append(visitor)
            seen[id] = true
    return residents

func _spawn_residents() -> void:
    for visual in npc_visuals.values():
        if is_instance_valid(visual):
            visual.queue_free()
    npc_visuals.clear()
    for data in _active_city_residents():
        var id := str(data["id"])
        var npc := Sprite3D.new()
        npc.name = "NPC_" + id
        npc.texture = _sprite_texture
        npc.pixel_size = 0.026
        npc.billboard = BaseMaterial3D.BILLBOARD_ENABLED
        npc.shaded = false
        npc.position = ROUTINES.position_for(id, GameState.day) + Vector3(0, 1, 0)
        settlement.add_child(npc)
        npc_visuals[id] = npc

func _refresh_resident_positions() -> void:
    _spawn_residents()

func _nearest_npc() -> Dictionary:
    for data in _active_city_residents():
        var id := str(data["id"])
        if npc_visuals.has(id) and is_instance_valid(npc_visuals[id]):
            var npc: Sprite3D = npc_visuals[id]
            if REGION_SYSTEM.can_talk(Vector2(player.position.x, player.position.z).distance_to(Vector2(npc.position.x, npc.position.z))):
                var info: Dictionary = data.duplicate(true)
                info["activity"] = ROUTINES.activity_for(id, GameState.day)
                return info
    return {}

func _talk_to_nearest_npc() -> void:
    if not active_interior.is_empty() or map_open:
        return
    var npc := _nearest_npc()
    if npc.is_empty():
        last_message = "Nao ha moradores proximos para conversar."
    else:
        var id := str(npc["id"])
        var memory_count := 0
        if GameState.npc_memory.has(id):
            memory_count = GameState.npc_memory[id].size()
        GameState.remember(id, "primeiro_encontro" if memory_count == 0 else "conversa")
        GameState.gain_friendship(id, 8, "dialogo", true)
        GameState.save_game()
        _dialogue_npc = npc
        var options := ["Conte-me sobre seu trabalho."]
        if GameState.OPENING_QUESTS.has(id):
            options.append("Precisa de ajuda? / Entregar materiais")
        _gift_option = options.size()
        options.append("Oferecer presente")
        options.append("Ate logo.")
        var quest_status := str(GameState.quest_progress.get(id, ""))
        var line := STORY.npc_line(id, GameState.oath, quest_status, memory_count)
        line += "\nVinculo: %d/100 — %s." % [GameState.friendship_points(id), GameState.friendship_level(id)]
        dialogue_ui.show_dialogue(str(npc["name"]), line, options)
    _refresh_hud()

func _create_dialogue_ui() -> void:
    dialogue_ui = preload("res://scripts/dialogue_panel.gd").new()
    dialogue_ui.name = "DialoguePanel"
    get_node("CanvasLayer").add_child(dialogue_ui)
    dialogue_ui.choice_selected.connect(_on_dialogue_choice)

func _on_dialogue_choice(index: int) -> void:
    if _food_mode:
        _food_mode = false
        if index >= 0 and index < _food_ids.size():
            var food_id := _food_ids[index]
            var eaten := GameState.eat_food(food_id)
            var msg := "Refeicao consumida. Bonus temporarios: %s" % str(GameState.active_food_bonuses) if eaten else "Nao foi possivel consumir este alimento."
            dialogue_ui.show_dialogue("Suprimentos", msg)
        else:
            dialogue_ui.close_dialogue()
        return
    if _craft_mode:
        _craft_mode = false
        if index >= 0 and index < _craft_ids.size():
            var crafted_id := _craft_ids[index]
            var crafted := GameState.craft_item(crafted_id)
            dialogue_ui.show_dialogue("Ferraria", "Fabricado: %s" % crafted_id if crafted else "Receita bloqueada ou moedas/materiais insuficientes.")
            _refresh_hud()
        else:
            dialogue_ui.close_dialogue()
        return
    if _gift_mode:
        _gift_mode = false
        if index >= 0 and index < _gift_ids.size():
            var item_id := _gift_ids[index]
            var npc_id := str(_gift_target.get("id", ""))
            var profession := str(_gift_target.get("profession", ""))
            var accepted := GameState.give_gift(npc_id, profession, item_id)
            var reply := "Presente aceito! Amizade %d/100: %s" % [GameState.friendship_points(npc_id), GameState.friendship_level(npc_id)] if accepted else "Nao aceito esse presente. Minha categoria preferida e %s (ou ja recebi um presente hoje)." % ITEMS.preferred_category(npc_id, profession)
            dialogue_ui.show_dialogue(str(_gift_target.get("name", "Morador")), reply)
            _refresh_hud()
        else:
            dialogue_ui.close_dialogue()
        return
    if _duke_riddle_mode:
        _duke_riddle_mode = false
        var result: Dictionary = GameState.duke_answer(index)
        if bool(result.get("accepted", false)):
            var response := "Correto. " if bool(result.get("correct", false)) else "A resposta nao me convence. "
            response += "Nossa amizade agora vale %d pontos. Volte amanha para a proxima charada." % int(result.get("friendship", 0))
            if GameState.DUKE.can_recruit_duke(GameState.duke_state, GameState.wave_number):
                response += " Voce conquistou minha confianca. Use R nesta mansao para me recrutar."
            dialogue_ui.show_dialogue("Duque", response)
        else:
            dialogue_ui.show_dialogue("Duque", "Ja conversamos hoje. O tempo nao volta para quem deseja mudar uma resposta.")
        return
    if _dialogue_npc.is_empty():
        dialogue_ui.close_dialogue()
        return
    var id := str(_dialogue_npc.get("id", ""))
    var name_value := str(_dialogue_npc.get("name", "Morador"))
    if index == 0:
        var profession := str(_dialogue_npc.get("profession", "viajante"))
        dialogue_ui.show_dialogue(name_value, "Meu oficio e %s. Esta cidade muda a cada dia." % profession)
    elif index == _gift_option:
        _present_to(_dialogue_npc)
    elif index == 1 and GameState.OPENING_QUESTS.has(id):
        var quest: Dictionary = GameState.OPENING_QUESTS[id]
        var status := str(GameState.quest_progress.get(id, ""))
        if status == "complete":
            dialogue_ui.show_dialogue(name_value, "Voce ja me ajudou. Sua bondade nao sera esquecida.")
        elif status == "active" and GameState.complete_quest(id):
            dialogue_ui.show_dialogue(name_value, "Excelente! Aqui estao suas %d moedas. Obrigado!" % int(quest["reward"]))
        elif status == "active":
            dialogue_ui.show_dialogue(name_value, "Ainda preciso de %d unidades de %s. Explore os arredores e use G para coletar." % [int(quest["amount"]), str(quest["item"])])
        else:
            GameState.start_quest(id)
            dialogue_ui.show_dialogue(name_value, "Missao iniciada: %s. Traga %d unidades de %s para receber %d moedas." % [str(quest["title"]), int(quest["amount"]), str(quest["item"]), int(quest["reward"])])
        _refresh_hud()
    else:
        dialogue_ui.close_dialogue()

func _spawn_resources() -> void:
    for obj in resource_visuals.values():
        if is_instance_valid(obj):
            obj.queue_free()
    resource_visuals.clear()
    var item_id := "ferro" if GameState.current_region == "Fortaleza" else "ervas"
    for index in range(5):
        var node_id := "%s_%s_%d" % [GameState.current_region, item_id, index]
        var resource := MeshInstance3D.new()
        var mesh := SphereMesh.new()
        mesh.radius = 0.43
        mesh.height = 0.7
        resource.mesh = mesh
        resource.position = Vector3(-3 + float(index % 3) * 3.0, 0.35, 5 + float(index / 3) * 3.0)
        var mat := StandardMaterial3D.new()
        mat.albedo_color = Color("#779e63") if item_id == "ervas" else Color("#69747e")
        resource.material_override = mat
        settlement.add_child(resource)
        resource_visuals[node_id] = resource
    for index in range(3):
        var wood_id := "%s_madeira_%d" % [GameState.current_region, index]
        var log_mesh := MeshInstance3D.new()
        var log := CylinderMesh.new()
        log.top_radius = .45
        log.bottom_radius = .55
        log.height = 1.2
        log_mesh.mesh = log
        log_mesh.position = Vector3(1.0 + float(index) * 2.7, .58, 15)
        var bark := StandardMaterial3D.new()
        bark.albedo_color = Color("#795638")
        log_mesh.material_override = bark
        settlement.add_child(log_mesh)
        resource_visuals[wood_id] = log_mesh
    _refresh_resource_visibility()

func _refresh_resource_visibility() -> void:
    for node_id in resource_visuals.keys():
        if is_instance_valid(resource_visuals[node_id]):
            resource_visuals[node_id].visible = int(GameState.collected_nodes.get(node_id, -1)) != GameState.day

func _gather_nearby() -> void:
    if not active_interior.is_empty() or map_open or dialogue_ui.visible:
        return
    for node_id in resource_visuals.keys():
        var obj: MeshInstance3D = resource_visuals[node_id]
        if not is_instance_valid(obj) or not obj.visible:
            continue
        if Vector2(player.position.x, player.position.z).distance_to(Vector2(obj.position.x, obj.position.z)) < 2.0:
            var item_id := "madeira" if str(node_id).contains("_madeira_") else ("ferro" if GameState.current_region == "Fortaleza" else "ervas")
            if GameState.collect_resource(str(node_id), item_id):
                last_message = "Coletou 1 %s. Veja seu inventario com I." % item_id
                _refresh_resource_visibility()
                _refresh_hud()
                return
    last_message = "Nenhum recurso proximo para coletar."
    _refresh_hud()

func _current_tavern_visitors() -> Array[Dictionary]:
    var visitors: Array[Dictionary] = preload("res://scripts/town_system.gd").tavern_visitors(GameState.current_region, GameState.day, GameState.npc_lives)
    if GameState.duke_tavern_visitor() and not bool(GameState.duke_state.get("daughter_recruited", false)):
        visitors.append({"id": DUKE.DAUGHTER_ID, "name": "Herdeira do Duque", "rarity": "S", "home": "Porto Cinzento", "profession": "Espadachim", "departure_day": int(GameState.duke_state.get("daughter_tavern_departure", GameState.day + 4))})
    return visitors

func _talk_in_manor() -> void:
    if dialogue_ui.visible:
        return
    _dialogue_npc.clear()
    var state: Dictionary = GameState.duke_state
    if GameState.DUKE.daughter_at_manor(state):
        dialogue_ui.show_dialogue("Herdeira do Duque", "Meu pai escolheu ficar quando podia fugir. Se conhece essa historia, entendera por que guardo a memoria dele.")
    elif not bool(state.get("duke_alive", true)):
        dialogue_ui.show_dialogue("Mordomo", "O Duque partiu deste mundo antes que a decima onda terminasse. A mansao permanece silenciosa.")
    elif GameState.DUKE.can_visit_for_question(state, GameState.day, GameState.wave_number):
        var question: Dictionary = DUKE.QUESTIONS[int(state.get("question_index", 0))]
        _duke_riddle_mode = true
        dialogue_ui.show_dialogue("Duque", str(question["question"]), question["options"])
    elif int(state.get("question_index", 0)) == DUKE.QUESTIONS.size():
        dialogue_ui.show_dialogue("Duque", "Nao busco respostas perfeitas, mas constancia. Amizade: %d/75. Use R para tentar me recrutar antes da onda 10." % int(state.get("friendship", 0)))
    else:
        dialogue_ui.show_dialogue("Duque", "Cada decisao merece uma noite de reflexao. Volte no proximo dia.")

func _recruit_at_manor() -> void:
    if dialogue_ui.visible:
        return
    if GameState.DUKE.daughter_at_manor(GameState.duke_state):
        if GameState.duke_daughter_recruit():
            dialogue_ui.show_dialogue("Herdeira do Duque", "Aceito lutar ao seu lado. A armadura de meu pai ainda espera seu ultimo juramento.")
        elif GameState.duke_daughter_quest():
            dialogue_ui.show_dialogue("Herdeira do Duque", "A armadura voltou para casa. Agora buscarei forca na Masmorra Antiga do Lago.")
        elif GameState.duke_daughter_evolve():
            dialogue_ui.show_dialogue("Herdeira do Duque", "O legado do meu pai se tornou minha propria forca. Alcancei o rank SS.")
        else:
            dialogue_ui.show_dialogue("Herdeira do Duque", "Para evoluir preciso da missao da armadura e dos materiais do lago.")
    elif GameState.duke_recruit():
        dialogue_ui.show_dialogue("Duque", "Seis dias de perguntas revelaram seu carater. A partir de agora, minha espada o acompanha.")
    else:
        dialogue_ui.show_dialogue("Mordomo", "O Duque so acompanha amigos leais, com no minimo 75 pontos, antes da onda 10.")
    _refresh_hud()

func _present_to(npc: Dictionary) -> void:
    if npc.is_empty():
        last_message = "Nao ha personagem disponivel para receber presente."
        _refresh_hud()
        return
    _gift_target = npc.duplicate(true)
    _gift_ids.clear()
    var choices: Array[String] = []
    for id in GameState.inventory.keys():
        var item_id := str(id)
        if int(GameState.inventory[id]) > 0 and ITEMS.is_tradeable(item_id):
            var data: Dictionary = ITEMS.get_item(item_id)
            _gift_ids.append(item_id)
            choices.append("%s (%s, %s)" % [str(data["name"]), str(data["category"]), str(data["rarity"])])
    if choices.is_empty():
        dialogue_ui.show_dialogue(str(npc.get("name", "Morador")), "Voce nao possui presentes no inventario.")
        return
    _gift_mode = true
    choices.append("Cancelar")
    var preference := ITEMS.preferred_category(str(npc.get("id", "")), str(npc.get("profession", "")))
    dialogue_ui.show_dialogue(str(npc.get("name", "Morador")), "Aceito somente presentes de %s. Outros itens serao recusados." % preference, choices)

func _refresh_market() -> void:
    _market_ids.clear()
    var mode := "VENDA" if _market_selling else "COMPRA"
    var title := "CARAVANA VIAJANTE" if _market_travelling else "MERCADO DA CIDADE"
    var available_ids: Array[String] = []
    for id in ITEMS.ITEMS.keys():
        var item_id := str(id)
        var data: Dictionary = ITEMS.get_item(item_id)
        if _market_selling and int(GameState.inventory.get(item_id, 0)) < 1:
            continue
        if not _market_travelling:
            if active_interior == "Ferraria" and not ["Minerios", "Armas"].has(str(data["category"])):
                continue
            if active_interior == "Taverna" and str(data["category"]) != "Comestiveis":
                continue
        available_ids.append(item_id)
    var pages := maxi(1, ceili(float(available_ids.size()) / 5.0))
    _market_page %= pages
    var lines: Array[String] = ["%s | %s | Moedas: %d | Pagina %d/%d" % [title, mode, GameState.money, _market_page + 1, pages]]
    var start_index := _market_page * 5
    for i in range(start_index, mini(available_ids.size(), start_index + 5)):
        var item_id := available_ids[i]
        var data: Dictionary = ITEMS.get_item(item_id)
        _market_ids.append(item_id)
        var price := ITEMS.sell_price(item_id) if _market_selling else ITEMS.price(item_id, GameState.current_region, GameState.oath, _market_travelling)
        lines.append("[%d] %s | %s | %s | %d moedas" % [_market_ids.size(), data["name"], data["category"], data["rarity"], price])
    lines.append("1-5: negociar | Z: compra/venda | L: proxima pagina | V: fechar")
    town_panel.text = "\n".join(lines)
    town_panel.visible = true

func _market_transaction(index: int) -> void:
    if index < 0 or index >= _market_ids.size():
        return
    var item_id := _market_ids[index]
    var success := GameState.market_sell(item_id) if _market_selling else GameState.market_buy(item_id, _market_travelling)
    last_message = ("Negociado: " if success else "Nao foi possivel negociar: ") + item_id
    _refresh_market()
    _refresh_hud()

func _open_food_menu() -> void:
    _food_ids.clear()
    var choices: Array[String] = []
    for id in GameState.inventory.keys():
        var item_id := str(id)
        if ITEMS.can_eat(item_id) and int(GameState.inventory[id]) > 0:
            var data: Dictionary = ITEMS.get_item(item_id)
            _food_ids.append(item_id)
            choices.append("%s (%s)" % [data["name"], data["rarity"]])
    if choices.is_empty():
        dialogue_ui.show_dialogue("Suprimentos", "Nao possui alimentos para consumir.")
        return
    _food_mode = true
    choices.append("Cancelar")
    dialogue_ui.show_dialogue("Suprimentos", "Escolha uma refeicao para receber bonus temporarios.", choices)

func _open_craft_menu() -> void:
    _craft_ids.clear()
    var choices: Array[String] = []
    for id in RECIPES.RECIPES.keys():
        var item_id := str(id)
        var formula: Dictionary = RECIPES.RECIPES[item_id]
        if str(formula["building"]) != "Ferraria":
            continue
        _craft_ids.append(item_id)
        choices.append("%s | %d moedas | nivel %d" % [ITEMS.get_item(item_id).get("name", item_id), int(formula["money"]), int(formula["level"])])
    if choices.is_empty():
        dialogue_ui.show_dialogue("Ferraria", "Nao existem receitas aqui.")
        return
    _craft_mode = true
    choices.append("Cancelar")
    dialogue_ui.show_dialogue("Ferraria", "Escolha uma receita. Ela exige moedas, materiais e nivel suficiente.", choices)

func _create_npc_menu() -> void:
    npc_menu = preload("res://scripts/npc_interaction_menu.gd").new()
    npc_menu.name = "NpcInteractionMenu"
    get_node("CanvasLayer").add_child(npc_menu)
    npc_menu.action_selected.connect(_npc_action)
    npc_menu.gift_selected.connect(_npc_gift)
    npc_menu.visitor_selected.connect(_show_npc_menu)

func _contextual_interact() -> void:
    if map_open:
        return
    if active_interior == "Mansao do Duque":
        var special_id := "herdeira_duque" if GameState.DUKE.daughter_at_manor(GameState.duke_state) else "duque"
        _show_npc_menu({"id": special_id, "name": "Herdeira do Duque" if special_id == "herdeira_duque" else "Duque", "profession": "Nobre", "rarity": "S" if special_id == "herdeira_duque" else "A"})
        return
    if active_interior == "Taverna":
        npc_menu.show_visitors(_current_tavern_visitors())
        return
    if not active_interior.is_empty():
        _interact()
        return
    var npc := _nearest_npc()
    if not npc.is_empty():
        _show_npc_menu(npc)
        return
    if preload("res://scripts/town_system.gd").travelling_merchant_present(GameState.current_region, GameState.day) and player.position.distance_to(Vector3(0, 0, 13)) <= 3.0:
        _show_npc_menu({"id": "mercador_viajante", "name": "Mercador Viajante", "profession": "Mercador", "rarity": "Comum"})
        return
    _interact()

func _npc_is_recruitable(npc: Dictionary) -> bool:
    var id := str(npc.get("id", ""))
    if GameState.recruited.has(id) or not NPCS.base_recruitable(id):
        return false
    if id == "duque":
        return GameState.current_region == "Fortaleza" and GameState.oath != "exile" and GameState.DUKE.can_recruit_duke(GameState.duke_state, GameState.wave_number)
    if id == GameState.DUKE.DAUGHTER_ID:
        return bool(GameState.duke_state.get("daughter_unlocked", false)) and not bool(GameState.duke_state.get("daughter_recruited", false)) and (GameState.oath != "exile" or not GameState.DUKE.daughter_at_manor(GameState.duke_state))
    if not preload("res://scripts/town_system.gd").can_recruit(npc, GameState.oath):
        return false
    var life: Dictionary = GameState.npc_lives.get(id, {})
    return life.get("status", "") == "tavern" and life.get("region", "") == GameState.current_region and GameState.friendship_points(id) >= 80

func _show_npc_menu(npc: Dictionary) -> void:
    if npc.is_empty():
        return
    _tavern_selected = npc.duplicate(true)
    var id := str(npc.get("id", ""))
    var profession := str(npc.get("profession", ""))
    var merchant := NPCS.is_vendor(id)
    npc_menu.show_npc(npc, GameState.friendship_points(id), GameState.friendship_level(id), ITEMS.preferred_category(id, profession), _npc_is_recruitable(npc), merchant, not active_interior.is_empty())

func _npc_action(action: String, npc: Dictionary) -> void:
    match action:
        "directory":
            npc_menu.show_directory()
        "talk":
            npc_menu.hide_menu()
            if active_interior == "Mansao do Duque":
                _talk_in_manor()
            elif active_interior == "Taverna":
                _dialogue_npc = npc.duplicate(true)
                var id := str(npc.get("id", ""))
                GameState.remember(id, "conversa_taverna")
                GameState.gain_friendship(id, 8, "dialogo", true)
                GameState.save_game()
                dialogue_ui.show_dialogue(str(npc.get("name", "Aventureiro")), STORY.npc_line(id, GameState.oath, str(GameState.quest_progress.get(id, "")), 1))
            else:
                _talk_to_nearest_npc()
        "shop":
            npc_menu.hide_menu()
            _market_mode = true
            _market_page = 0
            _market_selling = false
            _market_travelling = str(npc.get("id", "")) == "mercador_viajante"
            _refresh_market()
        "gifts":
            npc_menu.show_gifts(npc, GameState.inventory)
        "back":
            _show_npc_menu(npc)
        "recruit":
            var id := str(npc.get("id", ""))
            var success := false
            if _npc_is_recruitable(npc):
                if id == "duque":
                    success = GameState.duke_recruit()
                elif id == GameState.DUKE.DAUGHTER_ID:
                    success = GameState.duke_daughter_recruit()
                else:
                    success = GameState.recruit_visitor(npc)
            npc_menu.hide_menu()
            last_message = "Recrutado: %s" % str(npc.get("name", "NPC")) if success else "Recrutamento indisponivel."
            _refresh_hud()
        "step_aside":
            _npc_step_aside(npc)
            npc_menu.hide_menu()
            _refresh_hud()
        "exit":
            npc_menu.hide_menu()
            if not active_interior.is_empty():
                _interact()

func _npc_gift(npc: Dictionary, item_id: String) -> void:
    var id := str(npc.get("id", ""))
    var result := GameState.give_gift(id, str(npc.get("profession", "")), item_id)
    npc_menu.hide_menu()
    last_message = ("Presente aceito por %s: %d/100 (%s)." % [npc.get("name", "NPC"), GameState.friendship_points(id), GameState.friendship_level(id)]) if result else "Presente recusado ou limite diario. Nenhum item foi consumido."
    _refresh_hud()

func _npc_step_aside(npc: Dictionary) -> void:
    var id := str(npc.get("id", ""))
    var visual: Node3D = npc_visuals.get(id)
    if visual == null or not is_instance_valid(visual) or not active_interior.is_empty():
        last_message = "O personagem abre passagem, sem afetar a amizade."
        return
    var start_position := visual.position
    var candidates := [
        start_position + Vector3(1.7, 0, 0),
        start_position + Vector3(-1.7, 0, 0),
        start_position + Vector3(0, 0, 1.7),
        start_position + Vector3(0, 0, -1.7)
    ]
    for target in candidates:
        if not _is_blocked(target) and target.distance_to(player.position) > start_position.distance_to(player.position):
            visual.position = target
            last_message = "%s se afastou para liberar a passagem, sem penalidade." % str(npc.get("name", "NPC"))
            return
    last_message = "Nao ha espaco seguro para o personagem se afastar agora."

func _open_npc_directory() -> void:
    map_open = false
    map_dialog.visible = false
    npc_menu.show_directory()
