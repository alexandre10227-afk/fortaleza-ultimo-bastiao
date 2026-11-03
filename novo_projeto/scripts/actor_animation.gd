extends RefCounted
## Sprites pixel art autorais, frames previamente gerados para evitar alocacao por quadro.
const DIRECTIONS := ["down", "up", "left", "right"]
const COATS := [Color("#3d597e"), Color("#755347"), Color("#5b7550"), Color("#4a5b6b")]
const HAIR := Color("#352a25")
const SKIN := Color("#dfae8a")
const BOOTS := Color("#352f33")

static func make_frames(style_index: int = 0) -> Dictionary:
    var frames: Dictionary = {}
    for direction in DIRECTIONS:
        for step in range(3):
            var img := Image.create(24, 40, false, Image.FORMAT_RGBA8)
            img.fill(Color.TRANSPARENT)
            var coat: Color = COATS[clampi(style_index, 0, COATS.size() - 1)]
            var bounce := 1 if step == 1 else 0
            _rectangle(img, 8, 13 + bounce, 16, 28 + bounce, coat)
            _rectangle(img, 9, 4 + bounce, 15, 14 + bounce, SKIN)
            _rectangle(img, 8, 2 + bounce, 16, 7 + bounce, HAIR)
            _rectangle(img, 8, 28 + bounce, 11, 36 + (1 if step == 2 else 0), BOOTS)
            _rectangle(img, 13, 28 + bounce, 16, 36 + (1 if step == 1 else 0), BOOTS)
            var swing := -2 if step == 1 else 2 if step == 2 else 0
            _rectangle(img, 5 + swing, 16 + bounce, 8 + swing, 26 + bounce, SKIN)
            _rectangle(img, 16 - swing, 16 + bounce, 19 - swing, 26 + bounce, SKIN)
            if direction == "up":
                _rectangle(img, 8, 7 + bounce, 16, 14 + bounce, HAIR)
            elif direction == "down":
                img.set_pixel(10, 9 + bounce, Color("#2f2929"))
                img.set_pixel(14, 9 + bounce, Color("#2f2929"))
            elif direction == "left":
                img.set_pixel(9, 9 + bounce, Color("#2f2929"))
                _rectangle(img, 14, 9 + bounce, 16, 14 + bounce, HAIR)
            elif direction == "right":
                img.set_pixel(15, 9 + bounce, Color("#2f2929"))
                _rectangle(img, 8, 9 + bounce, 10, 14 + bounce, HAIR)
            frames["%s:%d" % [direction, step]] = ImageTexture.create_from_image(img)
    return frames

static func _rectangle(img: Image, x1: int, y1: int, x2: int, y2: int, color: Color) -> void:
    for y in range(maxi(0, y1), mini(40, y2)):
        for x in range(maxi(0, x1), mini(24, x2)):
            img.set_pixel(x, y, color)

static func direction_from_vector(direction: Vector3, last_direction: String) -> String:
    if direction.length_squared() < 0.001:
        return last_direction
    if absf(direction.x) > absf(direction.z):
        return "right" if direction.x > 0 else "left"
    return "down" if direction.z > 0 else "up"
