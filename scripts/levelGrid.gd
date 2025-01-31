extends Node2D

var save_path = "res://savegame.data"
var astar_grid
@onready var player = $Player
@onready var game_over = $CanvasLayer/GameOver
@onready var beans = $beans
@onready var score = $CanvasLayer/Score
@onready var border = $Border
@onready var win_screen = $CanvasLayer/WinScreen
@onready var camera = $Camera2D
@onready var pause_menu: Control = $CanvasLayer/PauseMenu
@onready var pickup_sfx: AudioStreamPlayer2D = $PickupSFX
@onready var rewards: Control = $CanvasLayer/Rewards

var highScore

var beanXPos = []
var beanYPos = []

var startingPosition = Vector2(0, 0)
var gridOffset = Vector2(8, 8)

var bean = preload("res://scenes/bean.tscn")
var explosion2 = preload("res://scenes/explosion2.tscn")

var rng = RandomNumberGenerator.new()

var gameOver = false
@export var gridWidth = 15
@export var gridHeight = 40
var maxScore = gridWidth * gridHeight

var explosionAmount = 3

var secondBeanSpawnChance = 0.0
var secondBeanSpawn = false


# Called when the node enters the scene tree for the first time.
func _ready():
	getHighScore()
	#create grid
	astar_grid = AStarGrid2D.new()
	astar_grid.region = Rect2i(0, 0, gridWidth, gridHeight)
	astar_grid.cell_size = Vector2(16, 16)
	astar_grid.set_offset(gridOffset)
	astar_grid.update()
	drawBorder()
	player.setStartingPosition(startingPosition)
	
	for i in range(gridWidth):
		beanXPos.append(i)
	for i in range(gridHeight):
		beanYPos.append(i)
	spawnBean()
	
	setCamera()

func _process(_delta):
	#Pausing functionality
	if Input.is_action_just_pressed("menu") and !gameOver:
		if pause_menu.visible:
			unpauseGame()
		else:
			pauseGame()

func setCamera():
	var middleOfGrid = astar_grid.get_point_position(Vector2(gridWidth / 2, gridHeight / 2))
	var halfOfScreen = get_viewport_rect().size / 2
	camera.position = middleOfGrid - halfOfScreen  #set position to middle of grid minus half the size of window (accounting for offset)

func drawBorder():
	var topLeft = astar_grid.get_point_position(Vector2(0, 0))
	var topRight = astar_grid.get_point_position(Vector2(gridWidth - 1, 0))
	var bottomLeft = astar_grid.get_point_position(Vector2(0, gridHeight - 1))
	var bottomRight = astar_grid.get_point_position(Vector2(gridWidth - 1, gridHeight - 1))
	
	border.add_point(topLeft - Vector2(16, 16))
	border.add_point(topRight - Vector2(-16, 16))
	border.add_point(bottomRight - Vector2(-16, -16))
	border.add_point(bottomLeft - Vector2(16, -16))
	border.closed = true

func spawnBean():
	var newBean = bean.instantiate()
	
	#temporary all potential bean positions
	var tempXPos = beanXPos
	var tempYPos = beanYPos
	
	#remove positions that the snake body are occupying
	for i in player.snakePositionArray:
		tempXPos.erase(i.x)
		tempYPos.erase(i.y)
	
	var beanPosition = Vector2(tempXPos.pick_random(), tempYPos.pick_random())
	
	newBean.position = astar_grid.get_point_position(beanPosition)
	beans.call_deferred("add_child", newBean)
	
	
	if secondBeanSpawnChance > 0.0 and secondBeanSpawn == false:
		var chance = rng.randf_range(0.0, 1.0)
		if chance <= secondBeanSpawnChance:
			secondBeanSpawn = true
			spawnBean()
	else:
		secondBeanSpawn = false
	

func beanPickedUp(location):
	pickup_sfx.set_pitch_scale(rng.randf_range(0.8, 1.5))
	pickup_sfx.play()
	var newExplosion = explosion2.instantiate()
	newExplosion.position = location
	add_child(newExplosion)
	#newExplosion.emitting = true
	explosionAmount += 1
	newExplosion.explode(explosionAmount)
	player.growSnake()
	score.addScore()
	if score.score >= maxScore:
		win()
	else:
		spawnBean()

func win():
	player.move_timer.stop()
	#rewards.rollRewards()
	rewards.visible = true


func pauseGame():
	player.process_mode = PROCESS_MODE_DISABLED
	pause_menu.visible = true

func unpauseGame():
	if !gameOver:
		player.process_mode = PROCESS_MODE_INHERIT #disable player(snake) process functionality
		pause_menu.visible = false

func showGameOver():
	save()
	gameOver = true
	game_over.visible = true

func restart():
	gameOver = false
	game_over.visible = false
	for b in beans.get_children():
		beans.remove_child(b)
		b.queue_free()
	player.clearData()
	player.setStartingPosition(startingPosition)
	score.resetScore()
	spawnBean()
	unpauseGame()

func save():
	if highScore == null:
		var file = FileAccess.open(save_path, FileAccess.WRITE)
		file.store_var(score.score)
		file.close()
	else:
		if score.score > highScore or highScore == null:
			var file = FileAccess.open(save_path, FileAccess.WRITE)
			var saveData = {
				"Score": score.score
			}
			file.store_var(saveData)
			file.close()

func load_data():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var saveData = file.get_var()
		highScore = saveData
		file.close()

func getHighScore():
	load_data()

func rewardChosen(reward, amount):
	if reward == "Speed":
		player.updateSpeed(amount)
	elif reward == "Bean":
		secondBeanSpawnChance += amount
	rewards.visible = false
	restart()
