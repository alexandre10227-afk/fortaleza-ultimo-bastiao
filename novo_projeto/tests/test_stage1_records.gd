extends SceneTree
const RECORDS = preload("res://scripts/stage1_records.gd")
func _initialize() -> void:
    call_deferred("run")

func run() -> void:
    assert(RECORDS.LOCATIONS.size() == 2)
    assert(RECORDS.create_expedition("Destino invalido", 1, 1).is_empty())
    var expedition := RECORDS.create_expedition("Estrada da Fortaleza", 1, 1)
    assert(expedition["return_day"] == 3)
    var data: Array = [expedition]
    assert(RECORDS.update_expeditions(data, 2).is_empty())
    assert(RECORDS.update_expeditions(data, 3).size() == 1)
    assert(data[0]["status"] == "returned")
    assert(RECORDS.update_expeditions(data, 4).is_empty())
    var sightings := {}
    assert(RECORDS.remember_creature(sightings, "lobo", "Fortaleza", 2))
    assert(RECORDS.remember_creature(sightings, "lobo", "Fortaleza", 4))
    assert(sightings["lobo"]["sightings"] == 2)
    assert(RECORDS.memorial_entry("", "Teste", 2, "Causa").is_empty())
    var memory := RECORDS.memorial_entry("id", "Amigo", 5, "Sacrificio")
    assert(memory["name"] == "Amigo")
    print("TEST_STAGE1_RECORDS_PASS")
    quit(0)
