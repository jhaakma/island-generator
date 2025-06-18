extends IslandRenderer
class_name GPUIslandRenderer

@export var viewport: SubViewport
@export var island_mesh: MeshInstance3D
@export var height_scale: float = 20.0

func _ready() -> void:
    if not viewport:
        viewport = SubViewport.new()
        viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
        add_child(viewport)
    if not island_mesh:
        island_mesh = MeshInstance3D.new()
        viewport.add_child(island_mesh)

func generate_island(world_map: WorldMap, generator: IslandGenerator) -> void:
    if world_map == null or generator == null:
        push_error("GPUIslandRenderer requires valid WorldMap and IslandGenerator")
        return

    var size: Vector2i = world_map.get_size()
    viewport.size = size

    var hm_tex := ImageTexture.create_from_image(world_map.get_height_map())
    var temp_tex := ImageTexture.create_from_image(world_map.get_temperature_map())

    var plane := PlaneMesh.new()
    plane.size = Vector2(size.x, size.y)
    plane.subdivide_width = size.x - 1
    plane.subdivide_depth = size.y - 1
    island_mesh.mesh = plane

    var shader_material := island_mesh.material_override as ShaderMaterial
    if shader_material == null:
        shader_material = ShaderMaterial.new()
        shader_material.shader = load("res://IslandGeneration/Render/Shaders/gpu_island.shader")
        island_mesh.material_override = shader_material

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

