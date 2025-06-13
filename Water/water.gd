extends Node2D
class_name Water

@export var water_color: Color = Color(0.15, 0.35, 0.85, 1.0)
@export var water_size: Vector2 = Vector2(512, 512)

@onready var rect: = $Rect

func _ready():
    # Set the color and size of the water
    rect.size = water_size
    rect.material.set_shader_parameter("water_color", water_color)
    rect.material.set_shader_parameter("water_size", water_size)

func set_size(size: Vector2):
    water_size = size
    if rect:
        rect.size = size

func update_water_time(delta: float):
    var time = rect.material.get_shader_parameter("time")
    rect.material.set_shader_parameter("time", time + delta)

func update_island_texture(texture: Texture2D):
    rect.material.set_shader_parameter("island_mask", texture)
