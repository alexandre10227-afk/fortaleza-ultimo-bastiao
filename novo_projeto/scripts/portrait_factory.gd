extends RefCounted
## Retratos pixel-art originais e reutilizados. Nenhum asset de outros jogos.
static var _cache: Dictionary = {}
const SKINS := [Color("#e2ac84"), Color("#c78b67"), Color("#f0c6a2"), Color("#a97255")]
const HAIR := [Color("#2b2424"), Color("#543c2c"), Color("#7e5e3f"), Color("#302f42")]
const COATS := [Color("#49607a"), Color("#66754b"), Color("#854f41"), Color("#6a5377"), Color("#80714a")]

static func portrait(npc_id: String, profession: String = "") -> Texture2D:
    var key := npc_id + "|" + profession
    if _cache.has(key):
        return _cache[key]
    var img := Image.create(72, 80, false, Image.FORMAT_RGBA8)
    img.fill(Color("#261f1b"))
    var seed_value: int = absi(hash(key))
    var skin: Color = SKINS[seed_value % SKINS.size()]
    var hair: Color = HAIR[(seed_value / 3) % HAIR.size()]
    var coat: Color = COATS[(seed_value / 7) % COATS.size()]
    var trim: Color = Color("#ceaf6a")
    # Decorative frame and backdrop, no texture allocations during playback.
    _rect(img, 2, 2, 70, 78, Color("#ae8850"))
    _rect(img, 5, 5, 67, 75, Color("#342b2a"))
    _rect(img, 8, 8, 64, 73, Color("#584a3a"))
    # Torso, shoulders, neck, face, sideburns and hair.
    _rect(img, 10, 59, 62, 75, coat.darkened(0.23))
    _rect(img, 16, 49, 56, 72, coat)
    _rect(img, 28, 47, 44, 57, skin.darkened(0.09))
    _rect(img, 21, 17, 51, 52, skin)
    _rect(img, 18, 13, 54, 28, hair)
    _rect(img, 19, 19, 25, 44, hair)
    _rect(img, 47, 19, 53, 43, hair)
    _rect(img, 27, 14, 46, 21, hair)
    # Eyes and brows, varying shape per character.
    _rect(img, 26, 34, 32, 36, Color("#362a26"))
    _rect(img, 40, 34, 46, 36, Color("#362a26"))
    _rect(img, 27, 31, 32, 33, hair.darkened(0.2))
    _rect(img, 40, 31, 45, 33, hair.darkened(0.2))
    _rect(img, 34, 43, 39, 44, skin.darkened(0.2))
    _rect(img, 32, 48, 41, 49, Color("#a46759"))
    # Coat highlights and occupation mark.
    _rect(img, 20, 58, 24, 69, trim)
    _rect(img, 48, 58, 52, 69, trim)
    if profession in ["Ferreiro", "Agricultor", "Mercador", "Feirante"]:
        _rect(img, 28, 59, 45, 75, Color("#7c6448"))
        _rect(img, 30, 62, 43, 64, Color("#bc9763"))
    elif profession in ["Soldado", "Mercenaria", "General", "Batedor"]:
        _rect(img, 15, 55, 24, 63, Color("#a7a5a4"))
        _rect(img, 48, 55, 57, 63, Color("#a7a5a4"))
    elif profession in ["Nobre", "Monarca"]:
        _rect(img, 20, 13, 52, 17, trim)
        for x in [23, 35, 48]:
            _rect(img, x, 8, x+4, 15, trim)
    elif profession in ["Curandeira", "Sacerdote"]:
        _rect(img, 33, 57, 39, 70, Color("#e8d6b2"))
        _rect(img, 29, 62, 43, 66, Color("#e8d6b2"))
    var texture := ImageTexture.create_from_image(img)
    _cache[key] = texture
    return texture

static func _rect(img: Image, left: int, top: int, right: int, bottom: int, paint: Color) -> void:
    for y in range(maxi(0, top), mini(bottom, img.get_height())):
        for x in range(maxi(0, left), mini(right, img.get_width())):
            img.set_pixel(x, y, paint)
