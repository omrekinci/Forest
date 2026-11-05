extends Node3D

@export var target: Node3D
@export var rotation_speed: float = 8.0

func _process(delta: float) -> void:
	if target:
		var target_pos = target.global_position
		target_pos.y = global_position.y
		
		var target_transform = global_transform.looking_at(target_pos, Vector3.UP)
		target_transform = target_transform.rotated_local(Vector3.UP, PI)
		
		var current_quat = Quaternion(global_transform.basis)
		var target_quat = Quaternion(target_transform.basis)
		
		current_quat = current_quat.slerp(target_quat, rotation_speed * delta)
		
		global_transform.basis = Basis(current_quat)
