extends Node2D

@export var player_one : Area2D
@export var player_one_score : Label
@export var player_two : Area2D
@export var player_two_score : Label
@export var ball : Area2D
@export var winner_screen : Control

var res = DisplayServer.window_get_size()
var rng = RandomNumberGenerator.new()
var ball_velocity : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	center_players()
	throw_ball()
	player_one_score.text = str(0)
	player_two_score.text = str(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_ball(delta)
	handle_death(delta)
	handle_players()
	process_winner()

func center_players():
	player_one.position.x = res.x / 8
	player_one.position.y = res.y / 2
	player_two.position.x = res.x - (res.x / 8)
	player_two.position.y = res.y / 2
	
	ball.position.y = res.y / 2
	ball.position.x = res.x / 2

func handle_players():
	var sprite_one = player_one.get_node("Sprite2D")
	var sprite_two = player_two.get_node("Sprite2D")
	var sprite_one_height = sprite_one.texture.get_height() * sprite_one.scale.y
	var sprite_two_height = sprite_two.texture.get_height() * sprite_two.scale.y
	
	if Input.is_action_pressed("Player1up"):
		player_one.position.y -= player_one.speed
	if Input.is_action_pressed("Player1down"):
		player_one.position.y += player_one.speed
	
	
	if Input.is_action_pressed("Player2up"):
		player_two.position.y -= player_two.speed
	if Input.is_action_pressed("Player2down"):
		player_two.position.y += player_two.speed
	
	player_one.position.y = clamp(player_one.position.y, sprite_one_height / 2, res.y - sprite_one_height / 2)
	
	player_two.position.y = clamp(player_two.position.y, sprite_two_height / 2, res.y - sprite_two_height / 2)

func throw_ball():
	var angle = 173  # Random angle between 30 and 150 degrees
	
	var radians = angle * PI/180 # convert angle in degree to angle in radians
		
	ball_velocity = Vector2(cos(radians), sin(radians)) * ball.speed
	


func move_ball(delta):
	ball.position += ball_velocity * delta

	# Ball collision with top and bottom of the screen
	if ball.position.y <= 0 or ball.position.y >= res.y:
		ball_velocity.y *= -1  # Reverse the y-direction


func _on_ball_area_entered(area):
	if area == player_one or area == player_two:
		# Reflect the ball's velocity
		ball_velocity.x *= -1

func handle_death(delta):
	if ball.position.x < player_one.position.x:
		update_score(player_two_score)
		handle_death_color(player_one)
		ball_velocity *= -1
		
	elif ball.position.x > player_two.position.x:
		update_score(player_one_score)
		handle_death_color(player_two)
		ball_velocity *= -1
		
func handle_death_color(player):
	var sprite = player.get_node("Sprite2D")
	sprite.modulate = Color(1, 0, 0)  # Turn red

	# Create and start a timer to revert the color
	var timer = Timer.new()
	timer.wait_time = 0.03  # 1 second
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout.bind(sprite))
	add_child(timer)
	timer.start()

func _on_timer_timeout(sprite):
	sprite.modulate = Color(1, 1, 1)  # Revert to original color

func update_score(score_label):
	score_label.text = str(int(score_label.text) + 1)

func process_winner():
	if int(player_one_score.text) >= 10:
		ball_velocity = Vector2(0, 0)
		winner_screen.get_node("WinnerText").text = "Player 1 won!"
		winner_screen.show()
		return
		
	if int(player_two_score.text) >= 10:
		ball_velocity = Vector2(0, 0)
		winner_screen.get_node("WinnerText").text = "Player 2 won!"
		winner_screen.show()
		return
		
