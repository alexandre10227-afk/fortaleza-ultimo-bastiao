extends RefCounted
## Tiling pixel textures. Original procedural art, generated once per material.
static var _textures: Dictionary = {}
const PIXEL_SIZE := 32

static func texture_for(kind: String) -> Texture2D:
    if _textures.has(kind):
        return _textures[kind]
    var img := Image.create(PIXEL_SIZE, PIXEL_SIZE, false, Image.FORMAT_RGB8)
    var base := Color("#c8b9a1") if kind == "stone" else Color("#ad7b4f") if kind == "wood" else Color("#718653") if kind == "grass" else Color("#9c8772")
    for y in range(PIXEL_SIZE):
        for x in range(PIXEL_SIZE):
            var grain: float = float((x * 17 + y * 31 + x * y * 7) % 23) / 190.0
            var tone := base.lightened(grain) if (x + y) % 3 == 0 else base.darkened(grain * 0.75)
            if kind == "stone":
                var stagger := (y / 8) % 2 * 8
                if y % 8 == 0 or ((x + stagger) % 16) == 0:
                    tone = base.darkened(0.35)
            elif kind == "wood":
                if x % 7 == 0:
                    tone = base.darkened(0.31)
                elif (y + x * 3) % 19 == 0:
                    tone = base.lightened(0.17)
            elif kind == "grass":
                if (x * 5 + y * 3) % 23 == 0:
                    tone = Color("#9da56b")
            elif kind == "road":
                if (x * 7 + y * 11) % 17 == 0:
                    tone = Color("#7e7769")
            img.set_pixel(x, y, tone)
    var result := ImageTexture.create_from_image(img)
    _textures[kind] = result
    return result

static func material_for(kind: String, tint: Color) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_texture = texture_for(kind)
    mat.albedo_color = tint
    mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
    mat.texture_repeat = BaseMaterial3D.TEXTURE_REPEAT_ENABLED
    mat.uv1_scale = Vector3(2.4, 2.4, 1)
    mat.roughness = 0.92
    return mat
