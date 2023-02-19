extends Node2D

@onready var background = $Camera2D/BackgroundImage
var _effect_capture
var input_threshold = 0.4
var recording
var file_path
var loaded_file = File.new()
var notes = {}
var pitchbends = {}
var dance_notes = {}
var time_accuracy = 0.1
var track_scene = preload("res://scenes/track.tscn")
var note_scene = preload("res://scenes/note.tscn")
var note_effect_scene = preload("res://scenes/note_effect.tscn")
var default_texture = load("res://assets/sprites/note_texture.png")
var default_effect_texture = load("res://assets/sprites/note_effect_texture.png")
var bpm = 512
var first_note_played = false
var alternate = 1
var previous_rotation = -0.008

var smf_data:SMF.SMFData = null


func _ready():
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

func load_midi():
	smf_data = null
	if self.smf_data == null:
		var smf_reader: = SMF.new( )
		var result: = smf_reader.read_file(GlobalVariables.json_path)
		if result.error == OK:
			self.smf_data = result.data
#			self.playing = true

#	bpm = midi_json["header"]["tempos"][0]["bpm"]
	var track_number = 0
	track_number = 0
	
	for track in smf_data.tracks:
		if track.events.size() == 0:
#			track_number += 1
			continue
		set_track_texture(track_number)
		set_track_effect_texture(track_number)
		track_number += 1
	await get_tree().create_timer(0.5).timeout
#	track_number = 0
	track_number = 0
	
	var tempo = 500000
	for track in smf_data.tracks:
		for note in track.events:
			if note.event.type == 240:
				if note.event.args.has("bpm"):
					tempo = note.event.args.bpm
					print("tempo: " + str(tempo))
	for track in smf_data.tracks:
		if track.events.size() == 0:
			continue
#			print(track)
		var track_instance = track_scene.instantiate()
		track_instance.name = "Track" + str(track_number)
		track_instance.track_number = track_number
		track_instance.speed = GlobalVariables.speed
		track_instance.global_position = Vector2(0.5 * GlobalVariables.speed * GlobalVariables.parallax[str(track_number)],0)
		$WaveAnchor/NoteHolder.add_child(track_instance)
		
		var unfinished_notes = []
		
		
		var ticks_per_beat = smf_data.timebase
#		var last_event_ticks = 0
#		var microseconds = 0

		for note in track.events:
#			if note.event.type == 240:
#				if note.event.args.has("bpm"):
#					tempo = note.event.args.bpm
#					print("tempo: " + str(tempo))
#			note_off = 0x80, 128
#			note_on = 0x90, 144
			var note_array = {}
			
			var per_tick = tempo / ticks_per_beat
#			print("per_tick: " + str(per_tick))
			var seconds_per_tick = per_tick / 1000000.0
#			print("seconds_per_tick: " + str(seconds_per_tick))
			
			var seconds = note.time * seconds_per_tick
#			print("seconds_per_tick: " + str(seconds_per_tick))
			
#			if note.event.type == 128:
#				for unfinished_note in unfinished_notes:
#					unfinished_note[2]

#				print("test")
			if note.event.type == 144:
				note_array["midi"] = note.event.note
				note_array["duration"] = 0.1
				note_array["time"] = seconds
#				print(seconds)
				add_note_to_array(note_array, track_number)
				
			unfinished_notes.append(note_array)
#			print(note.event.type)
#			print(note_array)
		track_number += 1
	start()


func load_json():
	var file = File.new()
	
	file.open(GlobalVariables.json_path, file.FileOpts.READ)
	var text = file.get_as_text()
	var json_var = JSON.new()	
	var midi_json = json_var.parse(text)
	if midi_json == OK:
		midi_json = json_var.get_data()
	file.close()
	
#	bpm = midi_json["header"]["tempos"][0]["bpm"]

	var track_number = 0
	for track in midi_json["tracks"]:
		if track["notes"].size() == 0:
#			print("track_number")
#			track_number += 1
			continue

		for pitchbend in track["pitchBends"]:
			add_pitchbend_to_array(pitchbend, track_number)
		track_number += 1
		
			
	track_number = 0
	for track in midi_json["tracks"]:
		if track["notes"].size() == 0:
#			track_number += 1
			continue
		set_track_texture(track_number)
		set_track_effect_texture(track_number)
		track_number += 1
	await get_tree().create_timer(0.5).timeout
	track_number = 0
	for track in midi_json["tracks"]:
		if track["notes"].size() == 0:
#			track_number += 1
			continue
		
		var track_instance = track_scene.instantiate()
		track_instance.name = "Track" + str(track_number)
		track_instance.track_number = track_number
		track_instance.speed = GlobalVariables.speed
		track_instance.global_position = Vector2(0.5 * GlobalVariables.speed * GlobalVariables.parallax[str(track_number)],0)
		$WaveAnchor/NoteHolder.add_child(track_instance)
		for note in track["notes"]:
#			print(note)
			
			add_note_to_array(note, track_number)
		track_number += 1
	start()

func set_track_texture(track_number):
	print(track_number)
	if GlobalVariables.note_texture[str(track_number)] == "res://assets/sprites/note_texture.png":
		GlobalVariables.note_images[str(track_number)] = default_texture
		return
#	var image = Image.new()
#	var err = image.load(GlobalVariables.note_texture[str(track_number)])
#	if err != OK:
#		# Failed
#		print("error loading image :(")
#	var texture = ImageTexture.new()
	var texture = ImageTexture.create_from_image(Image.load_from_file(GlobalVariables.note_texture[str(track_number)]))
	GlobalVariables.note_images[str(track_number)] = texture

func set_track_effect_texture(track_number):
	if GlobalVariables.note_effect_texture[str(track_number)] == "res://assets/sprites/note_effect_texture.png":
		GlobalVariables.effect_images[str(track_number)] = default_effect_texture
		return
#	var effect_image = Image.new()
#	var err = effect_image.load(GlobalVariables.note_effect_texture[str(track_number)])
#	if err != OK:
#		# Failed
#		print("error loading image :(")
#	var effect_texture = ImageTexture.new()
#	effect_texture.create_from_image(effect_image)
	var effect_texture = ImageTexture.create_from_image(Image.load_from_file(GlobalVariables.note_effect_texture[str(track_number)]))
	GlobalVariables.effect_images[str(track_number)] =  effect_texture
	
	

func load_background_image(file):
#	var image = Image.new()
#	var err = image.load(file)
#	if err != OK:
#		# Failed
#		print("error loading image :(")
	background.texture = ImageTexture.create_from_image(Image.load_from_file(file))
#	background.texture.create_from_image(image)
	$Camera2D/BackgroundImageSquare.texture = background.texture
	GlobalVariables.background_path = file
	
func start():
	await get_tree().create_timer(0.5).timeout
	for note in notes:
		play_notes(notes[note])
	for note in dance_notes:
		dance(dance_notes[note])
	
	await get_tree().create_timer(0.5).timeout
	if not compare_floats(0, GlobalVariables.happiness):
		if GlobalVariables.happiness > 0:
			await get_tree().create_timer(GlobalVariables.happiness).timeout
			
		
	$AudioStreamPlayer.play()
	$AudioStreamPlayer2.play()
	
	$stop.start()
	


func add_note_to_dance_array(note, track_number):
	var time = str(note["time"] + 0.5)
#	var time = str(note["time"])
	
	if not dance_notes.has(time):
		dance_notes[time] = []
	
	dance_notes[time].append([note["midi"], note["duration"], note["time"] + 0.5, track_number])

func add_pitchbend_to_array(pitchbend, track_number):
#	print(track_number)
#	var time = str(pitchbends["time"] + 0.5)
#	if not pitchbends.has(time):
#		pitchbends[time] = []
#	pitchbends[time].append([pitchbend["time"] + 0.5, pitchbend["value"], track_number])
	await get_tree().create_timer(pitchbend["time"] + 1.5).timeout
	
#	$Tween.interpolate_property(self, "scale", scale, original_scale * 0.01, 0.2, Tween.TRANS_SINE)
	for note in get_tree().get_nodes_in_group(str(track_number)):
#		print(pitchbend["value"])
		note.bend(pitchbend["value"])
#		var tween = get_tree().create_tween()
#		tween.set_trans(Tween.TRANS_SINE)
#		tween.set_ease(Tween.EASE_IN_OUT)
#		tween.set_parallel(true)
##		tween.interpolate_value(note.position.y, 1, )
#
#		tween.tween_property(note, "global_position:y", note.global_position.y + (pitchbend["value"] * 48), 0.5)

#func bend_note():
	
			

func add_note_to_array(note, track_number):
	if not compare_floats(0, GlobalVariables.happiness) && GlobalVariables.happiness > 0:
		var time = str(note["time"] + 0.5 + abs(GlobalVariables.happiness))
		if not notes.has(time):
			notes[time] = []
		notes[time].append([note["midi"], note["duration"], note["time"] + 0.5, track_number])
			
	else:
		var time = str(note["time"] + 0.5)
		if not notes.has(time):
			notes[time] = []
		notes[time].append([note["midi"], note["duration"], note["time"] + 0.5 + abs(GlobalVariables.happiness), track_number])
			
#	var time = str(note["time"])
	
#	if not notes.has(time):
#		notes[time] = []
	
#	notes[time].append([note["midi"], note["duration"], note["time"] + 0.5, track_number])

func dance(dance_notes):
	pass
	
func play_notes(notes):
#	return
	for note in notes:
		var note_number = note[0]
		var duration = note[1]
		var time = note[2]
		var note_instance = note_scene.instantiate()
		note_instance.note_number = note_number
		note_instance.duration = duration
		note_instance.speed = bpm
		note_instance.track_number = note[3]
		note_instance.time = time
		var parallax = 1.0 * GlobalVariables.parallax[str(note[3])]
	
		note_instance.global_position = Vector2(time * bpm * parallax, 0)
		$WaveAnchor/NoteHolder.position.y = GlobalVariables.vertical_offset
		get_node("WaveAnchor/NoteHolder/Track" + str(note[3])).add_child(note_instance)
		


func play_note_effect(notes):
#	return
	for note in notes:
		var note_number = note[0]
		var duration = note[1]
		var time = note[2]
		var note_instance = note_effect_scene.instantiate()
		note_instance.note_number = note_number
		note_instance.duration = duration
		note_instance.speed = bpm
		note_instance.track_number = note[3]
		note_instance.global_position = Vector2(-12 ,96)
		
		create_note_effect(note_instance)
#		$WaveAnchor/NoteHolder.add_child(note_instance)
		
func create_note_effect(note_instance):
	await get_tree().create_timer(note_instance.time).timeout
	note_instance.time = 1.0
	$WaveAnchor/NoteHolder.add_child(note_instance)
	print(note_instance)
	


func song_finished():
	await get_tree().create_timer(1).timeout
	get_tree().quit()


func compare_floats(a, b, epsilon = 0.01):
	return abs(a - b) <= epsilon
