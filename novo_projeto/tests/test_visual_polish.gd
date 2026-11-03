extends SceneTree
const PORTRAITS = preload("res://scripts/portrait_factory.gd")
const ICONS = preload("res://scripts/item_icon_factory.gd")
const CATEGORIES = ["Arte","Comestiveis","Estudos","Minerios","Armas"]
func _initialize() -> void:
    call_deferred("run")
func run() -> void:
    var doran: Texture2D = PORTRAITS.portrait("doran","Ferreiro")
    assert(doran != null)
    assert(doran.get_width() == 72 and doran.get_height() == 80)
    assert(doran == PORTRAITS.portrait("doran","Ferreiro"))
    assert(doran != PORTRAITS.portrait("elira","Mercenaria"))
    for category in CATEGORIES:
        var image: Texture2D = ICONS.icon_for(category)
        assert(image != null)
        assert(image.get_size() == Vector2(36,36))
        assert(image == ICONS.icon_for(category))
    var ui = load("res://scripts/npc_interaction_menu.gd").new()
    root.add_child(ui)
    await process_frame
    ui.show_npc({"id":"doran","name":"Doran","profession":"Ferreiro","rarity":"Raro"},20,"Conhecido","Minerios",false,true)
    assert(ui.find_children("*","TextureRect",true,false).size() >= 1)
    ui.show_gifts({"id":"doran","name":"Doran","profession":"Ferreiro"},{"ferro":1,"maca":1})
    assert(ui.find_children("*","TextureRect",true,false).size() >= 1)
    var filled_buttons := 0
    for item in ui.find_children("*","Button",true,false):
        if item.icon != null:
            filled_buttons += 1
    assert(filled_buttons == 2)
    ui.hide_menu()
    ui.queue_free()
    await process_frame
    print("TEST_VISUAL_POLISH_PASS")
    quit(0)
