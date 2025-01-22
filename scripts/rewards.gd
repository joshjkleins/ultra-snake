extends Control
@onready var level_grid: Node2D = $"../.."

func _on_reward_1_pressed() -> void:
	level_grid.rewardChosen("Speed", 0.05)


func _on_reward_2_pressed() -> void:
	level_grid.rewardChosen("Bean", 0.10)
