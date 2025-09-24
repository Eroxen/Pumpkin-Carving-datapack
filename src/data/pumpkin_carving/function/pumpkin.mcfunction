from eroxified2:custom_block import CustomBlock, PlacedBlockBarrier
from eroxified2:custom_item import CustomItem, transformer
from eroxified2:core import run_at_pack_tick
from eroxified2:interaction import call_on_lclick, call_on_rclick
from bolt_expressions import Scoreboard, Data
from plugins.generate_models import ModelOrdering
from bolt_expressions.sources import ScoreSource, DataSource
SCORE = Scoreboard("pumpkin_carving.calc")
NBT = Data.storage("pumpkin_carving:calc")

HERE = ~/

DEBUG = True
def debug(*args, color="yellow"):
  if DEBUG:
    message = [{"text":"[Debug]","color":color}]
    for arg in args:
      message.append(" ")
      if isinstance(arg, ScoreSource):
        message.append({"score":{"name":arg.holder,"objective":arg.objective}})
      elif isinstance(arg, DataSource):
        message.append(arg.component())
      else:
        message.append(arg)
    tellraw @a message

default_voxel_ds = {}
for group in ModelOrdering.main_groups:
  default_voxel_ds[group.name] = [True] * group.volume

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
    "flags": [True] * ModelOrdering.total_volume,
    "strings": ["full"] * ModelOrdering.total_groups
  }
  custom_data = {
    "voxels": default_voxel_ds
  }

  @transformer('lore', [])
  def add_pack_branding(cls, lore):
    return lore + [{"text":"Pumpkin Carving","color":"#e7a16b"}]

class CustomPumpkinBlock(CustomBlock):
  item = CustomPumpkin
  placed_block = PlacedBlockBarrier
  entity_tags = ["pumpkin_carving.entity","pumpkin_carving.custom_pumpkin","pumpkin_carving.custom_pumpkin.root"]

  def on_placed(cls):
    NBT.macro = {x_rot: Scoreboard("eroxified2.api")["custom_block.x_rotation"], y_rot: Scoreboard("eroxified2.api")["custom_block.y_rotation"]}
    with var NBT.macro:
      $summon item_display ~ ~ ~ {Rotation:[$(y_rot)f,$(x_rot)f],Tags:["pumpkin_carving.entity","pumpkin_carving.custom_pumpkin","pumpkin_carving.custom_pumpkin.display"],width:1f,height:1f}
    execute as @n[type=item_display,tag=pumpkin_carving.custom_pumpkin.display,distance=..0.1]:
      loot replace entity @s contents loot cls.item.loot_table
      data modify entity @s data.voxels set from storage eroxified2:api custom_block.placed.components."minecraft:custom_data".voxels
      function f"{HERE}/voxels_to_model"

  def on_broken(cls):
    playsound minecraft:block.wood.break block @a[distance=..16] ~ ~ ~ 1 0.8
    particle minecraft:block{block_state:{Name:"minecraft:pumpkin"}} ~ ~ ~ 0.3 0.3 0.3 0 16
    execute as @n[type=item_display,tag=pumpkin_carving.custom_pumpkin.display,distance=..0.1]:
      loot replace entity @s contents loot cls.item.loot_table
      function f"{HERE}/voxels_to_model"
      Data.entity("@s").item.components."minecraft:custom_data".voxels = Data.entity("@s").data.voxels
      with entity @s item:
        $loot spawn ~ ~ ~ loot {pools:[{rolls:1,entries:[{type:"minecraft:item",name:"$(id)",functions:[{function:"minecraft:set_components",components:$(components)}]}]}]}
      kill @s


def traverse_tree(group, top_group, level):
  if group.children is None:
    j = 0
    for x, y, z in group.iterate_voxels():
      # this should always be just 2 voxels
      i = top_group.index_of_voxel(x, y, z)
      execute store result score f"#temp.{j}" pumpkin_carving.calc run data get storage pumpkin_carving:calc f"temp.group_voxels[{i}]"
      j += 1
    SCORE["#temp.0"] += SCORE["#temp.1"]
    if SCORE["#temp.0"] == 0:
      NBT.temp.stack[-1].foo.bar.append("empty")
    if SCORE["#temp.0"] == 1:
      NBT.temp.stack[-1].foo.bar.append("mixed")
    if SCORE["#temp.0"] == 2:
      NBT.temp.stack[-1].foo.bar.append("full")
    NBT.temp.tree.append(NBT.temp.stack[-1].foo.bar[-1])
  else:
    NBT.temp.stack.append({"foo":{"bar":[]}})
    for child in group.children:
      traverse_tree(child, top_group, level+1)
    if not level == 0:
      execute if data storage pumpkin_carving:calc temp.stack[-1].foo{bar:["full"]} unless data storage pumpkin_carving:calc temp.stack[-1].foo{bar:["empty"]} unless data storage pumpkin_carving:calc temp.stack[-1].foo{bar:["mixed"]}:
        NBT.temp.stack[-2].foo.bar.append("full")
      execute if data storage pumpkin_carving:calc temp.stack[-1].foo{bar:["empty"]} unless data storage pumpkin_carving:calc temp.stack[-1].foo{bar:["full"]} unless data storage pumpkin_carving:calc temp.stack[-1].foo{bar:["mixed"]}:
        NBT.temp.stack[-2].foo.bar.append("empty")
      execute if data storage pumpkin_carving:calc temp.stack[-1].foo{bar:["full","empty"]} unless data storage pumpkin_carving:calc temp.stack[-1].foo{bar:["mixed"]}:
        NBT.temp.stack[-2].foo.bar.append("mixed")
      execute if data storage pumpkin_carving:calc temp.stack[-1].foo{bar:["mixed"]}:
        NBT.temp.stack[-2].foo.bar.append("mixed")
      NBT.temp.tree.append(NBT.temp.stack[-2].foo.bar[-1])
      data remove var NBT.temp.stack[-1]

function ~/voxels_to_model:
  memo_key = "voxels_to_model_shapes_4"
  memo memo_key:
    print("Generating model trees")
    seen_shapes = set()
    for group in ModelOrdering.main_groups:
      group_shape = f"{group.size(0)}_{group.size(1)}_{group.size(2)}"
      if group_shape not in seen_shapes:
        seen_shapes.add(group_shape)
        function f"{~/}/shape_{group_shape}":
          NBT.temp.tree = []
          NBT.temp.stack = [{"foo":{"bar":[]}}]
          traverse_tree(group, group, 0)

  NBT.temp = {flags:[],strings:[]}
  NBT.temp.voxels = Data.entity("@s").data.voxels
  for group in ModelOrdering.main_groups:
    NBT.temp.flags.append(NBT.temp.voxels[group.name][])
    NBT.temp.fill_level = "full"
    execute if data storage pumpkin_carving:calc f"temp.voxels{{{group.name}:[0b]}}":
      NBT.temp.fill_level = "empty"
      execute if data storage pumpkin_carving:calc f"temp.voxels{{{group.name}:[1b]}}":
        NBT.temp.fill_level = "mixed"
    NBT.temp.strings.append(NBT.temp.fill_level)
    if NBT.temp.fill_level == "full":
      NBT.temp.tree = ["full"] * group.num_descendants
    if NBT.temp.fill_level == "empty":
      NBT.temp.tree = ["empty"] * group.num_descendants
    if NBT.temp.fill_level == "mixed":
      NBT.temp.group_voxels = NBT.temp.voxels[group.name]
      group_shape = f"{group.size(0)}_{group.size(1)}_{group.size(2)}"
      function f"{~/}/shape_{group_shape}"
    NBT.temp.strings.append(NBT.temp.tree[])
  execute unless data storage pumpkin_carving:calc temp{flags:[1b]} run return:
    # all pixels were carved away
    execute align y positioned ~ ~-0.005 ~ as @n[type=interaction,tag=pumpkin_carving.carving_hitbox,distance=..0.1] on target:
      advancement grant @s only pumpkin_carving:gone_reduced_to_atoms
    kill @s
    execute align xyz positioned ~0.5 ~0.5 ~0.5 run kill @e[type=marker,tag=pumpkin_carving.custom_pumpkin.root,distance=..0.1]
    setblock ~ ~ ~ air
    particle poof ~ ~ ~ 0.2 0.2 0.2 0 5
    loot spawn ~ ~ ~ loot pumpkin_carving:item/pumpkinos
  Data.entity("@s").item.components."minecraft:custom_model_data".flags = NBT.temp.flags
  Data.entity("@s").item.components."minecraft:custom_model_data".strings = NBT.temp.strings
  



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
item_tag ~/interactable_carve_big lenient_tag(tools("minecraft:%_axe"))
predicate ~/interactable_carve_big {
  "condition": "minecraft:entity_properties",
  "entity": "this",
  "predicate": {
    "equipment": {
      "mainhand": {
        "items": f"#{~/interactable_carve_big}"
      }
    }
  }
}
item_tag ~/interactable_carve lenient_tag([f"#{~/interactable_carve_new}", f"#{~/interactable_carve_big}"])
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
    SCORE["#raycast"] = 40
    execute run function ~/loop:
      execute if block ~ ~ ~ raycaststop align xyz positioned ~0.5 ~0.5 ~0.5 run return run function ~/../hit
      SCORE["#raycast"] -= 1
      if SCORE["#raycast"] > 0:
        execute positioned ^ ^ ^0.1 run function ~/
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
        execute if predicate f"{HERE}/interactable_carve_new" if block ~ ~ ~ minecraft:pumpkin if items entity @s weapon.offhand CustomPumpkin.predicate run return:
          function pumpkin_carving:carve/init
          function pumpkin_carving:carve/paste
        execute if block ~ ~ ~ minecraft:pumpkin run function pumpkin_carving:carve/init
        execute if predicate f"{HERE}/interactable_carve":
          execute if predicate f"{HERE}/interactable_carve_big" run return run function pumpkin_carving:carve/carve_big
          function pumpkin_carving:carve/carve
        execute if predicate f"{HERE}/interactable_fill" run function pumpkin_carving:carve/fill

  function ~/tick:
    SCORE["#temp"] = 0
    execute as @e[type=interaction,tag=pumpkin_carving.carving_hitbox] at @s:
      execute unless entity @a[predicate=(~/../../interactable),distance=..8,limit=1] run return run kill @s
      SCORE["@s"] -= 1
      if SCORE["@s"] < 0:
        kill @s
      SCORE["#temp"] = 1
    if SCORE["#temp"] == 0:
      SCORE["#hitbox.ticking"] = 0
    if SCORE["#hitbox.ticking"] == 1:
      schedule function ~/ 1t replace