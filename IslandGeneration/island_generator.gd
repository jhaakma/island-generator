extends Node2D
class_name IslandGenerator

## SIGNALS ##
signal island_generated(texture: ImageTexture, collision_polygons: Array[CollisionPolygon2D])

## EXPORTS ##
@export var data_generator: IslandMapGenerator

## GENERATED NODES ##
var sprite: Sprite2D
var collision_polygons: Array[CollisionPolygon2D]

func _ready():
    if data_generator == null:
        data_generator = IslandMapGenerator.new()
    generate_island()

func generate_island():
    var result := data_generator.generate_map()
    var texture: ImageTexture = result["texture"]
    var polygons: Array[PackedVector2Array] = result["polygons"]

    if sprite:
        remove_child(sprite)
        sprite.queue_free()
    sprite = Sprite2D.new()
    sprite.texture = texture
    sprite.centered = false
    add_child(sprite)

    if collision_polygons:
        for polygon in collision_polygons:
            remove_child(polygon)
            polygon.queue_free()
    collision_polygons.clear()

    if polygons.size() > 0:
        for polygon in polygons:
            var collision_polygon := CollisionPolygon2D.new()
            collision_polygon.polygon = polygon
            collision_polygon.position = Vector2.ZERO
            add_child(collision_polygon)
            collision_polygons.append(collision_polygon)
    else:
        print("No collision polygon generated, using null.")

    island_generated.emit(texture, collision_polygons)

func _input(event):
    if event.is_action_pressed("ui_accept"):
        generate_island()

