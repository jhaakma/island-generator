extends IslandRenderer
class_name GPUIslandRenderer

@export var island_sprite: Sprite2D
@export var height_scale: float = 20.0
@export var map_scale: float = 8.0
@export var player_path: NodePath
@export var chunk_size: Vector2i = Vector2i(256, 256)
@export var render_radius: int = 1

func _ready() -> void:
    if not island_sprite:
        island_sprite = Sprite2D.new()
        island_sprite.centered = false
        add_child(island_sprite)
    _chunks = {}
    set_process(true)

var _generator: IslandGenerator
var _biome_threshold_tex: Texture2D
var _biome_color_tex: Texture2D
var _biome_count: int = 0
var _chunks: Dictionary

func generate_island(world_map: WorldMap, generator: IslandGenerator) -> void:
    if generator == null:
        push_error("GPUIslandRenderer requires a valid IslandGenerator")
        return

    _generator = generator
    if world_map:
        chunk_size = world_map.get_size()
        _create_chunk(Vector2i.ZERO, world_map)

    var colors := PackedColorArray()
    var thresholds := PackedColorArray()
    for biome in generator.biomes:
        if biome == null:
            continue
        colors.append(biome.color)
        thresholds.append(Color(biome.min_height, 0.0, biome.min_temperature, biome.max_temperature))

    _biome_count = colors.size()
    var threshold_img := Image.create(_biome_count, 1, false, Image.FORMAT_RGBAF)
    var color_img := Image.create(_biome_count, 1, false, Image.FORMAT_RGBAF)
    for i in _biome_count:
        threshold_img.set_pixel(i, 0, thresholds[i])
        color_img.set_pixel(i, 0, colors[i])
    _biome_threshold_tex = ImageTexture.create_from_image(threshold_img)
    _biome_color_tex = ImageTexture.create_from_image(color_img)

    _update_chunks()

func _process(_delta: float) -> void:
    _update_chunks()

func _get_player() -> Node2D:
    if player_path == NodePath():
        return null
    return get_node_or_null(player_path) as Node2D

func _update_chunks() -> void:
    var player = _get_player()
    if player == null or _generator == null:
        return
    var cs = chunk_size * map_scale
    var player_chunk := Vector2i(floor(player.global_position.x / cs.x), floor(player.global_position.y / cs.y))
    var needed := []
    for y in range(-render_radius, render_radius + 1):
        for x in range(-render_radius, render_radius + 1):
            needed.append(player_chunk + Vector2i(x, y))
    for coord in needed:
        if not _chunks.has(coord):
            _create_chunk(coord)
    for k in _chunks.keys():
        if not needed.has(k):
            var spr = _chunks[k]
            remove_child(spr)
            spr.queue_free()
            _chunks.erase(k)

func _create_chunk(coord: Vector2i, world_map: WorldMap = null) -> void:
    var wm := world_map if world_map else _generator.generate_map(chunk_size, coord * chunk_size)
    var sprite: Sprite2D
    if _chunks.is_empty() and island_sprite:
        sprite = island_sprite
        sprite.centered = false
    else:
        sprite = Sprite2D.new()
        sprite.centered = false
        add_child(sprite)
    sprite.position = coord * chunk_size * map_scale
    sprite.scale = Vector2(map_scale, map_scale)
    _apply_map(sprite, wm)
    _chunks[coord] = sprite

func _apply_map(sprite: Sprite2D, world_map: WorldMap) -> void:
    var hm_tex := ImageTexture.create_from_image(world_map.get_height_map())
    var temp_tex := ImageTexture.create_from_image(world_map.get_temperature_map())
    var shader_material := sprite.material as ShaderMaterial
    if shader_material == null:
        shader_material = ShaderMaterial.new()
        shader_material.shader = load("res://IslandGeneration/Render/Shaders/gpu_island.gdshader")
        sprite.material = shader_material
    shader_material.set_shader_parameter("height_map", hm_tex)
    shader_material.set_shader_parameter("temperature_map", temp_tex)
    shader_material.set_shader_parameter("height_scale", height_scale)
    shader_material.set_shader_parameter("biome_thresholds", _biome_threshold_tex)
    shader_material.set_shader_parameter("biome_colors", _biome_color_tex)
    shader_material.set_shader_parameter("biome_count", _biome_count)

func get_texture() -> Texture2D:
    if _chunks.size() > 0:
        return _chunks.values()[0].texture
    return null
