extends Resource

class_name HeightMap

var texture: ImageTexture
var _image: Image

func _init(image: Image):
    _image = image
    texture = ImageTexture.create_from_image(image)

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

func get_biome(x: int, y: int) -> int:
    var color = _image.get_pixel(x, y)
    return int(round(color.g * 255.0))

func set_biome(x: int, y: int, index: int) -> void:
    var color = _image.get_pixel(x, y)
    color.g = clamp(float(index) / 255.0, 0.0, 1.0)
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

func get_image() -> Image:
    return _image

func get_size() -> Vector2i:
    return _image.get_size()

