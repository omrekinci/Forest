extends Control

@onready var host_button: Button = $VBoxContainer/HostButton
@onready var address_input: LineEdit = $VBoxContainer/AddressInput
@onready var join_button: Button = $VBoxContainer/JoinButton
@onready var quit_button: Button = $VBoxContainer/QuitButton

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	host_button.pressed.connect(SessionManager.host_game)
	join_button.pressed.connect(_on_join_pressed)
	quit_button.pressed.connect(get_tree().quit)

func _on_join_pressed() -> void:
	var address := address_input.text.strip_edges()
	if address.is_empty():
		address = "127.0.0.1"
	SessionManager.join_game(address)
