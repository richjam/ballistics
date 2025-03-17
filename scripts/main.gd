extends Node2D

@export var ball_scene: PackedScene  # Assign `Ball.tscn` in Inspector

func _ready():
    # Connect all pockets to listen for potted balls
    for pocket in get_tree().get_nodes_in_group("pockets"):
        pocket.connect("ball_potted", Callable(self, "_on_ball_potted"))

func _on_ball_potted(ball):
    print("Ball removed:", ball.name)
  # ball.queue_free()  # Remove ball from play

    