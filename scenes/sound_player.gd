extends Node

func play_sound(stream: AudioStream):
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.stream = stream
	player.play()
	player.finished.connect(player.queue_free)
