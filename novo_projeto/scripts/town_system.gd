extends RefCounted

## Persisted NPC itineraries. Each tavern stay is exactly four calendar days.
## Characters move between the tavern, their village, and other regions.
const STAY_DAYS := 4
const CATALOG := {
    "pao": {"name": "Pao de viagem", "price": 8},
    "ervas": {"name": "Ervas medicinais", "price": 12},
    "ferro": {"name": "Minerio de ferro", "price": 20},
}
const VISITORS := [
    {"id": "elira", "name": "Elira", "rarity": "Raro", "home": "Porto Cinzento", "profession": "Mercenaria", "first_day": 1, "return_after": 8, "after_visit": "travel"},
    {"id": "doran", "name": "Doran", "rarity": "Comum", "home": "Fortaleza", "profession": "Ferreiro", "first_day": 1, "return_after": 0, "after_visit": "village"},
    {"id": "mira", "name": "Mira", "rarity": "Incomum", "home": "Porto Cinzento", "profession": "Curandeira", "first_day": 2, "return_after": 0, "after_visit": "village"},
    {"id": "kael", "name": "Kael", "rarity": "Epico", "home": "Fortaleza", "profession": "Explorador", "first_day": 3, "return_after": 7, "after_visit": "travel"},
    {"id": "selene", "name": "Selene", "rarity": "Lendario", "home": "Porto Cinzento", "profession": "Estrategista", "first_day": 5, "return_after": 12, "after_visit": "travel"},
]

static func initial_lives() -> Dictionary:
    var lives := {}
    for npc in VISITORS:
        lives[str(npc["id"])] = {
            "status": "travelling", "region": str(npc["home"]),
            "arrival_day": -1, "departure_day": -1,
            "next_arrival_day": int(npc["first_day"]), "visits": 0
        }
    return lives

static func advance_lives(lives: Dictionary, day: int, story_flags: Dictionary = {}) -> Array[Dictionary]:
    # Call once for each day advanced. Returns truthful changes to the world journal.
    var events: Array[Dictionary] = []
    for npc in VISITORS:
        var id := str(npc["id"])
        if not lives.has(id):
            continue
        var state: Dictionary = lives[id]
        if state.get("status", "") == "tavern" and day >= int(state["departure_day"]):
            var disposition := str(story_flags.get(id, npc["after_visit"]))
            if disposition == "village":
                state["status"] = "village"
                state["region"] = str(npc["home"])
                state["next_arrival_day"] = -1
            else:
                state["status"] = "travelling"
                state["next_arrival_day"] = day + int(npc["return_after"])
                state["region"] = "Fortaleza" if str(state["region"]) == "Porto Cinzento" else "Porto Cinzento"
            events.append({"kind": "npc_departed_tavern", "npc_id": id, "status": state["status"], "region": state["region"]})
        if state.get("status", "") == "travelling" and int(state.get("next_arrival_day", -1)) >= 0 and day >= int(state["next_arrival_day"]):
            state["status"] = "tavern"
            state["arrival_day"] = day
            state["departure_day"] = day + STAY_DAYS
            state["next_arrival_day"] = -1
            state["visits"] = int(state["visits"]) + 1
            events.append({"kind": "npc_arrived_tavern", "npc_id": id, "status": "tavern", "region": state["region"]})
    return events

static func tavern_visitors(region: String, _day: int, lives: Dictionary = {}) -> Array[Dictionary]:
    var available: Array[Dictionary] = []
    for npc in VISITORS:
        var id := str(npc["id"])
        if lives.has(id):
            var state: Dictionary = lives[id]
            if state.get("status", "") == "tavern" and state.get("region", "") == region:
                var guest: Dictionary = npc.duplicate(true)
                guest["arrival_day"] = state["arrival_day"]
                guest["departure_day"] = state["departure_day"]
                available.append(guest)
    return available

static func town_residents(region: String, lives: Dictionary) -> Array[Dictionary]:
    var residents: Array[Dictionary] = []
    for npc in VISITORS:
        var state: Dictionary = lives.get(str(npc["id"]), {})
        if state.get("status", "") == "village" and state.get("region", "") == region:
            residents.append(npc.duplicate(true))
    return residents

static func price(item_id: String, region: String, oath: String) -> int:
    if not CATALOG.has(item_id):
        return -1
    var cost: int = CATALOG[item_id]["price"]
    return cost * (3 if oath == "exile" and region == "Fortaleza" else 1)

static func can_recruit(npc: Dictionary, oath: String) -> bool:
    return not (oath == "exile" and npc.get("home", "") == "Fortaleza")

static func travelling_merchant_present(region: String, day: int) -> bool:
    # Caravan visits each region for four days every twelve game days.
    var first_day := 1 if region == "Fortaleza" else 5
    if day < first_day:
        return false
    return (day - first_day) % 12 < STAY_DAYS
