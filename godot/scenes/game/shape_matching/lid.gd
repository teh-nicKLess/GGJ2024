extends Node3D

signal box_hit


func _on_area_3d_body_entered(_body):
	print("box_hit")
	box_hit.emit()
