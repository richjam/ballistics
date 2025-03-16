extends RigidBody2D
""" Pool Ball Controller
Handles the physics behavior of a ball in a pool game.
Includes movement, collision response, and state tracking.
"""

@onready var logger = $"/root/GameLogger".get_logger("Ball") # Get component-specific logger

@export var ball_stop_threshold: float = 2.0  # Velocity below which ball is considered stopped
@export var friction_multiplier: float = 1.0  # Adjusts how quickly the ball slows down

var _last_hit_force: float = 0.0  # Tracks force of the last hit
var _last_hit_direction: Vector2 = Vector2.ZERO  # Tracks direction of last hit
var _was_moving: bool = false  # Previous frame movement state


func _ready() -> void:
	""" Initialize the ball in a stopped state.
	"""
	set_linear_velocity(Vector2.ZERO)


func _process(_delta: float) -> void:
	""" Process ball movement and state changes.
	
	Args:
	    _delta: Time elapsed since previous frame.
	"""
	_check_movement_state()


func _check_movement_state() -> void:
	""" Track changes in ball movement state for logging.
	"""
	var moving = is_moving()
	
	if moving != _was_moving:
		if moving:
			logger.debug("Ball started moving")
		else:
			logger.debug("Ball stopped", {
				"position": global_position,
				"total_travel": _last_hit_force
			})
	
	_was_moving = moving


func hit_ball(direction: Vector2, force: float) -> void:
	""" Apply force to the ball in a specific direction.
	
	Args:
	    direction: Normalized direction vector for the hit.
	    force: Magnitude of force to apply.
	"""
	var impulse = direction.normalized() * force
	linear_velocity = impulse
	
	_last_hit_direction = direction
	_last_hit_force = force


func is_moving() -> bool:
	""" Check if the ball is moving based on velocity threshold.
	
	Returns:
	    True if the ball is moving above the stop threshold.
	"""
	return linear_velocity.length() >= ball_stop_threshold


func reset_ball(reset_position: Vector2) -> void:
	""" Reset the ball to a specific position with no movement.
	
	Args:
	    position: Position to place the ball.
	"""
	global_position = reset_position
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	_last_hit_force = 0.0
	_last_hit_direction = Vector2.ZERO
	
	logger.debug("Ball reset", {"position": reset_position})
