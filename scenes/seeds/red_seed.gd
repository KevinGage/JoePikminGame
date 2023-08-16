extends Area2D

var red_pikmin_scene = preload("res://scenes/pikmin/red_pikmin.tscn")

func _on_area_entered(_area):
	call_deferred("spawn_pikmin")
	$Sprite2D.visible = false
	$AudioStreamPlayer.play()


func spawn_pikmin():
	var new_pikmin: CharacterBody2D = red_pikmin_scene.instantiate()
	new_pikmin.global_position = $SpawnPoint.global_position
	$"..".add_child(new_pikmin)


func _on_audio_stream_player_finished():
	queue_free()
