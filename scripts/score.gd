extends Control

@onready var label = $Label
var score = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	label.text = "Score: " + str(score)


func addScore():
	score += 1
	label.text = "Score: " + str(score)

func resetScore():
	score = 0
	label.text = "Score: " + str(score)
