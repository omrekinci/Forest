extends CharacterBody3D

@export var player: Node3D
@export var initial_move_speed: float = 3.0
@export var final_move_speed: float = 10.0
@export var wander_speed: float = 2.0

@onready var audio_player: AudioStreamPlayer3D = $PresenceAuido

enum State { wandering, stalking, waiting, chasing, fleeing }
var current_state: State = State.wandering
var is_stunned = false

var wait_timer: float = 0.0
var chase_timer: float = 0.0
var wander_timer: float = 0.0
var wander_target: Vector3 = Vector3.ZERO
var has_played_sound: bool = false

func _physics_process(delta: float) -> void:
	if not player:
		return
	
	var player_distance = global_position.distance_to(player.global_position)
	
	if player_distance < 8.0 and current_state != State.chasing and current_state != State.fleeing:
		chase_timer = 0.0
		current_state = State.chasing
	
	match current_state:
		State.wandering:
			has_played_sound = false
			
			if player_distance <= 20.0:
				current_state = State.stalking
				return
			
			if player_distance > 45.0:
				wander_target = player.global_position
			else:
				wander_timer -= delta
				if wander_timer <= 0.0 or global_position.distance_to(wander_target) < 1.5:
					var random_angle = randf() * TAU
					var random_dist = randf_range(20.0, 45.0)
					wander_target = player.global_position + Vector3(cos(random_angle), 0, sin(random_angle)) * random_dist
					wander_timer = randf_range(3.0, 6.0)
			
			var direction = (wander_target - global_position)
			direction.y = 0
			if direction.length() > 0.1:
				velocity = direction.normalized() * wander_speed
				look_at(Vector3(wander_target.x, global_position.y, wander_target.z), Vector3.UP)
				move_and_slide()
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
				var direction = (player.global_position - global_position)
				direction.y = 0
				
				velocity = direction.normalized() * initial_move_speed
				look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
				move_and_slide()
			else:
				velocity = Vector3.ZERO
				move_and_slide()
				
				wait_timer = 2.0
				current_state = State.waiting
				
		State.waiting:
			velocity = Vector3.ZERO
			move_and_slide()
			
			wait_timer -= delta
			
			if wait_timer <= 0.0:
				chase_timer = 0.0
				current_state = State.chasing
				
		State.chasing:
			chase_timer += delta
			
			if chase_timer >= 3.0:
				current_state = State.fleeing
				return
			
			if player_distance > 0.1:
				var direction = (player.global_position - global_position)
				direction.y = 0
				
				velocity = direction.normalized() * final_move_speed
				look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
				move_and_slide()
			else:
				velocity = Vector3.ZERO
				move_and_slide()
				
		State.fleeing:
			if player_distance < 30.0:
				var direction = (global_position - player.global_position)
				direction.y = 0
				
				velocity = direction.normalized() * final_move_speed
				
				var look_target = global_position + direction
				look_at(Vector3(look_target.x, global_position.y, look_target.z), Vector3.UP)
				move_and_slide()
			else:
				velocity = Vector3.ZERO
				move_and_slide()
				
				if player_distance > 20.0:
					current_state = State.wandering
				else:
					current_state = State.stalking

func stun():
	print("stunmonster")
	is_stunned = true
	set_physics_process(false)
	await get_tree().create_timer(5.0).timeout
	set_physics_process(true)
	is_stunned = false
