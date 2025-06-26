class_name DebugLayer
extends CanvasLayer

@export var minimap_sprite: Sprite2D
@export var wind_speed_label: RichTextLabel

func on_map_regenerated(world_map: WorldMap) -> void:
    if minimap_sprite:
        var image: Image = world_map.get_height_map()
        #var image = map_viewport.get_texture().get_image()
        var h: Texture2D = ImageTexture.create_from_image(image)
        minimap_sprite.texture = h

func update_wind_speed_label() -> void:
    var wind = Globals.get_wind()
    if wind and wind_speed_label:
        var speed = wind.current_wind_speed
        var direction = rad_to_deg(wind.get_wind_direction().angle())
        var label_text = "Wind: %.2f m/s, Origin: %.2f°" % [speed, direction]
        wind_speed_label.text = label_text


func _process(_delta: float) -> void:
    update_wind_speed_label()
