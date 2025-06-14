extends Node2D
class_name IslandRenderer

## SIGNALS ##
signal island_generated(texture: ImageTexture, collision_polygons: Array[CollisionPolygon2D])


## GENERATED NODES ##
var sprite: Sprite2D
var collision_polygons: Array[CollisionPolygon2D]


func generate_island(map_data):
    var texture: ImageTexture = map_data["texture"]
    var polygons: Array[PackedVector2Array] = map_data["polygons"]

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



