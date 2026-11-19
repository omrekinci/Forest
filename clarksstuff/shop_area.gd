extends Area3D

@onready var shopui = $shop
@onready var shop_camera = $shopcam
@onready var redbull = $redbull
@onready var ammobox = $ammobox

var player_in_range = false
var shop_opened = false
var active_player_camera: Camera3D = null

var original_camera_transform: Transform3D

func _ready() -> void:
	redbull.hide()
	ammobox.hide()
	
	shopui.visible = false
	if shop_camera:
		shop_camera.current = false

func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_E) and player_in_range:
		if not shop_opened:
			player_in_range = false 
			await get_tree().create_timer(0.2).timeout
			open_shop()
			player_in_range = true
		else:
			player_in_range = false
			await get_tree().create_timer(0.2).timeout
			close_shop()
			player_in_range = true

func open_shop() -> void:
	redbull.show()
	ammobox.show()
	Numbers.shopisopened = true
	shop_opened = true
	shopui.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	print("shop opened")
	
	active_player_camera = get_viewport().get_camera_3d()
	if active_player_camera and shop_camera:
		if active_player_camera.get_parent() is Node3D:
			original_camera_transform = active_player_camera.transform
		else:
			original_camera_transform = active_player_camera.global_transform
		
		var tween = create_tween().set_parallel(false).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(active_player_camera, "global_transform", shop_camera.global_transform, 0.8)


func close_shop() -> void:
	redbull.hide()
	ammobox.hide()
	Numbers.shopisopened = false
	shop_opened = false
	shopui.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	print("shop closed")
	
	if active_player_camera:
		var tween = create_tween().set_parallel(false).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

		if active_player_camera.get_parent() is Node3D:
			tween.tween_property(active_player_camera, "transform", original_camera_transform, 0.8)
		else:
			tween.tween_property(active_player_camera, "global_transform", original_camera_transform, 0.8)	
			
func _on_area_entered(area: Area3D) -> void:
	if area.name == "BodyArea":
		player_in_range = true

func _on_area_exited(area: Area3D) -> void:
	if area.name == "BodyArea":
		player_in_range = false
