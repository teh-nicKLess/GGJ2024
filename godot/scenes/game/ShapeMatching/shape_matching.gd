extends Node3D

var number_solved = 0

signal box_hit
signal one_solved
signal fallen_item
signal double_fill
signal object_snapping
signal object_unsnapping
signal level_solved

var areas


# Called when the node enters the scene tree for the first time.
func _ready():
	areas = [
		get_node("PuzzleBox/Area3D"),
		get_node("PuzzleBox/Area3D2"),
		get_node("PuzzleBox/Area3D3")
		]
	
	_prepare_snapping()


# Prepare snapping system
func _prepare_snapping():
	var lid = find_child("Lid*")
	for snap_area : Area3D in lid.find_children("SnapArea*"):
		snap_area.body_entered.connect(_snap_object.bind(snap_area.global_position))
	

func _snap_object(_object : RigidBody3D, snap_position : Vector3):
	print("Snap now!: ", _object, " ", snap_position)
	object_snapping.emit(snap_position)



func _on_area_3d_body_entered(body):
	print("%s in hole 3 of %s" % [body.name, name])
	on_area_3d_any_body_entered(areas[0], body)

func _on_area_3d_2_body_entered(body):
	print("%s in hole 3 of %s" % [body.name, name])
	on_area_3d_any_body_entered(areas[1], body)

func _on_area_3d_3_body_entered(body):
	print("%s in hole 3 of %s" % [body.name, name])
	on_area_3d_any_body_entered(areas[2], body)

func on_area_3d_any_body_entered(area, _body):
	var number_contents = area.get_overlapping_bodies().size()
	if number_contents == 2:
		double_fill.emit()
		print("double_fill")
		return
	
	var number_contents_sum = 0
	var solved = true
	for section in areas:
		var num_contents = section.get_overlapping_bodies().size()
		number_contents_sum += num_contents
		solved = solved && num_contents == 1
		
	if solved:
		print("level_solved")
		level_solved.emit()
	
	if number_contents_sum == 1:
		print("one_solved")
		one_solved.emit()
		return
	
func _on_box_hit():
	box_hit.emit()
