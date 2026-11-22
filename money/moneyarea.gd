extends Area3D


func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass


func _on_area_entered(area: Area3D) -> void:
	if area.name == "BodyArea":
		Numbers.money += 5
		owner.queue_free()
