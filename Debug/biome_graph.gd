extends Control
class_name BiomeGraph

@export var biomes: Array[Biome] = []
@export var graph_size: Vector2 = Vector2(200, 200)
@export var margin: float = 20.0
@export var axis_color: Color = Color.WHITE
@export var circle_radius: float = 6.0

func _ready() -> void:
    update()

func _draw() -> void:
    var origin: Vector2 = Vector2(margin, graph_size.y + margin)
    draw_line(origin, origin + Vector2(graph_size.x, 0), axis_color)
    draw_line(origin, origin - Vector2(0, graph_size.y), axis_color)
    for biome in biomes:
        if biome == null:
            continue
        var x: float = remap(biome.min_height, -1.0, 1.0, 0.0, graph_size.x)
        var avg_temp: float = (biome.min_temperature + biome.max_temperature) / 2.0
        var y: float = remap(avg_temp, 0.0, 1.0, graph_size.y, 0.0)
        var pos: Vector2 = origin + Vector2(x, -y)
        draw_circle(pos, circle_radius, biome.color)
