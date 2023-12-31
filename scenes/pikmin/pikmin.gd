extends CharacterBody2D

@export var movement_target: CharacterBody2D
@export var navigation_agent: NavigationAgent2D
@export var pikmin_color: String = "none"

@onready var is_collectable: bool = true

const SPEED = 200.0
const JUMP_VELOCITY = -400.0
const FRICTION: float = 50

const path_desired_distance_ground: float = 20.0
const path_desired_distance_jump: float = 4.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


# Called when the node enters the scene tree for the first time.
func _ready():
	navigation_agent.path_desired_distance = path_desired_distance_ground
	navigation_agent.target_desired_distance = 4.0
	
	call_deferred("actor_setup")


func actor_setup():
	await get_tree().physics_frame


func _physics_process(delta):
	if movement_target != null:
		if movement_target.is_on_floor() == false or is_on_floor() == false:
			navigation_agent.path_desired_distance = path_desired_distance_jump
		else:
			navigation_agent.path_desired_distance = path_desired_distance_ground

		navigation_agent.target_position = movement_target.position

		if navigation_agent.is_navigation_finished() == false:
			var target_distance = movement_target.position.distance_to($".".position)
			
			if target_distance < 175:
				var next_path_position: Vector2 = navigation_agent.get_next_path_position()
				var direction = (next_path_position - global_position).normalized()
#				var direction_angle = rad_to_deg(direction.angle())
				
				if direction.x < -0.5:
					velocity.x = -1 * SPEED
					$Flipables.scale.x = -1
					$AnimationPlayer.play("walk")
				elif direction.x > 0.5:
					velocity.x = SPEED
					$Flipables.scale.x = 1
					$AnimationPlayer.play("walk")
				if is_on_floor():
					if $Flipables/JumpDetectCast.is_colliding() == false and direction.y <= 0:
						velocity.y = JUMP_VELOCITY
					if $Flipables/RayCast2D2.is_colliding():
						if direction.y <= -0.1:
							velocity.y = JUMP_VELOCITY
			else:
				movement_target.stop_follow(self, true)
		else:
			velocity.x = 0
			
	else:
		if is_on_floor():
			apply_friction()

	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		if velocity.x == 0:
			if movement_target != null:
				$AnimationPlayer.play("idle")
			else:
				$AnimationPlayer.play("idle_down")
	
	if velocity.y > 0:
		$AnimationPlayer.play("jump")
	elif velocity.y < 0:
		$AnimationPlayer.play("jump")
		
	move_and_slide()


func apply_friction():
	velocity.x = move_toward(velocity.x, 0, FRICTION)


func throw(direction: Vector2):
	$CollectionArea.monitoring = false
	$CollectionArea.monitorable = false
	velocity.y = direction.y
	velocity.x = direction.x
	$ThrowAudioStreamPlayer.play()
	$Timer.start()


func _on_timer_timeout():
	$CollectionArea.monitoring = true
	$CollectionArea.monitorable = true


func stop_follow(follower: CharacterBody2D, chain: bool = true):
	if movement_target != null and "stop_follow" in movement_target:
		movement_target.stop_follow(follower, chain)


func _on_collection_area_body_entered(body):
	if is_collectable:
		if "follow" in body:
			$CollectAudioStreamPlayer.play()
			body.follow(self)


func beam_up(color: String, pos: Vector2):
	if color == pikmin_color:
		movement_target.stop_follow(self, false)
		var tween = get_tree().create_tween()
		tween.set_parallel(true)
		tween.tween_property($".", "scale", Vector2(0,0), 1.0)
		tween.tween_property($".", "position", pos, 1.0).set_trans(Tween.TRANS_EXPO)
		await tween.finished
		queue_free()
