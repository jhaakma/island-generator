class_name WaterTrail
extends GPUParticles2D

@export var character_body: CharacterBody2D

var previous_rotation: float = 0.0

func _physics_process(_delta: float) -> void:
    # If character body is moving, emit particles, otherwise stop emitting\
    if not character_body:
        push_error("WaterTrail requires a CharacterBody2D to function")
        return

    var is_moving: bool = character_body.velocity.length() > 1 or character_body.rotation != previous_rotation

    if is_moving:
        self.emitting = true
        self.amount_ratio = clamp(character_body.velocity.length() / 200.0, 0.0, 1.0)  # Adjust the divisor as needed
    else:
        self.emitting = false

    previous_rotation = character_body.rotation
