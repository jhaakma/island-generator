extends Node2D

@export var island_size: Vector2i = Vector2i(256, 256)
@export var island_renderer: IslandRenderer
@export var island_generator: IslandGenerator

func _ready():
    # Generate the island map data
    var world_map = island_generator.generate_map(island_size)

    # Start the island generation process
    island_renderer.generate_island(world_map, island_generator)

    # Set the debug sprite texture if available
    set_debug_sprite_texture(world_map)



func set_debug_sprite_texture(world_map: WorldMap) -> void:
    var debug_sprite: Sprite2D = get_node("CanvasLayer/DebugSprite")
    if debug_sprite:
        var image: Image = world_map.get_temperature_map()
        var h: Texture2D = ImageTexture.create_from_image(image)
        debug_sprite.texture = h

func _input(event):
    if event.is_action_pressed("ui_accept"):
        print("Regenerating island...")
        var height_map = island_generator.generate_map(island_size)
        island_renderer.generate_island(height_map, island_generator)
        set_debug_sprite_texture(height_map)
