extends Camera3D

@onready var gunlight = $gunlight
@onready var gun = $Gun
@onready var flashlight = $Flashlight

var gunorflashlight = 1
func _ready() -> void:
	gunlight.hide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if Numbers.bullets > 0:
			gunlightflash()
			
func gunlightflash() -> void:
	gunlight.show()
	await get_tree().create_timer(0.05).timeout
	gunlight.hide()

func _process(delta: float) -> void:
	pass
