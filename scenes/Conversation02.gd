extends Conversation

export var npc_path: NodePath
var npc: AnimatedSprite

export var characters = {
  "jules": {
    "name": "JULES",
    "portrait": preload("res://images/Pixel Portraits/male_06_t.png")
  }
}

export var conversation = [
  {
    "character": "jules",
    "dialogue": "Hey, I'm Jules. What should I do?",
    "choices": [
      {
        "dialogue": "TURN LEFT!",
        "call": ["turn_left"]
      },
      {
        "dialogue": "TURN RIGHT!",
        "call": ["turn_right"]
      }
    ]
  },
  {
    "character": "jules",
    "dialogue": "Turning is fun!"
  },
]

func _ready():
  npc = get_node(npc_path)

func turn_left():
  npc.flip_h = true
  
func turn_right():
  npc.flip_h = false
