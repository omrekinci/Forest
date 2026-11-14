extends Sprite3D

@export var recoil_offset := Vector3(0.0, 0.025, 0.15)
@export var return_speed := 15.0

var default_position: Vector3
var current_offset: Vector3 = Vector3.ZERO

func _ready() -> void:
	default_position = position

func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if Numbers.bullets > 0 and Numbers.inventoryisopenned == false:
			_rpc_apply_recoil.rpc()

@rpc("any_peer", "call_local", "reliable")
func _rpc_apply_recoil() -> void:
	apply_recoil()

func apply_recoil() -> void:
	current_offset += recoil_offset
	await get_tree().create_timer(0.05).timeout

func _process(delta: float) -> void:
	current_offset = current_offset.lerp(Vector3.ZERO, return_speed * delta)
	position = default_position + current_offset
