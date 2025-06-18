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

func select_biome(temperature: float, height: float) -> Biome:
    #Default is biome with lowest height
    var default = get_biome_by_id('ocean')

    var valid_biomes = []

    for biome in registered_biomes_by_uid:
        if not biome:
            print("Skipping null biome.")
            continue
        var temp_ok = (biome.min_temperature <= temperature and temperature <= biome.max_temperature)
        var height_ok = (biome.min_height <= height)
        if temp_ok and height_ok:
            valid_biomes.append(biome)

    var best_biome: Biome = null
    if valid_biomes.is_empty():
        print("No valid biomes found for temperature: " + str(temperature) + " and height: " + str(height))
        return default

    # Select the biome with the highest min_height
    for biome in valid_biomes:
        if not best_biome or biome.min_height > best_biome.min_height:
            best_biome = biome
    return best_biome
