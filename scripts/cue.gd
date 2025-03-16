extends Node2D
""" Pool Cue Controller
Handles the aiming and shooting mechanics for a pool cue in a pool game.
The cue allows player to aim, adjust power through pullback, and shoot the ball.
"""

@onready var logger = $"/root/GameLogger".get_logger("Cue") # Get component-specific logger

@export var ball: RigidBody2D  # The ball RigidBody2D that this cue will hit.
@export var max_force: float = 1000.0  # Maximum force that can be applied to the ball.
@export var max_pullback: float = 200.0  # Maximum distance the cue can be pulled back.
@export var force_multiplier: float = 5.0  # Multiplier for calculating force from pullback distance.

var is_power_adjusting: bool = false  # Whether the player is currently adjusting shot power.
var is_ball_ready: bool = false  # Whether the ball is stationary and ready to be hit.
var aim_direction: Vector2 = Vector2.ZERO  # The locked direction for aiming after initial click.
var cue_start_position: Vector2 = Vector2.ZERO  # Initial position of the mouse when starting pullback.
var mouse_start_position: Vector2 = Vector2.ZERO  # Initial position of the mouse when aiming starts.
var cue_offset: float = 0.0  # Current pullback distance of the cue.
var current_force: float = 0.0  # Current force calculated from pullback distance.


func _ready() -> void:
	""" Initialize the cue in a hidden state until the ball stops.
	"""
	hide()
	logger.info("Initialized and waiting for ball to stop")


func _process(_delta: float) -> void:
	""" Main process function called every frame.
	
	Updates the ball readiness state and cue visibility/position.
	
	Args:
		_delta: Time elapsed since previous frame.
	"""
	update_ball_readiness()
	
	if is_ball_ready:
		show()
		if not is_power_adjusting:
			update_cue_position()
	else:
		hide()


func _input(event: InputEvent) -> void:
	""" Handle input events for cue control.
	
	Processes mouse button and motion events for power adjustment and shooting.
	
	Args:
		event: The input event to be processed.
	"""
	if not is_ball_ready:
		return
		
	if event is InputEventMouseButton:
		handle_mouse_button(event)
	elif event is InputEventMouseMotion and is_power_adjusting:
		adjust_pullback(event.position)


func update_ball_readiness() -> void:
	""" Check if the ball is stationary and ready to be hit.
	
	Updates the is_ball_ready state variable.
	"""
	var was_ready = is_ball_ready
	is_ball_ready = not ball.is_moving()
	
	# Log state changes
	if is_ball_ready != was_ready:
		if is_ball_ready:
			logger.info("Ball stopped, cue ready")
		else:
			logger.info("Ball in motion, cue disabled")


func update_cue_position() -> void:
	""" Update the cue position and rotation based on mouse position.
	
	Positions the cue at the ball and rotates it to point at the mouse cursor.
	"""
	global_position = ball.global_position
	var direction = (get_global_mouse_position() - global_position).normalized()
	rotation = direction.angle()


func start_power_adjustment() -> void:
	""" Start the power adjustment process.
	
	Locks in the aim direction and prepares for cue pullback.
	"""
	is_power_adjusting = true
	current_force = 0.0
	mouse_start_position = get_global_mouse_position()
	cue_start_position = mouse_start_position
	
	# Lock aim direction at moment of click
	aim_direction = (ball.global_position - mouse_start_position).normalized()
	
	logger.info("Power adjustment started, direction: %s" % [aim_direction])


func adjust_pullback(mouse_position: Vector2) -> void:
	""" Adjust the cue pullback based on mouse movement.
	
	Calculates the pullback distance and corresponding force,
	and updates the cue position accordingly.
	
	Args:
		mouse_position: The current mouse position.
	"""
	var pull_vector = mouse_position - cue_start_position
	
	# Use dot product to check if mouse is moving along aim direction
	var dot_product = pull_vector.dot(aim_direction)
	
	# Only allow pulling back (negative dot product), not pushing forward
	if sign(dot_product) == 1:
		pull_vector = Vector2.ZERO
	
	# Calculate cue offset (negative when pulling back)
	cue_offset = clamp(pull_vector.length() * sign(dot_product), -max_pullback, 0)
	
	# Move cue based on pullback distance
	global_position = ball.global_position + (aim_direction * cue_offset)
	
	# Calculate force based on pullback distance
	current_force = min(pull_vector.length(), max_force) * force_multiplier
	
	if Engine.get_frames_drawn() % 10 == 0:  # Only log every 10 frames
		logger.debug("Pullback: %.1f px, Force: %.1f" % [abs(cue_offset), current_force])


func shoot_ball() -> void:
	""" Apply force to the ball based on current power settings.
	
	Shoots the ball with the calculated force in the aim direction.
	"""
	if not is_power_adjusting:
		return
		
	is_power_adjusting = false
	hide()
	
	logger.info("Shot fired - Force: %.1f, Direction: %s" % [current_force, aim_direction])
	
	# Apply force to the ball
	ball.hit_ball(aim_direction, current_force)


func cancel_power_adjustment() -> void:
	""" Cancel the current power adjustment process.
	
	Resets power adjustment state variables and repositions the cue.
	"""
	is_power_adjusting = false
	cue_offset = 0.0
	current_force = 0.0
	global_position = ball.global_position
	logger.info("Power adjustment canceled")


func handle_mouse_button(event: InputEventMouseButton) -> void:
	""" Handle mouse button input events.
	
	Processes left clicks for power adjustment/shooting and right clicks for canceling.
	
	Args:
		event: The mouse button event to be processed.
	"""
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			start_power_adjustment()
		else:
			shoot_ball()
	elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed and is_power_adjusting:
		cancel_power_adjustment()
