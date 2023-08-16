extends CharacterBody2D

@export var movement_target: CharacterBody2D
@export var navigation_agent: NavigationAgent2D

@onready var is_collectable: bool = true

const SPEED = 200.0
const JUMP_VELOCITY = -400.0
const FRICTION: float = 50

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


# Called when the node enters the scene tree for the first time.
func _ready():
	navigation_agent.path_desired_distance = 32.0
	navigation_agent.target_desired_distance = 4.0
	
	call_deferred("actor_setup")


func actor_setup():
	await get_tree().physics_frame


func _physics_process(delta):
	if movement_target != null:
		navigation_agent.target_position = movement_target.position

		if navigation_agent.is_navigation_finished() == false:
			var target_distance = movement_target.position.distance_to($".".position)
			
			if target_distance < 100:
				var next_path_position: Vector2 = navigation_agent.get_next_path_position()
				var direction = (next_path_position - global_position).normalized()
				var direction_angle = rad_to_deg(direction.angle())
				
				if direction.x < -0.5:
					velocity.x = -1 * SPEED
					$Flipables.scale.x = -1
					$AnimationPlayer.play("red_pikmin_walk")
				elif direction.x > 0.5:
					velocity.x = SPEED
					$Flipables.scale.x = 1
					$AnimationPlayer.play("red_pikmin_walk")
				if is_on_floor():
					if $Flipables/jump_detect_cast.is_colliding() == false and direction.y <= -0.48:
						velocity.y = JUMP_VELOCITY
					if direction_angle < -60 and direction_angle > -120:
						velocity.y = JUMP_VELOCITY
			else:
				movement_target.stop_follow(self)
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
				$AnimationPlayer.play("red_pikmin_idle")
			else:
				$AnimationPlayer.play("red_pikmin_idle_down")
	
	if velocity.y > 0:
		$AnimationPlayer.play("red_pikmin_jump")
	elif velocity.y < 0:
		$AnimationPlayer.play("red_pikmin_jump")
		
	move_and_slide()
#	# Add the gravity.
#	if not is_on_floor():
#		velocity.y += gravity * delta
#
#	# Handle Jump.
#	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
#		velocity.y = JUMP_VELOCITY
#
#	# Get the input direction and handle the movement/deceleration.
#	# As good practice, you should replace UI actions with custom gameplay actions.
#	var direction = Input.get_axis("ui_left", "ui_right")
#	if direction:
#		velocity.x = direction * SPEED
#
#		if velocity.x > 0:
#			$Flipables.scale = Vector2(1,1)
#		elif velocity.x < 0:
#			$Flipables.scale = Vector2(-1,1)
#	else:
#		velocity.x = move_toward(velocity.x, 0, SPEED)
#
#	# Handle animations
#	if is_on_floor():
#		if velocity.x == 0 and velocity.y == 0:
#			$AnimationPlayer.play("red_pikmin_idle_down")
#		else:
#			$AnimationPlayer.play("red_pikmin_walk")
#	else:
#		$AnimationPlayer.play("red_pikmin_jump")
#
#	move_and_slide()


func apply_friction():
	velocity.x = move_toward(velocity.x, 0, FRICTION)


func _on_area_2d_body_entered(body):
	if is_collectable:
		if "follow" in body:
			body.follow(self)


func throw(direction: Vector2):
	$Area2D.monitoring = false
	$Area2D.monitorable = false
	velocity.y = direction.y
	velocity.x = direction.x
	$AudioStreamPlayer.play()
	$Timer.start()

func _on_timer_timeout():
	$Area2D.monitoring = true
	$Area2D.monitorable = true


func stop_follow(follower):
	if movement_target != null and "stop_follow" in movement_target:
		movement_target.stop_follow(follower)
