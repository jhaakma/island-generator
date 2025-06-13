extends Resource
class_name HeightmapGenerator

@export var island_size: Vector2i = Vector2i(256, 256)
@export var noise_scale: float = 32.0
@export var noise_scale_detail: float = 8.0
@export var noise_weight_detail: float = 0.25
@export var starting_seed: int = 42
@export var center_bias: float = 3.0
@export var height_adjustment: float = 0.0

func generate_heightmap() -> Image:
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

    var img := Image.create(island_size.x, island_size.y, false, Image.FORMAT_RF)
    var center := island_size / 2
    var max_x = center.x
    var max_y = center.y

    for y in island_size.y:
        for x in island_size.x:
            var pos = Vector2i(x, y)
            var dx = abs(pos.x - center.x) / float(max_x) if max_x > 0 else 0
            var dy = abs(pos.y - center.y) / float(max_y) if max_y > 0 else 0
            var nd = max(dx, dy)

            var h = noise.get_noise_2d(x, y)
            h += noise_detail.get_noise_2d(x, y) * noise_weight_detail
            if max_x > 0 and max_y > 0:
                h *= pow(1 - nd, 1 + center_bias)
            h += height_adjustment * 0.01
            if nd > 1.0:
                h = 0.0
            h = max(h, 0.0)
            img.set_pixel(x, y, Color(h, 0, 0, 1))
    return img
