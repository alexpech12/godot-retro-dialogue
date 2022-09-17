extends AnimatedSprite

export var walk_speed = 40

export var ui_path: NodePath
onready var ui = get_node(ui_path)

var in_conversation = false
  
func _process(delta):
  if in_conversation:
    return

  if Input.is_action_pressed("ui_right"):
    translate(Vector2(walk_speed * delta,0))
    play("walk")
    flip_h = false
  elif Input.is_action_pressed("ui_left"):
    translate(Vector2(-walk_speed * delta,0))
    play("walk")
    flip_h = true
  else:
    play("idle")

func npc_in_range():
  if not in_conversation and Input.is_action_just_pressed("ui_accept"):
    in_conversation = true
    ui.start_conversation()

func _on_UI_conversation_finished():
  in_conversation = false
