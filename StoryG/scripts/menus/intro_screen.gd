extends Control

const INTRO_LINES: Array[Dictionary] = [
	{"speaker": "Professor Rowan Vale", "text": "Good morning, trainer. Every journey begins with a choice and a little courage."},
	{"speaker": "Professor Rowan Vale", "text": "Beyond your room waits a region full of creatures, rivals, and stories still waking up."},
	{"speaker": "Professor Rowan Vale", "text": "Before we step outside, tell me how you want this adventure to remember you."},
]

@onready var dialogue_player: Control = %DialoguePlayer
@onready var intro_music: AudioStreamPlayer = %IntroMusic


func _ready() -> void:
	dialogue_player.set_lines(INTRO_LINES)
	dialogue_player.sequence_finished.connect(_on_sequence_finished)
	intro_music.play()


func _on_sequence_finished() -> void:
	GameSession.mark_intro_seen()
	await SceneRouter.go_to(SceneRouter.CHARACTER_SELECT_SCENE)
