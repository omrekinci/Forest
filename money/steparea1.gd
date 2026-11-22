extends Area3D


func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	pass


func _on_area_entered(area: Area3D) -> void:
	if area.name == "BodyArea":
		await get_tree().create_timer(0.5).timeout
		get_parent().queue_free()
