class_name Player
extends CharacterBody2D

@export var thrust_force: float = 300.0
@export var reverse_force: float = 100.0
@export var rotation_speed: float = 3.0
@export var stationary_rotation_ratio: float = 0.2 # Speed at which the ship rotates when not moving
@export var drag: float = 0.95
@export var max_speed: float = 1000.0
@export var redirect_speed: float = 0.9 # Adjust this value for more/less steering effect

@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
    velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
    handle_rotation(delta)
    handle_thrust(delta)
    redirect_velocity_towards_facing(delta)
    apply_drag()
    move_and_slide()
    handle_collisions()
    handle_camera_zoom()

func apply_drag() -> void:
    velocity *= drag

func handle_camera_zoom() -> void:
    var zoom = camera.zoom
    if Input.is_action_just_pressed("scroll_up"):
        zoom += Vector2(0.1, 0.1)
    elif Input.is_action_just_pressed("scroll_down"):
        zoom -= Vector2(0.1, 0.1)
    if zoom == Vector2.ZERO:
        zoom = Vector2(0.1, 0.1)  # Prevent zero zoom

    camera.zoom = zoom

func handle_rotation(delta: float) -> void:
    # Can't turn if not moving
    var velocity_ratio = clamp(velocity.length() / thrust_force, stationary_rotation_ratio, 1.0)
    var forward = Vector2.UP.rotated(rotation)
    var moving_forward = velocity.dot(forward) >= 0

    var turn_direction = 1.0
    if not moving_forward:
        turn_direction = -1.0

    if Input.is_action_pressed("turn_left"):
        rotation -= rotation_speed * delta * velocity_ratio * turn_direction
    if Input.is_action_pressed("turn_right"):
        rotation += rotation_speed * delta * velocity_ratio * turn_direction

func handle_thrust(delta: float) -> void:
    if Input.is_action_pressed("move_forward"):
        var direction := Vector2.UP.rotated(rotation)
        velocity += direction * thrust_force * delta
        velocity = velocity.limit_length(max_speed)

    if Input.is_action_pressed("move_backward"):
        var direction := Vector2.UP.rotated(rotation)
        velocity -= direction * reverse_force * delta
        velocity = velocity.limit_length(max_speed)

# Redirects a percentage of current velocity towards the ship's facing direction when turning
func redirect_velocity_towards_facing(delta: float) -> void:
    var facing = Vector2.UP.rotated(rotation)
    velocity = velocity.lerp(facing * velocity.length(), redirect_speed * delta)

func handle_collisions() -> void:
    pass
