extends Control

export var characters = {
  "alex": {
    "name": "ALEX",
    "portrait": preload("res://images/Pixel Portraits/female_10_t.png")
  },
  "jupiter": {
    "name": "JUPITER",
    "portrait": preload("res://images/Pixel Portraits/female_11_t.png")
  }
}

onready var name_node = get_node("DialogueRect/CharacterName")
onready var dialogue_node = get_node("DialogueRect/Dialogue")
onready var choice_a_node = get_node("DialogueRect/ChoiceA")
onready var choice_b_node = get_node("DialogueRect/ChoiceB")
onready var select_a_node = get_node("DialogueRect/SelectA")
onready var select_b_node = get_node("DialogueRect/SelectB")
onready var portrait_node = get_node("PortraitRect/Portrait")
onready var text_timer_node = get_node("TextTimer")

var conversation = [
  {
    "character": "alex",
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
    "character": "alex",
    "label": "apples_good",
    "dialogue": "You like apples? Me too!",
    "destination": "part_2"
  },
  {
    "character": "alex",
    "label": "apples_bad",
    "dialogue": "You don't?\nThat's a shame."
  },
  {
    "label": "part_2",
    "character": "alex",
    "dialogue": "I like other fruits too."
  },
  {
    "character": "alex",
    "dialogue": "Hey JUPITER, what do you like?"
  },
  {
    "character": "jupiter",
    "dialogue": "I prefer oranges..."
  },
  {
    "character": "alex",
    "dialogue": "Bananas are my favourite!"
  }
]

var current_index = 0
var current_choice = 0
var text_in_progress = false

func _ready():
  print_dialogue(conversation[current_index]["dialogue"])

func _process(delta):
  if text_in_progress:
    return
  
  if current_index < (conversation.size() - 1):
    var previous_index = current_index
    
    if Input.is_action_just_pressed("ui_up"):
      safe_select_previous_choice()
      
    if Input.is_action_just_pressed("ui_down"):
      safe_select_next_choice()
      
    if Input.is_action_just_pressed("ui_accept"):
      current_index = get_next_index()
  
    if current_index != previous_index:
      print_dialogue(conversation[current_index]["dialogue"])

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
  
func update_character():
  var current_character = conversation[current_index].get("character")
  
  portrait_node.texture = characters[current_character]["portrait"]
  name_node.text = characters[current_character]["name"]
  
func show_choices():
  set_choices_visible(true)
  reset_selection()
  choice_a_node.text = get_current_choice(0).get("dialogue", "...")
  choice_b_node.text = get_current_choice(1).get("dialogue", "")
  
func hide_choices():
  set_choices_visible(false)
  
func set_choices_visible(visible):
  var nodes = [
    select_a_node,
    select_b_node,
    choice_a_node,
    choice_b_node
  ]
  for node in nodes:
    node.visible = visible

func print_dialogue( dialogue ):
  text_in_progress = true
  update_character()
  hide_choices()
  dialogue_node.text = ""
  
  for letter in dialogue:
    text_timer_node.start()
    dialogue_node.add_text(letter)
    yield(text_timer_node, "timeout")

  show_choices()
  text_in_progress = false
