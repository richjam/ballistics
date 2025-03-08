extends RigidBody2D

# Ball physics and behavior

func _ready():
    set_linear_velocity(Vector2(2000,1000))

# Example function to apply a force to the ball
func hit_ball(direction: Vector2, force: float) -> void:
    apply_impulse(Vector2.ZERO, direction.normalized() * force)

    