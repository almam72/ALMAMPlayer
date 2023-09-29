extends Control

@onready var pause_ = $HBoxContainer/Pause
@onready var seek_time_ = $HBoxContainer/SeekTime
@onready var seek_slider_ = $HBoxContainer/SeekSlider
@onready var audio_stream_player_ = $%LivePreview.get_node("AudioStreamPlayer2")

var pause_status_before_seek_ : bool
## Workaround for (what I think is) a bug where seek() calls to paused AudioStreamPlayers
## don't work :(
var queued_seek_value_ : float = -1

func _process(_delta):
	# Update seek slider and audio player
	if !get_tree().paused:
		# If we have a queued seek, apply it and clear queue
		if queued_seek_value_ != -1:
			audio_stream_player_.seek(queued_seek_value_)
			queued_seek_value_ = -1
		
		seek_slider_.max_value = audio_stream_player_.stream.get_length() # Inefficient to do this every frame, but idc
		
		var audio_position = audio_stream_player_.get_playback_position()
		seek_slider_.set_value_no_signal(audio_position)
		seek_time_.text = "%d:%02d" % [ floori(audio_position / 60), roundi(fmod(audio_position, 60)) ]
	elif queued_seek_value_ != -1: # This translates to: if the user is seeking via the slider
		$%LivePreview.set_audio_position(queued_seek_value_)

func _on_pause_button_pressed():
	get_tree().paused = !get_tree().paused
	pause_.text = "Play" if get_tree().paused else "Pause"

func _on_seek_slider_drag_started():
	pause_status_before_seek_ = get_tree().paused
	get_tree().paused = true

func _on_seek_slider_value_changed(value):
	queued_seek_value_ = value
	seek_time_.text = "%d:%02d" % [ floori(value / 60.0), roundi(fmod(value, 60)) ]

func _on_seek_slider_drag_ended(_value_changed):
	get_tree().paused = pause_status_before_seek_
