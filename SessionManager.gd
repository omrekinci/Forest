extends Node

signal host_address_updated(address_and_port: String)

const GAME_SCENE_PATH := "res://game.tscn"
const MAIN_MENU_PATH := "res://main_menu.tscn"
const DEFAULT_PORT := 7777
const MAX_PLAYERS := 4

var host_ip: String = ""
var host_port: int = DEFAULT_PORT

func start_singleplayer() -> void:
	host_ip = ""
	multiplayer.multiplayer_peer = null
	get_tree().change_scene_to_file(GAME_SCENE_PATH)

func host_game(port: int = DEFAULT_PORT) -> void:
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_server(port, MAX_PLAYERS - 1)
	if err != OK:
		push_error("Failed to host game: " + str(err))
		return

	host_port = port
	host_ip = ""
	multiplayer.multiplayer_peer = peer
	host_address_updated.emit("Fetching IP...")
	_fetch_public_ip()
	get_tree().change_scene_to_file(GAME_SCENE_PATH)

func join_game(raw_address: String = "127.0.0.1", default_port: int = DEFAULT_PORT) -> void:
	var address := raw_address.strip_edges()
	var port := default_port

	if ":" in address:
		var parts := address.split(":")
		address = parts[0].strip_edges()
		if parts.size() > 1 and parts[1].is_valid_int():
			port = parts[1].to_int()

	if address.is_empty():
		address = "127.0.0.1"

	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_client(address, port)
	if err != OK:
		push_error("Failed to join game: " + str(err))
		return

	multiplayer.multiplayer_peer = peer
	get_tree().change_scene_to_file(GAME_SCENE_PATH)

func return_to_menu() -> void:
	host_ip = ""
	multiplayer.multiplayer_peer = null
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file(MAIN_MENU_PATH)

func _fetch_public_ip() -> void:
	var http: HTTPRequest = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(func(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
		http.queue_free()
		if response_code == 200:
			var pub: String = body.get_string_from_utf8().strip_edges()
			if not pub.is_empty():
				host_ip = pub
				host_address_updated.emit("%s:%d" % [host_ip, host_port])
				return
		host_address_updated.emit("IP unavailable:%d" % host_port)
	)
	var err: Error = http.request("https://api.ipify.org")
	if err != OK:
		http.queue_free()
		host_address_updated.emit("IP unavailable:%d" % host_port)
