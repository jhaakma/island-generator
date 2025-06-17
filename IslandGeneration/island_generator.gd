extends Resource
class_name IslandGenerator

## EXPORTS ##
@export var heightmap_generator: HeightmapGenerator
@export var biomes: Array[Biome] =  []
@export var modifiers: Array[MapModifier] = []

var ocean_biome = preload("uid://dcy0deb03fpni")

var _initialised := false

func init():
    for biome in biomes:
        if not biome:
            push_error("IslandGenerator: Biome is null, skipping registration.")
            continue
        biome.register()
    _initialised = true


func generate_map(island_size) -> HeightMap:
    if not _initialised:
        init()

    if heightmap_generator == null:
        push_error("IslandGenerator requires a HeightmapGenerator")
        return null

    var heightmap := heightmap_generator.generate_heightmap(island_size)

    for y in island_size.y:
        for x in island_size.x:
            var height = heightmap.get_height(x, y)
            var this_biome = null

            #Sort biomes by min_height
            biomes.sort_custom(func(a, b):
                return a.min_height < b.min_height)

            for i in biomes.size():
                var biome = biomes[i]
                var next_biome = biomes[i + 1] if i + 1 < biomes.size() else null
                var max_height = next_biome.min_height if next_biome else 1.00
                if height >= biome.min_height and height < max_height:
                    this_biome = biome
                    break

            if this_biome == null:
                this_biome = BiomeRegistry.get_biome_by_id('ocean')

            heightmap.set_biome(x, y, this_biome)
            heightmap.set_ocean(x, y, height < 0.0)

    for modifier in modifiers:
        modifier.apply(self, heightmap)

    return heightmap
