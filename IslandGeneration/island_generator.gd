extends Node2D
class_name IslandGenerator

## SIGNALS ##
signal island_generated(texture: ImageTexture, collision_polygons: Array[CollisionPolygon2D])
## EXPORTS ##
@export var island_size: Vector2i = Vector2i(256, 256)
@export var noise_scale: float = 32.0
@export var noise_scale_detail: float = 8.0 # New: Scale for detail noise
@export var noise_weight_detail: float = 0.25 # New: How much detail noise affects the final height
@export var starting_seed: int = 42
@export var land_heights: LandHeights
@export var center_bias: float = 3.0
@export var height_adjustment: float = 0.0

## GENERATED NODES ##
var sprite: Sprite2D
var collision_polygons: Array[CollisionPolygon2D]

## NOISE RESOURCE ##
var noise := FastNoiseLite.new()
var noise_detail := FastNoiseLite.new() # New: Second noise object for details

func _ready():
    generate_island()


func generate_island():

    var this_seed = starting_seed
    if starting_seed == -1:
        # Generate a random seed if -1 is set
        this_seed = randi() % 1000000  # Limit to a reasonable range

    # 1. Configure noise
    noise.noise_type = FastNoiseLite.TYPE_PERLIN
    noise.frequency = 1.0 / noise_scale
    noise.seed = this_seed

    # New: Configure detail noise
    noise_detail.noise_type = FastNoiseLite.TYPE_PERLIN
    noise_detail.frequency = 1.0 / noise_scale_detail
    noise_detail.seed = this_seed + 1 # Use a different seed for detail noise for variation

    # 2. Generate island image
    var img := Image.create(island_size.x, island_size.y, false, Image.FORMAT_RGBA8)
    var center := island_size / 2
    var max_dist: int = min(center.x, center.y)

    for y in island_size.y:
        for x in island_size.x:
            var pos = Vector2i(x, y)
            var rel = pos - center
            var dist = rel.length()
            var normalized_dist = dist / max_dist

            # "Radial" falloff to ensure islandy shape
            var base_height = noise.get_noise_2d(x, y)
            var detail_height = noise_detail.get_noise_2d(x,y) # New: Get detail noise

            var height = base_height + (detail_height * noise_weight_detail) # New: Combine noise values

            # Adjust the exponent by center_bias.
            # A center_bias of 1.0 results in the original pow(..., 2.0).
            # A center_bias of 0.5 results in pow(..., 1.0) (linear falloff).
            # A center_bias of 0.0 results in pow(..., 0.0) (no falloff, height isn't changed by distance).
            if max_dist > 0: # Avoid division by zero if island is 1 pixel wide/high
                height *= pow(1 - normalized_dist, 1 + center_bias)


            # Adjust height by height_adjustment
            height += height_adjustment * 0.01

            if dist > max_dist:
                height = 0

            var color: Color
            if height < land_heights.sand:
                color = Color(0.0, 0.0, 0.0, 0.0) # Not island
            elif height < land_heights.grass:
                color = Color(0.95, 0.89, 0.55, 1.0) # Sand
            elif height < land_heights.forest:
                color = Color(0.35, 0.65, 0.25, 1.0) # Grass
            else:
                color = Color(0.15, 0.35, 0.13, 1.0) # Forest
            img.set_pixel(x, y, color)

    img.generate_mipmaps()
    var texture := ImageTexture.create_from_image(img)

    # 3. Display Sprite2D
    if sprite:
        remove_child(sprite)
        sprite.queue_free()
    sprite = Sprite2D.new()
    sprite.texture = texture
    sprite.centered = false
    #sprite.position = Vector2.ZERO
    add_child(sprite)

    # 4. Collision from alpha
    if collision_polygons:
        for polygon in collision_polygons:
            remove_child(polygon)
            polygon.queue_free()
    collision_polygons.clear()


    var bitmap := BitMap.new()
    bitmap.create_from_image_alpha(img, 0.5)
    var rect := Rect2i(Vector2i.ZERO, island_size)
    var polygons := bitmap.opaque_to_polygons(rect)
    if polygons.size() > 0:
        for polygon in polygons:
            var collision_polygon := CollisionPolygon2D.new()
            collision_polygon.polygon = polygon
            collision_polygon.position = Vector2.ZERO
            add_child(collision_polygon)
            collision_polygons.append(collision_polygon)
    else:
        print("No collision polygon generated, using null.")

    island_generated.emit(texture, collision_polygons)

#Debugging, regenerate on Enter key
func _input(event):
    if event.is_action_pressed("ui_accept"):
        generate_island()
        print("Island regenerated with seed:", starting_seed)
