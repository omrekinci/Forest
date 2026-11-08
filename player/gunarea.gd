extends Area3D

var monster_in_area = false
var bullets = 2

@onready var blast: AudioStreamPlayer = $Gunblast

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			shoot()

func _on_area_entered(area: Area3D) -> void:
	if area.name == "MonsterArea":
		print("Monster entered area")
		monster_in_area = true

func _on_area_exited(area: Area3D) -> void:
	if area.name == "MonsterArea":
		monster_in_area = false

func shoot():
	if bullets > 0:
		
		if blast and blast.stream:
			blast.play()
		
		if monster_in_area == true:
			var overlapping_areas = get_overlapping_areas()
		
			for area in overlapping_areas:
				if area.name == "MonsterArea":
					var monster = area.get_parent()
					if monster.has_method("stun"):
						print("gunstun")
						monster.stun()
		await get_tree().create_timer(0.1).timeout
