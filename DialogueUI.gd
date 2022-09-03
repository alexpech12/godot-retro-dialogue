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
        "destination": "apples_good"
      },
      {
        "dialogue": "No way, gross!",
        "destination": "apples_bad"
      }
      ]
  },
  {
    "label": "apples_good",
    "dialogue": "You like apples? Me too!",
    "destination": "part_2"
  },
  {
    "label": "apples_bad",
    "dialogue": "You don't?\nThat's a shame."
  },
  {
    "label": "part_2",
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
    var destination = null
    
    if conversation[current_index].has("choices"):
      if Input.is_action_just_pressed("ui_up"):
        destination = conversation[current_index]["choices"][0]["destination"]
        
      if Input.is_action_just_pressed("ui_down"):
        destination = conversation[current_index]["choices"][1]["destination"]
      
    if Input.is_action_just_pressed("ui_accept"):
      destination = conversation[current_index].get("destination", false)
    
    if destination != null:
      if destination:
        current_index = get_index_of_label(destination)
      else:
        current_index += 1
    
    if current_index != previous_index:
      dialogue_node.text = conversation[current_index]["dialogue"]

func get_index_of_label(label):
  for i in range(conversation.size()):
    if conversation[i].get("label") == label:
      return i
  
  assert(false, "Label %s does not exist in this conversation!" % label)
