extends Control

@onready var host_button: Button = $VBoxContainer/HostButton
@onready var address_input: LineEdit = $VBoxContainer/AddressInput
@onready var join_button: Button = $VBoxContainer/JoinButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var avatar_button = $VBoxContainer/AvatarButton

@onready var avatar_selector = $AvatarSelector

@onready var mainmenusprite = $mainmenu

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	host_button.pressed.connect(SessionManager.host_game)
	join_button.pressed.connect(_on_join_pressed)
	avatar_button.pressed.connect(_on_avatar_pressed)
	quit_button.pressed.connect(get_tree().quit)
	
	avatar_selector.visible = false
	
	mainmenusprite.play("default")

func _on_join_pressed() -> void:
	var address := address_input.text.strip_edges()
	if address.is_empty():
		address = "127.0.0.1"
	SessionManager.join_game(address)

func _on_avatar_pressed():
	avatar_selector.visible = !avatar_selector.visible
	
