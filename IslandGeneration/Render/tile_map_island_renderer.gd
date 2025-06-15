extends IslandRenderer
class_name TileMapIslandRenderer

signal island_generated

@export var terrain_set: int = 0
@export var ocean_terrain: int = 0
@export var land_terrain: int = 1

@export var tile_map_layer: TileMapLayer


func generate_island(height_map: HeightMap, generator: IslandGenerator) -> void:
    if height_map == null or generator == null:
        push_error("TileMapIslandRenderer requires valid HeightMap and IslandGenerator")
        return
    tile_map_layer.clear()
    var size: Vector2i = generator.get_island_size()
    var ocean_cells: Array[Vector2i] = []
    var land_cells: Array[Vector2i] = []
    for y in size.y:
        for x in size.x:
            var pos := Vector2i(x, y)
            if height_map.is_ocean(x, y):
                ocean_cells.append(pos)
            else:
                land_cells.append(pos)
    if ocean_cells.size() > 0:
        print("Setting ocean terrain for", ocean_cells.size(), "cells")
        tile_map_layer.set_cells_terrain_connect(ocean_cells, terrain_set, ocean_terrain)
    if land_cells.size() > 0:
        print("Setting land terrain for", land_cells.size(), "cells")
        tile_map_layer.set_cells_terrain_connect(land_cells, terrain_set, land_terrain)
    island_generated.emit()
