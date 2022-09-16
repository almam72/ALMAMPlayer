extends Node2D

var track_number = 0
var speed = 120
var parallax = 120

func _ready():
	set_parallax()
	
func _process(delta):
	position.x -= parallax * delta

func set_parallax():
	parallax = GlobalVariables.parallax[str(track_number)] * speed
