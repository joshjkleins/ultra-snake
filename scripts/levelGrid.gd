extends Node2D

var astar_grid
@onready var player = $Player
@onready var game_over = $CanvasLayer/GameOver
@onready var beans = $beans
@onready var score = $CanvasLayer/Score
@onready var border = $Border
@onready var win_screen = $CanvasLayer/WinScreen
@onready var camera = $Camera2D


var beanXPos = []
var beanYPos = []

var startingPosition = Vector2(0, 0)
var gridOffset = Vector2(8, 8)

var bean = preload("res://scenes/bean.tscn")
var explosion = preload("res://scenes/explosion.tscn")

var gameOver = false
@export var gridWidth = 15
@export var gridHeight = 40
var maxScore = gridWidth * gridHeight



#TODO
#persistent score
#camera to get game in middle of screen (find center of grid and focus camera on that? idk)
#better particles

# Called when the node enters the scene tree for the first time.
func _ready():
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
	if Input.is_action_just_pressed("menu"):
		if game_over.visible:
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

func beanPickedUp(location):
	var newExplosion = explosion.instantiate()
	newExplosion.position = location
	add_child(newExplosion)
	newExplosion.emitting = true
	player.growSnake()
	score.addScore()
	if score.score >= maxScore:
		win()
	else:
		spawnBean()

func win():
	#show win screen
	player.move_timer.stop()
	win_screen.visible = true


func pauseGame():
	player.process_mode = PROCESS_MODE_DISABLED
	game_over.visible = true

func unpauseGame():
	if !gameOver:
		player.process_mode = PROCESS_MODE_INHERIT #disable player(snake) process functionality
		game_over.visible = false

func showGameOver():
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
