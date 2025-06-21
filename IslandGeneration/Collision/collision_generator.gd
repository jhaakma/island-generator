class_name CollisionGenerator
extends Resource

@export_range(0.1, 10.0) var accuracy: float = 1.0


# Assumes 'land_mask.gdshader' is your custom shader as provided
func create_land_mask(height_map: Image) -> BitMap:
    var land_mask := BitMap.new()
    land_mask.create_from_image_alpha(height_map, 0.9)
    return land_mask


func generate_collision_polygons(map_image: Image)-> Array[CollisionPolygon2D]:

    var land_mask: BitMap = create_land_mask(map_image)
    var rect := Rect2i(Vector2i.ZERO, map_image.get_size())
    var epsilon := 1.0 / accuracy
    var polygons := land_mask.opaque_to_polygons(rect, epsilon)

    var collision_polygons: Array[CollisionPolygon2D] = []

    for polygon in polygons:
        var collision_polygon := CollisionPolygon2D.new()
        collision_polygon.polygon = polygon
        collision_polygon.position = Vector2.ZERO
        collision_polygons.append(collision_polygon)
        #add to map collision group
        collision_polygon.add_to_group("map_collision")
    return collision_polygons
