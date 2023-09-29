extends Node2D

var note_number = 0
var duration = 0
var speed = 120
var track_number = 0
var color
var rng = RandomNumberGenerator.new()
@onready var note_effect = $NoteEffect

func _ready():
	pass
#	await get_tree().create_timer(0.1).timeout
#	set_note_texture()
	
func set_note_texture():
#	print(GlobalVariables.effect_images[str(track_number)])
#	print(track_number)
	note_effect.texture = GlobalVariables.effect_images[str(track_number)]

func start():
#	set_text
	note_number = note_number
#	$NoteEffect.play("default")
#	$NoteEffect/NoteEffect2.play("default")
	z_index = 3000 + track_number * -1
#	if track_number/5 != 0:
#		self.scale.x = 1.0 / (track_number/2)
#		self.scale.y = 1.0 / (track_number/2)
#	else:
#		scale.x = 1
#		scale.y = 1
#	scale.x = clamp(scale.x, 0.5, 0.7)
#	scale.y = clamp(scale.y, 0.5, 0.7)
	
#	z_index = z_index - global_position.y / 100
	color = Color(0.929688, 0.618281, 0.522949)
	rng.randomize()
#	var scalar = rng.randf_range(0.95, 1.0)
#	scale = Vector2(scalar, scalar)
	set_color()

#	match track_number:
#		0:
#			speed *= 1.04
#		1:
#			speed *= 0.98
#		2:
#			speed *= 0.95
#		3:
#			speed *= 1.1
#		4:
#			speed *= 1.0
	$NoteEffect.modulate = color
	$NoteEffect.modulate.r += 0.1
	$NoteEffect.modulate.g += 0.1
	$NoteEffect.modulate.b += 0.1
	$AnimationPlayer.play("start")
#	$NoteEffect.modulate = color
#	position.y = 0
	position.x = 0
#	position.y -= note_number * GlobalVariables.note_spacing
#	$NoteTrail.position.x =  duration *20
#	$NoteTrail.modulate = Color(0.9, 0 + note_number/100, 0 , 1)
#	$ColorRect.rect_size.x = duration
	if duration > 0.09:
		$Timer.wait_time = duration - 0.025
	else:
		$Timer.wait_time = 0.065
	$Timer.start()
#	global_position = Vector2(snapped(global_position.x, 1.0),snapped(global_position.y, 1.0))


func _on_Timer_timeout():
	$AnimationPlayer.play("end")
	await $AnimationPlayer.animation_finished
#	yield($AnimationPlayer, "animation_finished")

	# Removing below lines for live preview support
	# hide()
	# queue_free()

func set_color():
	if not GlobalVariables.dont_color[str(track_number)]:
		color = GlobalVariables.colors[str(track_number)]
	else:
		color = Color(1.0, 1.0, 1.0, 1.0)
