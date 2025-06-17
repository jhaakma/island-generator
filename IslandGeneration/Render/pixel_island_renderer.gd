extends IslandRenderer
class_name PixelIslandRenderer

## SIGNALS ##
signal island_generated(texture: ImageTexture, collision_polygons: Array[CollisionPolygon2D])


## GENERATED NODES ##
var sprite: Sprite2D
var collision_polygons: Array[CollisionPolygon2D]


func generate_island(height_map: HeightMap, generator: IslandGenerator):
    var image := height_map.get_image()
    var size := image.get_size()
    var render_image := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
    for y in size.y:
        for x in size.x:
            var biome: Biome = height_map.get_biome(x, y)
            var color = biome.color
            if height_map.has_freshwater(x, y):
                for m in generator.modifiers:
                    if m is RiverModifier:
                        color = m.river_color
                        break
            render_image.set_pixel(x, y, color)
    render_image.generate_mipmaps()
    var texture: ImageTexture = ImageTexture.create_from_image(render_image)

    var bitmap := BitMap.new()
    bitmap.create_from_image_alpha(render_image, 0.5)
    var rect := Rect2i(Vector2i.ZERO, size)
    var polygons := bitmap.opaque_to_polygons(rect)

    if sprite:
        remove_child(sprite)
        sprite.queue_free()
    sprite = Sprite2D.new()
    sprite.texture = texture
    sprite.centered = true
    #Fill viewport
    sprite.scale = Vector2(4.0, 4.0)  # Adjust scale as needed


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
