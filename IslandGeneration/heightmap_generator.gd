extends Resource
class_name HeightmapGenerator

@export var island_size: Vector2i = Vector2i(256, 256)
@export var noise_scale: float = 32.0
@export var noise_scale_detail: float = 8.0
@export var noise_weight_detail: float = 0.25
@export var starting_seed: int = -1
@export var center_bias: float = 3.0
@export var height_adjustment: float = 0.0
@export var height_multiplier: float = 1.0

func generate_heightmap() -> HeightMap:
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

    var height_map := HeightMap.new(img)

    var min_h = INF
    var max_h = -INF
    var heights = []

    # First pass: calculate raw heights and track min/max
    for y in island_size.y:
        heights.append([])
        for x in island_size.x:
            var pos = Vector2i(x, y)
            var dx = abs(pos.x - center.x) / float(max_x) if max_x > 0 else 0
            var dy = abs(pos.y - center.y) / float(max_y) if max_y > 0 else 0
            var nd = max(dx, dy)

            var h = noise.get_noise_2d(x, y)
            h += noise_detail.get_noise_2d(x, y) * noise_weight_detail

            heights[y].append({
                "h": h,
                "nd": nd
            })
            min_h = min(min_h, h)
            max_h = max(max_h, h)

    # Second pass: remap and apply island mask for smooth transition to -1.0 at edges
    for y in island_size.y:
        for x in island_size.x:
            var h = heights[y][x]["h"]
            var nd = heights[y][x]["nd"]
            if max_h != min_h:
                h = remap(h, min_h, max_h, -1.0, 1.0)
            else:
                h = 0.0
            # Apply island mask: smoothly blend to -1.0 at edges using center_bias
            var mask = pow(1.0 - clamp(nd, 0.0, 1.0), 1.0 + center_bias)
            h = lerp(-1.0, h, mask)
            h += height_adjustment * 0.1
            h *= height_multiplier
            h = clamp(h, -0.999, 0.909)

            height_map.set_height(x, y, h)
    return height_map
