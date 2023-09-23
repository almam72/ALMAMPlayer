extends "res://scripts/beat_detection.gd"

# var elapsed_playtime : float = 0
var _audio_position : float = 0

var NoteEffectScene = preload("res://scenes/note_effect.tscn")

func _ready():
	# I think this is necessary so we don't run the base class's _ready
	print("oh i am *so* ready >:)")

func _process(delta):
	_audio_position += delta

## (Re-)creates the preview based on arguments dict (see beat_detection.gd::_ready)
func init(arguments):
	_clear()
	get_tree().paused = false
	GlobalVariables.load_settings(arguments["loaded_config"])
#	print(GlobalVariables.square_ratio)
	if GlobalVariables.square_ratio:
#		ProjectSettings.set_setting("display/window/size/viewport_width", 1080)
#		DisplayServer.window_set_size(Vector2(1080, 1080))
		$Camera2D/BackgroundImageSquare.visible = true
	else:
		$Camera2D/BackgroundImageSquare.visible = false
	load_background_image(GlobalVariables.background_path)
	bpm = GlobalVariables.speed
	var audio_loader = AudioLoader.new()
	$AudioStreamPlayer2.set_stream(audio_loader.loadfile(GlobalVariables.sound_path))
#	$AnimationPlayer.seek(0.3, true)
	load_midi()
	await start() # Some weird async stuff happens in this function which leads to audio not pausing properly if you don't await
	get_tree().paused = true
	_audio_position = 0

## Convenience function to relaod the preview based on the current config file
func reset():
	init({
		"loaded_config": GlobalVariables.loaded_settings_path
	})

## Removes all notes from the preview
func _clear():
	# Clear all nodes
	var note_holder = $WaveAnchor/NoteHolder
	for child in note_holder.get_children():
		if child.name.begins_with("Track"):
			note_holder.remove_child(child)
			child.free()

	# Clear internal state
	notes.clear()
	sorted_notes.clear()
	note_instances.clear()
	pitchbends.clear()
	dance_notes.clear()	

## Let the preview window know it needs to change stuff
func notify_global_variable_change(variable_name : String, _value : Variant):
	match variable_name:
		"vertical_offset", "note_spacing":
			_layout_tracks()
		"top_margin":
			_layout_tracks()
			_layout_notes()
		"audio_offset":
			_layout_tracks()
			_update_note_effect_timers()
		"speed":
			_layout_tracks()
			_layout_notes()
			_scale_notes()
		_:
			push_error("Unrecognized global variable \'%s\'" % variable_name)
			
## This function should only be called when user is seeking, not
## every frame while time is moving normally
func set_audio_position(value : float):
	assert(get_tree().paused)
	_audio_position = value
	_layout_tracks() # Update everything's position
	_update_note_effect_timers()	

func _update_note_effect_timers():
	var time = _get_time()
	for note_instance in note_instances:
		# Reset effect timer
		var timer = note_instance.get_node("Timer")
		timer.start(note_instance.time - time)
		note_instance.playing = false

## Estimates the playback time of the scene (basically guesstimates at a "time" value
## like in note.gd)
func _get_time():
	const an_arbitrary_but_necessary_offset = 0.4 # don't question it
	return -0.5 + an_arbitrary_but_necessary_offset + _audio_position + delay +  abs(GlobalVariables.audio_offset)

## Sets track position/speed
func _layout_tracks():
	var time = _get_time()
	for track_instance in $WaveAnchor/NoteHolder.get_children():
		if track_instance.name.begins_with("Track"):
			# Update track's fields
			track_instance.speed = GlobalVariables.speed
			track_instance.set_parallax()

			# Update position
			track_instance.position = Vector2(-time * track_instance.parallax, 0)

	$WaveAnchor/NoteHolder.position.y = GlobalVariables.vertical_offset

## Sets note position/speed (does NOT update note scale)
func _layout_notes():
	var time = _get_time()
	for note_instance in note_instances:
		note_instance.speed = GlobalVariables.speed
		note_instance.set_parallax()
		note_instance.position.x = note_instance.time * note_instance.parallax
		note_instance.position.y = -note_instance.note_number * GlobalVariables.note_spacing

## Makes notes look larger/smaller as things speed up/down
## This is slow :(
func _scale_notes():
	for note_instance in note_instances:
		note_instance.set_note_texture_transform()
