extends Node

@export var onion_color: String = "red"


func _on_area_2d_body_entered(body):
	if "beam_up" in body:
		body.beam_up(onion_color, $CollectionPosition.global_position)
