extends Node2D

@export var island_size: Vector2i = Vector2i(256, 256)
@export var island_renderer: IslandRenderer
@export var island_generator: IslandGenerator

func _ready():
    island_renderer.generate_island(null, island_generator)




func _input(event):
    if event.is_action_pressed("ui_accept"):
        print("Regenerating island...")
        island_renderer.generate_island(null, island_generator)
