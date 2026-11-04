extends RefCounted
## Economia territorial da Fase 2: tributos, recursos, consignacao e diplomacia.
## Nao transfere dinheiro do jogador para o tesouro sem uma venda real.
const TERRITORIES := ["Fortaleza", "Porto Cinzento"]
const TAX_PERCENT := 15
const CONSIGN_TAX_PERCENT := 12
const WORKER_PROFILES := {
    "lenhador": {"income":16, "goods":{"madeira":3}, "price":6},
    "mineiro": {"income":20, "goods":{"pedra":2, "ferro":1}, "price":9},
    "agricultor": {"income":12, "goods":{"cenoura":2}, "price":4},
    "mercador": {"income":26, "goods":{}, "price":0}
}
const INITIAL_STOCK := {"madeira":14,"pedra":12,"ferro":10,"pedra_incomum":2,"cristal_azul":0}
const UPGRADE_BASE := {
    "Ferraria":{"gold":125,"materials":{"madeira":3,"pedra":4,"ferro":3}},
    "Oficina":{"gold":90,"materials":{"madeira":6,"pedra":2,"ferro":1}},
    "Cozinha":{"gold":75,"materials":{"madeira":4,"pedra":3}},
    "Escritorio":{"gold":145,"materials":{"madeira":3,"pedra":5,"ferro":1}},
    "Muralha":{"gold":210,"materials":{"madeira":5,"pedra":8,"ferro":5}}
}
const MAX_LEVEL := 5

static func initial_state() -> Dictionary:
    var territories := {}
    for region in TERRITORIES:
        var wallets := {}
        for worker_id in WORKER_PROFILES:
            wallets[worker_id] = {"money":36,"income":0,"tax_paid":0}
        territories[region] = {
            "treasury":750,"market_liquidity":250,"stock":INITIAL_STOCK.duplicate(true),
            "workers":wallets,"tax_received":0,"consign_tax":0,"construction_spent":0,
            "goods_purchased":{},"alliances":[],"relations":{},
            "trade_history":[],"last_settlement_day":1
        }
    return {"territories":territories,"consignments":[],"next_listing_id":1,"transactions":[]}

static func valid_region(region: String) -> bool:
    return TERRITORIES.has(region)

static func costs(building: String, level: int) -> Dictionary:
    if not UPGRADE_BASE.has(building) or level < 1 or level >= MAX_LEVEL:
        return {}
    var base: Dictionary = UPGRADE_BASE[building]
    var materials := {}
    for material in base["materials"]:
        materials[material] = int(base["materials"][material]) * level
    if level >= 3:
        materials["pedra_incomum"] = level - 1
    if level >= 4 and building in ["Ferraria","Muralha"]:
        materials["cristal_azul"] = level - 3
    return {"gold":int(base["gold"])*level*level,"materials":materials,"next_level":level+1}

static func can_build(ledger: Dictionary, region: String, building: String, level: int) -> bool:
    if not valid_region(region):
        return false
    var cost := costs(building,level)
    if cost.is_empty():
        return false
    var city: Dictionary = ledger.get("territories",{}).get(region,{})
    if city.is_empty() or int(city.get("treasury",0)) < int(cost["gold"]):
        return false
    var stock: Dictionary = city.get("stock",{})
    for material in cost["materials"]:
        if int(stock.get(material,0)) < int(cost["materials"][material]):
            return false
    return true

static func build(ledger: Dictionary, region: String, building: String, level: int) -> bool:
    if not can_build(ledger,region,building,level):
        return false
    var city: Dictionary = ledger["territories"][region]
    var cost := costs(building,level)
    city["treasury"] = int(city["treasury"]) - int(cost["gold"])
    city["construction_spent"] = int(city["construction_spent"]) + int(cost["gold"])
    var stock: Dictionary = city["stock"]
    for material in cost["materials"]:
        stock[material] = int(stock.get(material,0)) - int(cost["materials"][material])
    return true

static func settle_day(ledger: Dictionary, day: int) -> Array[Dictionary]:
    var events: Array[Dictionary] = []
    for region in TERRITORIES:
        var city: Dictionary = ledger["territories"][region]
        var last_day := int(city.get("last_settlement_day",1))
        for completed_day in range(last_day+1,day+1):
            var workers: Dictionary = city["workers"]
            for job in WORKER_PROFILES:
                var profile: Dictionary = WORKER_PROFILES[job]
                var wallet: Dictionary = workers[job]
                var gross := int(profile["income"])
                wallet["money"] = int(wallet["money"])+gross
                wallet["income"] = int(wallet["income"])+gross
                # O tributo e transferido da carteira do trabalhador.
                var tax := mini(int(wallet["money"]),floori(float(gross)*TAX_PERCENT/100.0))
                wallet["money"] = int(wallet["money"])-tax
                wallet["tax_paid"] = int(wallet["tax_paid"])+tax
                city["treasury"] = int(city["treasury"])+tax
                city["tax_received"] = int(city["tax_received"])+tax
                # A cidade compra a producao pelo preco definido, se tiver caixa.
                for item_id in profile["goods"]:
                    var count := int(profile["goods"][item_id])
                    var payout := count*int(profile["price"])
                    if int(city["treasury"]) >= payout:
                        city["treasury"] = int(city["treasury"])-payout
                        wallet["money"] = int(wallet["money"])+payout
                        city["stock"][item_id] = int(city["stock"].get(item_id,0))+count
                        city["goods_purchased"][item_id] = int(city["goods_purchased"].get(item_id,0))+count
            # Economia dos compradores: fundos vêm de salários/produção simulados.
            city["market_liquidity"] = int(city["market_liquidity"])+15
            events.append({"region":region,"day":completed_day,"kind":"tax_and_supply"})
        city["last_settlement_day"] = maxi(last_day,day)
    return events

static func can_list(item_id: String, item_info: Dictionary, quantity: int, carried: Dictionary, equipped: Dictionary) -> bool:
    if quantity < 1 or quantity > 25 or item_info.is_empty():
        return false
    if int(item_info.get("price",0)) <= 0:
        return false
    var owned := int(carried.get(item_id,0))
    var reserved := 1 if equipped.values().has(item_id) else 0
    return owned-quantity >= reserved

static func list_item(ledger: Dictionary, item_id: String, item_info: Dictionary, quantity: int, region: String, day: int, carried: Dictionary, equipped: Dictionary) -> bool:
    if not valid_region(region) or not can_list(item_id,item_info,quantity,carried,equipped):
        return false
    carried[item_id] = int(carried.get(item_id,0))-quantity
    var listing_id := int(ledger.get("next_listing_id",1))
    ledger["next_listing_id"] = listing_id+1
    ledger["consignments"].append({"id":listing_id,"item":item_id,"quantity":quantity,"region":region,"unit_price":maxi(1,floori(float(item_info["price"])*.75)),"listed_day":day,"sold":0,"status":"active"})
    return true

static func settle_sales(ledger: Dictionary, day: int) -> Array[Dictionary]:
    var settlements: Array[Dictionary] = []
    for listing in ledger["consignments"]:
        if listing.get("status","") != "active" or day <= int(listing.get("listed_day",day)):
            continue
        var city: Dictionary = ledger["territories"][str(listing["region"])]
        var unit_price := int(listing["unit_price"])
        if int(listing["quantity"]) <= 0 or int(city["market_liquidity"]) < unit_price:
            continue
        # Venda de ate uma unidade por cidade/dia por anuncio.
        city["market_liquidity"] = int(city["market_liquidity"])-unit_price
        var tax := maxi(1,floori(float(unit_price)*CONSIGN_TAX_PERCENT/100.0))
        var player_income := unit_price-tax
        city["treasury"] = int(city["treasury"])+tax
        city["consign_tax"] = int(city["consign_tax"])+tax
        listing["quantity"] = int(listing["quantity"])-1
        listing["sold"] = int(listing["sold"])+1
        if int(listing["quantity"]) == 0:
            listing["status"] = "sold"
        settlements.append({"listing_id":int(listing["id"]),"item":str(listing["item"]),"region":str(listing["region"]),"gross":unit_price,"player":player_income,"tax":tax,"day":day})
    for result in settlements:
        ledger["transactions"].append(result)
    return settlements

static func withdraw_listing(ledger: Dictionary, listing_id: int, carried: Dictionary) -> bool:
    for listing in ledger.get("consignments",[]):
        if int(listing.get("id",-1)) != listing_id or listing.get("status","") != "active":
            continue
        var remaining := int(listing["quantity"])
        if remaining <= 0:
            return false
        carried[str(listing["item"])] = int(carried.get(str(listing["item"]),0))+remaining
        listing["quantity"] = 0
        listing["status"] = "withdrawn"
        return true
    return false

static func trade_for_alliance(ledger: Dictionary, origin: String, destination: String, item_id: String, amount: int) -> Dictionary:
    if not valid_region(origin) or not valid_region(destination) or origin == destination or amount < 1:
        return {}
    if not ["madeira","pedra","ferro","pedra_incomum"].has(item_id):
        return {}
    var seller: Dictionary = ledger["territories"][origin]
    var buyer: Dictionary = ledger["territories"][destination]
    if int(seller["stock"].get(item_id,0)) < amount:
        return {}
    var unit_price := 8 if item_id == "madeira" else 10 if item_id == "pedra" else 18 if item_id == "ferro" else 65
    var invoice := amount*unit_price
    if int(buyer["treasury"]) < invoice:
        return {}
    seller["stock"][item_id] = int(seller["stock"][item_id])-amount
    buyer["stock"][item_id] = int(buyer["stock"].get(item_id,0))+amount
    buyer["treasury"] = int(buyer["treasury"])-invoice
    seller["treasury"] = int(seller["treasury"])+invoice
    var relation := mini(100,int(seller["relations"].get(destination,0))+amount*5)
    seller["relations"][destination] = relation
    buyer["relations"][origin] = relation
    var ally := relation >= 60
    if ally and not seller["alliances"].has(destination):
        seller["alliances"].append(destination)
        buyer["alliances"].append(origin)
    var result := {"from":origin,"to":destination,"item":item_id,"amount":amount,"gold":invoice,"relation":relation,"alliance":ally}
    seller["trade_history"].append(result)
    buyer["trade_history"].append(result)
    return result
