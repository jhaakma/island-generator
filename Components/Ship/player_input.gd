class_name PlayerInput
extends Node

func is_move_forward() -> bool:
    return Input.is_action_pressed("move_forward")

func is_move_backward() -> bool:
    return Input.is_action_pressed("move_backward")

func is_turn_left() -> bool:
    return Input.is_action_pressed("turn_left")

func is_turn_right() -> bool:
    return Input.is_action_pressed("turn_right")
