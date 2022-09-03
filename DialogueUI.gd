extends Control

onready var name_node = get_node("DialogueRect/CharacterName")
onready var dialogue_node = get_node("DialogueRect/Dialogue")
onready var choice_a_node = get_node("DialogueRect/ChoiceA")
onready var choice_b_node = get_node("DialogueRect/ChoiceB")

var dialogue = [
  "Hey there.\nDo you like apples?",
  "I like other fruits too.",
  "Bananas are my favourite!"
]

var current_index = 0

func _ready():
  name_node.text = "ALEX"
  dialogue_node.text = dialogue[current_index]
  choice_a_node.text = "Sure do!"
  choice_b_node.text = "No way, gross!"
  
func _process(delta):
  if (Input.is_action_just_pressed("ui_accept")
      and current_index < (dialogue.size() - 1)):
    current_index += 1
    dialogue_node.text = dialogue[current_index]
