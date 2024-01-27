extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_3d_body_entered(body):
	print("shape in hole 1")


func _on_area_3d_2_body_entered(body):
	print("shape in hole 2")


func _on_area_3d_3_body_entered(body):
	print("shape in hole 3")
