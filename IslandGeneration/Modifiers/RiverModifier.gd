extends MapModifier
class_name RiverModifier

@export var river_color: Color = Color(0.2, 0.4, 1.0, 1.0)
@export var max_length: int = 200
@export var start_search_attempts: int = 100

func _calculate_height(generator: IslandGenerator, noise: FastNoiseLite, noise_detail: FastNoiseLite, pos: Vector2i, center: Vector2i, max_x: int, max_y: int) -> float:
    var h = noise.get_noise_2d(pos.x, pos.y)
    h += noise_detail.get_noise_2d(pos.x, pos.y) * generator.noise_weight_detail
    var dx = abs(pos.x - center.x) / float(max_x) if max_x > 0 else 0
    var dy = abs(pos.y - center.y) / float(max_y) if max_y > 0 else 0
    var nd = max(dx, dy)
    if max_x > 0 and max_y > 0:
        h *= pow(1 - nd, 1 + generator.center_bias)
    h += generator.height_adjustment * 0.01
    if nd > 1.0:
        h = 0
    return h

func apply(generator: IslandGenerator, image: Image) -> void:
    var noise := FastNoiseLite.new()
    noise.noise_type = FastNoiseLite.TYPE_PERLIN
    noise.frequency = 1.0 / generator.noise_scale
    noise.seed = generator.starting_seed

    var noise_detail := FastNoiseLite.new()
    noise_detail.noise_type = FastNoiseLite.TYPE_PERLIN
    noise_detail.frequency = 1.0 / generator.noise_scale_detail
    noise_detail.seed = generator.starting_seed + 1

    var center := generator.island_size / 2
    var max_x = center.x
    var max_y = center.y

    var start_pos := Vector2i.ZERO
    var found := false
    for _i in start_search_attempts:
        var x = randi() % generator.island_size.x
        var y = randi() % generator.island_size.y
        var h = _calculate_height(generator, noise, noise_detail, Vector2i(x, y), center, max_x, max_y)
        if h >= generator.biomes[-1].max_height:
            start_pos = Vector2i(x, y)
            found = true
            break
    if not found:
        return

    var pos := start_pos
    for _i in max_length:
        if pos.x < 0 or pos.x >= generator.island_size.x or pos.y < 0 or pos.y >= generator.island_size.y:
            break
        var c := image.get_pixelv(pos)
        if c.a == 0.0:
            break
        image.set_pixelv(pos, river_color)

        var neighbors = [
            pos + Vector2i(1, 0),
            pos + Vector2i(-1, 0),
            pos + Vector2i(0, 1),
            pos + Vector2i(0, -1)
        ]
        var best_neighbor := pos
        var best_height = 999.0
        for n in neighbors:
            if n.x < 0 or n.x >= generator.island_size.x or n.y < 0 or n.y >= generator.island_size.y:
                continue
            var h = _calculate_height(generator, noise, noise_detail, n, center, max_x, max_y)
            if h < best_height:
                best_height = h
                best_neighbor = n
        if best_neighbor == pos:
            break
        pos = best_neighbor
