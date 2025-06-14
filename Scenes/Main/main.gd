extends Node2D

@onready var water: Water = $Water
@onready var island_renderer: IslandRenderer = $IslandRenderer


## EXPORTS ##
@export var island_generator: IslandGenerator
@export var island_size: Vector2i = Vector2i(256, 256)

func _ready():
    # Connect the signal to handle island generation
    island_renderer.connect("island_generated", _on_island_generated)

    water.set_size(island_size)
    island_generator.heightmap_generator.island_size = island_size

    # Generate the island map data
    var height_map: = island_generator.generate_map()

    # Start the island generation process
    island_renderer.generate_island(height_map, island_generator)

    # Set the debug sprite texture if available
    set_debug_sprite_texture(height_map)



func set_debug_sprite_texture(height_map) -> void:
    var debug_sprite: Sprite2D = $DebugSprite
    if debug_sprite:
        var image: Image = height_map.get_image()
        var h: Texture2D = ImageTexture.create_from_image(image)
        debug_sprite.texture = h

func _on_island_generated(texture: Texture2D, _collision_polygons: Array[CollisionPolygon2D]) -> void:
    water.update_island_texture(texture)

func _process(delta: float) -> void:
   water.update_water_time(delta)

func _input(event):
    if event.is_action_pressed("ui_accept"):
        print("Regenerating island...")
        var height_map: HeightMap = island_generator.generate_map()
        island_renderer.generate_island(height_map, island_generator)
        set_debug_sprite_texture(height_map)
