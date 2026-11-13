extends Area3D

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_area_entered(area: Area3D) -> void:
	if area.name == "BodyArea":
		Numbers.energy += 25
		owner.queue_free()
