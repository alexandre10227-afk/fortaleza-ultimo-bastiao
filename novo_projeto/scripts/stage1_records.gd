extends RefCounted
## Dados da Etapa 1 para bestiario, expedicoes e memorial.
## Simulacao de combate e perdas reais sao integradas nas etapas seguintes.
const EXPEDITION_DURATION_DAYS := 2
const EXPEDITION_COST_MONEY := 10
const EXPEDITION_COST_ENERGY := 5
const LOCATIONS := ["Estrada da Fortaleza", "Caminho de Porto Cinzento"]

static func create_expedition(destination: String, day: int, serial: int) -> Dictionary:
    if not LOCATIONS.has(destination) or day < 1:
        return {}
    return {"id":"expedicao_%d" % serial,"destination":destination,"start_day":day,"return_day":day+EXPEDITION_DURATION_DAYS,"status":"active","report":""}

static func update_expeditions(expeditions: Array, day: int) -> Array[String]:
    var returned: Array[String] = []
    for entry in expeditions:
        if entry is Dictionary and entry.get("status", "") == "active" and int(entry.get("return_day", -1)) <= day:
            entry["status"] = "returned"
            entry["report"] = "Reconhecimento concluido. Combate e tesouros ainda nao simulados."
            returned.append(str(entry["id"]))
    return returned

static func remember_creature(bestiary: Dictionary, creature_id: String, location: String, day: int) -> bool:
    if creature_id.is_empty() or location.is_empty() or day < 1:
        return false
    if bestiary.has(creature_id):
        var current: Dictionary = bestiary[creature_id]
        current["last_seen_day"] = day
        current["sightings"] = int(current.get("sightings", 1)) + 1
        return true
    bestiary[creature_id] = {"location":location,"first_seen_day":day,"last_seen_day":day,"sightings":1}
    return true

static func memorial_entry(npc_id: String, name: String, day: int, cause: String) -> Dictionary:
    if npc_id.is_empty() or name.is_empty() or cause.is_empty() or day < 1:
        return {}
    return {"id":npc_id,"name":name,"day":day,"cause":cause}
