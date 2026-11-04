extends RefCounted
## Sprites pixel art autorais, frames previamente gerados para evitar alocacao por quadro.
const DIRECTIONS := ["down", "up", "left", "right", "down-left", "down-right", "up-left", "up-right"]
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
            # Original pixel-art fabric: collar, shoulders, sash, boots and glints.
            # Generated for 24 cached frames, never inside animation _process.
            var bright := coat.lightened(.24)
            var shadow := coat.darkened(.25)
            _rectangle(img, 8, 13 + bounce, 16, 16 + bounce, shadow)
            _rectangle(img, 9, 16 + bounce, 10, 27 + bounce, bright)
            _rectangle(img, 14, 16 + bounce, 15, 27 + bounce, shadow)
            _rectangle(img, 8, 24 + bounce, 16, 26 + bounce, Color("#a88b57"))
            _rectangle(img, 11, 24 + bounce, 13, 26 + bounce, Color("#d7bc7a"))
            _rectangle(img, 7, 14 + bounce, 9, 18 + bounce, Color("#757b7d"))
            _rectangle(img, 15, 14 + bounce, 17, 18 + bounce, Color("#757b7d"))
            _rectangle(img, 8, 34 + bounce, 11, 36 + bounce, BOOTS.lightened(.15))
            _rectangle(img, 13, 34 + bounce, 16, 36 + bounce, BOOTS.lightened(.15))
            if style_index == 2:
                _rectangle(img, 10, 17 + bounce, 14, 22 + bounce, Color("#8f754c"))
            elif style_index == 3:
                _rectangle(img, 9, 19 + bounce, 16, 20 + bounce, Color("#a7bcc2"))
            if direction == "up":
                _rectangle(img, 8, 7 + bounce, 16, 14 + bounce, HAIR)
            elif direction == "down":
                img.set_pixel(10, 9 + bounce, Color("#2f2929"))
                img.set_pixel(14, 9 + bounce, Color("#2f2929"))
            elif direction == "left" or direction == "down-left" or direction == "up-left":
                img.set_pixel(9, 9 + bounce, Color("#2f2929"))
                _rectangle(img, 14, 9 + bounce, 16, 14 + bounce, HAIR)
            elif direction == "right" or direction == "down-right" or direction == "up-right":
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
    var x_dir := "right" if direction.x > 0 else "left"
    var z_dir := "down" if direction.z > 0 else "up"
    if absf(direction.x) > 0.28 and absf(direction.z) > 0.28:
        return z_dir + "-" + x_dir
    if absf(direction.x) > absf(direction.z):
        return x_dir
    return z_dir
