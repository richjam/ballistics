extends Node2D

# Reference to the ball to be hit
@export var ball: RigidBody2D

# Aiming and shooting mechanics
@export var max_force: float = 1000.0
var current_force: float = 0.0

# Internal variables for aiming and force
var aiming: bool = false
var start_position: Vector2




func _ready() -> void:
	hide()  # Start hidden


func _process(delta: float) -> void:
	if not aiming:
		# Position the cue at the ball
		global_position = ball.global_position
		
		# Rotate the cue towards the mouse pointer
		var direction = (get_global_mouse_position() - global_position).normalized()
		rotation = direction.angle()
		
	else:
		# Draw a line indicating the shot direction and force
		pass #draw_aim_line()

	# Check if the ball is moving or stopped
	if not ball.is_moving():
		show()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				start_aiming()
			else:
				shoot_ball()

# Initiate aiming mode
func start_aiming() -> void:
	if not ball.is_moving():
		aiming = true
		start_position = get_global_mouse_position()
		print("Aiming...")
	else:
		print("The ball is still moving!")
  
# Apply force to the ball based on the aiming
func shoot_ball() -> void:
	if not ball.is_moving():
		print("Shooting...")
		aiming = false
		hide()
		
		# Calculate the direction and force
		var direction = (start_position - global_position).normalized()
		var force = min(start_position.distance_to(get_global_mouse_position()), max_force)
		
		# Apply the force to the ball
		ball.hit_ball(-direction, force)
	else:
		print("The ball is still moving!")
