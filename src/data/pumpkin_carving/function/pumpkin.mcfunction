from eroxified2:custom_block import CustomBlock, PlacedBlockBarrier
from eroxified2:custom_item import CustomItem, transformer
from eroxified2:core import run_at_pack_tick
from eroxified2:interaction import call_on_lclick, call_on_rclick
from bolt_expressions import Scoreboard
SCORE = Scoreboard("pumpkin_carving.calc")

HERE = ~/

class CustomPumpkin(CustomItem):
  base_item = "crafter"
  item_name = "Custom Pumpkin"
  item_model = "pumpkin_carving:custom_pumpkin"
  equippable = {
    "camera_overlay": "minecraft:misc/pumpkinblur",
    "slot": "head",
    "swappable": false
  }
  attribute_modifiers = [
    {
      "type": "minecraft:waypoint_transmit_range",
      "amount": -1.0,
      "display": {
        "type": "hidden"
      },
      "id": "minecraft:waypoint_transmit_range_hide",
      "operation": "add_multiplied_total",
      "slot": "head"
    }
  ]
  custom_model_data = {
    "flags": [True] * (16*16*4)
  }

  @transformer('lore', [])
  def add_pack_branding(cls, lore):
    return lore + [{"text":"Pumpkin Carving","color":"#e7a16b"}]

class CustomPumpkinBlock(CustomBlock):
  item = CustomPumpkin
  placed_block = PlacedBlockBarrier
  entity_tags = ["pumpkin_carving.entity","pumpkin_carving.custom_pumpkin","pumpkin_carving.custom_pumpkin.root"]

  def on_placed(cls):
    say @p[tag=eroxified2.custom_block.placer]

    summon item_display ~ ~ ~ {Tags:["pumpkin_carving.entity","pumpkin_carving.custom_pumpkin","pumpkin_carving.custom_pumpkin.display"]}
    loot replace entity @n[type=item_display,tag=pumpkin_carving.custom_pumpkin.display,distance=..0.1] contents loot cls.item.loot_table
    particle flame

  def on_broken(cls):
    particle soul_fire_flame
    kill @e[type=item_display,tag=pumpkin_carving.custom_pumpkin.display,distance=..0.1]
    loot spawn ~ ~ ~ loot cls.item.loot_table

def lenient_tag(items):
  values = []
  for item in items:
    values.append({
      "id": item,
      "required": false
    })
  return {"values":values}
def tools(pattern):
  items = []
  for material in ["wooden", "stone", "copper", "iron", "golden", "diamond", "netherite"]:
    items.append(pattern.replace("%", material))
  return items

item_tag ~/interactable_break lenient_tag(tools("minecraft:%_axe"))
predicate ~/interactable_break {
  "condition": "minecraft:entity_properties",
  "entity": "this",
  "predicate": {
    "equipment": {
      "mainhand": {
        "items": f"#{~/interactable_break}"
      }
    }
  }
}
item_tag ~/interactable_carve_new lenient_tag(tools("minecraft:%_sword"))
predicate ~/interactable_carve_new {
  "condition": "minecraft:entity_properties",
  "entity": "this",
  "predicate": {
    "equipment": {
      "mainhand": {
        "items": f"#{~/interactable_carve_new}"
      }
    }
  }
}
item_tag ~/interactable_carve lenient_tag([f"#{~/interactable_carve_new}"] + tools("minecraft:%_axe"))
predicate ~/interactable_carve {
  "condition": "minecraft:entity_properties",
  "entity": "this",
  "predicate": {
    "equipment": {
      "mainhand": {
        "items": f"#{~/interactable_carve}"
      }
    }
  }
}
item_tag ~/interactable_fill lenient_tag(["minecraft:pumpkin_seeds"])
predicate ~/interactable_fill {
  "condition": "minecraft:entity_properties",
  "entity": "this",
  "predicate": {
    "equipment": {
      "mainhand": {
        "items": f"#{~/interactable_fill}"
      }
    }
  }
}
item_tag ~/interactable lenient_tag([f"#{~/interactable_break}", f"#{~/interactable_carve}", f"#{~/interactable_fill}"])
predicate ~/interactable {
  "condition": "minecraft:entity_properties",
  "entity": "this",
  "predicate": {
    "equipment": {
      "mainhand": {
        "items": f"#{~/interactable}"
      }
    }
  }
}
predicate ~/interactable_carve_or_fill {
  "condition": "minecraft:any_of",
  "terms": [
    {
      "condition": "minecraft:reference",
      "name": (~/interactable_carve)
    },
    {
      "condition": "minecraft:reference",
      "name": (~/interactable_fill)
    }
  ]
}

block_tag ~/raycast_stop lenient_tag(["minecraft:pumpkin", "minecraft:barrier"])
raycaststop = f"#{~/raycast_stop}"

function ~/tick:
  run_at_pack_tick()
  execute as @a[predicate=(~/../interactable)] at @s anchored eyes positioned ^ ^ ^0.5 run function ~/raycast:
    SCORE["#raycast"] = 20
    execute run function ~/loop:
      execute if block ~ ~ ~ raycaststop align xyz positioned ~0.5 ~0.5 ~0.5 run return run function ~/../hit
      SCORE["#raycast"] -= 1
      if SCORE["#raycast"] > 0:
        execute positioned ^ ^ ^0.25 run function ~/
    function ~/hit:
      execute if block ~ ~ ~ minecraft:barrier unless entity @e[type=marker,tag=pumpkin_carving.custom_pumpkin.root,distance=..0.1,limit=1] run return fail
      execute if block ~ ~ ~ minecraft:pumpkin unless predicate f"{HERE}/interactable_carve_new" run return fail
      execute align y positioned ~ ~-0.005 ~:
        execute as @n[type=interaction,tag=pumpkin_carving.carving_hitbox,distance=..0.1] run return:
          SCORE["@s"] = 20
        summon interaction ~ ~ ~ {Tags:["pumpkin_carving.entity","pumpkin_carving.carving_hitbox","eroxified2.interaction"],width:1.01,height:1.01,response:true}
        SCORE["@n[type=interaction,tag=pumpkin_carving.carving_hitbox,distance=..0.1]"] = 20
        if SCORE["#hitbox.ticking"] != 1:
          function f"{HERE}/hitbox/start_ticking"

function ~/hitbox:
  function ~/start_ticking:
    SCORE["#hitbox.ticking"] = 1
    function ~/../tick
  
  function ~/lclick:
    call_on_lclick()
    execute if entity @s[tag=pumpkin_carving.carving_hitbox] on attacker if predicate f"{HERE}/interactable_break":
      kill @n[type=interaction,tag=pumpkin_carving.carving_hitbox,distance=..0.1]
      setblock ~ ~1 ~ air destroy
  
  function ~/rclick:
    call_on_rclick()
    execute if entity @s[tag=pumpkin_carving.carving_hitbox] on target if predicate f"{HERE}/interactable_carve_or_fill":
      SCORE["@n[type=interaction,tag=pumpkin_carving.carving_hitbox,distance=..0.1]"] = 20
      execute align y positioned ~ ~1.5 ~:
        execute if block ~ ~ ~ minecraft:pumpkin run function pumpkin_carving:carve/init
        execute if predicate f"{HERE}/interactable_carve" run function pumpkin_carving:carve/carve
        execute if predicate f"{HERE}/interactable_fill" run function pumpkin_carving:carve/fill

  function ~/tick:
    SCORE["#temp"] = 0
    execute as @e[type=interaction,tag=pumpkin_carving.carving_hitbox] at @s:
      SCORE["@s"] -= 1
      if SCORE["@s"] < 0:
        kill @s
      SCORE["#temp"] = 1
    if SCORE["#temp"] == 0:
      SCORE["#hitbox.ticking"] = 0
    if SCORE["#hitbox.ticking"] == 1:
      schedule function ~/ 1t replace