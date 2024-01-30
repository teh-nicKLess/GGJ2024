extends Node3D

@onready var clown_control: CanvasLayer = $ClownControl

var shape_matching_1 = preload("res://scenes/game/ShapeMatching/shape_matching_1.tscn")
var shape_matching_2 = preload("res://scenes/game/ShapeMatching/shape_matching_2.tscn")
var shape_matching_3 = preload("res://scenes/game/ShapeMatching/shape_matching_3.tscn")
var clown_end = preload("res://scenes/game/clown_end.tscn")

const PLAYER_MOVEMENT_COUNTER_MAX := 70
const MIN_RANDOM_EVENT_TIME := 15.0
const MAX_RANDOM_EVENT_TIME := 20.0

var waiting_for_player_movement := ""
var player_movement_counter := 0
var random_event_timer := 0.0
var random_event_type := ""
var game_is_on := false
var level_timeout_timer := 0.0
var current_puzzle : Node3D = null

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
		level_timeout_timer -= delta * (16.0 if Input.is_key_pressed(KEY_SPACE) else 1.0)
		if random_event_timer <= 0:
			clown_control.trigger(random_event_type)
			random_event_timer = randf_range(MIN_RANDOM_EVENT_TIME, MAX_RANDOM_EVENT_TIME)
			if randi_range(0, 1) == 0:
				random_event_type = "random_noise"
			else:
				random_event_type = "random_talk"
		if level_timeout_timer <= 0:
			level_timed_out()


func _input(event):

	# this is for debugging - it emulates the events created by interaction with the bricks and the box
	if false and event is InputEventKey and event.pressed:
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
		if event.keycode == KEY_9:
			play_ending_scene()
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

func handle_double_fill():
	# this must be called when the user manages to insert a brick in a correct hole
	clown_control.trigger("double_fill")
	play_ending_scene()

func handle_level_0_finished():
	game_is_on = false
	clown_control.trigger("level_0_finished")

func handle_level_1_finished():
	game_is_on = false
	clown_control.trigger("level_1_finished")

func handle_level_2_finished():
	game_is_on = false
	clown_control.trigger("level_2_finished")
	play_ending_scene()

func handle_level_0_prepared():
	game_is_on = true
	clown_control.reset_level(0, 300)
	level_timeout_timer = 300

func handle_level_1_prepared():
	game_is_on = true
	clown_control.reset_level(1, 120)
	level_timeout_timer = 120

func handle_level_2_prepared():
	game_is_on = true
	clown_control.reset_level(2, 20)
	level_timeout_timer = 60

func _on_timer_timeout():
	$Decoration/ClownAnimator.play("clown_show")

func level_timed_out():
	clown_control.trigger("timeout_kill")
	game_is_on = false
	play_ending_scene()


func fade_out_scene():
	# todo
	pass

func fade_in_scene():
	# todo
	pass

func prepare_level_0():
	$room_base/Ceiling/JoltConeTwistJoint3D/Lamp.flicker()
	_prepare_level(0)

func prepare_level_1():
	$room_base/Ceiling/JoltConeTwistJoint3D/Lamp.flicker()
	_prepare_level(1)

func prepare_level_2():
	$room_base/Ceiling/JoltConeTwistJoint3D/Lamp.flicker()
	_prepare_level(2)

func _prepare_level(number):
	# Wait for the lights to go out
	await get_tree().create_timer(0.8).timeout
	
	var table = find_child("operating_table")
	if current_puzzle:
		current_puzzle.get_parent().remove_child(current_puzzle)
		current_puzzle.queue_free()
	#var previous = table.find_child("ShapeMatching*")
	#if previous:
		#table.remove_child(previous)
		#previous.queue_free()
		#previous.visible = false
		#previous.global_position = Vector3(0, -1000, 0)

	var next : Node3D
	match number:
		0: next = shape_matching_1.instantiate()
		1: next = shape_matching_2.instantiate()
		2: next = shape_matching_3.instantiate()

	table.add_child(next)
	next.position = Vector3(0.1, 0.73, 0)
	next.rotate_y(PI/2.0)
	
	current_puzzle = next

	next.connect("one_solved", handle_one_solved)
	next.connect("box_hit", handle_box_hit)
	next.connect("double_fill", handle_double_fill)

	if number == 0:
		next.connect("level_solved", handle_level_0_finished)
	elif number == 1:
		next.connect("level_solved", handle_level_1_finished)
	elif number == 2:
		next.connect("level_solved", handle_level_2_finished)

func play_ending_scene():
	$room_base/Ceiling/JoltConeTwistJoint3D/Lamp.flicker()
	
	var table = find_child("operating_table")
	var puzzle = table.find_child("ShapeMatching*")
	var chair = find_child("painted_wooden_chair_01_2k")
	if puzzle:
		table.remove_child(puzzle)
		puzzle.queue_free()
	table.get_parent().remove_child(table)
	table.queue_free()
	chair.get_parent().remove_child(chair)
	chair.queue_free()
	
	var ending = clown_end.instantiate()
	ending.rotate_y(PI/2.0)
	add_child(ending)


