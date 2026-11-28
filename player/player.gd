extends CharacterBody3D

@onready var canvas1 = $Canvas1
@onready var asphalt_walking = $AsphaltWalking
@onready var grass_walking = $GrassWalking
@onready var body_area = $Body/BodyArea

@export var walk_speed := 5.0
@export var sprint_speed := 10.0
@export var jump_speed := 4.5
@export var mouse_sensitivity := 0.003

@export var normal_fov := 75.0
@export var sprint_fov := 85.0
@export var fov_change := 10.0

@export var max_stamina := 100.0
@export var stamina_drain_speed := 25.0
@export var stamina_regen_speed := 15.0

@export var current_avatar := 1:
	set(value):
		current_avatar = value

var stamina := 100.0
var has_stamina := false
var is_on_road := false

@onready var neck: Node3D = $Neck
@onready var camera: Camera3D = $Neck/Camera
@onready var stamina_bar: ProgressBar = $CanvasLayer/StaminaBar
@onready var sprite_front = $Neck/front
@onready var sprite_back = $Neck/back
@onready var sprite_side = $Neck/side
@onready var mic_input: AudioStreamPlayer = $MicInput
@onready var voice_output: AudioStreamPlayer3D = $VoiceOutput

var capture_effect: AudioEffectCapture
var playback: AudioStreamGeneratorPlayback
const PACKET_FRAME_SIZE: int = 512
const VOICE_THRESHOLD: float = 0.01

func _enter_tree() -> void:
	var peer_id := name.to_int()
	if peer_id > 0:
		set_multiplayer_authority(peer_id)
		if has_node("MultiplayerSynchronizer"):
			$MultiplayerSynchronizer.set_multiplayer_authority(peer_id)

func _ready() -> void:
	Numbers.health = 1
	var is_local := is_multiplayer_authority()
	canvas1.visible = is_local
	camera.current = is_local

	voice_output.play()
	playback = voice_output.get_stream_playback() as AudioStreamGeneratorPlayback

	body_area.area_entered.connect(_on_body_area_area_entered)
	body_area.area_exited.connect(_on_body_area_area_exited)

	if is_local:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		stamina = max_stamina
		if stamina_bar:
			stamina_bar.max_value = max_stamina
			stamina_bar.value = stamina

		var record_bus_idx = AudioServer.get_bus_index("Record")
		capture_effect = AudioServer.get_bus_effect(record_bus_idx, 0) as AudioEffectCapture
		mic_input.play()
		capture_effect.clear_buffer()

		rpc_id(1, "_register_my_avatar", multiplayer.get_unique_id(), Numbers.avatar)

@rpc("any_peer", "call_local", "reliable")
func _register_my_avatar(peer_id: int, av_id: int) -> void:
	if multiplayer.is_server():
		Numbers.player_avatars[peer_id] = av_id
		rpc("_sync_all_avatars", Numbers.player_avatars)

@rpc("any_peer", "call_local", "reliable")
func _sync_all_avatars(avatar_dict: Dictionary) -> void:
	Numbers.player_avatars = avatar_dict
	var peer_id = name.to_int()
	if Numbers.player_avatars.has(peer_id):
		current_avatar = Numbers.player_avatars[peer_id]

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		neck.rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))

	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta: float) -> void:
	if is_multiplayer_authority() and capture_effect != null:
		while capture_effect.can_get_buffer(PACKET_FRAME_SIZE):
			var buffer: PackedVector2Array = capture_effect.get_buffer(PACKET_FRAME_SIZE)
			if _is_above_threshold(buffer):
				_transmit_voice.rpc(buffer)

	var peer_id = name.to_int()
	if Numbers.player_avatars.has(peer_id):
		current_avatar = Numbers.player_avatars[peer_id]

	var current_camera := get_viewport().get_camera_3d()
	if not current_camera:
		return

	var to_cam = current_camera.global_position - global_position
	to_cam.y = 0
	to_cam = to_cam.normalized()

	var forward = -neck.global_transform.basis.z
	forward.y = 0
	forward = forward.normalized()

	var right = neck.global_transform.basis.x
	right.y = 0
	right = right.normalized()

	var fwd_dot = forward.dot(to_cam)
	var right_dot = right.dot(to_cam)

	sprite_front.visible = false
	sprite_back.visible = false
	sprite_side.visible = false

	var active_sprite = sprite_front
	if fwd_dot > 0.5:
		sprite_front.visible = true
		active_sprite = sprite_front
	elif fwd_dot < -0.5:
		sprite_back.visible = true
		active_sprite = sprite_back
	else:
		sprite_side.visible = true
		sprite_side.flip_h = right_dot < 0
		active_sprite = sprite_side

	var anim_name = str(current_avatar)
	if active_sprite.has_method("play") and active_sprite.animation != anim_name:
		active_sprite.play(anim_name)

func _is_above_threshold(buffer: PackedVector2Array) -> bool:
	for frame in buffer:
		if abs(frame.x) > VOICE_THRESHOLD or abs(frame.y) > VOICE_THRESHOLD:
			return true
	return false

@rpc("authority", "call_remote", "unreliable")
func _transmit_voice(audio_data: PackedVector2Array) -> void:
	if playback == null:
		return
	if playback.can_push_buffer(audio_data.size()):
		playback.push_buffer(audio_data)

func _physics_process(delta: float) -> void:
	if Numbers.energy <= 0:
		Numbers.energy = 0
	
	if Numbers.money <= 0:
		Numbers.money = 0
	
	if Numbers.shopisopened == false:
		if not is_multiplayer_authority():
			return

		Numbers.energy -= 0.005
		if not is_on_floor():
			velocity += get_gravity() * delta

		if (Input.is_key_pressed(KEY_SPACE) or Input.is_action_just_pressed("ui_accept")) and is_on_floor():
			velocity.y = jump_speed

		var input_dir := Vector2.ZERO
		if Input.is_key_pressed(KEY_W) or Input.is_action_pressed("ui_up"):
			input_dir.y -= 1
		if Input.is_key_pressed(KEY_S) or Input.is_action_pressed("ui_down"):
			input_dir.y += 1
		if Input.is_key_pressed(KEY_A) or Input.is_action_pressed("ui_left"):
			input_dir.x -= 1
		if Input.is_key_pressed(KEY_D) or Input.is_action_pressed("ui_right"):
			input_dir.x += 1

		input_dir = input_dir.normalized()
		var is_moving := input_dir.length() > 0

		var is_sprinting := false
		if Input.is_key_pressed(KEY_SHIFT) and is_moving and not has_stamina:
			if Numbers.energy > 0:
				is_sprinting = true

		if is_sprinting:
			Numbers.energy -= 0.05
			stamina = max(0.0, stamina - stamina_drain_speed * delta)
			if stamina <= 0.0:
				has_stamina = true
		else:
			stamina = min(max_stamina, stamina + stamina_regen_speed * delta)
			if has_stamina and stamina >= max_stamina * 0.2:
				has_stamina = false

		if stamina_bar:
			stamina_bar.value = stamina
			stamina_bar.visible = stamina < max_stamina

		var current_speed := walk_speed
		var target_fov := normal_fov

		if is_sprinting:
			current_speed = sprint_speed
			target_fov = sprint_fov

		camera.fov = lerpf(camera.fov, target_fov, delta * fov_change)

		var direction := (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

		if direction:
			velocity.x = direction.x * current_speed
			velocity.z = direction.z * current_speed
		else:
			velocity.x = move_toward(velocity.x, 0, current_speed)
			velocity.z = move_toward(velocity.z, 0, current_speed)

		move_and_slide()

		var is_walking = is_moving and is_on_floor()
		if is_walking:
			if is_on_road:
				asphalt_walking.is_sprinting = is_sprinting
				if grass_walking.playing:
					grass_walking.stop()
				if not asphalt_walking.playing:
					asphalt_walking.play()
			else:
				grass_walking.is_sprinting = is_sprinting
				if asphalt_walking.playing:
					asphalt_walking.stop()
				if not grass_walking.playing:
					grass_walking.play()
		else:
			asphalt_walking.is_sprinting = false
			grass_walking.is_sprinting = false
			if asphalt_walking.playing:
				asphalt_walking.stop()
			if grass_walking.playing:
				grass_walking.stop()

	elif Numbers.shopisopened == true:
		asphalt_walking.is_sprinting = false
		grass_walking.is_sprinting = false
		if asphalt_walking.playing:
			asphalt_walking.stop()
		if grass_walking.playing:
			grass_walking.stop()
		pass

func _on_body_area_area_entered(area: Area3D) -> void:
	if area.is_in_group("road"):
		is_on_road = true

func _on_body_area_area_exited(area: Area3D) -> void:
	if area.is_in_group("road"):
		is_on_road = false
