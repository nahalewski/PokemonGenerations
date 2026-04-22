extends Control

@onready var background = $Background
@onready var prof_sprite = $ProfessorSprite
@onready var dialogue_label = $DialogueBox/MarginContainer/Label
@onready var next_indicator = $DialogueBox/NextIndicator

var dialogues = [
	"Welcome to the realm of Aevora...",
	"My name is Professor Anthea. I've dedicated my life to studying the strange energy fractures that define our history.",
	"These beings we call Pokémon... they are more than just creatures. They are echoes of entire generations, woven into the fabric of this world.",
	"The path ahead is uncertain, and Aevora is a land of many faces...",
	"Tell me... which of these echoes do you resonate with?"
]

var current_dialogue_index = 0
var typing_speed = 0.05 # Standard scroll speed
var is_typing = false

func _ready():
	next_indicator.hide()
	start_dialogue()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if is_typing:
			# Skip typing
			dialogue_label.visible_ratio = 1.0
			is_typing = false
			next_indicator.show()
		else:
			next_dialogue()

func start_dialogue():
	show_text(dialogues[current_dialogue_index])

func next_dialogue():
	current_dialogue_index += 1
	if current_dialogue_index < dialogues.size():
		show_text(dialogues[current_dialogue_index])
	else:
		advance_to_player_select()

func show_text(text: String):
	dialogue_label.text = text
	dialogue_label.visible_ratio = 0.0
	is_typing = true
	next_indicator.hide()
	
	var tween = create_tween()
	var duration = text.length() * typing_speed
	tween.tween_property(dialogue_label, "visible_ratio", 1.0, duration)
	tween.finished.connect(func(): 
		is_typing = false
		next_indicator.show()
	)

func advance_to_player_select():
	get_tree().change_scene_to_file("res://scenes/player_select.tscn")
