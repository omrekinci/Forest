extends CharacterBody3D

@export var player: Node3D
@export var initial_move_speed := 5.0
@export var final_move_speed := 12.5
@export var wander_speed := 10.0

@onready var audio_player := $PresenceAuido

enum State { wandering, stalking, waiting, chasing, fleeing }
var current_state: State = State.wandering
var is_stunned := false

var wait_timer := 0.0
var chase_timer := 0.0
var wander_timer := 0.0
var wander_target := Vector3.ZERO
var has_played_sound := false
var default_wander_speed := 10.0

func _ready() -> void:
	default_wander_speed = wander_speed

func _find_target_player() -> Node3D:
	if is_instance_valid(player):
		return player

	var players_node := get_tree().current_scene.find_child("Players", true, false)
	if not players_node:
		return null

	var closest: Node3D = null
	var closest_dist := INF
	for child in players_node.get_children():
		if child is Node3D:
			var dist := global_position.distance_to(child.global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest = child
	player = closest
	return player

func _physics_process(delta: float) -> void:
	# Let the server drive monster AI; clients receive position via MultiplayerSynchronizer
	if multiplayer.has_multiplayer_peer() and not multiplayer.is_server():
		return

	if is_stunned:
		return

	if not _find_target_player():
		return

	var player_distance := global_position.distance_to(player.global_position)

	if player_distance < 8.0 and current_state != State.chasing and current_state != State.fleeing:
		chase_timer = 0.0
		current_state = State.chasing

	match current_state:
		State.wandering:
			has_played_sound = false

			if player_distance <= 20.0:
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
					var random_dist := randf_range(20.0, 45.0)
					wander_target = player.global_position + Vector3(cos(random_angle), 0.0, sin(random_angle)) * random_dist
					wander_timer = randf_range(3.0, 6.0)

			var direction := wander_target - global_position
			direction.y = 0.0
			if direction.length() > 0.1:
				velocity = direction.normalized() * wander_speed
				look_at(Vector3(wander_target.x, global_position.y, wander_target.z), Vector3.UP)
			else:
				velocity = Vector3.ZERO
			move_and_slide()

		State.stalking:
			if player_distance > 20.0:
				current_state = State.wandering
				return

			if player_distance <= 15.0 and not has_played_sound:
				if audio_player and audio_player.stream:
					audio_player.play()
					has_played_sound = true

			if player_distance > 10.0:
				var direction := player.global_position - global_position
				direction.y = 0.0
				velocity = direction.normalized() * initial_move_speed
				look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
			else:
				velocity = Vector3.ZERO
				wait_timer = 2.0
				current_state = State.waiting
			move_and_slide()

		State.waiting:
			velocity = Vector3.ZERO
			move_and_slide()

			wait_timer -= delta
			if wait_timer <= 0.0:
				chase_timer = 0.0
				current_state = State.chasing

		State.chasing:
			chase_timer += delta

			if chase_timer >= 4.0:
				current_state = State.fleeing
				return

			if player_distance > 0.1:
				var direction := player.global_position - global_position
				direction.y = 0.0
				velocity = direction.normalized() * final_move_speed
				look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
			else:
				velocity = Vector3.ZERO
			move_and_slide()

		State.fleeing:
			if player_distance < 30.0:
				var direction := global_position - player.global_position
				direction.y = 0.0
				velocity = direction.normalized() * final_move_speed
				var look_target := global_position + direction
				look_at(Vector3(look_target.x, global_position.y, look_target.z), Vector3.UP)
			else:
				velocity = Vector3.ZERO
				if player_distance > 20.0:
					current_state = State.wandering
				else:
					current_state = State.stalking
			move_and_slide()

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
	current_state = State.fleeing
