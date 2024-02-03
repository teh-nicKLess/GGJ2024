extends RigidBody3D

var should_flicker = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	apply_central_impulse(Vector3.LEFT * 0.2)

func turn_lights_on():
	$AnimationPlayer.play("lights_on")

func turn_lights_off():
	$AnimationPlayer.play("lights_off")

func flicker():
	should_flicker = true
	$AnimationPlayer.play("lights_off")

func _on_animation_player_animation_finished(anim_name):
	await get_tree().create_timer(0.5).timeout
	if should_flicker:
		$AnimationPlayer.play("lights_on")
		should_flicker = false
