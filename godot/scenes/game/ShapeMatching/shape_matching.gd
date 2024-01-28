extends Node3D

var number_solved = 0

signal box_hit
signal one_solved
signal fallen_item
signal double_fill
signal object_snapping

var areas
#var snap_areas

#@export var target_positions : Array[Vector3] = []
#@export var target_rotations : Array[Vector3] = []
##var linear_snapping_threshold = 0.05
##var angular_snapping_threshold = PI/20.0

# Called when the node enters the scene tree for the first time.
func _ready():
	areas = [
		get_node("PuzzleBox/Area3D"),
		get_node("PuzzleBox/Area3D2"),
		get_node("PuzzleBox/Area3D3")
		]
	
	_prepare_snapping()


func _physics_process(delta):
	test_snap_proximity()
	
func test_snap_proximity():
	# TODO: test for snap proximity
	pass


# Prepare snapping system
func _prepare_snapping():
	var lid = find_child("Lid*")
	for snap_area : Area3D in lid.find_children("SnapArea*"):
		snap_area.body_entered.connect(_snap_object.bind(snap_area.global_position))
	

func _snap_object(_object : RigidBody3D, position : Vector3):
	print("Snap now!: ", _object, " ", position)
	object_snapping.emit(position)

func _on_area_3d_body_entered(body):
	print("shape in hole 1")
	on_area_3d_any_body_entered(areas[0], body)

func _on_area_3d_2_body_entered(body):
	print("shape in hole 2")
	on_area_3d_any_body_entered(areas[1], body)

func _on_area_3d_3_body_entered(body):
	print("shape in hole 3")
	on_area_3d_any_body_entered(areas[2], body)

func on_area_3d_any_body_entered(area, body):
	var number_contents = area.get_overlapping_bodies().size()
	if number_contents == 2:
		double_fill.emit()
		print("double_fill")
		return
	
	var number_contents_sum = 0
	for section in areas:
		number_contents_sum += section.get_overlapping_bodies().size()
	
	if number_contents_sum == 1:
		print("one_solved")
		one_solved.emit()
		return
	
