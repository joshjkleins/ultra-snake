extends Node2D

var moveTowards = Vector2(1, 0)
var currentPosition
@onready var main = $".."
@onready var snakes = $Snakes
var snake = preload("res://scenes/snake.tscn")
var shouldAddSnake = false
var snakePositionArray = [] #keeps track of relevent grid position for following snake bits
@onready var move_timer = $MoveTimer
var waitTime = 0.25

var nextDirection
var currentDirection

#Starting position set in levelGrid and passed down
func setStartingPosition(startingPosition):
	position = main.astar_grid.get_point_position(startingPosition)
	currentPosition = startingPosition

func _ready():
	move_timer.wait_time = waitTime

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#Nested if statements prevent players from going the opposite direction immediately
	if Input.is_action_pressed("down"):
		nextDirection = "down"
	if Input.is_action_pressed("left"):
		nextDirection = "left"
	if Input.is_action_pressed("right"):
		nextDirection = "right"
	if Input.is_action_pressed("up"):
		nextDirection = "up"


func _on_move_timer_timeout():
	#Logic for moving head snake on timeout and preventing from moving in the opposite direction
	var nextDirectionLocked = nextDirection
	if nextDirectionLocked == "down" and currentDirection != "up":
		currentDirection = "down"
		moveTowards = Vector2(0, 1)
	elif nextDirectionLocked == "up" and currentDirection != "down":
		currentDirection = "up"
		moveTowards = Vector2(0, -1)
	elif nextDirectionLocked == "left" and currentDirection != "right":
		currentDirection = "left"
		moveTowards = Vector2(-1, 0)
	elif nextDirectionLocked == "right" and currentDirection != "left":
		currentDirection = "right"
		moveTowards = Vector2(1, 0)
	
	#move player
	var newPosition = currentPosition + moveTowards
	if main.astar_grid.is_in_boundsv(newPosition): #checking for out of bounds
		
		if snakePositionArray.has(main.astar_grid.get_point_position(newPosition)): #check if new position is found in snakepositionarray
			#snake ran into itself
			lose()
		position = main.astar_grid.get_point_position(newPosition) #move head of snake
		
		#all subsequent snake movement handled here
		if snakes.get_child_count() != 0:
			for s in range(snakes.get_children().size()):
				var thisSnakePos = snakePositionArray[snakePositionArray.size() - (s + 1)]
				snakes.get_child(s).position = thisSnakePos
		
		#adding new snake
		if shouldAddSnake:
			var newSnake = snake.instantiate()
			newSnake.position = main.astar_grid.get_point_position(currentPosition)
			snakes.add_child(newSnake)
			shouldAddSnake = false
		
		#keep position array to just the size it needs
		var arraySize = snakes.get_child_count() + 1
		snakePositionArray.append(main.astar_grid.get_point_position(newPosition))
		if snakePositionArray.size() >= arraySize:
			snakePositionArray.pop_front()
		
		
		currentPosition = newPosition
	else:
		lose()

func lose():
	move_timer.stop()
	main.showGameOver()


func growSnake():
	shouldAddSnake = true

func clearData():
	shouldAddSnake = false
	snakePositionArray = []
	for n in snakes.get_children():
		snakes.remove_child(n)
		n.queue_free()
	move_timer.one_shot = false
	nextDirection = "right"
	currentDirection = "right"
	move_timer.start()

func updateSpeed(amount):
	var currentWaitTime = move_timer.get_wait_time()
	waitTime = (currentWaitTime * (amount - 1.00)) * -1
	move_timer.set_wait_time(waitTime)
