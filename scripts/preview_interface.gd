extends Control

func _on_pause_button_pressed():
	var is_now_paused = !get_tree().paused
	get_tree().paused = is_now_paused
	$Pause.text = "Play" if is_now_paused else "Pause"