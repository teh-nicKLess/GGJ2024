extends Node3D

@onready var clown_control: CanvasLayer = $ClownControl

# Called when the node enters the scene tree for the first time.
func _ready():
    $room_base/room_inverted.visible = true

    clown_control.trigger_at(3.0, "start_game")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
