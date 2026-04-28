extends Node2D

@onready var sfx_player: AudioStreamPlayer2D = $SFX

@export var sfx_library: SFXLibrary

func _get_audio_stream(_tag: String):
	var index = -1
	if _tag:
		for sound : SFX in sfx_library.sound_effects:
			index += 1
			if sound.tag == _tag:
				break
		return sfx_library.sound_effects[index].stream
	else:
		printerr("No tag provided, cannot get sound effect!")
		return null

func play_sfx(_tag: String):
	var audio_stream = _get_audio_stream(_tag)
	if audio_stream:
		if !sfx_player.playing: sfx_player.play()
		
		var polyphonic_stream_playback := sfx_player.get_stream_playback()
		polyphonic_stream_playback.play_stream(audio_stream)
	else:
		printerr("Sound with tag [", _tag, "] not found!")
