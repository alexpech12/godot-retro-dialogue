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
var current_choice = 0

func _ready():
  update_text_labels()

func _process(delta):
  if current_index < (conversation.size() - 1):
    var previous_index = current_index
    
    if conversation[current_index].has("choices"):
      if Input.is_action_just_pressed("ui_up"):
        current_choice -= 1
        
      if Input.is_action_just_pressed("ui_down"):
        current_choice += 1
      
    if Input.is_action_just_pressed("ui_accept"):
      current_index = get_next_index()
  
    if current_index != previous_index:
      update_text_labels()

func get_next_index():
  var destination = null
  if conversation[current_index].has("choices"):
    var choice = conversation[current_index]["choices"][current_choice]
    destination = choice.get("destination")
  else:
    destination = conversation[current_index].get("destination")
    
  if destination:
    return get_index_of_label(destination)
  else:
    return current_index + 1

func get_index_of_label(label):
  for i in range(conversation.size()):
    if conversation[i].get("label") == label:
      return i
  
  assert(false, "Label %s does not exist in this conversation!" % label)
  
func get_current_choice(choice_index):
  var choices = conversation[current_index].get("choices", [])
  if choice_index < choices.size():
    return choices[choice_index]
  else:
    return {}
    
func update_text_labels():
  name_node.text = "ALEX"
  dialogue_node.text = conversation[current_index]["dialogue"]
  choice_a_node.text = get_current_choice(0).get("dialogue", "...")
  choice_b_node.text = get_current_choice(1).get("dialogue", "")
