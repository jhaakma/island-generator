extends Resource

class_name WorldMap

var texture: ImageTexture
var _image: Image
var temperature_image: Image
var humidity_image: Image

func _init(image: Image, temperature: Image = null, humidity: Image = null):
    _image = image
    texture = ImageTexture.create_from_image(image)
    temperature_image = temperature if temperature else Image.create(image.get_width(), image.get_height(), false, Image.FORMAT_RF)
    humidity_image = humidity if humidity else Image.create(image.get_width(), image.get_height(), false, Image.FORMAT_RF)

func _height_to_value(height: float) -> float:
    # Assuming height is normalized between 0.0 and 1.0
    return remap(height, -1.0, 1.0, 0.0, 1.0)

func _value_to_height(value: float) -> float:
    # Assuming value is normalized between 0.0 and 1.0
    return remap(value, 0.0, 1.0, -1.0, 1.0)

func get_height(x: int, y: int) -> float:
    var color = _image.get_pixel(x, y)
    # Assume height is stored in the red channel
    return _value_to_height(color.r)

func set_height(x: int, y: int, height: float) -> void:
    var color = _image.get_pixel(x, y)
    color.r = _height_to_value(height)
    _image.set_pixel(x, y, color)

func get_biome(x: int, y: int) -> Biome:
    var color = _image.get_pixel(x, y)
    var biome_uid = int(round(color.g * 255.0))
    return BiomeRegistry.get_biome_by_uid(biome_uid)

func set_biome(x: int, y: int, biome) -> void:
    var color = _image.get_pixel(x, y)
    color.g = clamp(float(biome.biome_uid) / 255.0, 0.0, 1.0)
    _image.set_pixel(x, y, color)

func has_freshwater(x: int, y: int) -> bool:
    return _image.get_pixel(x, y).b > 0.5

func set_freshwater(x: int, y: int, value: bool) -> void:
    var color = _image.get_pixel(x, y)
    color.b = 1.0 if value else 0.0
    _image.set_pixel(x, y, color)

func is_ocean(x: int, y: int) -> bool:
    return _image.get_pixel(x, y).a > 0.5

func set_ocean(x: int, y: int, value: bool) -> void:
    var color = _image.get_pixel(x, y)
    color.a = 1.0 if value else 0.0
    _image.set_pixel(x, y, color)

func get_temperature(x: int, y: int) -> float:
    return temperature_image.get_pixel(x, y).r

func set_temperature(x: int, y: int, value: float) -> void:
    var c = temperature_image.get_pixel(x, y)
    c.r = clamp(value, 0.0, 1.0)
    temperature_image.set_pixel(x, y, c)

func get_humidity(x: int, y: int) -> float:
    return humidity_image.get_pixel(x, y).r

func set_humidity(x: int, y: int, value: float) -> void:
    var c = humidity_image.get_pixel(x, y)
    c.r = clamp(value, 0.0, 1.0)
    humidity_image.set_pixel(x, y, c)

func get_image() -> Image:
    return _image

func get_size() -> Vector2i:
    return _image.get_size()
