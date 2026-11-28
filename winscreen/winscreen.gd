extends Control

@onready var quitbutton = $VBoxContainer/QuitButton

const MAIN_MENU_PATH := "res://main_menu.tscn"

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	quitbutton.pressed.connect(_on_quit_pressed)


func _process(delta: float) -> void:
	pass

func _on_quit_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
