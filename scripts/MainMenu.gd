extends Control

var save_path = "res://variable.save"
@onready var high_score: Label = $PanelContainer/MarginContainer/VBoxContainer/HighScore

# Called when the node enters the scene tree for the first time.
func _ready():
	load_data()


func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://scenes/levelGrid.tscn")


func _on_quit_button_pressed():
	get_tree().quit()


func load_data():
	var saveData = 0
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		saveData = file.get_var()
		file.close()
	else:
		print('no saved data found')
	print(saveData)
	high_score.text = "High Score: " + str(saveData.Score)
