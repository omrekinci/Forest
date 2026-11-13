extends Control

@export var inventory_width: int = 4
@export var inventory_height: int = 4

@onready var grid_container: GridContainer = $Panel/GridContainer
@onready var redbull_item: Sprite2D = $redbullitem

var redbull_texture: Texture2D

var inventory_data: Array = []

var held_item = null
var held_from_index: int = -1
var hovered_slot_index: int = -1

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	grid_container.columns = inventory_width
	
	var panel = $Panel as Control
	if panel:
		panel.anchors_preset = Control.PRESET_CENTER
		panel.custom_minimum_size = Vector2(460, 460)
	
	if redbull_item and redbull_item.texture:
		redbull_texture = redbull_item.texture
	
	var total_slots = inventory_width * inventory_height
	inventory_data.resize(total_slots)
	inventory_data.fill(null)
	
	Numbers.inventoryisopenned = visible
	
	sync_inventory_with_globals()
	refresh_grid()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		toggle_inventory()
	elif visible and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		consume_hovered_redbull()

func consume_hovered_redbull() -> void:
	if hovered_slot_index < 0 or hovered_slot_index >= inventory_data.size():
		return
	var item = inventory_data[hovered_slot_index]
	if item != null and item.get("item_name") == "Red Bull":
		Numbers.energy += 25
		inventory_data[hovered_slot_index] = null
		Numbers.redbull_amount = max(0, Numbers.redbull_amount - 1)
		hovered_slot_index = -1
		refresh_grid()

func toggle_inventory() -> void:
	visible = !visible
	
	Numbers.inventoryisopenned = visible
	
	if visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		sync_inventory_with_globals()
		refresh_grid()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		hovered_slot_index = -1
		if held_item != null:
			inventory_data[held_from_index] = held_item
			held_item = null
			held_from_index = -1
			refresh_grid()

func sync_inventory_with_globals() -> void:
	var current_count = 0
	for item in inventory_data:
		if item != null and item.get("item_name") == "Red Bull":
			current_count += 1
	
	var target_count = min(Numbers.redbull_amount, inventory_data.size())
	
	if target_count > current_count:
		var to_add = target_count - current_count
		for i in range(inventory_data.size()):
			if to_add <= 0:
				break
			if inventory_data[i] == null:
				inventory_data[i] = {
					"item_name": "Red Bull",
					"texture": redbull_texture
				}
				to_add -= 1
				
	elif target_count < current_count:
		var to_remove = current_count - target_count
		for i in range(inventory_data.size() - 1, -1, -1):
			if to_remove <= 0:
				break
			if inventory_data[i] != null and inventory_data[i].get("item_name") == "Red Bull":
				inventory_data[i] = null
				to_remove -= 1

func refresh_grid() -> void:
	hovered_slot_index = -1
	for child in grid_container.get_children():
		child.queue_free()
	
	for i in range(inventory_data.size()):
		var slot_node = Panel.new()
		slot_node.custom_minimum_size = Vector2(96, 96)
		
		slot_node.mouse_filter = Control.MOUSE_FILTER_STOP
		slot_node.gui_input.connect(_on_slot_gui_input.bind(i))
		slot_node.mouse_entered.connect(_on_slot_mouse_entered.bind(i))
		slot_node.mouse_exited.connect(_on_slot_mouse_exited.bind(i))
		
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.2, 0.2, 0.2, 0.8)
		style.border_width_left = 2
		style.border_width_right = 2
		style.border_width_top = 2
		style.border_width_bottom = 2
		
		if held_from_index == i:
			style.border_color = Color(1.0, 0.8, 0.2)
			style.bg_color = Color(0.3, 0.3, 0.3, 0.9)
		else:
			style.border_color = Color(0.4, 0.4, 0.4)
			
		slot_node.add_theme_stylebox_override("panel", style)
		
		var item = inventory_data[i]
		if item != null and item.has("texture") and item["texture"] != null:
			var icon_rect = TextureRect.new()
			icon_rect.texture = item["texture"]
			icon_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
			icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
			icon_rect.anchor_right = 1.0
			icon_rect.anchor_bottom = 1.0
			
			var scale_factor = 0.2
			icon_rect.scale = Vector2(scale_factor, scale_factor)
			icon_rect.pivot_offset = slot_node.custom_minimum_size / 2.0
			
			slot_node.add_child(icon_rect)
		
		grid_container.add_child(slot_node)

func _on_slot_mouse_entered(slot_index: int) -> void:
	hovered_slot_index = slot_index

func _on_slot_mouse_exited(slot_index: int) -> void:
	if hovered_slot_index == slot_index:
		hovered_slot_index = -1

func _on_slot_gui_input(event: InputEvent, slot_index: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if held_item == null:
			if inventory_data[slot_index] != null:
				held_item = inventory_data[slot_index]
				held_from_index = slot_index
				inventory_data[slot_index] = null
				refresh_grid()
		else:
			var target_item = inventory_data[slot_index]
			inventory_data[slot_index] = held_item
			
			if target_item != null:
				held_item = target_item
				held_from_index = slot_index
			else:
				held_item = null
				held_from_index = -1
				
			refresh_grid()
