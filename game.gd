extends Node3D

const PLAYER_SCENE: PackedScene = preload("res://player/player.tscn")
@onready var players_container: Node3D = $Players

func _ready() -> void:
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(_spawn_player)
		multiplayer.peer_disconnected.connect(_despawn_player)

		_spawn_player(1)

		for peer_id in multiplayer.get_peers():
			_spawn_player(peer_id)

func _spawn_player(id: int) -> void:
	if players_container.has_node(str(id)):
		return

	var player := PLAYER_SCENE.instantiate()
	player.name = str(id)
	player.position = Vector3(randf_range(-2.0, 2.0), 1.0, randf_range(-2.0, 2.0))
	players_container.add_child(player)

func _despawn_player(id: int) -> void:
	if players_container.has_node(str(id)):
		players_container.get_node(str(id)).queue_free()
