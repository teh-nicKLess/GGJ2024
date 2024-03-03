class_name PlayerController extends Node3D

## Shorthands for the children of PlayerController
@onready var camera := $Camera3D
@onready var raycast := $Camera3D/RayCast3D
@onready var aim_dot := $Camera3D/RayCast3D/AimDot
@onready var object_target := $Camera3D/ObjectTarget

## Mouse Sensitivity for looking around
## TODO: add setting for that
@export_range(0.0, 1.0) var look_sensitivity: float = 0.25

## Bounds that determine, how far the player can turn their head in each direction
@export_range(0, 90) var view_bound_hori: int = 45
@export_range(0, 90) var view_bound_vert: int = 60

## Movement vector of the mouse for the current state. Is reset to (0, 0)
var _last_mouse_movement = Vector2(0.0, 0.0)
var _total_pitch = 0.0
var _total_yaw = 0.0

var _is_game_on := false

var grabbed_object : RigidBody3D = null
var is_rotating_grabbed := false
var shift := false

var object_dist_min = 0.3
var object_dist_max = 2.0
var object_rotation_speed = 0.02

var is_snapping_active = false
var unsnap_linear_threshold = 0.005


# Set up for mouse look and connect to room scene signal for the blocking of user interaction 
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	%RoomScene.connect("is_game_on_switched", _switch_is_game_on)


func _input(event):
	# Receives mouse motion
	if event is InputEventMouseMotion:
		_last_mouse_movement = event.relative
		
	# Receives mouse button input
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT: # attempt to grab object
				if _is_game_on:
					if event.pressed:
						if grabbed_object:
							_release_object()
						else:
							_grab_object()
			MOUSE_BUTTON_RIGHT: # attempt to activate object rotation
				is_rotating_grabbed = event.pressed
			MOUSE_BUTTON_WHEEL_UP: # attempt to push object away
				if event.pressed and grabbed_object: _push_grabbed()
			MOUSE_BUTTON_WHEEL_DOWN: # attempt to pull object towards player
				if event.pressed and grabbed_object: _pull_grabbed()

	if event is InputEventKey:
		match event.keycode:
			KEY_SHIFT:
				shift = event.pressed


# Updates mouselook and movement every frame
func _process(_delta):
	if not is_rotating_grabbed:
		_update_mouselook()
		_update_aim_dot()


# Moves or rotates currently held opbject
func _physics_process(delta):
	if grabbed_object:
		if is_rotating_grabbed:
			_rotate_grabbed()
		else:
			_update_grabbed_position(delta)


# Updates mouse look
func _update_mouselook():
	
	_last_mouse_movement *= look_sensitivity
	var yaw = _last_mouse_movement.x
	var pitch = _last_mouse_movement.y
	_last_mouse_movement = Vector2(0, 0)
	
	# Prevents looking up/down too far
	pitch = clamp(pitch, -view_bound_vert - _total_pitch, view_bound_vert - _total_pitch)
	yaw = clamp(yaw, -view_bound_hori - _total_yaw, view_bound_hori - _total_yaw)

	_total_pitch += pitch
	_total_yaw += yaw

	camera.rotate_y(deg_to_rad(-yaw))
	camera.rotate_object_local(Vector3(1,0,0), deg_to_rad(-pitch))


# Updates the red laser dot that shows where the player is currently looking to
# facilitate interaction with objects
# TODO: SpringArm3D has a similar built-in functionality. Might be a bit more performant.
func _update_aim_dot():
	raycast.force_raycast_update()
	if not raycast.is_colliding() or grabbed_object:
		# Hide aim dot if not colliding with anything or while carrying object
		aim_dot.set_visible(false)
	else:
		# Update aim dot
		aim_dot.set_visible(_is_game_on)
		var ray_position = raycast.get_collision_point()
		var ray_normal = raycast.get_collision_normal()
		aim_dot.global_position = ray_position + 0.003 * ray_normal
		aim_dot.global_rotation = ray_normal.rotated(Vector3(0,0,1), PI/2.0)


func _grab_object():
	var object = raycast.get_collider()
	if not object:
		return
	object_target.position.z = - camera.global_position.distance_to(object.global_position)
	if object and object is RigidBody3D:
		grabbed_object = object
		#object.set_freeze_enabled(true)
		object.set_gravity_scale(0.0)


func _release_object():
	#grabbed_object.set_freeze_enabled(false)
	grabbed_object.set_gravity_scale(1.0)
	grabbed_object = null
	is_rotating_grabbed = false


func snap_object_to_target(snap_position : Vector3):
	if grabbed_object:
		is_snapping_active = true
		grabbed_object.set_global_position(snap_position + Vector3(0, 0.02, 0))


func _update_grabbed_position(delta):
	var target_pos = grabbed_object.global_position.lerp(object_target.global_position, 3.0 * delta)
	var old_position = grabbed_object.global_position
	grabbed_object.move_and_collide(target_pos - grabbed_object.global_position)
	
	if is_snapping_active:
		if grabbed_object.global_position.distance_to(old_position) > unsnap_linear_threshold:
			is_snapping_active = false
		else:
			grabbed_object.global_position.x = old_position.x
			grabbed_object.global_position.z = old_position.z


func _rotate_grabbed():
	#var old_rotation = grabbed_object.global_rotation
	grabbed_object.rotate_x(_last_mouse_movement.y * object_rotation_speed)
	
	if shift:
		grabbed_object.rotate_z(_last_mouse_movement.x * object_rotation_speed)
	else:
		grabbed_object.rotate_y(_last_mouse_movement.x * object_rotation_speed)
	_last_mouse_movement = Vector2(0, 0)
	
	#if is_snapping_active:
		#if grabbed_object.global_rotation.dot(old_rotation) > (1.0 - unsnap_angular_threshold):
			#is_snapping_active = false
		#else:
			#grabbed_object.set_global_rotation(old_rotation)


func _pull_grabbed():
	object_target.position.z = clamp(object_target.position.z + 0.1, -object_dist_max, -object_dist_min)


func _push_grabbed():
	object_target.position.z = clamp(object_target.position.z - 0.1, -object_dist_max, -object_dist_min)


func _switch_is_game_on(new_state : bool) ->  void:
	_is_game_on = new_state
	if not _is_game_on and grabbed_object:
		_release_object()
