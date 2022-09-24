extends Control

signal conversation_finished

export var characters_per_line = 21
export var max_lines_visible = 2

onready var name_node = get_node("DialogueRect/CharacterName")
onready var dialogue_node = get_node("DialogueRect/Dialogue")
onready var choice_a_node = get_node("DialogueRect/ChoiceA")
onready var choice_b_node = get_node("DialogueRect/ChoiceB")
onready var select_a_node = get_node("DialogueRect/SelectA")
onready var select_b_node = get_node("DialogueRect/SelectB")
onready var portrait_node = get_node("PortraitRect/Portrait")
onready var text_timer_node = get_node("TextTimer")

var conversation_node: Conversation

var current_index = 0
var current_choice = 0
var text_in_progress = false
var fast_text_printing = false
var current_scroll_position = 0

var inline_function_regex = RegEx.new()
var dialogue_calls = {}

func _ready():
  visible = false
  inline_function_regex.compile("<(?<function_call>.+?)>")
  
func start_conversation(resource):
  conversation_node = resource
  current_index = 0
  current_choice = 0
  print_dialogue(conversation_node.conversation[current_index]["dialogue"])
  visible = true

func _process(delta):
  if not visible:
    return
    
  if text_in_progress:
    if Input.is_action_just_pressed("ui_accept"):
      start_fast_text_printing()
    elif Input.is_action_just_released("ui_accept"):
      stop_fast_text_printing()
      
    return
  
  if current_index < (conversation_node.conversation.size() - 1):
    var previous_index = current_index
    
    if Input.is_action_just_pressed("ui_up"):
      safe_select_previous_choice()
      
    if Input.is_action_just_pressed("ui_down"):
      safe_select_next_choice()
      
    if Input.is_action_just_pressed("ui_accept"):
      execute_current_choice()
      current_index = get_next_index()
  
    if current_index != previous_index:
      print_dialogue(conversation_node.conversation[current_index]["dialogue"])
  else:
    if Input.is_action_just_pressed("ui_accept"):
      finish_conversation()

func get_next_index():
  var destination = null
  if conversation_node.conversation[current_index].has("choices"):
    var choice = conversation_node.conversation[current_index]["choices"][current_choice]
    destination = choice.get("destination")
  else:
    destination = conversation_node.conversation[current_index].get("destination")
    
  if destination:
    return get_index_of_label(destination)
  else:
    return current_index + 1

func get_index_of_label(label):
  for i in range(conversation_node.conversation.size()):
    if conversation_node.conversation[i].get("label") == label:
      return i
  
  assert(false, "Label %s does not exist in this conversation!" % label)
  
func get_current_choice(choice_index):
  var choices = conversation_node.conversation[current_index].get("choices", [])
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
  var choices = conversation_node.conversation[current_index].get("choices")
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
  var current_character = conversation_node.conversation[current_index].get("character")
  
  portrait_node.texture = conversation_node.characters[current_character]["portrait"]
  name_node.bbcode_text = conversation_node.characters[current_character]["name"]
  
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
  
  var formatted_dialogue = format_dialogue(dialogue)
  dialogue_node.bbcode_text = process_dialogue_inline_functions(formatted_dialogue)
  dialogue_node.visible_characters = 0
  dialogue_node.scroll_to_line(0)
  current_scroll_position = 0

  yield(get_tree(),"idle_frame")
  for i in dialogue_node.get_total_character_count():
    # Process any function calls first, before showing the next character.
    var results = call_dialogue_functions(i)
    if results:
      for result in results:
        if not result:
          continue
          
        var dialogue_function = result[0]
        var result_value = result[1]
          
        # This is what the function will return if it yields.
        if result_value is GDScriptFunctionState:
          # If we're trying to skip quickly through the text, complete this function immediately if we're allowed to do so.
          if fast_text_printing and dialogue_function in skippable_functions:
            while result_value is GDScriptFunctionState and result_value.is_valid():
              result_value = result_value.resume()
          else:
            # Otherwise, if the function has yielded, we need to yield here also to wait until that coroutine completes.
            yield(result_value, "completed")

    if fast_text_printing:
      dialogue_node.visible_characters += 1
      yield(get_tree(),"idle_frame")
    else:
      text_timer_node.start()
      dialogue_node.visible_characters += 1
      yield(text_timer_node, "timeout")

  show_choices()
  text_in_progress = false
  
func start_fast_text_printing():
  fast_text_printing = true
  text_timer_node.emit_signal("timeout")
  
func stop_fast_text_printing():
  fast_text_printing = false
  
func execute_current_choice():
  var call_array = get_current_choice(current_choice).get("call")
  
  if call_array:
    var call_method = call_array[0]
    var call_object = conversation_node if conversation_node.has_method(call_method) else self
    var call_args = call_array.slice(1, call_array.size())
    call_object.callv(call_method, call_args)

func add_dialogue_call(index, dialogue_call):
  var dialogue_calls_at_index = dialogue_calls.get(index, [])
  dialogue_calls_at_index.push_back(dialogue_call) 
  dialogue_calls[index] = dialogue_calls_at_index

func process_dialogue_inline_functions(dialogue):
  # Clear our existing function call list
  dialogue_calls = {}
  
  var visible_character_count = 0
  var line_count = 1
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
    # Perform manual scrolling.
    # If this is a newline and we're above the maximum number of visible lines, insert a 'scroll' function
    elif character == "\n":
      line_count += 1
      if line_count > max_lines_visible:
        add_dialogue_call(visible_character_count, ["scroll"])
    else:
      visible_character_count += 1

  return dialogue
  
func pause(delay_string):
  var delay = float(delay_string)
  yield(get_tree().create_timer(delay), "timeout")
  
var skippable_functions = ["pause"]

func call_dialogue_functions(index):
  var dialogue_calls_for_index = dialogue_calls.get(index)
  var results = []
  if dialogue_calls_for_index:
    for dialogue_call in dialogue_calls_for_index:
      var call_method = dialogue_call[0]
      dialogue_call.remove(0)
      
      var call_object = conversation_node if conversation_node.has_method(call_method) else self

      results.push_back([call_method, call_object.callv(call_method, dialogue_call)])
    
  return results

func format_dialogue(dialogue):
  # Replace any variables in {} brackets with their values
  var formatted_dialogue = dialogue.format(conversation_node.dialogue_variables())
  
  var characters_in_line_count = 0
  var line_count = 1
  var last_space_index = 0
  var ignore_stack = []
  # Everything between these brackets should be ignored.
  # It's formatted in a dictionary so we can easily fetch the corresponding close bracket for an open bracket.
  var ignore_bracket_pairs = { 
    "[": "]", 
    "<": ">" 
  }

  for i in formatted_dialogue.length():
    var character = formatted_dialogue[i]
    
    # Ignore everything between [] or <> brackets.
    # By using a stack, we can more easily support nested brackets, like [<>] or <[]>
    if character in ignore_bracket_pairs.keys():
      ignore_stack.push_back(character)
      continue
    elif character == ignore_bracket_pairs.get(ignore_stack.back()):
      ignore_stack.pop_back()
      continue
    elif not ignore_stack.empty():
      continue
    
    # Keep track of the last space we encounter. 
    # This will be where we want to insert a newline if the line overflows.
    if character == " ":
      last_space_index = i
      
    # If we've encountered a newline that's been manually inserted into the string, reset our counter
    if character == "\n":
      characters_in_line_count = 0
    elif characters_in_line_count > characters_per_line:
      # This character has caused on overflow and we need to insert a newline.
      # Insert it at the position of the last space so that we don't break up the work.
      formatted_dialogue[last_space_index] = "\n"
      # Since this word will now wrap, we'll be starting part way through the next line.
      # Our new character count is going to be the amount of characters between the current position
      # and the last space (where we inserted the newline)
      characters_in_line_count = i - last_space_index
    
    characters_in_line_count += 1
  
  return formatted_dialogue
  
func scroll():
  current_scroll_position += 1
  dialogue_node.scroll_to_line(current_scroll_position)

func finish_conversation():
  visible = false
  emit_signal("conversation_finished")
