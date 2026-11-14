extends CanvasLayer

@onready var label: Label = $VBoxContainer/Label
@onready var exit_button: Button = $VBoxContainer/QuitButton

@export var fade_duration: float = 1.5

var _triggered: bool = false

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	_reset_ui_opacity()
	exit_button.pressed.connect(_on_exit_button_pressed)

func _reset_ui_opacity() -> void:
	label.modulate.a = 0.0
	exit_button.modulate.a = 0.0
	exit_button.disabled = true

func _process(_delta: float) -> void:
	if not _triggered and Numbers.health <= 0:
		_open_death_screen()

func _open_death_screen() -> void:
	_triggered = true
	_reset_ui_opacity()
	show()
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_parallel(true)
	tween.tween_property(label, "modulate:a", 1.0, fade_duration)
	tween.tween_property(exit_button, "modulate:a", 1.0, fade_duration)
	tween.chain().tween_callback(func() -> void:
		exit_button.disabled = false
	)

func _on_exit_button_pressed() -> void:
	get_tree().paused = false
	Numbers.health = 100
	get_tree().change_scene_to_file("res://main_menu.tscn")
