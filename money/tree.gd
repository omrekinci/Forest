extends Area3D

const tree_scene = preload("res://tree/Tree.tscn")

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func spawn_tree() -> void:
	var tree_instance = tree_scene.instantiate() as Node3D
	tree_instance.global_position = global_position
	get_tree().current_scene.add_child(tree_instance)
	queue_free()

func _on_area_entered(area: Area3D) -> void:
	if area.name == "BodyArea":
		await get_tree().create_timer(2.0).timeout
		spawn_tree()
