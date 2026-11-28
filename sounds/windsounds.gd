extends Node3D

@export var sound_effects: Array[AudioStream] = []
@export var min_pitch: float = 0.85
@export var max_pitch: float = 1.15

@onready var player_1: AudioStreamPlayer = $Player1
@onready var player_2: AudioStreamPlayer = $Player2

var active_player: AudioStreamPlayer
var idle_player: AudioStreamPlayer
var is_transitioning: bool = false

func _ready() -> void:
	active_player = player_1
	idle_player = player_2
	
	play_initial_sound()

func play_initial_sound() -> void:
	if sound_effects.is_empty():
		return
		
	var chosen_stream = sound_effects.pick_random()
	active_player.stream = chosen_stream
	active_player.pitch_scale = randf_range(min_pitch, max_pitch)
	active_player.volume_db = 0.0
	active_player.play()
	
	schedule_crossfade(chosen_stream.get_length())

func schedule_crossfade(total_length: float) -> void:
	var trigger_time = total_length - 4.0
	
	if trigger_time < 0.1:
		trigger_time = total_length / 4.0 
		
	await get_tree().create_timer(trigger_time).timeout
	
	if not is_transitioning:
		start_crossfade()

func start_crossfade() -> void:
	is_transitioning = true
	
	var next_stream = sound_effects.pick_random()
	idle_player.stream = next_stream
	idle_player.pitch_scale = randf_range(min_pitch, max_pitch)
	idle_player.volume_db = -80.0 
	idle_player.play()
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(active_player, "volume_db", -80.0, 2.0)
	tween.tween_property(idle_player, "volume_db", 0.0, 2.0)
	
	tween.chain().tween_callback(func():
		active_player.stop()
		active_player.volume_db = 0.0 
		
		var temp = active_player
		active_player = idle_player
		idle_player = temp
		
		is_transitioning = false
		
		schedule_crossfade(next_stream.get_length())
	)
