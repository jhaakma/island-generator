extends Resource
class_name IslandGenerator

## EXPORTS ##
@export var heightmap_generator: HeightmapGenerator
@export var biomes: Array[Biome] = []
@export var modifiers: Array[MapModifier] = []

func get_island_size() -> Vector2i:
    return heightmap_generator.island_size

func generate_map() -> Dictionary:
    if heightmap_generator == null:
        push_error("IslandGenerator requires a HeightmapGenerator")
        return {}

    var heightmap := heightmap_generator.generate_heightmap()
    var size := heightmap_generator.island_size

    var img := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)

    for y in size.y:
        for x in size.x:
            var height = heightmap.get_pixel(x, y).r

            var color: Color = Color(0.0, 0.0, 0.0, 0.0)
            for i in biomes.size():
                var biome = biomes[i]
                var next_biome = biomes[i + 1] if i + 1 < biomes.size() else null
                var max_height = next_biome.min_height if next_biome else 1.00
                if height >= biome.min_height and height < max_height:
                    color = biome.color
                    break
            img.set_pixel(x, y, color)

    for modifier in modifiers:
        modifier.apply(self, img, heightmap)

    img.generate_mipmaps()
    var texture := ImageTexture.create_from_image(img)

    var bitmap := BitMap.new()
    bitmap.create_from_image_alpha(img, 0.5)
    var rect := Rect2i(Vector2i.ZERO, size)
    var polygons := bitmap.opaque_to_polygons(rect)

    return {
        "texture": texture,
        "image": img,
        "heightmap": heightmap,
        "polygons": polygons
    }
