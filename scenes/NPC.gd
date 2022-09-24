extends AnimatedSprite

export var player_path: NodePath
onready var player = get_node(player_path)

export var conversation_distance = 30

onready var conversation = get_node("Conversation")

func _ready():
  $SpeechBubble.visible = false

func _process(delta):
  if abs(position.x - player.position.x) < conversation_distance:
    $SpeechBubble.visible = true
    player.npc_in_range(self)
  else:
    $SpeechBubble.visible = false
