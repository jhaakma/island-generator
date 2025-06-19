extends IslandRenderer
class_name GPUIslandRenderer

@export var viewport: SubViewport
@export var island_sprite: Sprite2D
@export var height_scale: float = 20.0

func _ready() -> void:
    if not viewport:
        viewport = SubViewport.new()
        viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
        add_child(viewport)
    if not island_sprite:
        island_sprite = Sprite2D.new()
        island_sprite.centered = false
        viewport.add_child(island_sprite)

func generate_island(world_map: WorldMap, generator: IslandGenerator) -> void:
    if world_map == null or generator == null:
        push_error("GPUIslandRenderer requires valid WorldMap and IslandGenerator")
        return

    var size: Vector2i = world_map.get_size()
    viewport.size = size

    var hm_tex := ImageTexture.create_from_image(world_map.get_height_map())
    var temp_tex := ImageTexture.create_from_image(world_map.get_temperature_map())

    island_sprite.texture = hm_tex

    var shader_material := island_sprite.material as ShaderMaterial
    if shader_material == null:
        shader_material = ShaderMaterial.new()
        shader_material.shader = load("res://IslandGeneration/Render/Shaders/gpu_island.gdshader")
        island_sprite.material = shader_material

    shader_material.set_shader_param("height_map", hm_tex)
    shader_material.set_shader_param("temperature_map", temp_tex)
    shader_material.set_shader_param("height_scale", height_scale)

    var colors := PackedColorArray()
    var thresholds := PackedColorArray()
    for biome in generator.biomes:
        if biome == null:
            continue
        colors.append(biome.color)
        var max_height := 1.0
        thresholds.append(Color(biome.min_height, max_height, biome.min_temperature, biome.max_temperature))

    var count := colors.size()
    var threshold_img := Image.create(count, 1, false, Image.FORMAT_RGBAF)
    var color_img := Image.create(count, 1, false, Image.FORMAT_RGBAF)
    for i in count:
        threshold_img.set_pixel(i, 0, thresholds[i])
        color_img.set_pixel(i, 0, colors[i])
    var threshold_tex := ImageTexture.create_from_image(threshold_img)
    var color_tex := ImageTexture.create_from_image(color_img)

    shader_material.set_shader_param("biome_thresholds", threshold_tex)
    shader_material.set_shader_param("biome_colors", color_tex)
    shader_material.set_shader_param("biome_count", count)

func get_texture() -> Texture2D:
    return viewport.get_texture() if viewport else null

