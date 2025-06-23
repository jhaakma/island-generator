class_name Wind
extends Node2D

@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var timer : Timer = $Timer
@export var player: Player
#Use to determine the

@export_category("Wind Speed")
@export var min_wind_speed: float = 10
@export var max_wind_speed: float = 100.0
@export var wind_speed_change_per_second: float = 1.0
@export var wind_speed_curve: Curve

@export_category("Rotation")
@export var min_rotation_degrees_per_second: float = 10.0
@export var max_rotation_degrees_per_second: float = 30.0
@export var min_rotation_wait_seconds: float = 1.0
@export var max_rotation_wait_seconds: float = 10.0
@export var rotation_change_curve: Curve

var target_rotation: float = 0.0
var rotation_speed: float = 0.0
var current_wind_speed: float = 0.0
var target_wind_speed: float = 0.0

func get_wind_direction() -> Vector2:
    # Returns the wind direction as a normalized vector
    return Vector2(cos(rotation), sin(rotation)).normalized()

func _ready() -> void:
    # Start the timer to emit particles
    timer.wait_time = randf_range(min_rotation_wait_seconds, max_rotation_wait_seconds)
    timer.start()
    timer.timeout.connect(update_wind_targets)

    update_wind_targets()  # Initialize the first wind rotation

    set_wind_speed(target_wind_speed)
    particles.emitting = true


func _physics_process(delta: float) -> void:
    position = player.position

    # Lerp towards the target rotation, framerate independent
    rotation = lerp_angle(rotation, target_rotation, 1.0 - exp(-delta * deg_to_rad(rotation_speed)))
    process_wind_speed(delta)


func process_wind_speed(delta: float):
    # Lerp towards the target wind speed
    var speed = lerp(current_wind_speed, target_wind_speed, 1.0 - exp(-delta * wind_speed_change_per_second))
    set_wind_speed(speed)



func set_wind_speed(speed: float) -> void:
    current_wind_speed = speed
    var mat: ParticleProcessMaterial = particles.process_material
    mat.initial_velocity_min = current_wind_speed * 0.9
    mat.initial_velocity_max = current_wind_speed

func update_wind_targets() -> void:
    _update_target_rotation()
    _update_rotation_speed()
    _update_target_wind_speed()

func _update_target_wind_speed():
    var r = randf()
    var curve_value = wind_speed_curve.sample(r)
    target_wind_speed = lerp(min_wind_speed, max_wind_speed, curve_value)
    print("Target wind speed updated to: ", target_wind_speed)

func _update_rotation_speed():
    rotation_speed = randf_range(min_rotation_degrees_per_second, max_rotation_degrees_per_second)

func _update_target_rotation():
    var r = randf()
    var curve_value = rotation_change_curve.sample(r)
    var rotation_change: float= lerp(-180, 180, curve_value)
    target_rotation += deg_to_rad(rotation_change)
    print("Target rotation updated to: ", target_rotation, " (change: ", rotation_change, ")")
