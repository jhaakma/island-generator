extends Node

func get_player() -> Player:
    return get_tree().get_first_node_in_group("Player")

func get_wind() -> Wind:
    return get_tree().get_first_node_in_group("Wind")
