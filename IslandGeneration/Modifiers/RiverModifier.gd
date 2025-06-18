extends MapModifier
class_name RiverModifier

@export var river_color: Color = Color(0.2, 0.4, 1.0, 1.0)
@export var min_length: int = 2
@export var max_length: int = 100
@export var start_search_attempts: int = 100
@export var river_count: int = 10
@export var min_starting_height: float = 0.15
@export var meander_chance: float = 0.30 # Chance to meander at each step
@export var max_temperature: float = 0.5

# Cache world_map as a 2D array for fast lookup
func _cache_heightmap(world_map: WorldMap, size: Vector2i) -> Array:
    var heights := []
    for x in size.x:
        heights.append([])
        for y in size.y:
            heights[x].append(world_map.get_height(x, y))
    return heights

# Use a 2D array for the flow field for faster access
func _compute_flow_field(heights: Array, size: Vector2i) -> Array:
    var flow_field := []
    for x in size.x:
        flow_field.append([])
        for y in size.y:
            var pos = Vector2i(x, y)
            var lowest = pos
            var min_h = heights[x][y]
            for dx in range(-1, 2):
                for dy in range(-1, 2):
                    if dx == 0 and dy == 0:
                        continue
                    var nx = x + dx
                    var ny = y + dy
                    if nx < 0 or nx >= size.x or ny < 0 or ny >= size.y:
                        continue
                    var h = heights[nx][ny]
                    if h < min_h:
                        min_h = h
                        lowest = Vector2i(nx, ny)
            flow_field[x].append(lowest)
    return flow_field

func _generate_river(_generator: IslandGenerator, world_map: WorldMap, heights: Array, flow_field: Array, visited: Array) -> void:
    var size := world_map.get_size()
    var start_pos := Vector2i.ZERO
    var found := false

    for _i in start_search_attempts:
        var x = randi() % size.x
        var y = randi() % size.y
        var h = heights[x][y]

        var height_ok = h >= min_starting_height
        var temp_ok = world_map.get_temperature(x, y) <= max_temperature
        if height_ok and temp_ok and not visited[x][y]:
            start_pos = Vector2i(x, y)
            found = true
            break
    if not found:
        print("RiverModifier: No valid starting position found after", start_search_attempts, "attempts.")
        return

    var pos := start_pos
    var river_length = 0
    for i in max_length:
        if pos.x < 0 or pos.x >= size.x or pos.y < 0 or pos.y >= size.y:
            print("RiverModifier: Out of bounds at position", pos, "after", i, "steps.")
            break
        if visited[pos.x][pos.y]:
            print("RiverModifier: Already visited position", pos, "after", i, "steps.")
            break
        if heights[pos.x][pos.y] < 0.0:
            print("RiverModifier: Reached negative height at position", pos, "after", i, "steps.")
            break

        visited[pos.x][pos.y] = true
        river_length += 1

        var next = flow_field[pos.x][pos.y]
        # Only check for meander if the chance triggers
        if randf() < meander_chance:
            var downhill_neighbors = []
            var min_h = heights[pos.x][pos.y]
            for dx in range(-1, 2):
                for dy in range(-1, 2):
                    if dx == 0 and dy == 0:
                        continue
                    var nx = pos.x + dx
                    var ny = pos.y + dy
                    if nx < 0 or nx >= size.x or ny < 0 or ny >= size.y:
                        continue
                    var h = heights[nx][ny]
                    if h < min_h:
                        downhill_neighbors.append(Vector2i(nx, ny))
            if downhill_neighbors.size() > 0:
                next = downhill_neighbors[randi() % downhill_neighbors.size()]
        if next == pos:
            print("RiverModifier: Next position is the same as current position", pos, "after", i, "steps.")
            break
        pos = next
        if i >= max_length - 1:
            print("RiverModifier: Reached maximum length of river at position", pos, "after", i + 1, "steps.")
            break


    # set freshwater for each visiteed, if there's more than 1
    if river_length >= min_length:
        for x in size.x:
            for y in size.y:
                if visited[x][y]:
                    world_map.set_freshwater(x, y, true)
    else:
        print("RiverModifier: River too short, not setting freshwater.")



func apply(generator: IslandGenerator, world_map: WorldMap) -> void:
    var size := world_map.get_size()
    var heights = _cache_heightmap(world_map, size)
    var flow_field = _compute_flow_field(heights, size)
    # Track visited cells to avoid overlapping rivers
    var visited := []
    for x in size.x:
        visited.append([])
        for y in size.y:
            visited[x].append(false)
    for _i in river_count:
        _generate_river(generator, world_map, heights, flow_field, visited)
