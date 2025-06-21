extends Node2D

@export var island_size: Vector2i = Vector2i(256, 256)
@export var island_renderer: IslandRenderer
@export var island_generator: IslandGenerator
@export var map_node: MapNode
@export var collision_generator: CollisionGenerator
@export var player: Player


func _ready():
    regenerate()

func find_valid_player_position():
    #Use collision polygons to find a valid position for the player
    var collision_polygons = map_node.collision.get_children()
    if collision_polygons.size() == 0:
        return Vector2.ZERO
    var valid_position: Vector2 = Vector2.ZERO
    var attempts: int = 0

    var island_pixel_size: Vector2i = island_size * Vector2i(map_node.scale)

    # Define a radius to check around the center of the island
    var check_bounds = Rect2(
        #position at center
        Vector2(
            island_pixel_size.x / 2.0,
            island_pixel_size.y / 2.0
        ),
        island_pixel_size * 0.1
    )
    print("Checking bounds: ", check_bounds)

    while attempts < 100:
        var random_x: float = randf_range(check_bounds.position.x, check_bounds.position.x + check_bounds.size.x)
        var random_y: float = randf_range(check_bounds.position.y, check_bounds.position.y + check_bounds.size.y)
        valid_position = Vector2(random_x, random_y)
        print("Attempting position: ", valid_position)

        # Check if the position is valid
        var is_valid: bool = true
        for polygon: CollisionPolygon2D in collision_polygons:
            if Geometry2D.is_point_in_polygon(valid_position / map_node.scale, polygon.polygon):
                is_valid = false
                print("Position is inside a collision polygon, retrying...")
                break

        if is_valid:
            print("Found valid position for player at: ", valid_position)
            return valid_position

        attempts += 1
        check_bounds.position.x += 0.01 * island_pixel_size.x
        check_bounds.position.y += 0.01 * island_pixel_size.y
    print("Failed to find a valid position for the player after 100 attempts.")
    return Vector2.ZERO

func set_debug_sprite_texture(world_map: WorldMap) -> void:
    var debug_sprite: Sprite2D = get_tree().get_first_node_in_group("debug_sprite")
    if debug_sprite:
        var image: Image = world_map.get_height_map()

        var h: Texture2D = ImageTexture.create_from_image(image)
        debug_sprite.texture = h

func regenerate():
    print("Regenerating island...")
    var world_map = island_generator.generate_map(island_size)
    island_renderer.generate_island(world_map, island_generator)
    set_debug_sprite_texture(world_map)


    for child in map_node.collision.get_children():
        map_node.collision.remove_child(child)
        child.queue_free()

    var collision_polygons = collision_generator.generate_collision_polygons(map_node.sprite.texture.get_image())
    for polygon in collision_polygons:
        map_node.collision.add_child(polygon)
    player.position = find_valid_player_position()

func _input(event):
    if event.is_action_pressed("ui_accept"):
        regenerate()
