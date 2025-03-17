extends Area2D

signal ball_potted(ball)  # Signal when a ball is potted

func _ready():
	connect("body_entered", Callable(self, "_on_ball_entered"))

func _on_ball_entered(body):
	if body is RigidBody2D:  # Ensure it's a ball
		emit_signal("ball_potted", body)
		print("Ball potted:", body.name)

		# Tween disappearing effect
		var tween = create_tween()
		tween.tween_property(body, "scale", Vector2.ZERO, 0.3)
		tween.tween_callback(func(): body.queue_free())
