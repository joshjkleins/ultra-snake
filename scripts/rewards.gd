extends Control
@onready var level_grid: Node2D = $"../.."
@onready var rewards_container: HBoxContainer = $Panel/MarginContainer/VBoxContainer/RewardsContainer

var rng = RandomNumberGenerator.new()
var rewards = ["Speed", "Bean"]
var rewardValues = [0.03, 0.05, 0.07, 0.10]

var reward1 = "Speed"
var reward2 = "Bean"
var reward1Value
var reward2Value

var reward = preload("res://scenes/reward.tscn")

func rewardChosen(type, amount):
	level_grid.rewardChosen(type, amount)


func rollRewards():
	var reward1Value = rng.randi_range(1, 100)
	if reward1Value < 5:
		reward1Value = rewardValues[3]
	elif reward1Value < 20:
		reward1Value = rewardValues[2]
	elif reward1Value < 55:
		reward1Value = rewardValues[1]
	else:
		reward1Value = rewardValues[0]
	
	var reward2Value = rng.randi_range(1, 100)
	if reward2Value < 5:
		reward2Value = rewardValues[3]
	elif reward2Value < 20:
		reward2Value = rewardValues[2]
	elif reward2Value < 55:
		reward2Value = rewardValues[1]
	else:
		reward2Value = rewardValues[0]
	
	var reward1Scene = reward.instantiate()
	reward1Scene.updateRewardInfo(reward1, reward1Value)
	var reward2Scene = reward.instantiate()
	reward2Scene.updateRewardInfo(reward2, reward2Value)
	
	rewards_container.add_child(reward1Scene)
	rewards_container.add_child(reward2Scene)


func _on_reward_reward_chosen(type, amount) -> void:
	level_grid.rewardChosen(type, amount)
