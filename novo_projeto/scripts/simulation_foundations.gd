extends RefCounted
## Esqueleto persistente dos sistemas de estrategia e simulacao.
## Sem combates imaginarios, herancas automaticas ou inteligencia onisciente.
const REGIONS := ["Fortaleza", "Porto Cinzento"]

static func initial_intelligence() -> Dictionary:
    return {"scouting_reports": [], "known_threats": {}, "garrison": {
        "Fortaleza": {"commander":"general_vaelor","defenders":24},
        "Porto Cinzento": {"commander":"","defenders":8}
    }}

static func initial_legacy() -> Dictionary:
    return {"masters": {}, "families": {}, "property_owners": {}}

static func initial_nemeses() -> Dictionary:
    return {"enemies": {}}

static func add_report(intel: Dictionary, day: int, region: String, summary: String) -> bool:
    if not REGIONS.has(region) or day < 1 or summary.is_empty():
        return false
    var reports: Array = intel.get("scouting_reports", [])
    reports.append({"day":day,"region":region,"summary":summary,"verified":false})
    intel["scouting_reports"] = reports
    return true

static func register_apprentice(legacy: Dictionary, master_id: String, apprentice_id: String) -> bool:
    if master_id.is_empty() or apprentice_id.is_empty() or master_id == apprentice_id:
        return false
    var masters: Dictionary = legacy.get("masters", {})
    if masters.has(apprentice_id):
        return false
    masters[apprentice_id] = master_id
    legacy["masters"] = masters
    return true

static func remember_enemy(registry: Dictionary, enemy_id: String, day: int, reason: String) -> bool:
    if enemy_id.is_empty() or reason.is_empty() or day < 1:
        return false
    var enemies: Dictionary = registry.get("enemies", {})
    if enemies.has(enemy_id):
        var entry: Dictionary = enemies[enemy_id]
        entry["encounters"] = int(entry.get("encounters", 1)) + 1
        entry["last_day"] = day
    else:
        enemies[enemy_id] = {"first_day":day,"last_day":day,"encounters":1,"reason":reason}
    registry["enemies"] = enemies
    return true

static func register_migration(history: Array, npc_id: String, origin: String, destination: String, day: int) -> bool:
    if npc_id.is_empty() or not REGIONS.has(origin) or not REGIONS.has(destination) or origin == destination:
        return false
    history.append({"npc":npc_id,"from":origin,"to":destination,"day":day})
    return true
