extends Node2D

#@onready var visibility = $Visibility

#var note_effect_scene = preload("res://scenes/note_effect.tscn")

@onready var texture_rext = $NoteAnchor/TextureRect
@onready var staccato_texture = $NoteAnchor/TextureRect/Staccato
var track_images = {}
var effect_images = {}
var note_number = 0
var duration = 0
var speed = 120
var track_number = 0
var color 
var time = 0
var new_color = Color(0.929688, 0.618281, 0.522949)
var old_color = Color(0.929688, 0.618281, 0.522949)
var parallax = 120
var original_scale = 1.0
var rng = RandomNumberGenerator.new()
var preview = false
var staccato = false
var bend_to = 0
var playing = false
var bend_tween
var ease_var = -1

var velocity = 1

func _ready():
	staccato = GlobalVariables.staccato[str(track_number)]
	note_number = note_number - GlobalVariables.bottom_note
#	print(note_number)
	
	
	color = Color(0.929688, 0.618281, 0.522949)
	set_color()
#	parallax = 0
	set_parallax()
	set_note_texture()
	set_note_margins()
	if not staccato:
		texture_rext.size.y = texture_rext.texture.get_size().y
		GlobalVariables.note_size = texture_rext.texture.get_size().y
		texture_rext.position.y = GlobalVariables.note_size * -0.5
	else:
		staccato_texture.size.y = staccato_texture.texture.get_size().y
		GlobalVariables.note_size = staccato_texture.texture.get_size().y
		texture_rext.position.y = GlobalVariables.note_size * -0.5
#	parallax *= 1.2
#	z_index *= parallax

	
#	scale.y *= parallax / 190 + 10

	
#	$TextureRect.texture = load("res://assets/sprites/cat-png-clipart-6.png")
#	rng.randomize()
#	var texture = rng.randi_range(0,2)
#	if texture == 0:
#		$TextureRect.texture = load("res://assets/sprites/note00.png")
#		$TextureRect2.texture = load("res://assets/sprites/note00.png")
#	if texture == 1:
#		$TextureRect.texture = load("res://assets/sprites/note01.png")
#		$TextureRect2.texture = load("res://assets/sprites/note01.png")
#	if texture == 2:
#		$TextureRect.texture = load("res://assets/sprites/note02.png")
#		$TextureRect2.texture = load("res://assets/sprites/note02.png")
#	if GlobalVariables.audio_offset > 0.1:
#		$TextureRect.material.set_shader_param("happy", true)
#		$TextureRect.material.set_shader_param("speed", GlobalVariables.audio_offset)
		
	
#	$ColorRect.margin_bottom *= parallax / 190 + 6
#	$ColorRect2.margin_bottom = $ColorRect.margin_bottom / 1 + 3
#	$ColorRect2.margin_top = $ColorRect2.margin_bottom -4
	z_index += parallax 
	texture_rext.modulate = color
#	$ColorRect.modulate = color
	texture_rext.modulate = Color(texture_rext.modulate.r + note_number / 600, texture_rext.modulate.g + note_number / 600, texture_rext.modulate.b + note_number / 600, 1)
#	$ColorRect.modulate = Color($ColorRect.modulate.r + 0.2, $ColorRect.modulate.g + 0.2, $ColorRect.modulate.b + 0.2, 1)
	position.y = 0
#	print(note_number * GlobalVariables.note_size * GlobalVariables.note_spacing)
	position.y -= note_number * GlobalVariables.note_spacing
	if not staccato:
		texture_rext.size.x = duration * parallax
	else:
		texture_rext.size.x = staccato_texture.texture.get_size().x
#	$TextureRect2.size.x = duration * parallax
#	$ColorRect.margin_right = duration * parallax
#	$ColorRect2.margin_right = duration * parallax
#	$NoteTrail.position.x =  duration * parallax
#	$NoteTrail.modulate = color
	
	if staccato:
		duration = 0.1
	if time > 0.075:
		$Timer.wait_time = time - 0.03
	else:
		$Timer.wait_time = 0.06
#	if time > 2.06:
#		$StartTimer.wait_time = time - 2.06
	if duration > 0:
		$DurationTimer.wait_time = duration
	else:
		$DurationTimer.wait_time = 0.1
#	global_position = Vector2(stepify(global_position.x, 1.0),stepify(global_position.y, 1.0))
#	$StartTimer.start()
	$Timer.start()
	if preview:
		await get_tree().create_timer(0.1).timeout
		queue_free()


func _process(delta):
	if playing:
		ease_var = smoothstep(-2.0, 5.0, ease_var)
#		print(ease)
		$NoteAnchor.position.y = lerpf($NoteAnchor.position.y, bend_to, ease_var)
#		$NoteAnchor.rotation_degrees += bend_to * delta * 0.1
		if get_node_or_null("Node/NoteEffect") != null:
			
			$Node/NoteEffect.position.y = $NoteAnchor/TextureRect.global_position.y
			$Node/NoteEffect.rotation_degrees += bend_to * delta * 0.1
#	if not preview:
#		position.x -= parallax * delta
#	position.y += 0.25

func _on_Timer_timeout():
	playing = true
	add_to_group(str(track_number))
	original_scale = scale
	new_color.r = texture_rext.modulate.r + 0.3
	new_color.g = texture_rext.modulate.g + 0.3
	new_color.b = texture_rext.modulate.b + 0.3
	old_color = texture_rext.modulate
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_parallel(true)
	tween.tween_property(texture_rext, "modulate", new_color, 0.17)
	tween.tween_property(self, "scale",  scale * 1.03, 0.2).from(original_scale)
	if GlobalVariables.velocity_strength < 0.01:
		tween.tween_property(self, "position:y", position.y + 6, 0.17)
	else:
		tween.tween_property(self, "position:y", position.y + 0.25 + velocity * GlobalVariables.velocity_strength * 0.7, 0.17)
	if duration > 1:
		$AnimationPlayer.play("fade")
	play_note_effect()
	
	if duration > 0.4:
		$DurationTimer.start(duration)
	else:
		$DurationTimer.start(duration +0.2)
	
	
func play_note_effect():
	var note_instance = $Node/NoteEffect
#	note_instance.scale = Vector2(0.8, 0.8)
	if GlobalVariables.velocity_strength > 0.01:
		var new_size = remap(velocity * GlobalVariables.velocity_strength, 0, 127 * GlobalVariables.velocity_strength, 0.55, 1.05)
		note_instance.scale.x = new_size
		note_instance.scale.y = new_size
	note_instance.note_number = note_number
	note_instance.duration = duration
	note_instance.speed = speed
	note_instance.track_number = track_number
	note_instance.set_note_texture()
	note_instance.z_index = z_index + 1000
	note_instance.global_position = global_position
	note_instance.start()
#	return
#	if not preview:
#		var note_instance = note_effect_scene.instantiate()
#		note_instance.note_number = note_number
#		note_instance.duration = duration
#		note_instance.speed = speed
#		note_instance.track_number = track_number
#		note_instance.z_index = z_index + 1000
#	#	note_instance.scale.x = scale.y *0.9
#	#	note_instance.scale.y = scale.y *0.9
#		note_instance.global_position = self.global_position
#		get_tree().get_nodes_in_group("NoteHolder")[0].add_child(note_instance)


func _on_DurationTimer_timeout():
	remove_from_group(str(track_number))
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_parallel(true)
	var color_tween = create_tween()
	color_tween.set_ease(Tween.EASE_IN_OUT)
	color_tween.tween_property(texture_rext, "modulate", old_color, 0.27)
#	$Tween.interpolate_property(self, "scale", scale, original_scale * 0.01, 0.2, Tween.TRANS_SINE)
	if GlobalVariables.velocity_strength < 0.01:
		tween.tween_property(self, "position:y", position.y - 6, 0.27)
	else:
		tween.tween_property(self, "position:y", position.y - 0.25 - velocity * GlobalVariables.velocity_strength * 0.7, 0.27)
#	bend_to = 0

	await get_tree().create_timer(1.2).timeout
	playing = false
#	var backtween = create_tween()
#	backtween.set_trans(Tween.TRANS_SINE)
#	backtween.set_ease(Tween.EASE_IN_OUT)
#	backtween.tween_property($NoteAnchor, "position:y", 0.0, 0.6)
	
	
#	tween.start()
#	$DeleteTimer.start()
	
func set_parallax():
	parallax = GlobalVariables.parallax[str(track_number)] * speed

func set_color():
	color = GlobalVariables.colors[str(track_number)]

func set_note_texture():
	if staccato:
		staccato_texture.texture = GlobalVariables.note_images[str(track_number)]
	else:
		texture_rext.texture = GlobalVariables.note_images[str(track_number)]

func set_note_margins():
	texture_rext.patch_margin_left = GlobalVariables.note_texture_margins[str(track_number)].x
	texture_rext.patch_margin_right = GlobalVariables.note_texture_margins[str(track_number)].y

func bend(value = 0):
	bend_to = value * GlobalVariables.note_spacing * -4 * 0.0001 * GlobalVariables.pitch_bend_strength
	
