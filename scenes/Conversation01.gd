extends Conversation

var title = "STRANGER"

func dialogue_variables():
  return {
    "title": title
  }

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

export var conversation = [
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
