extends Control

@onready var level_grid = $"../.."

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false

func _on_quit_pressed():
	get_tree().quit()

func _on_start_over_pressed():
	level_grid.restart()
	visible = false


func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
