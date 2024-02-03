extends Node2D

@onready var fade_overlay = %FadeOverlay
@onready var pause_overlay = %PauseOverlay

func _ready() -> void:
	fade_overlay.visible = true

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if SaveGame.has_save():
		SaveGame.load_game(get_tree())

	pause_overlay.game_exited.connect(_save_game)

	for shape_matching in find_children("ShapeMatching*"):
		shape_matching.object_snapping.connect(snap_object)


func _input(event) -> void:
	if event.is_action_pressed("pause") and not pause_overlay.visible:
		get_viewport().set_input_as_handled()
		get_tree().paused = true
		pause_overlay.grab_button_focus()
		pause_overlay.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _save_game() -> void:
	SaveGame.save_game(get_tree())


func snap_object(snap_position : Vector3):
	$PlayerController.snap_object_to_target(snap_position)
