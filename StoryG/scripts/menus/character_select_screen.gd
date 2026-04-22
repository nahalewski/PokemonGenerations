extends Control

const CHARACTER_DATA := [
	{
		"id": &"player_m",
		"name": "Boy Trainer",
		"subtitle": "Classic field-ready lead with a strong handheld-era silhouette.",
		"color": Color(1.0, 1.0, 1.0, 1.0),
		"portrait": preload("res://assets/imported/ui/welcome-boy.png"),
	},
	{
		"id": &"player_f",
		"name": "Girl Trainer",
		"subtitle": "Bright, confident, and ready for a region-opening adventure.",
		"color": Color(1.0, 1.0, 1.0, 1.0),
		"portrait": preload("res://assets/imported/ui/welcome-girl.png"),
	},
]

@onready var cards: Array[Node] = [%CardLeft, %CardRight]
@onready var confirm_button: Button = %ConfirmButton
@onready var detail_label: Label = %DetailLabel

var _selected_index := 0


func _ready() -> void:
	_setup_cards()
	_refresh_selection()
	(cards[_selected_index] as Button).grab_focus()
	confirm_button.pressed.connect(_confirm_selection)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_confirm_selection()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		await SceneRouter.go_to(SceneRouter.TITLE_SCENE)
		get_viewport().set_input_as_handled()


func _setup_cards() -> void:
	for index: int in cards.size():
		var card := cards[index]
		var data: Dictionary = CHARACTER_DATA[index]
		card.character_id = data["id"]
		card.title_text = data["name"]
		card.subtitle_text = data["subtitle"]
		card.accent_color = data["color"]
		card.portrait_texture = data["portrait"]
		card.pressed.connect(_on_card_pressed.bind(index))
		card.focus_entered.connect(_on_card_focus_entered.bind(index))


func _on_card_pressed(index: int) -> void:
	_selected_index = index
	_refresh_selection()


func _on_card_focus_entered(index: int) -> void:
	_selected_index = index
	_refresh_selection()


func _refresh_selection() -> void:
	for index: int in cards.size():
		(cards[index] as Button).set_selected(index == _selected_index)
	var selected: Dictionary = CHARACTER_DATA[_selected_index]
	detail_label.text = "%s\n%s" % [selected["name"], selected["subtitle"]]


func _confirm_selection() -> void:
	var selected: Dictionary = CHARACTER_DATA[_selected_index]
	GameSession.set_selected_character(selected["id"])
	await SceneRouter.go_to(SceneRouter.BEDROOM_SCENE)
