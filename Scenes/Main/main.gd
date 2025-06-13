extends Node2D

@onready var water: Water = $Water
@onready var island_renderer: IslandRenderer = $IslandRenderer

func _ready():
    # Connect the signal to handle island generation
    island_renderer.connect("island_generated", _on_island_generated)

    # Start the island generation process
    island_renderer.generate_island()

    water.water_size = island_renderer.data_generator.island_size

func _on_island_generated(texture: Texture2D, _collision_polygons: Array[CollisionPolygon2D]) -> void:
    water.update_island_texture(texture)

func _process(delta: float) -> void:
   water.update_water_time(delta)
