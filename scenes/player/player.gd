extends CharacterBody2D

@onready var followers: Array[CharacterBody2D] = []

const SPEED = 200.0
const JUMP_VELOCITY = -400.0
#const ACCELERATION: float = 30.0
const FRICTION: float = 50.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		
		if velocity.x > 0:
			$Sprite2D.flip_h = false
		elif velocity.x < 0:
			$Sprite2D.flip_h = true
	else:
#		velocity.x = move_toward(velocity.x, 0, SPEED)
		apply_friction()
		
		# Handle animations
	if is_on_floor():
		if velocity.x == 0 and velocity.y == 0:
			$AnimationPlayer.play("player_idle")
		else:
			$AnimationPlayer.play("player_walk")
	else:
		$AnimationPlayer.play("player_jump")

	move_and_slide()


#func accelerate(direction: Vector2):
#	velocity = velocity.move_toward(SPEED * direction, ACCELERATION)


func apply_friction():
	velocity.x = move_toward(velocity.x, 0, FRICTION)


func _input(event):
	if event.is_action_pressed("throw"):
		throw()
	elif event.is_action_pressed("pluck"):
		pluck()


func follow(follower):
	print("follow me")
	if followers.size() == 0:
		follower.movement_target = self
	else:
		follower.movement_target = followers.back()

	follower.is_collectable = false
	followers.append(follower)


func throw():
	print("throw")
	if followers.size() > 0:
		if "throw" in followers[0]:
			var throw_direction = Vector2(400 + (abs(velocity.x) / 2) , -300)
			if $Sprite2D.flip_h == true:
				throw_direction.x *= -1
			
			followers[0].throw(throw_direction)
			followers[0].is_collectable = true
			followers[0].movement_target = null
			followers.pop_front()
			if followers.size() > 0:
				followers[0].movement_target = self


func pluck():
	print("pluck")
