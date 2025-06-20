extends Resource
class_name NoisePass

@export_range(1, 512) var scale: int = 64
@export_range(0.0, 2.0) var weight: float = 1.0

enum NoiseType {
    PERLIN,
    SIMPLEX,
    VALUE
}

@export var noise_type: FastNoiseLite.NoiseType = FastNoiseLite.TYPE_PERLIN

var noise: FastNoiseLite

func init(_seed: int):
    noise = FastNoiseLite.new()
    noise.seed = _seed
    noise.noise_type = noise_type
    noise.frequency = 1.0 / float(scale)


func get_noise(x: int, y: int) -> float:
    noise.noise_type = noise_type
    noise.frequency = 1.0 / float(scale)
    if not noise:
        push_error("NoisePass not initialized. Call init() with a seed.")
        return 0.0
    return noise.get_noise_2d(x, y) * weight
