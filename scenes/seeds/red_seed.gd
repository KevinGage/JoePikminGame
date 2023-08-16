extends Area2D

var red_pikmin_scene = preload("res://scenes/pikmin/red_pikmin.tscn")

func _on_area_entered(_area):
	var new_pikmin: CharacterBody2D = red_pikmin_scene.instantiate()
	
	var current_position = $".".position
	var spawn_position = Vector2(current_position.x, current_position.y - 32)
	
	new_pikmin.position = spawn_position
	
	$"..".add_child(new_pikmin)

	$".".queue_free()
