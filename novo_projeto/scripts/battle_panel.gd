extends Control
## Batalha em turnos com UI própria. Sinais não realizam mudanças sem GameState.
signal action_chosen(action: String)
signal result_closed
const UI = preload("res://scripts/ui_theme.gd")
var heading: Label
var hero_status: Label
var enemy_status: Label
var combat_log: RichTextLabel
var actions: Dictionary = {}
var finish: Button

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_STOP
    visible = false
    var dark := ColorRect.new()
    dark.color = Color(0.02,0.02,0.03,.84)
    dark.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(dark)
    var center := CenterContainer.new()
    center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(center)
    var frame := PanelContainer.new()
    frame.custom_minimum_size = Vector2(820,620)
    UI.apply_panel(frame)
    center.add_child(frame)
    var col := VBoxContainer.new()
    col.add_theme_constant_override("separation", 12)
    frame.add_child(col)
    heading = Label.new()
    heading.text = "ENCONTRO NAS ESTRADAS"
    UI.apply_title(heading)
    col.add_child(heading)
    var info := HBoxContainer.new()
    info.add_theme_constant_override("separation", 25)
    col.add_child(info)
    hero_status = Label.new()
    hero_status.custom_minimum_size.x = 360
    UI.apply_text(hero_status)
    info.add_child(hero_status)
    enemy_status = Label.new()
    UI.apply_text(enemy_status)
    info.add_child(enemy_status)
    combat_log = RichTextLabel.new()
    combat_log.custom_minimum_size = Vector2(740,270)
    combat_log.scroll_active = true
    combat_log.fit_content = false
    combat_log.add_theme_font_size_override("normal_font_size",19)
    combat_log.add_theme_color_override("default_color",UI.LIGHT_TEXT)
    col.add_child(combat_log)
    var button_row := HBoxContainer.new()
    button_row.add_theme_constant_override("separation", 12)
    col.add_child(button_row)
    for pair in [
        {"id":"attack","name":"Atacar"},
        {"id":"skill","name":"Habilidade"},
        {"id":"defend","name":"Defender"},
        {"id":"potion","name":"Pocao"}
    ]:
        var button := Button.new()
        button.custom_minimum_size = Vector2(174,52)
        button.text = str(pair["name"])
        UI.apply_button(button)
        button.pressed.connect(_choose.bind(str(pair["id"])))
        actions[str(pair["id"])] = button
        button_row.add_child(button)
    finish = Button.new()
    finish.text = "Encerrar encontro"
    UI.apply_button(finish)
    finish.pressed.connect(_finish_pressed)
    col.add_child(finish)

func display(battle: Dictionary, potion_count: int) -> void:
    if battle.is_empty():
        visible = false
        return
    var enemy: Dictionary = battle.get("enemy",{})
    var active := str(battle.get("state","")) == "active"
    var suffix := " | VITORIA" if battle.get("state","") == "won" else " | DERROTA" if battle.get("state","") == "lost" else ""
    heading.text = "BATALHA - TURNO %d%s" % [int(battle.get("turn",1)),suffix]
    hero_status.text = "HERÓI (%s)\nPV %d / %d\nPM %d / %d" % [str(battle.get("hero_class","")),int(battle.get("hero_hp",0)),int(battle.get("max_hp",0)),int(battle.get("hero_mp",0)),int(battle.get("max_mp",0))]
    enemy_status.text = "%s\nPV %d / %d" % [str(enemy.get("name","Inimigo")),int(enemy.get("hp",0)),int(enemy.get("max_hp",0))]
    combat_log.text = "\n".join(battle.get("log",[]))
    for action in actions:
        actions[action].visible = active
        actions[action].disabled = action == "potion" and potion_count <= 0 or (action == "skill" and int(battle.get("hero_mp",0)) < int(preload("res://scripts/combat_core.gd").CLASS_SKILLS[str(battle.get("hero_class","Guerreiro"))]["mana"]))
    actions["potion"].text = "Pocao (%d)" % potion_count
    actions["skill"].text = str(preload("res://scripts/combat_core.gd").CLASS_SKILLS[str(battle.get("hero_class","Guerreiro"))]["name"])
    finish.visible = not active
    visible = true

func _choose(action: String) -> void:
    action_chosen.emit(action)

func _finish_pressed() -> void:
    result_closed.emit()
