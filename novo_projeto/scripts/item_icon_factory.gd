extends RefCounted
## Icones procedurais em pixel art. Todos os itens da mesma categoria reutilizam a textura.
static var _cache: Dictionary = {}
const BG := Color("#312720")
const BRONZE := Color("#b99a62")
static func icon_for(category: String) -> Texture2D:
    if _cache.has(category):
        return _cache[category]
    var img := Image.create(36, 36, false, Image.FORMAT_RGBA8)
    img.fill(BG)
    _rect(img, 1, 1, 35, 35, BRONZE)
    _rect(img, 3, 3, 33, 33, Color("#49362a"))
    match category:
        "Arte":
            _rect(img, 12, 8, 24, 12, Color("#d6b686"))
            _rect(img, 9, 13, 27, 28, Color("#8b774e"))
            _rect(img, 13, 16, 23, 25, Color("#d9b85f"))
            _rect(img, 9, 28, 27, 31, BRONZE)
        "Comestiveis":
            _ellipse(img, Vector2(18, 21), 9, Color("#c46d4b"))
            _rect(img, 17, 10, 20, 16, Color("#6b8542"))
            _rect(img, 19, 9, 24, 12, Color("#7d9850"))
        "Estudos":
            _rect(img, 8, 9, 27, 29, Color("#dfd0a3"))
            _rect(img, 9, 10, 12, 28, Color("#97754e"))
            for y in [14, 19, 24]:
                _rect(img, 15, y, 25, y + 1, Color("#725642"))
        "Minerios":
            _triangle(img, Vector2(18, 7), Vector2(29, 20), Vector2(17, 31), Color("#78b6c3"))
            _triangle(img, Vector2(18, 7), Vector2(17, 31), Vector2(8, 21), Color("#477d9b"))
            _rect(img, 17, 12, 20, 24, Color("#c4d4c9"))
        "Armas":
            _triangle(img, Vector2(28, 6), Vector2(16, 20), Vector2(21, 24), Color("#d9d2b9"))
            _rect(img, 10, 22, 21, 25, Color("#c5a96b"))
            _rect(img, 6, 27, 13, 30, Color("#654638"))
        _:
            _ellipse(img, Vector2(18, 18), 8, BRONZE)
    var texture := ImageTexture.create_from_image(img)
    _cache[category] = texture
    return texture

static func _rect(img: Image, l: int, t: int, r: int, b: int, c: Color) -> void:
    for y in range(maxi(0,t), mini(img.get_height(),b)):
        for x in range(maxi(0,l), mini(img.get_width(),r)):
            img.set_pixel(x,y,c)

static func _ellipse(img: Image, center: Vector2, radius: float, c: Color) -> void:
    for y in range(5, 32):
        for x in range(5, 32):
            if Vector2(x,y).distance_to(center) <= radius:
                img.set_pixel(x,y,c)

static func _triangle(img: Image, a: Vector2, b: Vector2, c: Vector2, paint: Color) -> void:
    for y in range(5,32):
        for x in range(5,32):
            var p := Vector2(x,y)
            var area := (b.x-a.x)*(c.y-a.y)-(b.y-a.y)*(c.x-a.x)
            if is_zero_approx(area):
                continue
            var e1 := ((b.x-a.x)*(p.y-a.y)-(b.y-a.y)*(p.x-a.x))/area
            var e2 := ((c.x-b.x)*(p.y-b.y)-(c.y-b.y)*(p.x-b.x))/area
            var e3 := ((a.x-c.x)*(p.y-c.y)-(a.y-c.y)*(p.x-c.x))/area
            if e1 >= 0 and e2 >= 0 and e3 >= 0:
                img.set_pixel(x,y,paint)
