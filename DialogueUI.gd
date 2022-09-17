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
    "dialogue": "Hi, I'm ALEX. <pause 0.5>.<pause 0.5>.<pause 0.5>. [color=yellow]It's nice to meet you![/color] Uh...<pause 2.0> How should I refer to you?",
    "choices": [
      {
        "dialogue": "Call me FRIEND",
        "call": ["set", "title", "FRIEND"]
      },
      {
        "dialogue": "It's CAPTAIN to you",
        "call": ["set", "title", "CAPTAIN"]
      }
    ]
  },
  {
    "character": "alex",
    "dialogue": "Hey {title}.\nDo you like [wave amp=10 freq=-10][color=green]apples[/color][/wave]?",
    "choices": [
      {
        "dialogue": "[wave amp=10 freq=10]Sure do![/wave]",
        "destination": "apples_good"
      },
      {
        "dialogue": "No way, [color=grey][shake rate=10 level=10]gross![/shake][/color]",
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
var skip_text_printing = false

var title = "STRANGER"

var inline_function_regex = RegEx.new()
var dialogue_calls = {}

func _ready():
  inline_function_regex.compile("<(?<function_call>.+?)>")
  print_dialogue(conversation[current_index]["dialogue"])

func _process(delta):
  if text_in_progress:
    if Input.is_action_just_pressed("ui_accept"):
      skip_text_printing()
    
    return
  
  if current_index < (conversation.size() - 1):
    var previous_index = current_index
    
    if Input.is_action_just_pressed("ui_up"):
      safe_select_previous_choice()
      
    if Input.is_action_just_pressed("ui_down"):
      safe_select_next_choice()
      
    if Input.is_action_just_pressed("ui_accept"):
      execute_current_choice()
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
  name_node.bbcode_text = characters[current_character]["name"]
  
func show_choices():
  set_choices_visible(true)
  reset_selection()
  choice_a_node.bbcode_text = get_current_choice(0).get("dialogue", "...")
  choice_b_node.bbcode_text = get_current_choice(1).get("dialogue", "")
  
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
  
  var formatted_dialogue = dialogue.format({ "title": title })
  dialogue_node.bbcode_text = process_dialogue_inline_functions(formatted_dialogue)
  dialogue_node.visible_characters = 0

  yield(get_tree(),"idle_frame")
  for i in dialogue_node.get_total_character_count():
    # Process any function calls first, before showing the next character.
    var results = call_dialogue_functions(i)
    if results:
      for result in results:
        # This is what the function will return if it yields.
        # If it does yield, we also need to yield here to wait until that coroutine completes.
        if result is GDScriptFunctionState:
            yield(result, "completed")
            
    text_timer_node.start()
    dialogue_node.visible_characters += 1
    yield(text_timer_node, "timeout")

    if skip_text_printing:
      skip_text_printing = false
      dialogue_node.visible_characters = -1
      break

  show_choices()
  text_in_progress = false
  
func skip_text_printing():
  skip_text_printing = true
  text_timer_node.emit_signal("timeout")
  text_timer_node.stop()
  
func execute_current_choice():
  var call_array = get_current_choice(current_choice).get("call")
  
  if call_array:
    var call_method = call_array[0]
    var call_args = call_array.slice(1, call_array.size())
    callv(call_method, call_args)

func add_dialogue_call(index, dialogue_call):
  var dialogue_calls_at_index = dialogue_calls.get(index, [])
  dialogue_calls_at_index.push_back(dialogue_call) 
  dialogue_calls[index] = dialogue_calls_at_index

func process_dialogue_inline_functions(dialogue):
  # Clear our existing function call list
  dialogue_calls = {}
  
  var visible_character_count = 0
  var in_bbcode = false

  var i = -1
  while i + 1 < dialogue.length():
    i += 1
    
    var character = dialogue[i]
    
    # Ignore bbcode tag sections
    if character == '[':
      in_bbcode = true
      continue
    elif character == ']':
      in_bbcode = false
      continue
    elif in_bbcode:
      continue
    
    # If this is the start of an inline function call, process it and strip it from the dialogue
    if character == '<':
      var result = inline_function_regex.search(dialogue, i)
      if result:
        add_dialogue_call(visible_character_count, result.get_string("function_call").split(" "))
        dialogue.erase(result.get_start(), result.get_end() - result.get_start())
        i -= 1
    else:
      visible_character_count += 1

  return dialogue
  
func pause(delay_string):
  var delay = float(delay_string)
  yield(get_tree().create_timer(delay), "timeout")
  
func call_dialogue_functions(index):
  var dialogue_calls_for_index = dialogue_calls.get(index)
  var results = []
  if dialogue_calls_for_index:
    for dialogue_call in dialogue_calls_for_index:
      var call_method = dialogue_call[0]
      dialogue_call.remove(0)

      results.push_back(callv(call_method, dialogue_call))
    
  return results
