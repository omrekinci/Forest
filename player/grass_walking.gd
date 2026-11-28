extends AudioStreamPlayer3D

@export var audio_streams: Array[AudioStream] = []
@export var min_wait_time: float = 1.0
@export var max_wait_time: float = 5.0
@export var sprint_multiplier: float = 0.5
@export var normal_pitch: float = 1.0
@export var sprint_pitch: float = 1.5

var timer: Timer
var is_sprinting: bool = false:
	set(value):
		is_sprinting = value
		pitch_scale = sprint_pitch if is_sprinting else normal_pitch

func _ready() -> void:
	timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	_start_random_timer()

func _start_random_timer() -> void:
	var current_min = min_wait_time
	var current_max = max_wait_time
	if is_sprinting:
		current_min *= sprint_multiplier
		current_max *= sprint_multiplier
	
	var wait_time = randf_range(current_min, current_max)
	timer.start(wait_time)

func _on_timer_timeout() -> void:
	if playing and audio_streams.size() > 0:
		stream = audio_streams.pick_random()
		play()
	_start_random_timer()
