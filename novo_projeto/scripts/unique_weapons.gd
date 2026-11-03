extends RefCounted
## Itens de enredo exclusivos, SEM precos de mercado ou chance de gerar em lojas.
const UNIQUE_WEAPONS := {
    "espada_heroi": {
        "name": "Espada do Heroi", "rank": "Especial", "type": "Espada",
        "tradeable": false, "giftable": false,
        "source": "Missao exclusiva de heroi (etapa futura)"
    },
}
const UNIQUE_RELICS := {
    "armadura_duque": {
        "name": "Armadura do Duque", "rank": "Especial",
        "tradeable": false, "giftable": false,
        "source": "Somente pela conclusao do evento do Duque"
    }
}

static func is_unique(item_id: String) -> bool:
    return UNIQUE_WEAPONS.has(item_id) or UNIQUE_RELICS.has(item_id)

static func is_tradeable(_item_id: String) -> bool:
    return false
