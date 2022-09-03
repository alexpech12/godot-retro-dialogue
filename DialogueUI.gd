extends Control

onready var name_node = get_node("DialogueRect/CharacterName")
onready var dialogue_node = get_node("DialogueRect/Dialogue")
onready var choice_a_node = get_node("DialogueRect/ChoiceA")
onready var choice_b_node = get_node("DialogueRect/ChoiceB")

var conversation = [
  {
    "dialogue": "Hey there.\nDo you like apples?",
    "choices": [
      {
        "dialogue": "Sure do!",
        "destination": 1
      },
      {
        "dialogue": "No way, gross!",
        "destination": 2
      }
      ]
  },
  {
    "dialogue": "You like apples? Me too!",
    "destination": 3
  },
  {
    "dialogue": "You don't?\nThat's a shame."
  },
  {
    "dialogue": "I like other fruits too."
  },
  {
    "dialogue": "Bananas are my favourite!"
  }
  ]

var current_index = 0

func _ready():
  name_node.text = "ALEX"
  dialogue_node.text = conversation[current_index]["dialogue"]
  choice_a_node.text = "Sure do!"
  choice_b_node.text = "No way, gross!"

func _process(delta):
  if current_index < (conversation.size() - 1):
    var previous_index = current_index
    
    if conversation[current_index].has("choices"):
      if Input.is_action_just_pressed("ui_up"):
        current_index = conversation[current_index]["choices"][0]["destination"]
        
      if Input.is_action_just_pressed("ui_down"):
        current_index = conversation[current_index]["choices"][1]["destination"]
      
    if Input.is_action_just_pressed("ui_accept"):
      current_index = conversation[current_index].get(
        "destination", current_index + 1
      )
    
    if current_index != previous_index:
      dialogue_node.text = conversation[current_index]["dialogue"]
