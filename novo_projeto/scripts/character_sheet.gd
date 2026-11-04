extends Control
## Original tabbed character dossier. Inventory/social data are live.
signal closed
const UI = preload("res://scripts/ui_theme.gd")
const ITEMS = preload("res://scripts/item_catalog.gd")
const GEAR = preload("res://scripts/equipment_catalog.gd")
const TABS := ["Personagem", "Inventario", "Relacoes", "Diario", "Habilidades", "Mundo", "Catalogo"]
var page: String = "Personagem"
var body: VBoxContainer
var _tab_row: HBoxContainer
var _top_label: Label
var _catalog_class := "Guerreiro"
var _catalog_rarity := "Raro"
var _catalog_page := 0

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_STOP
    visible = false
    var backdrop := ColorRect.new()
    backdrop.color = Color(0,0,0,.70)
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(backdrop)
    var center := CenterContainer.new()
    center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(center)
    var panel := PanelContainer.new()
    panel.custom_minimum_size = Vector2(800, 600)
    UI.apply_panel(panel)
    center.add_child(panel)
    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 12)
    panel.add_child(column)
    _top_label = Label.new()
    UI.apply_title(_top_label)
    column.add_child(_top_label)
    _tab_row = HBoxContainer.new()
    column.add_child(_tab_row)
    for tab in TABS:
        var button := Button.new()
        button.text = tab
        UI.apply_button(button)
        button.pressed.connect(show_page.bind(tab))
        _tab_row.add_child(button)
    var scroll := ScrollContainer.new()
    scroll.custom_minimum_size = Vector2(745, 430)
    column.add_child(scroll)
    body = VBoxContainer.new()
    body.custom_minimum_size.x = 710
    body.add_theme_constant_override("separation", 9)
    scroll.add_child(body)
    var close_button := Button.new()
    close_button.text = "Fechar ficha"
    UI.apply_button(close_button)
    close_button.pressed.connect(hide_sheet)
    column.add_child(close_button)

func open_sheet(page_name: String = "Personagem") -> void:
    visible = true
    show_page(page_name)

func hide_sheet() -> void:
    visible = false
    closed.emit()

func show_page(page_name: String) -> void:
    if not TABS.has(page_name):
        page_name = "Personagem"
    page = page_name
    _top_label.text = "CRONICAS DO BASTIAO  /  " + page.to_upper()
    for child in body.get_children():
        body.remove_child(child)
        child.queue_free()
    match page:
        "Personagem":
            _line("Protagonista: %s  |  Origem: %s" % [GameState.character_name, GameState.character_origin], true)
            _line("Dificuldade: %s  |  Juramento: %s" % [GameState.difficulty, GameState.oath])
            _line("Dia: %d  |  Onda: %d  |  Energia: %d" % [GameState.day, GameState.wave_number, GameState.energy])
            _line("Classe inicial: %s" % GameState.protagonist_track.get("base_class", "Guerreiro"))
            _line("Especializacoes aprendidas: " + str(GameState.protagonist_track.get("specializations", [])))
            _line("Equipamentos", true)
            for slot in GEAR.SLOTS:
                var equipped_id := str(GameState.equipped.get(slot, ""))
                var equipped_label := "Vazio" if equipped_id.is_empty() else str(GEAR.GEAR[equipped_id]["name"])
                _line("%s: %s" % [slot.capitalize(), equipped_label])
            var totals: Dictionary = GameState.equipment_stats()
            _line("Bonus de ataque: +%d | Defesa: +%d" % [int(totals["attack"]), int(totals["defense"])])
            _line("Vida +%d | Mana +%d | Agilidade +%d | Cura +%d | Critico +%d" % [int(totals["life"]),int(totals["mana"]),int(totals["agility"]),int(totals["healing"]),int(totals["critical"])])
            _line("Combate e progressao", true)
            var battle_stats: Dictionary = GameState.hero_combat_stats()
            _line("Nivel %d | Experiencia %d/%d" % [int(battle_stats["level"]),int(battle_stats["xp"]),int(battle_stats["next_xp"])])
            _line("PV %d/%d | PM %d/%d" % [int(battle_stats["hp"]),int(battle_stats["max_hp"]),int(battle_stats["mp"]),int(battle_stats["max_mp"])])
            _line("Ataque %d | Defesa %d" % [int(battle_stats["attack"]),int(battle_stats["defense"])])
            _line("Atributos de criacao", true)
            var radar := preload("res://scripts/attribute_radar.gd").new()
            body.add_child(radar)
            radar.set_stats(GameState.character_stats)
            for stat in GameState.character_stats:
                _line("%s: %d" % [stat, int(GameState.character_stats[stat])])
            _line("Equipamento e habilidades de batalha serao integrados na Etapa 2.")
        "Inventario":
            _line("Moedas: %d" % GameState.money, true)
            var found := false
            for item_id in GameState.inventory:
                var quantity := int(GameState.inventory[item_id])
                if quantity <= 0:
                    continue
                found = true
                var data: Dictionary = ITEMS.get_item(str(item_id))
                var rare_gear: Dictionary = GEAR.GEAR.get(str(item_id), {})
                var label := str(data.get("name", rare_gear.get("name", str(item_id).replace("_", " ").capitalize())))
                var rarity := str(data.get("rarity", rare_gear.get("rarity", "Material/Especial")))
                _line("%s  x%d  |  %s" % [label, quantity, rarity])
                if GEAR.is_equipment(str(item_id)):
                    var gear: Dictionary = GEAR.GEAR[str(item_id)]
                    var equip_button := Button.new()
                    var valid_class := GEAR.can_equip(str(item_id), str(GameState.protagonist_track.get("base_class","")))
                    equip_button.text = "Equipar (%s): %s" % [str(gear["slot"]), str(gear["name"])]
                    equip_button.disabled = not valid_class
                    UI.apply_button(equip_button)
                    equip_button.pressed.connect(_equip_owned_item.bind(str(item_id)))
                    body.add_child(equip_button)
                if GameState.PLAYER_CLASSES.BOSS_BOOKS.has(str(item_id)):
                    var book_button := Button.new()
                    var specialization := GameState.PLAYER_CLASSES.specialization_from_book(str(item_id))
                    book_button.text = "Estudar livro: " + specialization
                    book_button.disabled = not GameState.PLAYER_CLASSES.can_learn(GameState.protagonist_track, specialization)
                    UI.apply_button(book_button)
                    book_button.pressed.connect(_read_boss_book.bind(str(item_id)))
                    body.add_child(book_button)
            if not found:
                _line("Seu inventario esta vazio.")
        "Relacoes":
            _line("Amizades e companheiros", true)
            for id in GameState.npc_friendship:
                _line("%s: %d/100 (%s)" % [str(id).capitalize(), GameState.friendship_points(str(id)), GameState.friendship_level(str(id))])
            _line("Grupo: " + str(GameState.recruited))
            _line("Reputacao regional: " + str(GameState.region_reputation))
        "Diario":
            _line("Escolhas permanentes: " + str(GameState.narrative_flags), true)
            _line("Missoes: " + str(GameState.quest_progress))
            for index in range(maxi(0, GameState.events.size() - 12), GameState.events.size()):
                var event: Dictionary = GameState.events[index]
                _line("Dia %d | %s" % [int(event.get("day", 0)), str(event.get("description", ""))])
        "Mundo":
            _line("BESTIARIO", true)
            if GameState.discovered_bestiary.is_empty():
                _line("Nenhum monstro identificado ate o momento.")
            for creature_id in GameState.discovered_bestiary:
                var info: Dictionary = GameState.discovered_bestiary[creature_id]
                _line("%s | %s | Avistamentos: %d" % [str(creature_id), str(info.get("location", "")), int(info.get("sightings", 1))])
            _line("EXPEDICOES", true)
            if GameState.expeditions.is_empty():
                _line("Ainda nao houve expedicoes de reconhecimento.")
            for expedition in GameState.expeditions:
                if expedition is Dictionary:
                    _line("%s | %s | Retorno dia %d" % [str(expedition.get("destination", "")), str(expedition.get("status", "")), int(expedition.get("return_day", 0))])
            _line("INTELIGENCIA MILITAR", true)
            var garrisons: Dictionary = GameState.military_intel.get("garrison", {})
            for region_name in garrisons:
                var garrison: Dictionary = garrisons[region_name]
                _line("%s | Comando: %s | Defensores (base): %d" % [region_name, str(garrison.get("commander","")), int(garrison.get("defenders",0))])
            _line("Relatorios de reconhecimento: %d (nao verificados)" % GameState.military_intel.get("scouting_reports", []).size())
            _line("MIGRACAO E LEGADO", true)
            _line("Movimentos entre regioes: %d" % GameState.migration_history.size())
            _line("Vinculos de mestre e aprendiz: %d" % GameState.legacy_records.get("masters", {}).size())
            _line("INIMIGOS PERSISTENTES", true)
            _line("Inimigos registrados: %d" % GameState.nemesis_records.get("enemies", {}).size())
            _line("MEMORIAL DOS CAIDOS", true)
            if GameState.memorial.is_empty():
                _line("Nenhum companheiro registrado no memorial.")
            for fallen in GameState.memorial:
                if fallen is Dictionary:
                    _line("%s | Dia %d | %s" % [str(fallen.get("name", "")), int(fallen.get("day", 0)), str(fallen.get("cause", ""))])
        "Catalogo":
            _show_catalog()
        "Habilidades":
            _line("Atributos iniciais e progressao", true)
            _line("Experiencia em agilidade por viagem: %d" % GameState.agility_xp)
            _line("Bonus temporarios de refeicoes: " + str(GameState.active_food_bonuses))
            _line("Classe do protagonista: " + str(GameState.protagonist_track.get("base_class", "")))
            _line("Especializacoes aprendidas: " + str(GameState.protagonist_track.get("specializations", [])))
            _line("Tecnicas: " + str(GameState.protagonist_track.get("skills", [])))
            var core := preload("res://scripts/combat_core.gd")
            var starting_class := str(GameState.protagonist_track.get("base_class","Guerreiro"))
            var technique: Dictionary = core.CLASS_SKILLS.get(starting_class,{})
            if not technique.is_empty():
                _line("Tecnica ativa: %s | Custo de PM: %d" % [technique["name"],int(technique["mana"])])
            _line("As habilidades de mestres e chefes serao conectadas ao combate progressivamente.")
            _line("Origens das tecnicas: " + str(GameState.protagonist_track.get("learned_sources", {})))
            _line("Treinamento e livros de chefes: efeitos de combate completos na Etapa 2.")

func _line(message: String, title: bool = false) -> void:
    var label := Label.new()
    label.text = message
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    if title:
        UI.apply_title(label)
    else:
        UI.apply_text(label)
    body.add_child(label)

func _read_boss_book(book_id: String) -> void:
    if GameState.learn_from_boss_book(book_id):
        show_page("Habilidades")
    else:
        show_page("Inventario")

func _equip_owned_item(item_id: String) -> void:
    if GameState.equip_item(item_id):
        show_page("Personagem")
    else:
        show_page("Inventario")
