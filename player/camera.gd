extends Camera3D

@onready var flashlight = $Flashlight
@onready var gunlight = $gunlight
@onready var gun = $Gun

func _ready() -> void:
	gunlight.hide()

func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if Numbers.bullets > 0 and Numbers.inventoryisopenned == false:
			_rpc_gunlightflash.rpc()

@rpc("any_peer", "call_local", "reliable")
func _rpc_gunlightflash() -> void:
	gunlightflash()

func gunlightflash() -> void:
	gunlight.show()
	await get_tree().create_timer(0.05).timeout
	if is_instance_valid(gunlight):
		gunlight.hide()

func _process(delta: float) -> void:
	pass
