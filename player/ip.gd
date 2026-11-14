extends Label

func _ready() -> void:
	SessionManager.host_address_updated.connect(_on_host_address_updated)
	if not SessionManager.host_ip.is_empty():
		_on_host_address_updated("%s:%d" % [SessionManager.host_ip, SessionManager.host_port])
	else:
		visible = false

func _on_host_address_updated(address_and_port: String) -> void:
	visible = not address_and_port.is_empty()
	text = "Host: " + address_and_port
