extends Node2D


var note_scene = preload("res://scenes/note.tscn")
var note_effect_scene = preload("res://scenes/note_effect.tscn")
var notes = {}
var bpm = 512
var current_note = 0


func _ready():
	return
	bpm = GlobalVariables.speed
	var file = File.new()
		
	file.open(GlobalVariables.json_path, file.READ)
	var text = file.get_as_text()
	var json_var = JSON.new()
	var midi_json = json_var.parse(text)
	if midi_json == OK:
		midi_json = json_var.get_data()
	var track_number = 0
	for track in midi_json["tracks"]:
		if track["notes"].size() == 0:
			continue
		for note in track["notes"]:
			add_note_to_array(note, track_number)
		track_number += 1
	file.close()

func add_note_to_array(note, track_number):
	if note["time"] > 5 && note["time"] < 10:
		var time = str(note["time"] + 1.3)
		
		if not notes.has(time):
			notes[time] = []
		
		notes[time].append([note["midi"], note["duration"], note["time"] + 1.3, track_number])



func play_notes(notez):
#	return
	
	for note in notez:
		var note_number = note[0]
		var duration = note[1]
		var time = note[2]
		var note_instance = note_scene.instantiate()
		note_instance.note_number = note_number
#		print(note_number)
		note_instance.duration = duration
		note_instance.speed = GlobalVariables.speed
		note_instance.track_number = note[3] + current_note
		note_instance.time = time
		note_instance.preview = true
		var parallax = 1.0 * GlobalVariables.parallax[str(note[3])]
		note_instance.global_position = Vector2((time * GlobalVariables.speed * parallax) - parallax * GlobalVariables.speed, 0)
		$Anchor/NoteHolder.position.y = GlobalVariables.vertical_offset
		$Anchor/NoteHolder.add_child(note_instance)


func _on_timer_timeout():
#	current_note = 0
	for note in notes:
		play_notes(notes[note])
#		current_note += 1
