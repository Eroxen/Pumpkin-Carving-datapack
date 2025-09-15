from pumpkin_carving:pumpkin import CustomPumpkin, CustomPumpkinBlock
from bolt_expressions import Scoreboard, Data
from bolt_expressions.sources import ScoreSource, DataSource
from plugins.generate_models import ModelOrdering
SCORE = Scoreboard("pumpkin_carving.calc")
FSCALE = 1000
NBT = Data.storage("pumpkin_carving:calc")

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

function ~/init:
  setblock ~ ~ ~ crafter{components:CustomPumpkin.components}
  function f"{CustomPumpkinBlock.func_root}/detect_placed/found_block"

function ~/carve:
  function ~/../raycast/init
  execute as @n[type=item_display,tag=pumpkin_carving.custom_pumpkin.display,distance=..0.1]:
    function ~/../raycast/start
    if SCORE[f"#raycast.hit"] == 0:
      execute run return fail
    function ~/../get_macro
    with var NBT.macro:
      $data modify entity @s data.voxels.$(group)[$(i)] set value false
    function pumpkin_carving:pumpkin/voxels_to_model

function ~/fill:
  function ~/../raycast/init
  execute as @n[type=item_display,tag=pumpkin_carving.custom_pumpkin.display,distance=..0.1]:
    function ~/../raycast/start
    if SCORE[f"#raycast.hit"] == 0:
      execute run return fail
    function ~/../raycast/place_onto
    if SCORE[f"#raycast.hit"] == 0:
      execute run return fail
    function ~/../get_macro
    with var NBT.macro:
      $data modify entity @s data.voxels.$(group)[$(i)] set value true
    function pumpkin_carving:pumpkin/voxels_to_model

function ~/get_macro:
  for group in ModelOrdering.main_groups:
    execute if score #raycast.hit_voxel.0 pumpkin_carving.calc matches group.voxel_bounds(0) if score #raycast.hit_voxel.1 pumpkin_carving.calc matches group.voxel_bounds(1) if score #raycast.hit_voxel.2 pumpkin_carving.calc matches group.voxel_bounds(2):
      for i in range(3):
        SCORE[f"#group.voxel.{i}"] = SCORE[f"#raycast.hit_voxel.{i}"] - group.voxel_bounds(i)[0]
      NBT.macro = {"group": group.name, "i": (SCORE["#group.voxel.2"] * (group.size(0)*group.size(1)) + SCORE["#group.voxel.1"] * group.size(0) + SCORE["#group.voxel.0"])}



def exclude(axis):
  for i in range(3):
    if i != axis:
      yield i

function ~/raycast:
  function ~/init:
    NBT.raycast = {}
    execute at @s anchored eyes positioned ^ ^ ^ summon marker:
      rotate @s ~ ~
      NBT.raycast.p1 = Data.entity("@s").Pos
      tp @s ^ ^ ^1
      NBT.raycast.p2 = Data.entity("@s").Pos
      kill @s
  
  function ~/start:
    NBT.raycast.origin = Data.entity("@s").Pos
    NBT.raycast.voxels = Data.entity("@s").data.voxels
    SCORE[f"#raycast.hit"] = 0
    for i in range(3):
      SCORE[f"#raycast.dir_vec.{i}"] = FSCALE * NBT.raycast.p2[i] - FSCALE * NBT.raycast.p1[i]
      SCORE[f"#raycast.origin.{i}"] = FSCALE * NBT.raycast.origin[i]
      SCORE[f"#raycast.ray_start.{i}"] = FSCALE * NBT.raycast.p1[i] - SCORE[f"#raycast.origin.{i}"]
      if SCORE[f"#raycast.dir_vec.{i}"] < 0:
        SCORE[f"#raycast.dir.{i}"] = -1
      else:
        SCORE[f"#raycast.dir.{i}"] = 1
      SCORE[f"#raycast.next_plane.{i}"] = int(FSCALE * -0.5) * SCORE[f"#raycast.dir.{i}"]
      SCORE[f"#raycast.current.{i}"] = SCORE[f"#raycast.ray_start.{i}"]
      for j in exclude(i):
        SCORE[f"#raycast.next_plane.{i}.min.{j}"] = int(FSCALE * -0.5)
        SCORE[f"#raycast.next_plane.{i}.max.{j}"] = int(FSCALE * 0.5)
    debug("dir", SCORE["#raycast.dir.0"], SCORE["#raycast.dir.1"], SCORE["#raycast.dir.2"])
    function ~/../loop
    debug("dist", SCORE["#raycast.next_plane.0.distance"], SCORE["#raycast.next_plane.1.distance"], SCORE["#raycast.next_plane.2.distance"])
  
  function ~/loop:
    function ~/../step
        
    debug("hit plane:", SCORE[f"#raycast.next_plane"])
    debug("hit voxel:", SCORE[f"#raycast.hit_voxel.0"], SCORE[f"#raycast.hit_voxel.1"], SCORE[f"#raycast.hit_voxel.2"])
    debug("next targets:", SCORE[f"#raycast.next_plane.0"], SCORE[f"#raycast.next_plane.1"], SCORE[f"#raycast.next_plane.2"])
    execute if score #raycast.hit_voxel.0 pumpkin_carving.calc matches 2..13 if score #raycast.hit_voxel.1 pumpkin_carving.calc matches 2..13 if score #raycast.hit_voxel.2 pumpkin_carving.calc matches 2..13 run return fail
    if not SCORE[f"#raycast.next_plane"] == -1:
      function ~/../../get_macro
      with var NBT.macro:
        $execute store result score #raycast.voxel_solid pumpkin_carving.calc run data get storage pumpkin_carving:calc raycast.voxels.$(group)[$(i)]
      if SCORE[f"#raycast.voxel_solid"] == 1:
        execute run return run function ~/../hit
      for i in range(3):
        SCORE[f"#raycast.next_plane.{i}"] = (SCORE[f"#raycast.hit_voxel.{i}"] * 2 + SCORE[f"#raycast.dir.{i}"] - 14) / 2 * FSCALE / 16
        execute unless score f"#raycast.next_plane.{i}" pumpkin_carving.calc matches (-FSCALE//2, FSCALE//2) run return fail
      function ~/

  function ~/hit:
    SCORE[f"#raycast.hit"] = 1
  
  function ~/place_onto:
    SCORE[f"#raycast.hit"] = 0
    for i in range(3):
      if SCORE[f"#raycast.next_plane"] == i:
        SCORE[f"#raycast.hit_voxel.{i}"] -= SCORE[f"#raycast.dir.{i}"]
    
    execute if score #raycast.hit_voxel.0 pumpkin_carving.calc matches 0..15 if score #raycast.hit_voxel.1 pumpkin_carving.calc matches 0..15 if score #raycast.hit_voxel.2 pumpkin_carving.calc matches 0..15:
      SCORE[f"#raycast.hit"] = 1
    execute if score #raycast.hit_voxel.0 pumpkin_carving.calc matches 2..13 if score #raycast.hit_voxel.1 pumpkin_carving.calc matches 2..13 if score #raycast.hit_voxel.2 pumpkin_carving.calc matches 2..13:
      SCORE[f"#raycast.hit"] = 0

  function ~/step:
    SCORE[f"#raycast.next_plane"] = -1
    SCORE[f"#raycast.next_plane.distance"] = (2**31-1)
    for i in range(3):
      SCORE[f"#raycast.next_plane.{i}.straight_distance"] = SCORE[f"#raycast.next_plane.{i}"] - SCORE[f"#raycast.current.{i}"]
      if (SCORE[f"#raycast.next_plane.{i}.straight_distance"] * SCORE[f"#raycast.dir.{i}"]) > 0:
        SCORE[f"#raycast.next_plane.{i}.distance"] = ((SCORE[f"#raycast.next_plane.{i}.straight_distance"] * FSCALE) / SCORE[f"#raycast.dir_vec.{i}"])
        if SCORE[f"#raycast.next_plane.{i}.distance"] > 0:
          if SCORE[f"#raycast.next_plane.{i}.distance"] < SCORE[f"#raycast.next_plane.distance"]:
            axes = list(exclude(i))
            for j in axes:
              SCORE[f"#raycast.next_plane.{i}.hit.{j}"] = SCORE[f"#raycast.next_plane.{i}.distance"] * SCORE[f"#raycast.dir_vec.{j}"] / FSCALE + SCORE[f"#raycast.current.{j}"]
            # debug(f"hit plane {i}:", SCORE[f"#raycast.next_plane.{i}.hit.{axes[0]}"], SCORE[f"#raycast.next_plane.{i}.hit.{axes[1]}"])
            if SCORE[f"#raycast.next_plane.{i}.hit.{axes[0]}"] >= SCORE[f"#raycast.next_plane.{i}.min.{axes[0]}"]:
              if SCORE[f"#raycast.next_plane.{i}.hit.{axes[0]}"] <= SCORE[f"#raycast.next_plane.{i}.max.{axes[0]}"]:
                if SCORE[f"#raycast.next_plane.{i}.hit.{axes[1]}"] >= SCORE[f"#raycast.next_plane.{i}.min.{axes[1]}"]:
                  if SCORE[f"#raycast.next_plane.{i}.hit.{axes[1]}"] <= SCORE[f"#raycast.next_plane.{i}.max.{axes[1]}"]:
                    SCORE[f"#raycast.next_plane"] = i
                    SCORE[f"#raycast.next_plane.distance"] = SCORE[f"#raycast.next_plane.{i}.distance"]
    for i in range(3):
      if SCORE[f"#raycast.next_plane"] == i:
        SCORE[f"#raycast.hit_voxel.{i}"] = SCORE[f"#raycast.next_plane.{i}"] + (SCORE[f"#raycast.dir.{i}"] * FSCALE / 32)
        for j in exclude(i):
          SCORE[f"#raycast.hit_voxel.{j}"] = SCORE[f"#raycast.next_plane.{i}.hit.{j}"]
    debug("hit point:", SCORE[f"#raycast.hit_voxel.0"], SCORE[f"#raycast.hit_voxel.1"], SCORE[f"#raycast.hit_voxel.2"])
    for i in range(3):
      SCORE[f"#raycast.hit_voxel.{i}"] *= 16
      SCORE[f"#raycast.hit_voxel.{i}"] /= FSCALE
      SCORE[f"#raycast.hit_voxel.{i}"] += 8