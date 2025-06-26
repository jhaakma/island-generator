class_name Player
extends CharacterBody2D

@onready var camera: Camera2D = $Camera2D

func _physics_process(_delta: float) -> void:
    handle_camera_zoom()

func handle_camera_zoom() -> void:
    var zoom = camera.zoom

    if Input.is_action_just_pressed("reset_zoom"):
        zoom = Vector2(1, 1)  # Reset to default zoom level
    elif Input.is_action_just_pressed("scroll_up"):
        zoom += Vector2(0.1, 0.1)
    elif Input.is_action_just_pressed("scroll_down"):
        zoom -= Vector2(0.1, 0.1)
    zoom.x = max(zoom.x, 0.1)  # Prevent zooming out too far
    zoom.y = max(zoom.y, 0.1)  # Prevent zooming
    camera.zoom = zoom
