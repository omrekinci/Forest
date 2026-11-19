extends CharacterBody3D

@export var player: Node3D
@export var initial_move_speed := 6.5
@export var final_move_speed := 13.5
@export var wander_speed := 10.0
@export var attack_range := 2.2
@export var pause_distance := 10.0
@export var pause_duration := 2.0
@export var max_chase_time := 10.0
@export var flee_distance := 38.0
@export var flee_cooldown := 3.5

@onready var audio_player := $PresenceAuido

enum State { wandering, stalking, waiting, chasing, fleeing }
var current_state: State = State.wandering
var is_stunned := false
var has_paused_at_10m := false

var wait_timer := 0.0
var chase_timer := 0.0
var flee_timer := 0.0
var wander_timer := 0.0
var wander_target := Vector3.ZERO
var has_played_sound := false
var default_wander_speed := 10.0

func _ready() -> void:
	default_wander_speed = wander_speed

func _find_target_player() -> Node3D:
	var players_node := get_tree().current_scene.find_child("Players", true, false)
	if players_node:
		var closest: Node3D = null
		var closest_dist := INF
		for child in players_node.get_children():
			if child is Node3D and child.visible:
				var dist := global_position.distance_to(child.global_position)
				if dist < closest_dist:
					closest_dist = dist
					closest = child
		if closest:
			player = closest
			return player

	if is_instance_valid(player):
		return player
	return null

func _face_target(target_pos: Vector3) -> void:
	var look_pos := Vector3(target_pos.x, global_position.y, target_pos.z)
	if not global_position.is_equal_approx(look_pos):
		look_at(look_pos, Vector3.UP)

func _move_toward(target_pos: Vector3, speed: float) -> void:
	var to_target := target_pos - global_position
	to_target.y = 0.0
	if to_target.length() > 0.05:
		var dir := to_target.normalized()
		velocity = dir * speed
		_face_target(target_pos)
	else:
		velocity = Vector3.ZERO
	move_and_slide()

func _start_10m_pause() -> void:
	has_paused_at_10m = true
	velocity = Vector3.ZERO
	move_and_slide()
	if is_instance_valid(player):
		_face_target(player.global_position)
	wait_timer = pause_duration
	current_state = State.waiting

func _enter_fleeing() -> void:
	current_state = State.fleeing
	flee_timer = flee_cooldown
	has_played_sound = false
	has_paused_at_10m = false

func _physics_process(delta: float) -> void:
	# Let the server drive monster AI; clients receive position via MultiplayerSynchronizer
	if multiplayer.has_multiplayer_peer() and not multiplayer.is_server():
		return

	if is_stunned:
		return

	if not _find_target_player():
		return

	var player_distance := global_position.distance_to(player.global_position)

	if player_distance > pause_distance + 4.0 and current_state != State.chasing:
		has_paused_at_10m = false

	match current_state:
		State.wandering:
			has_played_sound = false

			if player_distance <= pause_distance and not has_paused_at_10m:
				_start_10m_pause()
				return

			if player_distance <= 24.0:
				current_state = State.stalking
				return

			if player_distance > 50.0:
				wander_speed = 20.0
				wander_target = player.global_position
			else:
				wander_speed = default_wander_speed
				wander_timer -= delta
				if wander_timer <= 0.0 or global_position.distance_to(wander_target) < 1.5:
					var random_angle := randf() * TAU
					var random_dist := randf_range(15.0, 35.0)
					wander_target = player.global_position + Vector3(cos(random_angle), 0.0, sin(random_angle)) * random_dist
					wander_timer = randf_range(2.5, 4.5)

			_move_toward(wander_target, wander_speed)

		State.stalking:
			if player_distance > 26.0:
				current_state = State.wandering
				return

			if player_distance <= 18.0 and not has_played_sound:
				if audio_player and audio_player.stream:
					audio_player.play()
					has_played_sound = true

			if player_distance <= pause_distance and not has_paused_at_10m:
				_start_10m_pause()
				return

			_move_toward(player.global_position, initial_move_speed)

		State.waiting:
			velocity = Vector3.ZERO
			move_and_slide()
			_face_target(player.global_position)

			wait_timer -= delta
			if wait_timer <= 0.0:
				chase_timer = 0.0
				current_state = State.chasing

		State.chasing:
			chase_timer += delta

			if chase_timer >= max_chase_time or player_distance > 35.0:
				_enter_fleeing()
				return

			if player_distance > attack_range * 0.6:
				_move_toward(player.global_position, final_move_speed)
			else:
				_face_target(player.global_position)
				velocity = Vector3.ZERO
				move_and_slide()

		State.fleeing:
			flee_timer -= delta

			if player_distance < flee_distance and flee_timer > 0.0:
				var away_dir := global_position - player.global_position
				away_dir.y = 0.0
				_move_toward(global_position + away_dir, final_move_speed)
			else:
				velocity = Vector3.ZERO
				move_and_slide()
				has_paused_at_10m = false
				if player_distance > 26.0:
					current_state = State.wandering
				else:
					current_state = State.stalking

func stun() -> void:
	if multiplayer.has_multiplayer_peer() and not multiplayer.is_server():
		return
	print("stunmonster")
	is_stunned = true
	velocity = Vector3.ZERO
	await get_tree().create_timer(1.0).timeout
	if not is_inside_tree():
		return
	is_stunned = false
	_enter_fleeing()


func _on_monster_area_area_entered(area: Area3D) -> void:
	if area.name == "SafeZone":
		stun()


func _on_monster_area_area_exited(area: Area3D) -> void:
	if area.name == "SafeZone":
		stun()
