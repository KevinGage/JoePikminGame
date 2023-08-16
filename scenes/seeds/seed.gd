extends Sprite2D

@export var pikmin_scene = preload("res://scenes/pikmin/red_pikmin.tscn")


func spawn_pikmin():
	var new_pikmin: CharacterBody2D = pikmin_scene.instantiate()
	new_pikmin.global_position = $SpawnPoint.global_position
	$"..".add_child(new_pikmin)


func _on_audio_stream_player_finished():
	queue_free()


func _on_area_2d_area_entered(_area):
	call_deferred("spawn_pikmin")
	$".".visible = false
	$AudioStreamPlayer.play()
