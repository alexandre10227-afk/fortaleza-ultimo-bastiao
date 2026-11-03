extends Control
## Original tabbed character dossier. Inventory/social data are live.
signal closed
const UI = preload("res://scripts/ui_theme.gd")
const ITEMS = preload("res://scripts/item_catalog.gd")
const TABS := ["Personagem", "Inventario", "Relacoes", "Diario", "Habilidades"]
var page: String = "Personagem"
var body: VBoxContainer
var _tab_row: HBoxContainer
var _top_label: Label

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
                var label := str(data.get("name", str(item_id).replace("_", " ").capitalize()))
                var rarity := str(data.get("rarity", "Material/Especial"))
                _line("%s  x%d  |  %s" % [label, quantity, rarity])
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
        "Habilidades":
            _line("Atributos iniciais e progressao", true)
            _line("Experiencia em agilidade por viagem: %d" % GameState.agility_xp)
            _line("Bonus temporarios de refeicoes: " + str(GameState.active_food_bonuses))
            _line("Classe do protagonista: " + str(GameState.protagonist_track.get("base_class", "")))
            _line("Especializacoes aprendidas: " + str(GameState.protagonist_track.get("specializations", [])))
            _line("Tecnicas: " + str(GameState.protagonist_track.get("skills", [])))
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
