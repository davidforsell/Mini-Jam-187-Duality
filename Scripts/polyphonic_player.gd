extends AudioStreamPlayer

@onready var audio_library: AudioLibrary = load("res://Resources/main.tres")
@export var custom_max_polyphony: int = 32

func _ready() -> void:
	stream = AudioStreamPolyphonic.new()
	stream.polyphony = custom_max_polyphony

func play_sound_effect_from_library(_tag: String) -> void:
	if _tag:
		var audioStream = audio_library.get_audio_stream(_tag)
		
		if !playing: self.play()
		
		var polyphonic_stream_playback := self.get_stream_playback()
		polyphonic_stream_playback.play_stream(audioStream)
	else:
		printerr("No tag provided")
