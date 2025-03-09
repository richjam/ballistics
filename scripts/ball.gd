extends RigidBody2D

# Threshold to consider the ball as "stopped"
@export var ball_stop_threshold: float = 2.0


func _ready():
	set_linear_velocity((Vector2.ZERO))

# Example function to apply a force to the ball
func hit_ball(direction: Vector2, force: float) -> void:
	var impulse = direction.normalized() * force
	linear_velocity = impulse


func is_moving():
	return linear_velocity.length() >= ball_stop_threshold
