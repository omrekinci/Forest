extends OptionButton

func _ready() -> void:
	refresh_microphone_list()
	item_selected.connect(_on_microphone_selected)

func refresh_microphone_list() -> void:
	clear()
	
	var devices = AudioServer.get_input_device_list()
	var current_device = AudioServer.get_input_device()
	
	var index = 0
	for device in devices:
		add_item(device)
		if device == current_device:
			select(index)
		index += 1

func _on_microphone_selected(index: int) -> void:
	var selected_device = get_item_text(index)
	AudioServer.set_input_device(selected_device)
	
	save_audio_preference(selected_device)

func save_audio_preference(device_name: String) -> void:
	var config = ConfigFile.new()
	config.set_value("audio", "microphone", device_name)
	config.save("user://settings.cfg")
