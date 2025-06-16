extends Resource
class_name HeightmapGenerator

@export var starting_seed: int = -1
@export var center_bias: float = 3.0
@export var height_adjustment: float = 0.0
@export var height_multiplier: float = 1.0
@export var noise_passes: Array[NoisePass] = []

func generate_heightmap(size: Vector2i) -> HeightMap:

    var _seed = starting_seed
    if starting_seed == -1:
        _seed = randi() % 1000000

    for noise_pass in noise_passes:
        noise_pass.init(_seed)
    var img := Image.create(size.x, size.y, false, Image.FORMAT_RGBAF)
    var center := size / 2
    var max_x = center.x
    var max_y = center.y

    var height_map := HeightMap.new(img)

    var min_h = INF
    var max_h = -INF
    var heights = []

    # First pass: calculate raw heights and track min/max
    for y in size.y:
        heights.append([])
        for x in size.x:
            var pos = Vector2i(x, y)
            var dx = abs(pos.x - center.x) / float(max_x) if max_x > 0 else 0
            var dy = abs(pos.y - center.y) / float(max_y) if max_y > 0 else 0
            var nd = max(dx, dy)

            var h = 0.0
            for noise_pass in noise_passes:
                h += noise_pass.get_noise(x, y)

            heights[y].append({
                "h": h,
                "nd": nd
            })
            min_h = min(min_h, h)
            max_h = max(max_h, h)

    # Second pass: remap and apply island mask for smooth transition to -1.0 at edges
    for y in size.y:
        for x in size.x:
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
            h = clamp(h, -0.999, 0.999)

            height_map.set_height(x, y, h)
            height_map.set_biome(x, y, 0)
            height_map.set_freshwater(x, y, false)
            height_map.set_ocean(x, y, h < 0.0)
    return height_map
