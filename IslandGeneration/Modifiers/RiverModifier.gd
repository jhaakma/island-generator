extends MapModifier
class_name RiverModifier

@export var river_color: Color = Color(0.2, 0.4, 1.0, 1.0)
@export var max_length: int = 20000
@export var start_search_attempts: int = 100
@export var river_count: int = 10
@export var min_starting_height: float = 0.2

func _height_at(heightmap: Image, pos: Vector2i) -> float:
    return heightmap.get_pixelv(pos).r

func _generate_river(generator: IslandGenerator, image: Image, heightmap: Image) -> void:
    var start_pos := Vector2i.ZERO
    var found := false

    var size := generator.get_island_size()

    for _i in start_search_attempts:
        var x = randi() % size.x
        var y = randi() % size.y
        var h = _height_at(heightmap, Vector2i(x, y))

        if h >= min_starting_height:
            start_pos = Vector2i(x, y)
            found = true
            break
    if not found:
        print("RiverModifier: No valid starting position found after", start_search_attempts, "attempts.")
        return

    var pos := start_pos
    var direction := Vector2(randf() * 2.0 - 1.0, randf() * 2.0 - 1.0).normalized()
    var bend_freq := 0.08 + randf() * 0.08 # Frequency of bends
    var bend_strength := 0.7 + randf() * 0.5 # How strong the bends are

    for i in max_length:
        if pos.x < 0 or pos.x >= size.x or pos.y < 0 or pos.y >= size.y:
            break
        var c := image.get_pixelv(pos)
        if c.a == 0.0:
            break
        image.set_pixelv(pos, river_color)

        # Calculate bend using sine and cosine for smooth curves
        var angle = sin(i * bend_freq) * bend_strength
        var perp = Vector2(-direction.y, direction.x) # Perpendicular vector
        var bend_dir = (direction + perp * angle).normalized()

        # Find the best downhill neighbor in the general bend direction
        var best_neighbor := pos
        var best_height = 999.0
        var best_dot = -1.0
        for dx in range(-1, 2):
            for dy in range(-1, 2):
                if dx == 0 and dy == 0:
                    continue
                var n = pos + Vector2i(dx, dy)
                if n.x < 0 or n.x >= size.x or n.y < 0 or n.y >= size.y:
                    continue
                var h = _height_at(heightmap, n)
                var dir_vec = Vector2(n - pos).normalized()
                var dot = bend_dir.dot(dir_vec)
                # Prefer lower height and direction close to bend_dir
                if h < best_height or (h == best_height and dot > best_dot):
                    best_height = h
                    best_neighbor = n
                    best_dot = dot

        if best_neighbor == pos:
            break

        # Smoothly update direction toward the chosen neighbor
        direction = (direction * 0.7 + Vector2(best_neighbor - pos).normalized() * 0.3).normalized()
        pos = best_neighbor

func apply(generator: IslandGenerator, image: Image, heightmap: Image) -> void:
    for _i in river_count:
        _generate_river(generator, image, heightmap)
