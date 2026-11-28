extends AudioStreamPlayer3D

# Add your sound files here in the Inspector
@export var audio_streams: Array[AudioStream] = []

# Range for the random delay between sounds (in seconds)
@export var min_wait_time: float = 1.0
@export var max_wait_time: float = 5.0

var timer: Timer

func _ready() -> void:
	# Create and configure a timer to handle the delays
	timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	
	# Start the initial timer
	_start_random_timer()

func _start_random_timer() -> void:
	var wait_time = randf_range(min_wait_time, max_wait_time)
	timer.start(wait_time)

func _on_timer_timeout() -> void:
	if audio_streams.size() > 0:
		# Pick a random audio stream from the array and play it
		stream = audio_streams.pick_random()
		play()
	else:
		print("No audio streams assigned to the player!")
	
	# Schedule the next sound
	_start_random_timer()
