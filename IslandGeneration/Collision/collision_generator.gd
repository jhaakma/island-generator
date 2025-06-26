class_name CollisionGenerator
extends Resource

@export_range(0.1, 10.0) var accuracy: float = 1.0


# Assumes 'land_mask.gdshader' is your custom shader as provided
func create_land_mask(height_map: Image) -> BitMap:
    var land_mask := BitMap.new()
    land_mask.create_from_image_alpha(height_map, 0.9)
    return land_mask


func generate_collision_polygons(map_image: Image)-> Array[CollisionPolygon2D]:
    var size := map_image.get_size()
    map_image.resize(int(size.x * accuracy), int(size.y * accuracy), Image.INTERPOLATE_NEAREST) # Resize to double the size for better accuracy
    print("Generating collision polygons with accuracy: ", accuracy)
    var land_mask: BitMap = create_land_mask(map_image)
    var rect := Rect2i(Vector2i.ZERO, map_image.get_size())
    var epsilon := 0.1
    var polygons := land_mask.opaque_to_polygons(rect, epsilon)

    var collision_polygons: Array[CollisionPolygon2D] = []

    for polygon in polygons:
        # ignore small polygons

        var min_length = INF
        var max_length = 0.0
        var circumference := 0.0

        var scaled_polygon := PackedVector2Array()
        for point in polygon:
            var next_point := polygon[(polygon.find(point) + 1) % polygon.size()]
            var length := point.distance_to(next_point)
            max_length = max(max_length, length)
            min_length = min(min_length, length)
            circumference += length

            scaled_polygon.append(point / accuracy)

        if circumference / polygon.size() <= 1.0:
            print("Skipping polygon with average legnth <= 1.0")
            continue
        var collision_polygon := CollisionPolygon2D.new()
        collision_polygon.polygon = scaled_polygon
        collision_polygon.position = Vector2.ZERO
        collision_polygons.append(collision_polygon)
        #add to map collision group
        collision_polygon.add_to_group("map_collision")
    return collision_polygons
