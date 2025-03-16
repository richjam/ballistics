extends Node2D
## [u]Pool Cue Controller[/u] [br]
## Handles the aiming and shooting mechanics for a pool cue in a pool game. 
## The cue allows player to aim, adjust power through pullback, and shoot the ball.


@onready var logger = $"/root/GameLogger".get_logger("Cue")  ## Logger for cue component

@export var ball: RigidBody2D  ## The ball RigidBody2D that this cue will hit.
@export var max_force: float = 600.0  ## Maximum force that can be applied to the ball.
@export var max_pullback: float = 200.0  ## Maximum distance the cue can be pulled back.
@export var force_multiplier: float = 5.0  ## Multiplier for calculating force from pullback distance.

var is_power_adjusting: bool = false  ## Whether the player is currently adjusting shot power.
var is_ball_ready: bool = false  ## Whether the ball is stationary and ready to be hit.
var aim_direction: Vector2 = Vector2.ZERO  ## The locked direction for aiming after initial click.
var cue_start_position: Vector2 = Vector2.ZERO  ## Initial position of the mouse when starting pullback.
var mouse_start_position: Vector2 = Vector2.ZERO  ## Initial position of the mouse when aiming starts.
var cue_offset: float = 0.0  ## Current pullback distance of the cue.
var current_force: float = 0.0  ## Current force calculated from pullback distance.


## Initialize the cue in a hidden state until the ball stops.
func _ready() -> void:
	hide()
	logger.info("Initialized and waiting for ball to stop")


## Main process function called every frame. [br][br]
## [b]Args[/b][br]
## [param _delta]: Time elapsed since previous frame.
func _process(_delta: float) -> void:
	update_ball_readiness()
	
	if is_ball_ready:
		show()
		if not is_power_adjusting:
			update_cue_position()
	else:
		hide()


## Handle input events for cue control. [br]
## Processes mouse button and motion events for power adjustment and shooting. [br][br]
## [b]Args[/b][br]
## [param event]: The input event to be processed.
func _input(event: InputEvent) -> void:
	if not is_ball_ready:
		return
		
	if event is InputEventMouseButton:
		handle_mouse_button(event)
	elif event is InputEventMouseMotion and is_power_adjusting:
		adjust_pullback(event.position)


## Check if the ball is stationary and ready to be hit. [br]
func update_ball_readiness() -> void:
	var was_ready = is_ball_ready
	is_ball_ready = not ball.is_moving()
	
	# Log state changes
	if is_ball_ready != was_ready:
		if is_ball_ready:
			logger.info("Ball stopped, cue ready")
		else:
			logger.info("Ball in motion, cue disabled")


## Update the cue position and rotation based on mouse position.
func update_cue_position() -> void:
	global_position = ball.global_position
	var direction = (get_global_mouse_position() - global_position).normalized()
	rotation = direction.angle()


## Start the power adjustment process. [br]
## Locks in the aim direction and prepares for cue pullback.
func start_power_adjustment() -> void:
	is_power_adjusting = true
	current_force = 0.0
	mouse_start_position = get_global_mouse_position()
	cue_start_position = mouse_start_position
	
	# Lock aim direction at moment of click
	aim_direction = (ball.global_position - mouse_start_position).normalized()
	
	logger.info("Power adjustment started, direction: %s" % [aim_direction])


## Adjust the cue pullback based on mouse movement. [br]
## Calculates the pullback distance and corresponding force and updates the cue position accordingly. [br][br]
## [b]Args[/b][br]
## [param mouse_position]: The current mouse position.
func adjust_pullback(mouse_position: Vector2) -> void:
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
	current_force = min(pull_vector.length() * force_multiplier, max_force)
	
	if Engine.get_frames_drawn() % 10 == 0:  # Only log every 10 frames
		logger.debug("Pullback: %.1f px, Force: %.1f" % [abs(cue_offset), current_force])


## Apply force to the ball based on current power settings. [br]
## Shoots the ball with the calculated force in the aim direction.
func shoot_ball() -> void:
	if not is_power_adjusting:
		return
		
	is_power_adjusting = false
	hide()
	
	logger.info("Shot fired - Force: %.1f, Direction: %s" % [current_force, aim_direction])
	
	# Apply force to the ball
	ball.hit_ball(aim_direction, current_force)


## Cancel the current power adjustment process. [br]
## Resets power adjustment state variables and repositions the cue.
func cancel_power_adjustment() -> void:
	is_power_adjusting = false
	cue_offset = 0.0
	current_force = 0.0
	global_position = ball.global_position
	logger.info("Power adjustment canceled")


## Handle mouse button input events. [br]
## Processes left clicks for power adjustment/shooting and right clicks for canceling. [br][br]
## [b]Args[/b][br]
## [param event]: The mouse button event to be processed.
func handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			start_power_adjustment()
		else:
			shoot_ball()
	elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed and is_power_adjusting:
		cancel_power_adjustment()
