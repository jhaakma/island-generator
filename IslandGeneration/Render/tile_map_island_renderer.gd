extends IslandRenderer
class_name TileMapIslandRenderer

signal island_generated

@export var terrain_set: int = 0
@export var ocean_terrain: int = 0
@export var land_terrain: int = 1
@export var forest_terrain: int = 2

@export var ocean_layer: TileMapLayer
@export var land_layer: TileMapLayer


func generate_island(height_map: WorldMap, _generator: IslandGenerator) -> void:
    if height_map == null:
        push_error("TileMapIslandRenderer requires valid WorldMap and IslandGenerator")
        return
    ocean_layer.clear()
    land_layer.clear()

    var size: Vector2i = height_map.get_size()
    var ocean_cells: Array[Vector2i] = []
    var land_cells: Array[Vector2i] = []
    var forest_cells: Array[Vector2i] = []
    for y in size.y:
        for x in size.x:
            var pos := Vector2i(x, y)
            ocean_cells.append(pos)
            if not height_map.is_ocean(x, y):
                land_cells.append(pos)

    if ocean_cells.size() > 0:
        print("Setting ocean terrain for ", ocean_cells.size(), " cells")
        ocean_layer.set_cells_terrain_connect(ocean_cells, terrain_set, ocean_terrain)
    if land_cells.size() > 0:
        print("Setting land terrain for ", land_cells.size(), " cells")
        land_layer.set_cells_terrain_connect(land_cells, terrain_set, land_terrain)
    if forest_cells.size() > 0:
        print("Setting forest terrain for ", forest_cells.size(), " cells")
        #land_layer.set_cells_terrain_connect(forest_cells, terrain_set, forest_terrain)  # Assuming 2 is the forest terrain index
    island_generated.emit()
