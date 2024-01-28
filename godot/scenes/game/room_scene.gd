extends Node3D

@onready var clown_control: CanvasLayer = $ClownControl

const PLAYER_MOVEMENT_COUNTER_MAX := 70
const MIN_RANDOM_EVENT_TIME := 5.0
const MAX_RANDOM_EVENT_TIME := 10.0

var waiting_for_player_movement := ""
var player_movement_counter := 0
var random_event_timer := 0.0
var random_event_type := ""
var game_is_on := false

# Called when the node enters the scene tree for the first time.
func _ready():
	$room_base/room_inverted.visible = true

	clown_control.trigger_at(3.0, "start_game")

	random_event_timer = randf_range(MIN_RANDOM_EVENT_TIME, MAX_RANDOM_EVENT_TIME)
	random_event_type = "random_noise"

	$Decoration/BalloonAnimator.play("balloon_floating")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if game_is_on:
		random_event_timer -= delta
		if random_event_timer <= 0:
			clown_control.trigger(random_event_type)
			random_event_timer = randf_range(MIN_RANDOM_EVENT_TIME, MAX_RANDOM_EVENT_TIME)
			if randi_range(0, 1) == 0:
				random_event_type = "random_noise"
			else:
				random_event_type = "random_talk"


func _input(event):

	# this is for debugging - it emulates the events created by interaction with the bricks and the box
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_B:
			handle_box_hit()
		if event.keycode == KEY_S:
			handle_one_solved()
		if event.keycode == KEY_0:
			handle_level_0_finished()
		if event.keycode == KEY_1:
			handle_level_1_finished()
		if event.keycode == KEY_2:
			handle_level_2_finished()
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
	elif action == "prepare_level_0":
		prepare_level_0()
	elif action == "level_0_ready":
		handle_level_0_prepared()
	elif action == "prepare_level_1":
		prepare_level_1()
	elif action == "level_1_ready":
		handle_level_1_prepared()
	elif action == "prepare_level_2":
		prepare_level_2()
	elif action == "level_2_ready":
		handle_level_2_prepared()

func handle_box_hit():
	# this must be called when the user hits the box with a brick instead of inserting it
	clown_control.trigger("box_hit")
	random_event_type = "random_talk"
	random_event_timer = randf_range(1, 3)

func handle_one_solved():
	# this must be called when the user manages to insert a brick in a correct hole
	clown_control.trigger("one_solved")
	random_event_type = "random_talk"

func handle_level_0_finished():
	game_is_on = false
	clown_control.trigger("level_0_finished")

func handle_level_1_finished():
	game_is_on = false
	clown_control.trigger("level_1_finished")

func handle_level_2_finished():
	game_is_on = false
	clown_control.trigger("level_2_finished")

func handle_level_0_prepared():
	game_is_on = true
	clown_control.reset_level(0, 3600)

func handle_level_1_prepared():
	game_is_on = true
	clown_control.reset_level(1, 120)

func handle_level_2_prepared():
	game_is_on = true
	clown_control.reset_level(2, 60)


func _on_timer_timeout():
	$Decoration/ClownAnimator.play("clown_show")

func fade_out_scene():
	# todo
	pass

func fade_in_scene():
	# todo
	pass

func prepare_level_0():
	# todo
	pass

func prepare_level_1():
	# todo
	pass

func prepare_level_2():
	# todo
	pass

func prepare_level_3():
	# todo
	pass

func play_ending_scene():
	# todo
	pass

