extends Node3D

var number_solved = 0

signal box_hit
signal one_solved
signal fallen_item
signal double_fill

var areas

# Called when the node enters the scene tree for the first time.
func _ready():
	areas = [
		get_node("PuzzleBox/Area3D"),
		get_node("PuzzleBox/Area3D2"),
		get_node("PuzzleBox/Area3D3")
		]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

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
	print(areas[0].get_overlapping_bodies().size())
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
	
