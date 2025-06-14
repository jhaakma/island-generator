extends Resource
class_name NoisePass

@export var scale: float = 64.0
@export var weight: float = 1.0

var noise: FastNoiseLite

func init(_seed: int):
    noise = FastNoiseLite.new()
    noise.noise_type = FastNoiseLite.TYPE_PERLIN
    noise.frequency = 1.0 / scale
    noise.seed = _seed


func get_noise(x: int, y: int) -> float:
    if not noise:
        push_error("NoisePass not initialized. Call init() with a seed.")
        return 0.0
    return noise.get_noise_2d(x, y) * weight
