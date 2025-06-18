extends Resource

class_name WorldMap

var texture: ImageTexture
var _height_image: Image
var _temperature_image: Image

func _init(height_image: Image, temperature_image: Image = null):
    _height_image = height_image
    texture = ImageTexture.create_from_image(height_image)
    _temperature_image = temperature_image if temperature_image else Image.create(height_image.get_width(), height_image.get_height(), false, Image.FORMAT_RF)

func _height_to_value(height: float) -> float:
    # Assuming height is normalized between 0.0 and 1.0
    return remap(height, -1.0, 1.0, 0.0, 1.0)

func _value_to_height(value: float) -> float:
    # Assuming value is normalized between 0.0 and 1.0
    return remap(value, 0.0, 1.0, -1.0, 1.0)

func get_height(x: int, y: int) -> float:
    var color = _height_image.get_pixel(x, y)
    # Assume height is stored in the red channel
    return _value_to_height(color.r)

func set_height(x: int, y: int, height: float) -> void:
    var color = _height_image.get_pixel(x, y)
    color.r = _height_to_value(height)
    _height_image.set_pixel(x, y, color)

func get_biome(x: int, y: int) -> Biome:
    var color = _height_image.get_pixel(x, y)
    var biome_uid = int(round(color.g * 255.0))
    return BiomeRegistry.get_biome_by_uid(biome_uid)

func set_biome(x: int, y: int, biome) -> void:
    var color = _height_image.get_pixel(x, y)
    color.g = clamp(float(biome.biome_uid) / 255.0, 0.0, 1.0)
    _height_image.set_pixel(x, y, color)

func has_freshwater(x: int, y: int) -> bool:
    return _height_image.get_pixel(x, y).b > 0.5

func set_freshwater(x: int, y: int, value: bool) -> void:
    var color = _height_image.get_pixel(x, y)
    color.b = 1.0 if value else 0.0
    _height_image.set_pixel(x, y, color)

func is_ocean(x: int, y: int) -> bool:
    return _height_image.get_pixel(x, y).a > 0.5

func set_ocean(x: int, y: int, value: bool) -> void:
    var color = _height_image.get_pixel(x, y)
    color.a = 1.0 if value else 0.0
    _height_image.set_pixel(x, y, color)

func get_temperature(x: int, y: int) -> float:
    return _temperature_image.get_pixel(x, y).r

func set_temperature(x: int, y: int, value: float) -> void:
    var c = _temperature_image.get_pixel(x, y)
    c.r = clamp(value, 0.0, 1.0)
    _temperature_image.set_pixel(x, y, c)

func get_height_map() -> Image:
    return _height_image

func get_temperature_map() -> Image:
    return _temperature_image

func get_size() -> Vector2i:
    return _height_image.get_size()
