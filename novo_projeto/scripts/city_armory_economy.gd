extends RefCounted
## Reequipamento autonomo apos defesa da cidade. Nao concede itens ao jogador.
## A venda de materiais, substituicao de armadura e reparos movem dinheiro real da cidade.
const GEAR = preload("res://scripts/equipment_catalog.gd")
const ECONOMY = preload("res://scripts/economy_system.gd")
const MIN_GARRISON := 12
const INITIAL_STOCK := {"ferro":160,"madeira":90,"pedra_incomum":28,"cristal_azul":12}
const SUPPLY_DELIVERY := {"ferro":15,"madeira":9,"pedra_incomum":2,"cristal_azul":1}
const DELIVERY_COST := 110

static func initial_state() -> Dictionary:
    var troops: Array = []
    for i in range(24):
        var soldier_class := "Guerreiro" if i % 2 == 0 else "Cavaleiro"
        troops.append({"id":"soldado_%02d" % i,"class":soldier_class,"weapon":"","chest":"","head":"","feet":"","last_service":0,"condition":65})
    return {"treasury":4200,"forge_income":0,"supplier_income":0,"stock":INITIAL_STOCK.duplicate(true),"troops":troops,"battle_orders":[],"processed_battles":[],"supplies_received":0}

static func allowed_rarity(building_level: int) -> String:
    if building_level >= 4:
        return "Epico"
    if building_level >= 2:
        return "Raro"
    return "Comum"

static func _planned_item(soldier_class: String, slot: String, forge_level: int) -> String:
    var best := ""
    var best_score := -1
    for id in GEAR.GEAR:
        var item: Dictionary = GEAR.GEAR[id]
        if item.get("class","") != soldier_class or item.get("slot","") != slot:
            continue
        var rarity := str(item.get("rarity",""))
        if not ["Comum","Raro","Epico"].has(rarity) or not ECONOMY.RECIPES.has(id):
            continue
        var recipe: Dictionary = ECONOMY.RECIPES[id]
        if int(recipe["level"]) > forge_level:
            continue
        var score := int(item.get("stats",{}).get("attack",0)) + int(item.get("stats",{}).get("defense",0))*2
        score += ["Comum","Raro","Epico"].find(rarity)*100
        if score > best_score:
            best = str(id)
            best_score = score
    return best

static func receive_supplies(economy: Dictionary, battle_id: String) -> bool:
    if not economy.has("treasury") or int(economy["treasury"]) < DELIVERY_COST:
        return false
    if economy.get("processed_battles",[]).has(battle_id):
        return false
    economy["treasury"] = int(economy["treasury"]) - DELIVERY_COST
    economy["supplier_income"] = int(economy.get("supplier_income",0)) + DELIVERY_COST
    var stock: Dictionary = economy["stock"]
    for material in SUPPLY_DELIVERY:
        stock[material] = int(stock.get(material,0)) + int(SUPPLY_DELIVERY[material])
    economy["supplies_received"] = int(economy.get("supplies_received",0)) + 1
    return true

static func settle_defense(economy: Dictionary, battle_id: String, forge_level: int, battle_day: int) -> Dictionary:
    if battle_id.is_empty() or battle_day <= 0 or forge_level < 1 or forge_level > 5:
        return {}
    if economy.get("processed_battles",[]).has(battle_id):
        return {}
    receive_supplies(economy,battle_id)
    var troops: Array = economy["troops"]
    var stock: Dictionary = economy["stock"]
    var replacements := 0
    var repairs := 0
    var unmet := 0
    var spent := 0
    var requested := 0
    for soldier in troops:
        if not soldier is Dictionary:
            continue
        var soldier_class := str(soldier.get("class","Guerreiro"))
        # Cada soldado precisa revisar arma e pecas de armadura depois da batalha.
        for slot in GEAR.SLOTS:
            var desired := _planned_item(soldier_class,slot,forge_level)
            if desired.is_empty():
                continue
            requested += 1
            var same := str(soldier.get(slot,"")) == desired
            var recipe: Dictionary = ECONOMY.RECIPES[desired]
            var cost := maxi(1,ceili(float(recipe["money"])*(.20 if same else .65)))
            var requirements: Dictionary = {}
            for material in recipe["materials"]:
                requirements[material] = maxi(1,ceili(float(recipe["materials"][material])*(.25 if same else 1.0)))
            if int(economy["treasury"]) < cost or not ECONOMY.can_pay(stock,int(economy["treasury"]),requirements,cost):
                unmet += 1
                continue
            economy["treasury"] = int(economy["treasury"]) - cost
            ECONOMY.remove_materials(stock,requirements)
            spent += cost
            if same:
                repairs += 1
            else:
                soldier[slot] = desired
                replacements += 1
        soldier["last_service"] = battle_day
        soldier["condition"] = 100 if unmet == 0 else maxi(15,int(soldier.get("condition",65))-10)
    economy["forge_income"] = int(economy.get("forge_income",0)) + spent
    var receipt := {"battle":battle_id,"day":battle_day,"forge_level":forge_level,"rarity":allowed_rarity(forge_level),"requested":requested,"replacements":replacements,"repairs":repairs,"unmet":unmet,"paid_to_forge":spent,"remaining_treasury":int(economy["treasury"])}
    economy["battle_orders"].append(receipt)
    economy["processed_battles"].append(battle_id)
    return receipt
