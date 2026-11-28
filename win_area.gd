extends Area3D

@onready var winscreen = $Winscreen

func _ready() -> void:
	winscreen.visible = false

func _process(delta: float) -> void:
	if winscreen.visible == true:
		Input.mouse_mode == Input.MOUSE_MODE_VISIBLE
	elif winscreen.visible == false:
		Input.mouse_mode == Input.MOUSE_MODE_CAPTURED


func _on_area_entered(area: Area3D) -> void:
	winscreen.visible = true
	
