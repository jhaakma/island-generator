extends Resource
class_name IslandGenerator


## EXPORTS ##
@export var heightmap_generator: HeightmapGenerator
@export var biomes: Array[Biome] =  []
@export var modifiers: Array[MapModifier] = []

func generate_map(island_size) -> HeightMap:
    if heightmap_generator == null:
        push_error("IslandGenerator requires a HeightmapGenerator")
        return null

    var heightmap := heightmap_generator.generate_heightmap(island_size)

    for y in island_size.y:
        for x in island_size.x:
            var height = heightmap.get_height(x, y)
            var biome_index := 0
            for i in biomes.size():
                var biome = biomes[i]
                var next_biome = biomes[i + 1] if i + 1 < biomes.size() else null
                var max_height = next_biome.min_height if next_biome else 1.00
                if height >= biome.min_height and height < max_height:
                    biome_index = i
                    break
            heightmap.set_biome(x, y, biome_index)
            heightmap.set_ocean(x, y, height < 0.0)

    for modifier in modifiers:
        modifier.apply(self, heightmap)

    return heightmap
