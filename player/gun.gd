extends Sprite3D

@export var recoil_offset: Vector3 = Vector3(0.0, 0.05, 0.1)
@export var return_speed: float = 15.0          

@onready var gunlight = $gunlight

var default_position: Vector3
var current_offset: Vector3 = Vector3.ZERO

func _ready() -> void:
	gunlight.hide()
	default_position = position

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		apply_recoil()

func apply_recoil() -> void:
	gunlight.show()
	current_offset += recoil_offset
	await get_tree().create_timer(0.05).timeout
	gunlight.hide()

func _process(delta: float) -> void:
	current_offset = current_offset.lerp(Vector3.ZERO, return_speed * delta)

	position = default_position + current_offset
