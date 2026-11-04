extends RefCounted
## Catalogo expandido independente dos 24 equipamentos da Etapa 1.
## Gera IDs estaveis sem criar recursos graficos em tempo de execucao.
const RARITIES := ["Comum", "Raro", "Epico", "Lendario"]
const TIER_SCALE := {"Comum":1,"Raro":2,"Epico":4,"Lendario":7}
const ARMOR_SLOTS := ["head","chest","feet"]
const CLASSES := {
    "Guerreiro": {"id":"guerreiro","focus":["Forca","Constituicao","Destreza"],"sets":["Gladiador","Baluarte","Duelista"],"weapons":["Montante","Machado de Guerra","Sabre de Duelo"]},
    "Cavaleiro": {"id":"cavaleiro","focus":["Constituicao","Forca","Destreza"],"sets":["Sentinela","Justicar","Cavaleiro Errante"],"weapons":["Lanca de Guarda","Espada Longa","Martelo de Guerra"]},
    "Mago": {"id":"mago","focus":["Inteligencia","Constituicao","Destreza"],"sets":["Arcanista","Runico","Tecelao dos Ventos"],"weapons":["Cajado de Runas","Orbe Arcano","Varinha de Cristal"]},
    "Sacerdote": {"id":"sacerdote","focus":["Inteligencia","Constituicao","Sorte"],"sets":["Oraculo","Guardiao da Fe","Peregrino"],"weapons":["Cetro da Aurora","Bastao da Vida","Livro Sagrado"]}
}
const SLOT_NAMES := {"head":"Capacete","chest":"Peitoral","feet":"Botas"}
const SPECIAL := {
    "boss_lamina_carrasco": {"name":"Lamina do Carrasco do Juramento","class":"Guerreiro","slot":"weapon","rarity":"Mitico","stats":{"attack":46,"Forca":6},"source_type":"boss","source_id":"carrasco_juramento"},
    "boss_escudo_colosso": {"name":"Peitoral do Colosso de Ferro","class":"Cavaleiro","slot":"chest","rarity":"Mitico","stats":{"defense":42,"Constituicao":7},"source_type":"boss","source_id":"colosso_ferro"},
    "boss_orbe_tempestade": {"name":"Orbe do Coracao da Tempestade","class":"Mago","slot":"weapon","rarity":"Mitico","stats":{"attack":35,"Inteligencia":8},"source_type":"boss","source_id":"coracao_tempestade"},
    "boss_cetro_vida": {"name":"Cetro da Matriarca Sombria","class":"Sacerdote","slot":"weapon","rarity":"Mitico","stats":{"attack":27,"Inteligencia":6,"Sorte":4},"source_type":"boss","source_id":"matriarca_sombria"},
    "boss_elmo_abismo": {"name":"Elmo do Devorador","class":"Guerreiro","slot":"head","rarity":"Mitico","stats":{"defense":29,"Constituicao":5},"source_type":"boss","source_id":"devorador"},
    "boss_botas_nevoa": {"name":"Botas do Espectro da Nevoa","class":"Cavaleiro","slot":"feet","rarity":"Mitico","stats":{"defense":18,"Destreza":7},"source_type":"boss","source_id":"espectro_nevoa"},
    "boss_manto_cinzas": {"name":"Peitoral do Arauto das Cinzas","class":"Mago","slot":"chest","rarity":"Mitico","stats":{"defense":25,"Inteligencia":5},"source_type":"boss","source_id":"arauto_cinzas"},
    "boss_coroa_penitente": {"name":"Coroa do Penitente","class":"Sacerdote","slot":"head","rarity":"Mitico","stats":{"defense":25,"Sorte":6},"source_type":"boss","source_id":"penitente"},
    "dungeon_espada_lago": {"name":"Espada das Profundezas","class":"Guerreiro","slot":"weapon","rarity":"Mitico","stats":{"attack":49,"Destreza":5},"source_type":"dungeon","source_id":"lago_antigo"},
    "dungeon_peitoral_rocha": {"name":"Peitoral da Rocha Eterna","class":"Cavaleiro","slot":"chest","rarity":"Mitico","stats":{"defense":46,"Constituicao":8},"source_type":"dungeon","source_id":"lago_antigo"},
    "dungeon_cajado_quatro": {"name":"Cajado das Quatro Correntes","class":"Mago","slot":"weapon","rarity":"Mitico","stats":{"attack":42,"Inteligencia":9},"source_type":"dungeon","source_id":"lago_antigo"},
    "dungeon_cetro_pureza": {"name":"Cetro da Purificacao","class":"Sacerdote","slot":"weapon","rarity":"Mitico","stats":{"attack":32,"Inteligencia":7},"source_type":"dungeon","source_id":"lago_antigo"},
    "dungeon_elmo_ecos": {"name":"Elmo dos Ecos Antigos","class":"Guerreiro","slot":"head","rarity":"Mitico","stats":{"defense":31,"Forca":5},"source_type":"dungeon","source_id":"lago_antigo"},
    "dungeon_botas_passagem": {"name":"Botas do Caminho Esquecido","class":"Cavaleiro","slot":"feet","rarity":"Mitico","stats":{"defense":18,"Destreza":8},"source_type":"dungeon","source_id":"lago_antigo"},
    "dungeon_veste_mana": {"name":"Veste do Lago Arcano","class":"Mago","slot":"chest","rarity":"Mitico","stats":{"defense":30,"Inteligencia":6},"source_type":"dungeon","source_id":"lago_antigo"},
    "dungeon_veu_sacerdote": {"name":"Veu da Memoria Sagrada","class":"Sacerdote","slot":"head","rarity":"Mitico","stats":{"defense":23,"Sorte":8},"source_type":"dungeon","source_id":"lago_antigo"},
    "quest_espada_juramento": {"name":"Espada do Juramento","class":"Guerreiro","slot":"weapon","rarity":"Lendario","stats":{"attack":33,"Forca":4},"source_type":"quest","source_id":"juramento_ferreiros"},
    "quest_peitoral_guardia": {"name":"Couraca do Povo","class":"Cavaleiro","slot":"chest","rarity":"Lendario","stats":{"defense":29,"Constituicao":5},"source_type":"quest","source_id":"proteger_refugiados"},
    "quest_orbe_erudito": {"name":"Orbe do Sabio Perdido","class":"Mago","slot":"weapon","rarity":"Lendario","stats":{"attack":29,"Inteligencia":5},"source_type":"quest","source_id":"biblioteca_ancestral"},
    "quest_cetro_esperanca": {"name":"Bastao da Esperanca","class":"Sacerdote","slot":"weapon","rarity":"Lendario","stats":{"attack":21,"Sorte":5},"source_type":"quest","source_id":"curar_vila"},
    "quest_elmo_vigilante": {"name":"Elmo do Vigilante","class":"Guerreiro","slot":"head","rarity":"Epico","stats":{"defense":19,"Destreza":3},"source_type":"quest","source_id":"patrulha_noturna"},
    "quest_botas_sentinela": {"name":"Botas da Sentinela","class":"Cavaleiro","slot":"feet","rarity":"Epico","stats":{"defense":12,"Destreza":4},"source_type":"quest","source_id":"fronteira_segura"},
    "quest_manto_pesquisador": {"name":"Vestes do Pesquisador","class":"Mago","slot":"chest","rarity":"Epico","stats":{"defense":16,"Inteligencia":4},"source_type":"quest","source_id":"pesquisa_elemental"},
    "quest_capuz_abrigo": {"name":"Capuz do Acolhimento","class":"Sacerdote","slot":"head","rarity":"Epico","stats":{"defense":17,"Constituicao":4},"source_type":"quest","source_id":"abrigo_necessitados"}
}
static var _cache: Dictionary = {}

static func regular_gear() -> Dictionary:
    if not _cache.is_empty():
        return _cache
    for archetype in CLASSES:
        var info: Dictionary = CLASSES[archetype]
        var prefix := str(info["id"])
        for rarity in RARITIES:
            var scale := int(TIER_SCALE[rarity])
            for index in range(3):
                var weapon_id := "%s_weapon_%s_%d" % [prefix,rarity.to_lower(),index+1]
                var weapon_name := str(info["weapons"][index])
                var weapon_focus := str(info["focus"][index])
                _cache[weapon_id] = {"name":"%s %s" % [weapon_name,rarity],"class":archetype,"slot":"weapon","rarity":rarity,"focus":weapon_focus,"set":"","price":scale*95+index*24,"stats":{"attack":5*scale+index*2,weapon_focus:scale+1},"source_type":"forge" if rarity == "Comum" else "merchant","source_id":""}
                for slot in ARMOR_SLOTS:
                    var armor_id := "%s_%s_%s_%d" % [prefix,slot,rarity.to_lower(),index+1]
                    var armor_name := "%s do %s %s" % [SLOT_NAMES[slot],str(info["sets"][index]),rarity]
                    var defense_base := 3 if slot == "head" else 6 if slot == "chest" else 2
                    _cache[armor_id] = {"name":armor_name,"class":archetype,"slot":slot,"rarity":rarity,"focus":weapon_focus,"set":str(info["sets"][index]),"price":(defense_base*18+index*15)*scale,"stats":{"defense":defense_base*scale,weapon_focus:scale+1},"source_type":"forge" if rarity == "Comum" else "merchant","source_id":""}
    return _cache

static func get_item(item_id: String) -> Dictionary:
    if SPECIAL.has(item_id):
        return SPECIAL[item_id]
    return regular_gear().get(item_id,{})

static func is_regular(item_id: String) -> bool:
    return regular_gear().has(item_id)

static func is_special(item_id: String) -> bool:
    return SPECIAL.has(item_id)

static func catalog_count() -> Dictionary:
    return {"regular":regular_gear().size(),"exclusive":SPECIAL.size()}
