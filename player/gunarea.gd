extends Area3D

var monster_in_area := false

@onready var blast = $Gunblast

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			shoot()

	if Input.is_key_pressed(KEY_R):
		if Numbers.inventoryisopenned == false:
			if Numbers.bullets == 0 and Numbers.ammo >= 2:
				Numbers.bullets += 2
				Numbers.ammo -= 2
			elif Numbers.bullets == 0 and Numbers.ammo == 1:
				Numbers.bullets += 1
				Numbers.ammo -= 1
			elif Numbers.bullets == 1 and Numbers.ammo >= 1:
				Numbers.bullets += 1
				Numbers.ammo -= 1

func _on_area_entered(area: Area3D) -> void:
	if area.name == "MonsterArea":
		print("Monster entered area")
		monster_in_area = true

func _on_area_exited(area: Area3D) -> void:
	if area.name == "MonsterArea":
		monster_in_area = false

func shoot() -> void:
	if not is_multiplayer_authority():
		return

	if Numbers.inventoryisopenned == false and Numbers.bullets > 0:
		Numbers.bullets -= 1
		_rpc_shoot_effects.rpc()

		if monster_in_area == true:
			var overlapping_areas := get_overlapping_areas()
			for area in overlapping_areas:
				if area.name == "MonsterArea":
					var monster = area.get_parent()
					if monster and monster.has_method("stun"):
						print("gunstun")
						monster.stun()

@rpc("any_peer", "call_local", "reliable")
func _rpc_shoot_effects() -> void:
	if blast and blast.stream:
		blast.play()
	await get_tree().create_timer(0.1).timeout
