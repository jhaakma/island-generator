extends Node

var registered_biomes_by_uid: Array[Biome] = []
var registered_biomes_by_id: Dictionary[String, Biome] = {}

## Returns the ID assigned to the biome.
func register_biome(biome: Biome) -> int:
    if not biome:
        push_error("Cannot register a null biome.")
        return -1

    if biome in registered_biomes_by_uid:
        push_warning("Biome already registered: " + biome.name)
        return registered_biomes_by_uid.find(biome)

    if registered_biomes_by_uid.size() >= 255:
        push_error("Maximum number of biomes reached (255). Cannot register more.")
        return -1

    biome.biome_uid = registered_biomes_by_uid.size()
    registered_biomes_by_uid.append(biome)
    registered_biomes_by_id[biome.biome_id] = biome
    print("Registered biome: " + biome.biome_id + " with UID: " + str(biome.biome_uid))
    return biome.biome_uid

## Returns the biome with the given UID.
func get_biome_by_uid(biome_uid: int) -> Biome:
    if biome_uid < 0 or biome_uid >= registered_biomes_by_uid.size():
        push_error("Biome ID out of range: " + str(biome_uid))
        return null
    return registered_biomes_by_uid[biome_uid]

## Returns the biome with the given ID string.
func get_biome_by_id(biome_id: String) -> Biome:
    if not registered_biomes_by_id.has(biome_id):
        push_error("Biome ID not found: " + biome_id)
        return null
    return registered_biomes_by_id[biome_id]