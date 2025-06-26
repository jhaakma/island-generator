extends IslandRenderer
class_name PixelIslandRenderer

## SIGNALS ##
signal island_generated(texture: ImageTexture, collision_polygons: Array[CollisionPolygon2D])


## GENERATED NODES ##
@export var sprite: Sprite2D


func generate_island(world_map: WorldMap, generator: IslandGenerator):
    var image := world_map.get_height_map()
    var size := image.get_size()
    var render_image := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
    for y in size.y:
        for x in size.x:
            var biome: Biome = world_map.get_biome(x, y)
            var color = biome.color
            if world_map.has_freshwater(x, y):
                for m in generator.modifiers:
                    if m is RiverModifier:
                        color = m.river_color
                        break
            render_image.set_pixel(x, y, color)
    render_image.generate_mipmaps()
    var texture: ImageTexture = ImageTexture.create_from_image(render_image)

    sprite.texture = texture

    island_generated.emit(texture)
