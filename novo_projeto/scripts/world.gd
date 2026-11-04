extends Node3D
const UI = preload("res://scripts/ui_theme.gd")
const STORY = preload("res://scripts/story_content.gd")
const ITEMS = preload("res://scripts/item_catalog.gd")
const RECIPES = preload("res://scripts/economy_system.gd")
const NPCS = preload("res://scripts/npc_registry.gd")
const ROUTINES = preload("res://scripts/npc_daily_routines.gd")
const ACTOR_ANIM = preload("res://scripts/actor_animation.gd")
const GEAR = preload("res://scripts/equipment_catalog.gd")
const TEXTURES = preload("res://scripts/world_texture_factory.gd")
const COMBAT = preload("res://scripts/combat_core.gd")

var player: CharacterBody3D
var hud: Label
var news: RichTextLabel
var town_panel: RichTextLabel
var last_message := ""
var active_interior := ""
var interior_node: Node3D
var map_dialog: PanelContainer
var travel_map_canvas: Control
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
var _story_option := -1
var _story_mode := false
var _story_npc_id := ""
var _tavern_selected: Dictionary = {}
var _market_mode := false
var _market_selling := false
var _market_travelling := false
var _market_ids: Array[String] = []
var _market_vendor_id := ""
var equipment_market: Control
var forge_panel: Control
var battle_panel: Control
var enemy_visuals: Dictionary = {}
var npc_menu: Control
var character_sheet: Control
var _door_cooldown := 0.0
var _door_armed := true
var _scene_fade: ColorRect
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
var _player_sprite: Sprite3D
var _player_walk_frames: Dictionary = {}
var _player_animation_time := 0.0
var _player_animation_step := 0
var _player_facing := "down"
var _interior_return_position := Vector3(0, 0, 13)
var _active_region_label: Label


func _ready() -> void:
    _generate_world()
    _apply_region_theme()
    _generate_ui()
    _generate_map_dialog()
    _create_dialogue_ui()
    _create_npc_menu()
    _create_equipment_market()
    _create_forge_panel()
    _create_character_sheet()
    _create_scene_fade()
    _create_battle_panel()
    _spawn_field_enemies()
    if not GameState.active_battle.is_empty():
        _show_battle()
    _refresh_hud()

func _make_box(parent: Node3D, location: Vector3, dimensions: Vector3, tint: Color, solid: bool = false) -> void:
    var mesh := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = dimensions
    mesh.mesh = box
    mesh.position = location
    var key := tint.to_html()
    if not _shared_materials.has(key):
        var material_kind := "stone" if dimensions.y >= 2.6 and tint.r > .35 and tint.g > .35 and tint.b > .35 else "wood" if dimensions.y >= 1.2 else "road" if dimensions.x >= 4.0 and dimensions.y < 0.2 else "grass"
        var mat := TEXTURES.material_for(material_kind, Color.WHITE.lerp(tint, 0.22))
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

func _decorate_house(side: float, z: float, index: int) -> void:
    # Original decorative roofs/facades built only once at scene initialization.
    var facing := 1.0 if side < 0.0 else -1.0
    var door_x := side + facing * 3.06
    var accent := Color("#a98048") if index == 0 else Color("#787f68") if index == 1 else Color("#985b51") if index == 4 else Color("#8a745b")
    _make_box(settlement, Vector3(door_x, 1.1, z), Vector3(0.13, 2.2, 1.35), Color("#493727"))
    _make_box(settlement, Vector3(door_x + facing * 0.08, 1.1, z + 0.41), Vector3(0.14, 0.13, 0.13), Color("#c9a46b"))
    for offset_z in [-1.7, 1.7]:
        _make_box(settlement, Vector3(door_x, 1.65, z + offset_z), Vector3(.17, 1.12, .85), Color("#42342b"))
        _make_box(settlement, Vector3(door_x + facing * .09, 1.64, z + offset_z), Vector3(.09, .87, .60), Color("#b9b5a0"))
        _make_box(settlement, Vector3(door_x + facing * .17, 1.65, z + offset_z), Vector3(.10, .86, .09), Color("#6b503b"))
    for roof_half in [-1.0, 1.0]:
        var roof := MeshInstance3D.new()
        var roof_box := BoxMesh.new()
        roof_box.size = Vector3(3.95, .20, 6.3)
        roof.mesh = roof_box
        roof.position = Vector3(side + roof_half * 1.73, 4.0, z)
        roof.rotation.z = -roof_half * 0.30
        var tint := Color("#574139") if index in [0, 2] else Color("#4e514b")
        var material_key := tint.to_html()
        if not _shared_materials.has(material_key):
            var roof_mat := TEXTURES.material_for("wood", Color.WHITE.lerp(tint, 0.20))
            _shared_materials[material_key] = roof_mat
        roof.material_override = _shared_materials[material_key]
        settlement.add_child(roof)
    _make_box(settlement, Vector3(side, 4.65, z), Vector3(.27, .27, 6.4), accent)
    _make_box(settlement, Vector3(door_x + facing*.75, .07, z), Vector3(1.8,.11,1.65), Color("#8a806d"))
    _make_box(settlement, Vector3(door_x, 2.82, z), Vector3(.13,.24,1.7), accent)
    _make_box(settlement, Vector3(door_x + facing*.13, 2.63, z), Vector3(.08,.38,1.25), accent)

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
    settlement = Node3D.new()
    settlement.name = "RegionSettlement"
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
        _decorate_house(-9.0, z, i)
        _decorate_house(9.0, z, i)
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
    player.position = GameState.get_region_position()
    add_child(player)
    var character := Sprite3D.new()
    _player_sprite = character
    _player_walk_frames = ACTOR_ANIM.make_frames(GameState.character_appearance)
    character.texture = _player_walk_frames["down:0"]
    character.pixel_size = 0.053
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

func _make_sprite_texture(style_index: int = 0) -> Texture2D:
    var picture := Image.create(24, 40, false, Image.FORMAT_RGBA8)
    picture.fill(Color.TRANSPARENT)
    var coats := [Color("#395679"), Color("#735044"), Color("#647948"), Color("#475c6e"), Color("#78647e")]
    var hair_colors := [Color("#352c2a"), Color("#45301e"), Color("#5d3a28"), Color("#242e38"), Color("#533d33")]
    var look := clampi(style_index, 0, coats.size() - 1)
    for x in range(7, 17):
        for y in range(12, 35):
            picture.set_pixel(x, y, coats[look])
    for x in range(8, 16):
        for y in range(3, 13):
            picture.set_pixel(x, y, Color("#e9b58e"))
    for x in range(7, 17):
        for y in range(1, 6):
            picture.set_pixel(x, y, hair_colors[look])
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
    var hud_frame := PanelContainer.new()
    hud_frame.position = Vector2(8, 8)
    hud_frame.custom_minimum_size = Vector2(565, 0)
    UI.apply_panel(hud_frame)
    frame.add_child(hud_frame)
    var column := VBoxContainer.new()
    column.custom_minimum_size = Vector2(525, 0)
    column.add_theme_constant_override("separation", 7)
    hud_frame.add_child(column)
    hud = Label.new()
    hud.add_theme_font_size_override("font_size", 18)
    hud.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    UI.apply_text(hud)
    column.add_child(hud)
    var help := Label.new()
    help.add_theme_font_size_override("font_size", 14)
    help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    UI.apply_text(help)
    help.text = "WASD: explorar | N: avancar dia | T: viajar | C: cronicas | F5: salvar"
    column.add_child(help)
    var sheet_button := Button.new()
    sheet_button.text = "Personagem / Inventario"
    UI.apply_button(sheet_button)
    sheet_button.pressed.connect(_open_character_sheet.bind("Personagem"))
    column.add_child(sheet_button)
    help.text = "WASD mover | E interagir/coletar | M mapa | I inventario | F5 salvar"
    var quick_row := HBoxContainer.new()
    quick_row.add_theme_constant_override("separation", 7)
    column.add_child(quick_row)
    for option in [
        {"label": "Mapa", "action": "map"},
        {"label": "Diario", "action": "journal"},
        {"label": "Proximo dia", "action": "day"},
        {"label": "Salvar", "action": "save"}
    ]:
        var control := Button.new()
        control.text = str(option["label"])
        UI.apply_button(control)
        control.pressed.connect(_on_quick_action.bind(str(option["action"])))
        quick_row.add_child(control)
    interact_hint = Label.new()
    UI.apply_text(interact_hint)
    interact_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    column.add_child(interact_hint)
    news = RichTextLabel.new()
    news.position = Vector2(15, 270)
    news.size = Vector2(530, 260)
    news.add_theme_stylebox_override("normal", UI.panel_style())
    news.visible = false
    news.mouse_filter = Control.MOUSE_FILTER_IGNORE
    frame.add_child(news)
    town_panel = RichTextLabel.new()
    town_panel.position = Vector2(665, 90)
    town_panel.size = Vector2(500, 350)
    town_panel.add_theme_stylebox_override("normal", UI.panel_style())
    town_panel.visible = false
    town_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    frame.add_child(town_panel)
    town_panel.add_theme_color_override("default_color", UI.LIGHT_TEXT)

func _process(delta: float) -> void:
    if _controls_blocked():
        return
    _hint_accumulator += delta
    if _hint_accumulator >= HINT_REFRESH_SECONDS:
        _hint_accumulator = 0.0
        _update_hint()

func _controls_blocked() -> bool:
    return map_open or (dialogue_ui != null and dialogue_ui.visible) or (npc_menu != null and npc_menu.is_open()) or (character_sheet != null and character_sheet.visible) or (equipment_market != null and equipment_market.visible) or (forge_panel != null and forge_panel.visible) or (battle_panel != null and battle_panel.visible)

func _physics_process(delta: float) -> void:
    if player == null:
        return
    var direction := Vector3.ZERO
    if not _controls_blocked():
        if Input.is_key_pressed(KEY_W): direction.z -= 1.0
        if Input.is_key_pressed(KEY_S): direction.z += 1.0
        if Input.is_key_pressed(KEY_A): direction.x -= 1.0
        if Input.is_key_pressed(KEY_D): direction.x += 1.0
    direction = direction.normalized()
    if _door_cooldown > 0.0:
        _door_cooldown = maxf(0.0, _door_cooldown - delta)
    if active_interior.is_empty() and not _controls_blocked():
        var doorway := _nearest_building()
        if doorway.is_empty():
            _door_armed = true
        elif _door_armed and _door_cooldown <= 0.0 and player.position.distance_to(doorway["entrance"]) < 2.15:
            _door_armed = false
            _interact()
            direction = Vector3.ZERO
    _animate_player(delta, direction)
    var target := player.position + direction * WALK_SPEED * delta
    if active_interior.is_empty() and direction != Vector3.ZERO and (absf(target.x) >= 26.0 or absf(target.z) >= 29.0):
        map_open = true
        map_dialog.visible = true
        travel_map_canvas.configure(GameState.current_region)
        player.velocity = Vector3.ZERO
        return
    target.x = clampf(target.x, -26.0, 26.0)
    target.z = clampf(target.z, -29.0, 29.0)
    if active_interior.is_empty():
        player.velocity = direction * WALK_SPEED
        if direction != Vector3.ZERO and not _is_blocked(target):
            player.move_and_slide()
        else:
            player.velocity = Vector3.ZERO
        player.position.x = clampf(player.position.x, -26.0, 26.0)
        player.position.z = clampf(player.position.z, -29.0, 29.0)
        if direction != Vector3.ZERO:
            GameState.set_region_position(player.position)
    elif direction != Vector3.ZERO:
        player.velocity = direction * WALK_SPEED
        player.move_and_slide()
        player.position.x = clampf(player.position.x, -5.2, 5.2)
        player.position.z = clampf(player.position.z, -4.5, 4.5)
    else:
        player.velocity = Vector3.ZERO
    camera.position = player.position + Vector3(16, 19, 23)

func _animate_player(delta: float, direction: Vector3) -> void:
    if _player_sprite == null or _player_walk_frames.is_empty():
        return
    _player_facing = ACTOR_ANIM.direction_from_vector(direction, _player_facing)
    if direction == Vector3.ZERO:
        _player_animation_step = 0
        _player_animation_time = 0.0
    else:
        _player_animation_time += delta
        if _player_animation_time >= 0.14:
            _player_animation_time = 0.0
            _player_animation_step = (_player_animation_step + 1) % 3
    var key := "%s:%d" % [_player_facing, _player_animation_step]
    var image: Texture2D = _player_walk_frames[key]
    if _player_sprite.texture != image:
        _player_sprite.texture = image

func _create_scene_fade() -> void:
    _scene_fade = ColorRect.new()
    _scene_fade.color = Color(0.08, 0.06, 0.05, 0.0)
    _scene_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _scene_fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    get_node("CanvasLayer").add_child(_scene_fade)

func _play_scene_transition() -> void:
    if _scene_fade == null:
        return
    # Cheap visual dissolve; actual scene switch is immediate for reliable saves.
    if _scene_fade.has_meta("active_tween"):
        var previous: Tween = _scene_fade.get_meta("active_tween")
        if previous != null and previous.is_running():
            previous.kill()
    _scene_fade.color.a = 0.62
    var fade := create_tween()
    fade.tween_property(_scene_fade, "color:a", 0.0, 0.38).set_trans(Tween.TRANS_CUBIC)
    _scene_fade.set_meta("active_tween", fade)

func _close_top_window() -> void:
    if dialogue_ui != null and dialogue_ui.visible:
        dialogue_ui.close_dialogue()
    elif npc_menu != null and npc_menu.is_open():
        npc_menu.hide_menu()
    elif equipment_market != null and equipment_market.visible:
        equipment_market.hide_store()
        _market_mode = false
    elif forge_panel != null and forge_panel.visible:
        forge_panel.hide_forge()
    elif battle_panel != null and battle_panel.visible:
        _close_battle_result()
    elif character_sheet != null and character_sheet.visible:
        character_sheet.hide_sheet()
    elif map_open:
        map_open = false
        map_dialog.visible = false
    elif town_panel != null and town_panel.visible:
        town_panel.visible = false
        _market_mode = false
    elif news != null and news.visible:
        news.visible = false
    elif not active_interior.is_empty():
        _interact()

func _unhandled_key_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo:
        return
    if event.keycode == KEY_ESCAPE:
        if battle_panel != null and battle_panel.visible and GameState.active_battle.get("state","") == "active":
            return
        _close_top_window()
        get_viewport().set_input_as_handled()
        return
    if (dialogue_ui != null and dialogue_ui.visible) or (npc_menu != null and npc_menu.is_open()) or (character_sheet != null and character_sheet.visible) or (equipment_market != null and equipment_market.visible) or (forge_panel != null and forge_panel.visible) or (battle_panel != null and battle_panel.visible):
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
            _open_character_sheet("Inventario")
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
    hud.text += "\nNivel %d | PV %d/%d | PM %d/%d | XP %d/%d" % [GameState.hero_level,GameState.hero_hp,COMBAT.hero_max_hp(GameState.character_stats,GameState.hero_level,GameState.equipment_stats()),GameState.hero_mp,COMBAT.hero_max_mp(GameState.character_stats,GameState.hero_level,GameState.equipment_stats()),GameState.hero_xp,COMBAT.xp_for_next_level(GameState.hero_level)]
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
        next_hint = "Interior: %s | E: abrir servicos / sair" % active_interior
    else:
        var npc := _nearest_npc()
        if not npc.is_empty():
            next_hint = "E: interagir com %s" % npc["name"]
        var nearby := _nearest_building()
        if npc.is_empty():
            if not nearby.is_empty():
                next_hint = "Aproxime-se da porta para entrar em %s" % nearby["room"]
            elif not _nearest_resource().is_empty():
                next_hint = "E: coletar recurso"
            elif not _nearest_field_enemy().is_empty():
                next_hint = "E: enfrentar criatura"
            else:
                next_hint = "Explore a vila, aproxime-se dos personagens e recursos"
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
        _set_interior_collision(false)
        player.position = _interior_return_position + Vector3(-1.1 if _interior_return_position.x < 0.0 else 1.1, 0, 0)
        _door_cooldown = 1.3
        _door_armed = false
        _play_scene_transition()
        town_panel.visible = false
        last_message = "Voce voltou para a vila."
    else:
        var target := _nearest_building()
        if target.is_empty():
            last_message = "Nao ha entrada perto de voce."
        else:
            _interior_return_position = player.position
            GameState.set_region_position(player.position)
            active_interior = str(target["room"])
            settlement.visible = false
            interior_node.visible = true
            _build_interior(active_interior)
            _set_interior_collision(true)
            player.position = Vector3(0, 0, 3)
            _door_cooldown = 0.8
            _play_scene_transition()
            last_message = "Voce entrou em %s." % active_interior
    camera.position = player.position + Vector3(16, 19, 23)
    _refresh_hud()

func _set_interior_collision(enabled: bool) -> void:
    if interior_node == null:
        return
    # Invisibilidade nao desativa fisica no Godot: evitar colisao fantasma
    # com paredes internas enquanto o jogador explora a vila.
    for node in interior_node.get_children():
        if node is StaticBody3D:
            node.collision_layer = 1 if enabled else 0
            node.collision_mask = 1 if enabled else 0

func _build_interior(room_name: String) -> void:
    # Duas salas distintas e uma passagem aberta; geometria reconstruida apenas
    # quando um novo interior e visitado, sem objetos criados a cada frame.
    for obj in interior_node.get_children():
        interior_node.remove_child(obj)
        obj.queue_free()
    var floor_color := Color("#b3946b") if room_name != "Mansao do Duque" else Color("#c0a982")
    _make_box(interior_node, Vector3(0, -0.35, 0), Vector3(14, 0.6, 12), floor_color)
    var dark_wood := Color("#694a34")
    _make_box(interior_node, Vector3(-6.6, 1.6, 0), Vector3(0.5, 3.2, 12), dark_wood, true)
    _make_box(interior_node, Vector3(6.6, 1.6, 0), Vector3(0.5, 3.2, 12), dark_wood, true)
    _make_box(interior_node, Vector3(0, 1.6, -5.7), Vector3(14, 3.2, 0.5), dark_wood, true)
    # Frente com entrada central, consistente em cada tipo de predio.
    _make_box(interior_node, Vector3(-3.7, 1.6, 5.7), Vector3(6.3, 3.2, 0.5), dark_wood, true)
    _make_box(interior_node, Vector3(3.7, 1.6, 5.7), Vector3(6.3, 3.2, 0.5), dark_wood, true)
    # Parede divisoria: abertura central proxima ao ponto inicial (z=3).
    _make_box(interior_node, Vector3(0, 1.6, -2.25), Vector3(0.45, 3.2, 6.5), dark_wood, true)
    _make_box(interior_node, Vector3(0, 1.6, 4.85), Vector3(0.45, 3.2, 1.7), dark_wood, true)
    # Sala principal no lado esquerdo; dormitorio no lado direito.
    match room_name:
        "Ferraria":
            _make_box(interior_node, Vector3(-3.5, 0.9, -2.5), Vector3(2.6, 1.8, 2.3), Color("#6d6562"), true)
            _make_box(interior_node, Vector3(-4.3, 0.25, -2.6), Vector3(0.9, 0.5, 0.9), Color("#a84f26"))
            _make_box(interior_node, Vector3(-3.1, 1.0, 2.0), Vector3(3.3, 1.1, 1.2), Color("#81563a"), true)
            _make_box(interior_node, Vector3(3.7, 0.35, -2.8), Vector3(2.1, 0.7, 3.0), Color("#695346"), true)
            _make_box(interior_node, Vector3(3.7, 0.15, -2.8), Vector3(2.0, 0.2, 2.7), Color("#a59379"))
        "Taverna":
            for n in range(2):
                _make_box(interior_node, Vector3(-4.3 + n * 2.8, 0.8, -2.2), Vector3(1.9, 0.45, 1.8), Color("#70513a"), true)
            _make_box(interior_node, Vector3(3.5, 0.35, -2.3), Vector3(2.1, 0.7, 3.1), Color("#594534"), true)
            _make_box(interior_node, Vector3(3.4, 1.1, 1.2), Vector3(2.1, 2.1, 0.7), Color("#745f4c"), true)
        "Mansao do Duque":
            _make_box(interior_node, Vector3(-3.3, 0.8, -2.0), Vector3(3.3, 0.7, 2.0), Color("#765333"), true)
            _make_box(interior_node, Vector3(-3.2, 1.9, -5.2), Vector3(1.0, 1.8, 0.4), Color("#d4b877"))
            _make_box(interior_node, Vector3(3.4, 0.4, -2.8), Vector3(2.2, 0.8, 3.1), Color("#6b4a3d"), true)
            _make_box(interior_node, Vector3(3.7, 1.0, 1.4), Vector3(1.5, 1.9, 0.7), Color("#755c46"), true)
        "Quarto":
            _make_box(interior_node, Vector3(3.3, 0.4, -2.1), Vector3(2.0, 0.8, 2.7), Color("#745342"), true)
            _make_box(interior_node, Vector3(-3.3, 0.8, -2.0), Vector3(2.5, 0.9, 1.4), Color("#816345"), true)
        _:
            _make_box(interior_node, Vector3(-3.3, 0.8, -2.0), Vector3(3.2, 0.7, 2), Color("#76563b"), true)
            _make_box(interior_node, Vector3(3.3, 0.4, -2.1), Vector3(2.1, 0.8, 2.7), Color("#7e5944"), true)


func _make_terrain_texture(parent: Node3D) -> void:
    var img := Image.create(64, 64, false, Image.FORMAT_RGB8)
    for y in range(64):
        for x in range(64):
            var n := (x * 71 + y * 43 + x * y * 3) % 19
            img.set_pixel(x, y, Color.from_hsv(.27, .29, .39 + float(n) * .003))
    var mat := StandardMaterial3D.new()
    mat.albedo_texture = ImageTexture.create_from_image(img)
    mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
    mat.uv1_scale = Vector3(20, 20, 1)
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
    map_dialog.custom_minimum_size = Vector2(600, 455)
    var layout := VBoxContainer.new()
    map_dialog.add_child(layout)
    var title := Label.new()
    title.text = "MAPA DO VALE | Viagem: 5 energia + XP de Agilidade"
    UI.apply_title(title)
    layout.add_child(title)
    travel_map_canvas = preload("res://scripts/travel_map.gd").new()
    layout.add_child(travel_map_canvas)
    travel_map_canvas.destination_selected.connect(_travel_to)
    for destination in ["Fortaleza", "Porto Cinzento"]:
        var button := Button.new()
        button.text = "Viajar para " + destination
        UI.apply_button(button)
        button.pressed.connect(_travel_to.bind(destination))
        layout.add_child(button)
    var scout_button := Button.new()
    scout_button.text = "Enviar expedicao de reconhecimento (10 moedas, 5 energia)"
    UI.apply_button(scout_button)
    scout_button.pressed.connect(_launch_scouting)
    layout.add_child(scout_button)
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

func _launch_scouting() -> void:
    var destination := "Estrada da Fortaleza" if GameState.current_region == "Fortaleza" else "Caminho de Porto Cinzento"
    var success := GameState.launch_reconnaissance(destination)
    last_message = "Expedicao enviada: volta em 2 dias." if success else "Expedicao indisponivel: dinheiro ou energia insuficientes, ou ja existe uma ativa."
    map_open = false
    map_dialog.visible = false
    _refresh_hud()

func _toggle_map() -> void:
    map_open = not map_open
    if map_open:
        travel_map_canvas.configure(GameState.current_region)
    map_dialog.visible = map_open

func _travel_to(destination: String) -> void:
    if not GameState.travel(destination, 210):
        last_message = "Viagem bloqueada: regiao atual ou energia insuficiente."
    else:
        active_interior = ""
        settlement.visible = true
        interior_node.visible = false
        _set_interior_collision(false)
        player.position = GameState.get_region_position()
        _interior_return_position = player.position
        _apply_region_theme()
        _spawn_field_enemies()
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
    # Locais de trabalho, geometria compartilhada e gerada so na troca de regiao.
    if region["type"] == "frontier":
        _make_box(regional_details, Vector3(17.5, .45, 8), Vector3(3.5, .9, 2), Color("#836245"))
        _make_box(regional_details, Vector3(17.5, 2.3, 8), Vector3(4, .35, 2.6), Color("#a97c54"))
        for plot in range(3):
            _make_box(regional_details, Vector3(-20 + plot * 2, .05, 22), Vector3(1.1, .15, 5), Color("#566b38"))
    else:
        _make_box(regional_details, Vector3(16, .35, 14), Vector3(3, .7, 2), Color("#8a7457"))
        _make_box(regional_details, Vector3(16, 1.9, 14), Vector3(3.6, .25, 2.5), Color("#c0a783"))
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

func _create_npc_visual(data: Dictionary) -> Sprite3D:
    var npc := Sprite3D.new()
    var id := str(data["id"])
    npc.name = "NPC_" + id
    npc.texture = _sprite_texture
    npc.pixel_size = 0.048
    npc.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    npc.shaded = false
    npc.position = ROUTINES.position_for(id, GameState.day) + Vector3(0, 1, 0)
    # Corpo move com o sprite. Pedir passagem desloca ambos.
    var body := AnimatableBody3D.new()
    body.name = "PassageCollider"
    body.collision_layer = 1
    body.collision_mask = 1
    body.position.y = -0.35
    var collider := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.4
    capsule.height = 1.3
    collider.shape = capsule
    body.add_child(collider)
    npc.add_child(body)
    settlement.add_child(npc)
    return npc

func _spawn_residents() -> void:
    for visual in npc_visuals.values():
        if is_instance_valid(visual):
            visual.queue_free()
    npc_visuals.clear()
    for data in _active_city_residents():
        var id := str(data["id"])
        npc_visuals[id] = _create_npc_visual(data)

func _refresh_resident_positions() -> void:
    # Mantem instancias e recursos se o NPC continua na cidade;
    # so aloca/remove para quem chegou ou partiu.
    var visible_ids: Dictionary = {}
    for data in _active_city_residents():
        var id := str(data["id"])
        visible_ids[id] = true
        if not npc_visuals.has(id) or not is_instance_valid(npc_visuals[id]):
            npc_visuals[id] = _create_npc_visual(data)
            continue
        var visual: Sprite3D = npc_visuals[id]
        var goal := ROUTINES.position_for(id, GameState.day) + Vector3(0, 1, 0)
        if visual.position.distance_to(goal) > 0.1:
            var tween := create_tween()
            tween.tween_property(visual, "position", goal, 1.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    for id in npc_visuals.keys():
        if not visible_ids.has(id):
            if is_instance_valid(npc_visuals[id]):
                npc_visuals[id].queue_free()
            npc_visuals.erase(id)

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
        _story_option = -1
        if STORY.TOWN_DILEMMAS.has(id) and not GameState.narrative_flags.has("dilema_" + id):
            _story_option = options.size()
            options.append("Decidir o destino da cidade")
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
    if _story_mode:
        _story_mode = false
        var event_id := _story_npc_id
        _story_npc_id = ""
        var data: Dictionary = STORY.TOWN_DILEMMAS.get(event_id, {})
        if data.is_empty() or not GameState.resolve_town_dilemma(event_id, index):
            dialogue_ui.show_dialogue("Cronicas", "A decisao nao pode mais ser alterada.")
        else:
            dialogue_ui.show_dialogue(str(_dialogue_npc.get("name", "Morador")), str(data["answers"][index]))
        _refresh_hud()
        return
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
    elif index == _story_option and STORY.TOWN_DILEMMAS.has(id):
        _story_npc_id = id
        _story_mode = true
        var dilemma: Dictionary = STORY.TOWN_DILEMMAS[id]
        dialogue_ui.show_dialogue(name_value, str(dilemma["question"]), dilemma["choices"])
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

func _create_battle_panel() -> void:
    battle_panel = preload("res://scripts/battle_panel.gd").new()
    battle_panel.name = "BattlePanel"
    get_node("CanvasLayer").add_child(battle_panel)
    battle_panel.action_chosen.connect(_battle_action)
    battle_panel.result_closed.connect(_close_battle_result)

func _battle_action(action: String) -> void:
    if GameState.play_battle_turn(action):
        _show_battle()
        _refresh_field_enemies()
        _refresh_hud()

func _show_battle() -> void:
    battle_panel.display(GameState.active_battle,int(GameState.inventory.get("pocao_vida",0)))

func _close_battle_result() -> void:
    if GameState.close_battle_result():
        battle_panel.visible = false
        _refresh_field_enemies()
        _refresh_hud()

func _spawn_field_enemies() -> void:
    for visual in enemy_visuals.values():
        if is_instance_valid(visual):
            visual.queue_free()
    enemy_visuals.clear()
    # Posicoes fixas por regiao e visita, sem AI por quadro.
    var placements := [
        {"id": GameState.current_region + "_lobo", "enemy":"lobo_cinzento", "pos":Vector3(0,0,24)},
        {"id": GameState.current_region + "_saqueador", "enemy":"saqueador", "pos":Vector3(0,0,-25)}
    ]
    for entry in placements:
        var root_node := Node3D.new()
        root_node.name = str(entry["id"])
        root_node.position = entry["pos"]
        var body := MeshInstance3D.new()
        var mesh := CapsuleMesh.new()
        mesh.radius = .40
        mesh.height = 1.2
        body.mesh = mesh
        body.position.y = .7
        var color := Color("#947b53") if entry["enemy"] == "lobo_cinzento" else Color("#794a52")
        var mat := StandardMaterial3D.new()
        mat.albedo_color = color
        body.material_override = mat
        root_node.add_child(body)
        settlement.add_child(root_node)
        enemy_visuals[str(entry["id"])] = root_node
    _refresh_field_enemies()

func _refresh_field_enemies() -> void:
    for encounter_id in enemy_visuals:
        var marker: Node3D = enemy_visuals[encounter_id]
        marker.visible = GameState.day != int(GameState.defeated_field_enemies.get(encounter_id,-1))

func _nearest_field_enemy() -> Dictionary:
    if not active_interior.is_empty():
        return {}
    for id in enemy_visuals:
        var visual: Node3D = enemy_visuals[id]
        if visual.visible and player.position.distance_to(visual.position) <= 2.4:
            var enemy_id := "lobo_cinzento" if str(id).ends_with("_lobo") else "saqueador"
            return {"id":str(id),"enemy":enemy_id}
    return {}

func _nearest_resource() -> Dictionary:
    if not active_interior.is_empty():
        return {}
    for node_id in resource_visuals:
        var obj: Node3D = resource_visuals[node_id]
        if is_instance_valid(obj) and obj.visible:
            var horizontal_distance := Vector2(player.position.x, player.position.z).distance_to(Vector2(obj.position.x, obj.position.z))
            if horizontal_distance <= 1.9:
                return {"id": str(node_id), "object": obj}
    return {}

func _on_quick_action(action: String) -> void:
    if _controls_blocked():
        return
    match action:
        "map":
            _toggle_map()
        "journal":
            _open_character_sheet("Diario")
        "day":
            GameState.advance_days(1)
            _refresh_resident_positions()
            _refresh_resource_visibility()
            _refresh_field_enemies()
            _refresh_hud()
        "save":
            GameState.save_game()
            last_message = "Campanha salva."
            _refresh_hud()

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
    var title := "LOJA: %s" % _market_vendor_id if not _market_vendor_id.is_empty() else ("CARAVANA VIAJANTE" if _market_travelling else "MERCADO DA CIDADE")
    var available_ids: Array[String] = []
    for id in ITEMS.ITEMS.keys():
        var item_id := str(id)
        var data: Dictionary = ITEMS.get_item(item_id)
        if not _market_selling and GEAR.is_equipment(item_id):
            if _market_vendor_id.is_empty() or not GEAR.vendor_inventory(_market_vendor_id).has(item_id):
                continue
        elif not _market_selling and not _market_vendor_id.is_empty():
            continue
        if _market_selling and int(GameState.inventory.get(item_id, 0)) < 1:
            continue
        if not _market_travelling and _market_vendor_id.is_empty():
            if active_interior == "Ferraria" and not ["Minerios", "Armas"].has(str(data["category"])):
                continue
            if active_interior == "Taverna" and str(data["category"]) != "Comestiveis":
                continue
        available_ids.append(item_id)
    var pages := maxi(1, ceili(float(available_ids.size()) / 5.0))
    _market_page %= pages
    var lines: Array[String] = ["%s | %s | Moedas: %d | Pagina %d/%d" % [title, mode, GameState.money, _market_page + 1, pages]]
    var store_rows: Array[Dictionary] = []
    var start_index := _market_page * 5
    for i in range(start_index, mini(available_ids.size(), start_index + 5)):
        var item_id := available_ids[i]
        var data: Dictionary = ITEMS.get_item(item_id)
        _market_ids.append(item_id)
        var price := ITEMS.sell_price(item_id) if _market_selling else ITEMS.price(item_id, GameState.current_region, GameState.oath, _market_travelling)
        lines.append("[%d] %s | %s | %s | %d moedas" % [_market_ids.size(), data["name"], data["category"], data["rarity"], price])
        var slot_name := GEAR.slot_for(item_id)
        store_rows.append({"id":item_id, "name":str(data["name"]), "rarity":str(data["rarity"]), "category":str(data["category"]), "slot":slot_name, "price":price})
    lines.append("1-5: negociar | Z: compra/venda | L: proxima pagina | V: fechar")
    town_panel.text = "\n".join(lines)
    town_panel.visible = false
    if equipment_market != null:
        equipment_market.show_inventory(title + " / " + mode, store_rows, GameState.money)

func _create_equipment_market() -> void:
    equipment_market = preload("res://scripts/equipment_market_panel.gd").new()
    equipment_market.name = "EquipmentMarket"
    get_node("CanvasLayer").add_child(equipment_market)
    equipment_market.purchase_requested.connect(_market_click_purchase)
    equipment_market.next_page_requested.connect(func():
        _market_page += 1
        _refresh_market()
    )
    equipment_market.toggle_trade_requested.connect(func():
        _market_selling = not _market_selling
        _market_page = 0
        _refresh_market()
    )

func _market_click_purchase(item_id: String) -> void:
    var success := false
    if _market_selling:
        success = GameState.market_sell(item_id)
    elif not _market_vendor_id.is_empty():
        success = GameState.buy_from_merchant(_market_vendor_id, item_id)
    else:
        success = GameState.market_buy(item_id, _market_travelling)
    last_message = "Negociado: " + item_id if success else "Moedas insuficientes ou item indisponivel."
    _refresh_market()
    _refresh_hud()

func _market_transaction(index: int) -> void:
    if index < 0 or index >= _market_ids.size():
        return
    var item_id := _market_ids[index]
    var success := GameState.market_sell(item_id) if _market_selling else (GameState.buy_from_merchant(_market_vendor_id, item_id) if not _market_vendor_id.is_empty() else GameState.market_buy(item_id, _market_travelling))
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

func _create_forge_panel() -> void:
    forge_panel = preload("res://scripts/forge_panel.gd").new()
    forge_panel.name = "ForgePanel"
    get_node("CanvasLayer").add_child(forge_panel)
    forge_panel.craft_requested.connect(_forge_craft_requested)

func _forge_craft_requested(item_id: String) -> void:
    var crafted := GameState.craft_item(item_id)
    last_message = "Item fabricado: " + item_id if crafted else "Material, moedas ou nivel de ferraria insuficientes."
    forge_panel.refresh_forge(GameState.inventory, GameState.money, GameState.building_levels)
    _refresh_hud()

func _open_craft_menu() -> void:
    forge_panel.open_forge(GameState.inventory, GameState.money, GameState.building_levels, str(GameState.protagonist_track.get("base_class","Guerreiro")))

func _create_character_sheet() -> void:
    character_sheet = preload("res://scripts/character_sheet.gd").new()
    character_sheet.name = "CharacterSheet"
    get_node("CanvasLayer").add_child(character_sheet)

func _open_character_sheet(tab: String = "Personagem") -> void:
    if npc_menu != null and npc_menu.is_open():
        npc_menu.hide_menu()
    if dialogue_ui != null and dialogue_ui.visible:
        return
    character_sheet.open_sheet(tab)

func _create_npc_menu() -> void:
    npc_menu = preload("res://scripts/npc_interaction_menu.gd").new()
    npc_menu.name = "NpcInteractionMenu"
    get_node("CanvasLayer").add_child(npc_menu)
    npc_menu.action_selected.connect(_npc_action)
    npc_menu.gift_selected.connect(_npc_gift)
    npc_menu.training_selected.connect(_npc_training)
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
        if active_interior == "Ferraria" or active_interior == "Salao":
            npc_menu.show_services(active_interior)
        else:
            _interact()
        return
    var nearby_enemy := _nearest_field_enemy()
    if not nearby_enemy.is_empty():
        if GameState.begin_field_battle(str(nearby_enemy["enemy"]),str(nearby_enemy["id"])):
            _show_battle()
        return
    var npc := _nearest_npc()
    if not npc.is_empty():
        _show_npc_menu(npc)
        return
    if preload("res://scripts/town_system.gd").travelling_merchant_present(GameState.current_region, GameState.day) and player.position.distance_to(Vector3(0, 0, 13)) <= 3.0:
        _show_npc_menu({"id": "mercador_viajante", "name": "Mercador Viajante", "profession": "Mercador", "rarity": "Comum"})
        return
    if not _nearest_resource().is_empty():
        _gather_nearby()
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
        "service_shop":
            npc_menu.hide_menu()
            _market_mode = true
            _market_page = 0
            _market_selling = false
            _market_travelling = false
            _market_vendor_id = ""
            _refresh_market()
        "service_craft":
            npc_menu.hide_menu()
            _open_craft_menu()
        "service_upgrade":
            var success := GameState.upgrade_building("Ferraria")
            npc_menu.hide_menu()
            last_message = "Ferraria melhorada." if success else "Moedas ou materiais insuficientes, ou nivel maximo."
            _refresh_hud()
        "service_sheet":
            npc_menu.hide_menu()
            _open_character_sheet("Diario")
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
            _market_vendor_id = str(npc.get("id", "")) if GEAR.MERCHANT_ARCHETYPES.has(str(npc.get("id", ""))) else ""
            _refresh_market()
        "gifts":
            npc_menu.show_gifts(npc, GameState.inventory)
        "training":
            npc_menu.show_training(npc)
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

func _npc_training(npc: Dictionary, specialization: String) -> void:
    var teacher_id := str(npc.get("id", ""))
    var learned := GameState.learn_from_master(teacher_id, specialization)
    npc_menu.hide_menu()
    last_message = "Nova especializacao aprendida: %s" % specialization if learned else "Treinamento indisponivel. Verifique amizade, presenca e classe."
    _refresh_hud()

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
        var occupied := false
        for other_id in npc_visuals:
            if other_id == id or not is_instance_valid(npc_visuals[other_id]):
                continue
            if npc_visuals[other_id].position.distance_to(target) < 1.25:
                occupied = true
                break
        if not occupied and not _is_blocked(target) and target.distance_to(player.position) > start_position.distance_to(player.position):
            visual.position = target
            last_message = "%s se afastou para liberar a passagem, sem penalidade." % str(npc.get("name", "NPC"))
            return
    last_message = "Nao ha espaco seguro para o personagem se afastar agora."

func _open_npc_directory() -> void:
    map_open = false
    map_dialog.visible = false
    npc_menu.show_directory()
