class_name ShipMovement
extends Node

@export var ship: CharacterBody2D
# X axis: 0 to 180 degrees from downwind, Y axis: 0.0-1.0 efficiency
@export var efficiency_curve: Curve
@export var input_provider: Node
@export var thrust_force: float = 300.0
@export var reverse_force: float = 100.0
@export var rotation_speed: float = 3.0
@export var stationary_rotation_ratio: float = 0.2
@export var drag: float = 0.95
@export var max_speed: float = 1000.0
@export var redirect_speed: float = 0.9
@export var rotation_acceleration: float = 8.0 # New: How quickly the ship turns towards target rotation velocity


var current_rotation_velocity: float = 0.0

func _physics_process(delta: float) -> void:
    if not ship:
        push_error("ShipMovement requires a CharacterBody2D")
        return

    handle_rotation(delta)
    handle_thrust(delta)
    redirect_velocity_towards_facing(delta)
    apply_drag()
    ship.move_and_slide()

func apply_drag() -> void:
    ship.velocity *= drag

func handle_rotation(delta: float) -> void:
    var velocity_ratio = clamp(ship.velocity.length() / thrust_force, stationary_rotation_ratio, 1.0)
    var target_rotation_velocity := 0.0

    if input_provider and input_provider.has_method("is_turn_left") and input_provider.is_turn_left():
        target_rotation_velocity -= rotation_speed * velocity_ratio
    if input_provider and input_provider.has_method("is_turn_right") and input_provider.is_turn_right():
        target_rotation_velocity += rotation_speed * velocity_ratio

    # Lerp current rotation velocity towards the target
    current_rotation_velocity = lerp(current_rotation_velocity, target_rotation_velocity, rotation_acceleration * delta)
    ship.rotation += current_rotation_velocity * delta


func get_efficiency() -> float:
    var wind = Globals.get_wind()
    var wind_direction = wind.get_wind_direction().normalized()
    var angle_to_wind = wind_direction.angle_to(Vector2.LEFT.rotated(ship.rotation))
    var angle_from_wind = abs(angle_to_wind) * (180.0 / PI)  # Convert to degrees
    var efficiency = efficiency_curve.sample_baked(angle_from_wind) if efficiency_curve else 1.0
    return efficiency

func handle_thrust(delta: float) -> void:
    var wind = Globals.get_wind()
    if not wind:
        push_error("ShipMovement requires a Wind node in the scene tree")
        return
    var wind_speed = wind.current_wind_speed
    var max_wind_speed = wind.max_wind_speed
    var efficiency = get_efficiency()
    var adjusted_thrust_force = thrust_force * efficiency * (wind_speed / max_wind_speed)
    adjusted_thrust_force = max(adjusted_thrust_force, reverse_force)

    if input_provider and input_provider.has_method("is_move_forward") and input_provider.is_move_forward():
        var direction := Vector2.UP.rotated(ship.rotation)
        ship.velocity += direction * adjusted_thrust_force * delta
        ship.velocity = ship.velocity.limit_length(max_speed)

    if input_provider and input_provider.has_method("is_move_backward") and input_provider.is_move_backward():
        var direction := Vector2.UP.rotated(ship.rotation)
        ship.velocity -= direction * reverse_force * delta
        ship.velocity = ship.velocity.limit_length(max_speed)

func redirect_velocity_towards_facing(delta: float) -> void:
    var facing = Vector2.UP.rotated(ship.rotation)
    ship.velocity = ship.velocity.lerp(facing * ship.velocity.length(), redirect_speed * delta)
