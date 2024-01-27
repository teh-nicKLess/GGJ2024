extends Node3D

@onready var clown_control: CanvasLayer = $ClownControl

const PLAYER_MOVEMENT_COUNTER_MAX := 100

var waiting_for_player_movement := ""
var player_movement_counter := 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$room_base/room_inverted.visible = true

	clown_control.trigger_at(3.0, "start_game")
	
	$AnimationPlayer.play("balloon_floating")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event):

	# this is for debugging - it emulates the events created by interaction with the bricks and the box
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_B:
			clown_control.trigger("box_hit")
		if event.keycode == KEY_S:
			clown_control.trigger("one_solved")
	elif event is InputEventMouseMotion and waiting_for_player_movement:
		player_movement_counter += 1
		if player_movement_counter >= PLAYER_MOVEMENT_COUNTER_MAX:
			if waiting_for_player_movement == "game_intro_waiting_player":
				clown_control.trigger("continue_level_0")
				waiting_for_player_movement = ""


func _on_clown_control_action_triggered(action: String) -> void:
	if action == "game_intro_waiting_player":
		waiting_for_player_movement = action
		player_movement_counter = 0

