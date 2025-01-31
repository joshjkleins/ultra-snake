extends PanelContainer

#@onready var reward_text: Label = $MarginContainer/VBoxContainer/RewardText

signal rewardChosen

var rewardType
var rewardAmount

func updateRewardInfo(type, amount):
	rewardType = type
	rewardAmount = amount
	var reward_text = $MarginContainer/VBoxContainer/RewardText
	if type == "Speed":
		reward_text.text = "Increase speed by " + str(amount * 100) + "%"
	elif type == "Bean":
		reward_text.text = "Increase chance for bean to spawn an additional bean by " + str(amount * 100) + "%"


func _on_reward_1_pressed() -> void:
	rewardChosen.emit(rewardType, rewardAmount)
