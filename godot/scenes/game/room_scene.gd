extends Node3D

@onready var clown_control: CanvasLayer = $ClownControl

const PLAYER_MOVEMENT_COUNTER_MAX := 70
const MIN_RANDOM_EVENT_TIME := 5.0
const MAX_RANDOM_EVENT_TIME := 15.0

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

    $BalloonAnimator.play("balloon_floating")

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
    elif action == "level_0_ready":
        game_is_on = true
        clown_control.reset_level(0, 3600)

func handle_box_hit():
    # this must be called when the user hits the box with a brick instead of inserting it
    clown_control.trigger("box_hit")
    random_event_type = "random_talk"
    random_event_timer = randf_range(1, 3)

func handle_one_solved():
    # this must be called when the user manages to insert a brick in a correct hole
    clown_control.trigger("one_solved")
    random_event_type = "random_talk"



func _on_timer_timeout():
    $ClownAnimator.play("clown_show")
