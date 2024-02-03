extends SpotLight3D

var velocity : Vector2
var speed_mult = 0.01

var base_rotation

# Called when the node enters the scene tree for the first time.
func _ready():
	base_rotation = rotation_degrees
	velocity = Vector2(1, 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	rotate_x(velocity.x * speed_mult)
