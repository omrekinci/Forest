extends Label

# Add as many sentences as you want in the Inspector or right here
@export var sentences: Array[String] = [
	"Your car broke down in the middle of the forest.",
	"There is a Gas Station 1 KM away :D",
	"You need to follow the road and find safety",
	"Good Luck"
]
@export var seconds_per_character: float = 0.05
@export var pause_between_sentences: float = 1.0

func _ready() -> void:
	play_dialogue()

func play_dialogue() -> void:
	for sentence in sentences:
		text = sentence
		visible_characters = 0
		
		var total_duration = text.length() * seconds_per_character
		var tween = create_tween()
		tween.tween_property(self, "visible_characters", text.length(), total_duration)
		
		# Wait for the typing animation to finish
		await tween.finished
		
		# Wait a moment so the player has time to read before replacing the text
		await get_tree().create_timer(pause_between_sentences).timeout
	
	# Optional: hide the label once all sentences are done
	visible = false
