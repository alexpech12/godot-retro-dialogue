extends Control

export var character_name = "ALEX"
export var character_portrait: Texture

onready var name_node = get_node("DialogueRect/CharacterName")
onready var dialogue_node = get_node("DialogueRect/Dialogue")
onready var choice_a_node = get_node("DialogueRect/ChoiceA")
onready var choice_b_node = get_node("DialogueRect/ChoiceB")
onready var select_a_node = get_node("DialogueRect/SelectA")
onready var select_b_node = get_node("DialogueRect/SelectB")
onready var portrait_node = get_node("PortraitRect/Portrait")

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
  update_select_indicators()
  
  portrait_node.texture = character_portrait
  name_node.text = character_name

func _process(delta):
  if current_index < (conversation.size() - 1):
    var previous_index = current_index
    
    if Input.is_action_just_pressed("ui_up"):
      safe_select_previous_choice()
      
    if Input.is_action_just_pressed("ui_down"):
      safe_select_next_choice()
      
    if Input.is_action_just_pressed("ui_accept"):
      current_index = get_next_index()
  
    if current_index != previous_index:
      update_text_labels()
      reset_selection()

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
  
func update_select_indicators():
  var select_nodes = [
    select_a_node,
    select_b_node
  ]
  for node in select_nodes:
    node.visible = false
    
  select_nodes[current_choice].visible = true
  
func get_current_choice_count():
  var choices = conversation[current_index].get("choices")
  if choices:
    return choices.size()
  else:
    return 1

func safe_select_previous_choice():
  current_choice = clamp(current_choice - 1, 0, get_current_choice_count() - 1)
  update_select_indicators()
  
func safe_select_next_choice():
  current_choice = clamp(current_choice + 1, 0, get_current_choice_count() - 1)
  update_select_indicators()
  
func reset_selection():
  current_choice = 0
  update_select_indicators()
