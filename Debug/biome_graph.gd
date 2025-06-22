@tool
extends Control
class_name BiomeGraph

@export var biomes: Array[Biome] = []:
    set(value):
        biomes = value
        queue_redraw()

@export var graph_size: Vector2 = Vector2(200, 200):
    set(value):
        graph_size = value
        queue_redraw()

@export_range(0.0, 50.0) var margin: float = 20.0:
    set(value):
        margin = value
        queue_redraw()

@export var axis_color: Color = Color.WHITE:
    set(value):
        axis_color = value
        queue_redraw()


func _ready() -> void:


    queue_redraw()

func _draw() -> void:
    #Sort biomes by min_height
    biomes.sort_custom(func(a, b):
        return a.min_height < b.min_height)

    var origin: Vector2 = Vector2(margin, graph_size.y + margin)
    draw_line(origin, origin + Vector2(graph_size.x, 0), axis_color)
    draw_line(origin, origin - Vector2(0, graph_size.y), axis_color)
    for i in range(biomes.size()):
        var biome = biomes[i]
        if biome == null:
            continue
        var min_height = biome.min_height
        var max_height = 1.0
        # Map biome height and temperature ranges to graph coordinates
        var y0: float = remap(min_height, -1.0, 1.0, 0.0, graph_size.x)
        var y1: float = remap(max_height, -1.0, 1.0, 0.0, graph_size.x)
        var x0: float = remap(biome.max_temperature, 1.0, 0.0, graph_size.y, 0.0)
        var x1: float = remap(biome.min_temperature, 1.0, 0.0, graph_size.y, 0.0)
        var rect_pos: Vector2 = origin + Vector2(x0, -y1)
        var rect_size: Vector2 = Vector2(x1 - x0, y1 - y0)
        draw_rect(Rect2(rect_pos, rect_size), biome.color, true)