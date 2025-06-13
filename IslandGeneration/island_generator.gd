extends Resource
class_name IslandGenerator

## EXPORTS ##
@export var island_size: Vector2i = Vector2i(256, 256)
@export var noise_scale: float = 32.0
@export var noise_scale_detail: float = 8.0
@export var noise_weight_detail: float = 0.25
@export var starting_seed: int = 42
@export var land_heights: LandHeights
@export var center_bias: float = 3.0
@export var height_adjustment: float = 0.0

func generate_map() -> Dictionary:
    var seed = starting_seed
    if starting_seed == -1:
        seed = randi() % 1000000

    var noise := FastNoiseLite.new()
    noise.noise_type = FastNoiseLite.TYPE_PERLIN
    noise.frequency = 1.0 / noise_scale
    noise.seed = seed

    var noise_detail := FastNoiseLite.new()
    noise_detail.noise_type = FastNoiseLite.TYPE_PERLIN
    noise_detail.frequency = 1.0 / noise_scale_detail
    noise_detail.seed = seed + 1

    var img := Image.create(island_size.x, island_size.y, false, Image.FORMAT_RGBA8)
    var center := island_size / 2
    var max_x = center.x
    var max_y = center.y

    for y in island_size.y:
        for x in island_size.x:
            var pos = Vector2i(x, y)
            var dx = abs(pos.x - center.x) / float(max_x) if max_x > 0 else 0
            var dy = abs(pos.y - center.y) / float(max_y) if max_y > 0 else 0
            var normalized_dist = max(dx, dy) # Rectangle falloff

            var base_height = noise.get_noise_2d(x, y)
            var detail_height = noise_detail.get_noise_2d(x, y)
            var height = base_height + (detail_height * noise_weight_detail)
            if max_x > 0 and max_y > 0:
                height *= pow(1 - normalized_dist, 1 + center_bias)
            height += height_adjustment * 0.01
            if normalized_dist > 1.0:
                height = 0

            var color: Color
            if height < land_heights.sand:
                color = Color(0.0, 0.0, 0.0, 0.0)
            elif height < land_heights.grass:
                color = Color(0.95, 0.89, 0.55, 1.0)
            elif height < land_heights.forest:
                color = Color(0.35, 0.65, 0.25, 1.0)
            else:
                color = Color(0.15, 0.35, 0.13, 1.0)
            img.set_pixel(x, y, color)

    img.generate_mipmaps()
    var texture := ImageTexture.create_from_image(img)

    var bitmap := BitMap.new()
    bitmap.create_from_image_alpha(img, 0.5)
    var rect := Rect2i(Vector2i.ZERO, island_size)
    var polygons := bitmap.opaque_to_polygons(rect)

    return {
        "texture": texture,
        "image": img,
        "polygons": polygons
    }
