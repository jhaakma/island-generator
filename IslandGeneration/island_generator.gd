extends Resource
class_name IslandGenerator

## EXPORTS ##
@export var map_generator: WorldMapGenerator
@export var biomes: Array[Biome] =  []
@export var modifiers: Array[MapModifier] = []


var _initialised := false

func init():
    for biome in biomes:
        if not biome:
            push_error("IslandGenerator: Biome is null, skipping registration.")
            continue
        biome.register()
    _initialised = true


func generate_map(island_size, offset: Vector2i = Vector2i.ZERO) -> WorldMap:
    if not _initialised:
        init()

    if map_generator == null:
        push_error("IslandGenerator requires a WorldMapGenerator")
        return null

    var world_map := map_generator.generate_map(island_size, offset)

    # for y in island_size.y:
    #     for x in island_size.x:
    #         var height = world_map.get_height(x, y)
    #         var temp = world_map.get_temperature(x, y)
    #         var this_biome = BiomeRegistry.select_biome(temp, height)
    #         world_map.set_biome(x, y, this_biome)
    #         world_map.set_ocean(x, y, height < 0.0)

    for modifier in modifiers:
        modifier.apply(self, world_map)

    return world_map
