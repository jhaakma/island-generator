extends Resource
class_name Biome

## Used to store in heightMap, set by BiomeRegistry
var biome_uid: int
## ID used to fetch known biome from BiomeRegistry
@export var biome_id: String
@export var name: String = ""
@export var min_height: float = 1.0
@export var color: Color = Color.WHITE
@export var is_land: bool = true
@export var layer_index: int = 0
@export var tile_set: TileSet
@export var terrain_id: int = 0

func register():
    BiomeRegistry.register_biome(self)
