extends Node3D


@onready
var camera : Camera3D = $Path3D/PathFollow3D/camera
@onready
var blood_animplayer : AnimationPlayer = $blood_aniplayer
@onready
var cam_animplayer : AnimationPlayer = $cam_aniplayer
@onready
var credits : Control = $credits


# Called when the node enters the scene tree for the first time.
func _ready():
	# Switch to cutscene camera
	camera.current = true
	
	blood_animplayer.play("blood_pool")
	cam_animplayer.play("cam")
	
	var fade_tween = get_tree().create_tween()
	fade_tween.tween_property(credits, "modulate", Color.WHITE, 3.0).set_delay(10.0)
