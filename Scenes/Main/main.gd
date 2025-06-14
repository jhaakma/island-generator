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
    var map_data: Dictionary = island_generator.generate_map()

    # Start the island generation process
    island_renderer.generate_island(map_data)



func _on_island_generated(texture: Texture2D, _collision_polygons: Array[CollisionPolygon2D]) -> void:
    water.update_island_texture(texture)

func _process(delta: float) -> void:
   water.update_water_time(delta)

func _input(event):
    if event.is_action_pressed("ui_accept"):
        print("Regenerating island...")
        var map_data: Dictionary = island_generator.generate_map()
        island_renderer.generate_island(map_data)
