extends Control

@onready var arrowredbull = $arrowredbull
@onready var arrowammo = $arrowammo

var current_selection: int = 0

func _ready() -> void:
	arrowredbull.hide()
	arrowammo.hide()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("ui_left") or (event is InputEventKey and event.pressed and event.keycode == KEY_LEFT):
		current_selection = 1
		arrowredbull.show()
		arrowammo.hide()
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("ui_right") or (event is InputEventKey and event.pressed and event.keycode == KEY_RIGHT):
		current_selection = 2
		arrowredbull.hide()
		arrowammo.show()
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and event.keycode == KEY_ENTER):
		if current_selection == 1:
			if Numbers.money >= 5:
				Numbers.money -= 5
				Numbers.redbull_amount += 1
				if Numbers.money <= 0:
					Numbers.money = 0
		elif current_selection == 2:
			if Numbers.money >= 10:
				Numbers.money -= 10
				Numbers.ammo += 4
				if Numbers.money <= 0:
					Numbers.money = 0
				
		get_viewport().set_input_as_handled()
