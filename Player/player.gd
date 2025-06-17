class_name Player
extends CharacterBody2D

@export var thrust_force: float = 300.0
@export var reverse_force: float = 100.0
@export var rotation_speed: float = 3.0
@export var drag: float = 0.95
@export var max_speed: float = 1000.0

func _ready() -> void:
    velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
    handle_rotation(delta)
    handle_thrust(delta)
    apply_drag()
    move_and_slide()
    handle_collisions()

func apply_drag() -> void:
    velocity *= drag

func handle_rotation(delta: float) -> void:
    if Input.is_action_pressed("turn_left"):
        rotation -= rotation_speed * delta
    if Input.is_action_pressed("turn_right"):
        rotation += rotation_speed * delta

func handle_thrust(delta: float) -> void:
    if Input.is_action_pressed("move_forward"):
        var direction := Vector2.UP.rotated(rotation)
        velocity += direction * thrust_force * delta
        velocity = velocity.limit_length(max_speed)

    if Input.is_action_pressed("move_backward"):
        var direction := Vector2.UP.rotated(rotation)
        velocity -= direction * reverse_force * delta
        velocity = velocity.limit_length(max_speed)

func handle_collisions() -> void:
    pass
