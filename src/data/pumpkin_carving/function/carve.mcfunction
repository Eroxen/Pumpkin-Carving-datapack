from pumpkin_carving:pumpkin import CustomPumpkin, CustomPumpkinBlock
from bolt_expressions import Scoreboard, Data
from bolt_expressions.sources import ScoreSource, DataSource
from plugins.generate_models import ModelOrdering
import eroxified2:item as e2_item
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
        message.append(str(arg))
    tellraw @a message

function ~/init:
  function ~/../raycast/init
  function ~/../raycast/get_first_hit_plane
  setblock ~ ~ ~ crafter{components:CustomPumpkin.components}
  if SCORE["#raycast.next_plane"] == 0:
    if SCORE["#raycast.dir.0"] == 1:
      setblock ~ ~ ~ crafter[orientation=west_up]
  if SCORE["#raycast.next_plane"] == 0:
    if SCORE["#raycast.dir.0"] == -1:
      setblock ~ ~ ~ crafter[orientation=east_up]
  if SCORE["#raycast.next_plane"] == 2:
    if SCORE["#raycast.dir.2"] == 1:
      setblock ~ ~ ~ crafter[orientation=north_up]
  if SCORE["#raycast.next_plane"] == 2:
    if SCORE["#raycast.dir.2"] == -1:
      setblock ~ ~ ~ crafter[orientation=south_up]
  if SCORE["#raycast.next_plane"] == 1:
    execute if entity @s[y_rotation=45..135] run setblock ~ ~ ~ crafter[orientation=east_up]
    execute if entity @s[y_rotation=135..225] run setblock ~ ~ ~ crafter[orientation=south_up]
    execute if entity @s[y_rotation=225..315] run setblock ~ ~ ~ crafter[orientation=west_up]
    execute if entity @s[y_rotation=-45..45] run setblock ~ ~ ~ crafter[orientation=north_up]

  function f"{CustomPumpkinBlock.func_root}/detect_placed/found_block"

  Scoreboard("pumpkin_carving.stats.pumpkins_carved")["@s"] += 1

function ~/paste:
  NBT.temp = Data.entity("@s").equipment.offhand.components."minecraft:custom_data".voxels
  execute as @n[type=item_display,tag=pumpkin_carving.custom_pumpkin.display,distance=..0.1]:
    Data.entity("@s").data.voxels = NBT.temp
    function pumpkin_carving:pumpkin/voxels_to_model
  playsound minecraft:block.pumpkin.carve block @a[distance=..8]

function ~/carved_success:
  Scoreboard("pumpkin_carving.stats.voxels_carved")["@s"] += SCORE[f"#voxels_changed"]
  playsound minecraft:block.pumpkin.carve block @a[distance=..8]

function ~/filled_success:
  Scoreboard("pumpkin_carving.stats.voxels_filled")["@s"] += SCORE[f"#voxels_changed"]
  playsound minecraft:block.mud.place block @a[distance=..8]
  execute if predicate pumpkin_carving:survival_or_adventure run function eroxified2:item/api/decrement_mainhand

function ~/carve:
  SCORE["#voxels_changed"] = 0
  function ~/../raycast/init
  execute as @n[type=item_display,tag=pumpkin_carving.custom_pumpkin.display,distance=..0.1]:
    function ~/../raycast/start
    if SCORE[f"#raycast.hit"] == 0:
      execute run return fail
    function ~/../get_macro
    with var NBT.macro:
      $execute store success score #temp pumpkin_carving.calc run data modify entity @s data.voxels.$(group)[$(i)] set value false
    SCORE["#voxels_changed"] += SCORE["#temp"]
    function pumpkin_carving:pumpkin/voxels_to_model
  if SCORE["#voxels_changed"] > 0:
    function ~/../carved_success

function ~/carve_big:
  SCORE[f"#voxels_changed"] = 0
  function ~/../raycast/init
  execute as @n[type=item_display,tag=pumpkin_carving.custom_pumpkin.display,distance=..0.1]:
    function ~/../raycast/start
    if SCORE[f"#raycast.hit"] == 0:
      execute run return fail
    function ~/../raycast/align_big
    for dx in range(2):
      SCORE[f"#raycast.hit_voxel.0"] = SCORE[f"#raycast.hit_voxel_ref.0"] + dx
      for dy in range(2):
        SCORE[f"#raycast.hit_voxel.1"] = SCORE[f"#raycast.hit_voxel_ref.1"] + dy
        for dz in range(2):
          SCORE[f"#raycast.hit_voxel.2"] = SCORE[f"#raycast.hit_voxel_ref.2"] + dz
          execute if score #raycast.hit_voxel.0 pumpkin_carving.calc matches 0..15 if score #raycast.hit_voxel.1 pumpkin_carving.calc matches 0..15 if score #raycast.hit_voxel.2 pumpkin_carving.calc matches 0..15:
            function ~/carve_voxel
    function pumpkin_carving:pumpkin/voxels_to_model
  function ~/carve_voxel:
    execute if score #raycast.hit_voxel.0 pumpkin_carving.calc matches 2..13 if score #raycast.hit_voxel.1 pumpkin_carving.calc matches 2..13 if score #raycast.hit_voxel.2 pumpkin_carving.calc matches 2..13 run return fail
    function ~/../../get_macro
    with var NBT.macro:
      $execute store success score #temp pumpkin_carving.calc run data modify entity @s data.voxels.$(group)[$(i)] set value false
    SCORE[f"#voxels_changed"] += SCORE[f"#temp"]
  if SCORE["#voxels_changed"] > 0:
    function ~/../carved_success

function ~/fill:
  SCORE[f"#voxels_changed"] = 0
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
      $execute store success score #temp pumpkin_carving.calc run data modify entity @s data.voxels.$(group)[$(i)] set value true
    SCORE[f"#voxels_changed"] += SCORE[f"#temp"]
    function pumpkin_carving:pumpkin/voxels_to_model
    execute unless data storage pumpkin_carving:calc temp{flags:[0b]} run return:
      # all pixels were filled
      kill @s
      execute align xyz positioned ~0.5 ~0.5 ~0.5 run kill @e[type=marker,tag=pumpkin_carving.custom_pumpkin.root,distance=..0.1]
      setblock ~ ~ ~ pumpkin
  if SCORE["#voxels_changed"] > 0:
    function ~/../filled_success

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
  
  function ~/get_first_hit_plane:
    execute summon marker:
      NBT.raycast.origin = Data.entity("@s").Pos
      kill @s
    for i in range(3):
      SCORE[f"#raycast.dir_vec.{i}"] = (FSCALE * NBT.raycast.p2[i] - FSCALE * NBT.raycast.p1[i])
      SCORE[f"#raycast.ray_start.{i}"] = (FSCALE * NBT.raycast.p1[i] - FSCALE * NBT.raycast.origin[i])
      if SCORE[f"#raycast.dir_vec.{i}"] < 0:
        SCORE[f"#raycast.dir.{i}"] = -1
      else:
        SCORE[f"#raycast.dir.{i}"] = 1
      SCORE[f"#raycast.next_plane.{i}"] = int(FSCALE * -0.5) * SCORE[f"#raycast.dir.{i}"]
      SCORE[f"#raycast.current.{i}"] = SCORE[f"#raycast.ray_start.{i}"]
      for j in exclude(i):
        SCORE[f"#raycast.next_plane.{i}.min.{j}"] = int(FSCALE * -0.5)
        SCORE[f"#raycast.next_plane.{i}.max.{j}"] = int(FSCALE * 0.5)
    function ~/../step
    
  
  function ~/start:
    NBT.raycast.origin = Data.entity("@s").Pos
    NBT.raycast.voxels = Data.entity("@s").data.voxels
    SCORE[f"#raycast.hit"] = 0
    for i in range(3):
      SCORE[f"#raycast._dir_vec.{i}"] = (FSCALE * NBT.raycast.p2[i] - FSCALE * NBT.raycast.p1[i])
      SCORE[f"#raycast._ray_start.{i}"] = (FSCALE * NBT.raycast.p1[i] - FSCALE * NBT.raycast.origin[i])
    
    SCORE["#raycast.y_rot"] = (Data.entity("@s").Rotation[0] / 90) % 4
    SCORE["#raycast.x_rot"] = Data.entity("@s").Rotation[1] / 90
    def set_transform(nx, ny, nz):
      if nx < 0:
        SCORE["#raycast.dir_vec.0"] = SCORE[f"#raycast._dir_vec.{(-nx-1)}"] * -1
        SCORE["#raycast.ray_start.0"] = SCORE[f"#raycast._ray_start.{(-nx-1)}"] * -1
      else:
        SCORE["#raycast.dir_vec.0"] = SCORE[f"#raycast._dir_vec.{nx-1}"]
        SCORE["#raycast.ray_start.0"] = SCORE[f"#raycast._ray_start.{nx-1}"]
      if ny < 0:
        SCORE["#raycast.dir_vec.1"] = SCORE[f"#raycast._dir_vec.{(-ny-1)}"] * -1
        SCORE["#raycast.ray_start.1"] = SCORE[f"#raycast._ray_start.{(-ny-1)}"] * -1
      else:
        SCORE["#raycast.dir_vec.1"] = SCORE[f"#raycast._dir_vec.{ny-1}"]
        SCORE["#raycast.ray_start.1"] = SCORE[f"#raycast._ray_start.{ny-1}"]
      if nz < 0:
        SCORE["#raycast.dir_vec.2"] = SCORE[f"#raycast._dir_vec.{(-nz-1)}"] * -1
        SCORE["#raycast.ray_start.2"] = SCORE[f"#raycast._ray_start.{(-nz-1)}"] * -1
      else:
        SCORE["#raycast.dir_vec.2"] = SCORE[f"#raycast._dir_vec.{nz-1}"]
        SCORE["#raycast.ray_start.2"] = SCORE[f"#raycast._ray_start.{nz-1}"]

    if SCORE["#raycast.y_rot"] == 0:
      if SCORE["#raycast.x_rot"] == 0:
        set_transform(-1, 2, -3)
    if SCORE["#raycast.y_rot"] == 1:
      if SCORE["#raycast.x_rot"] == 0:
        set_transform(-3, 2, 1)
    if SCORE["#raycast.y_rot"] == 2:
      if SCORE["#raycast.x_rot"] == 0:
        set_transform(1, 2, 3)
    if SCORE["#raycast.y_rot"] == 3:
      if SCORE["#raycast.x_rot"] == 0:
        set_transform(3, 2, -1)
    
    if SCORE["#raycast.y_rot"] == 0:
      if SCORE["#raycast.x_rot"] == -1:
        set_transform(-1, -3, -2)
    if SCORE["#raycast.y_rot"] == 1:
      if SCORE["#raycast.x_rot"] == -1:
        set_transform(-3, 1, -2)
    if SCORE["#raycast.y_rot"] == 2:
      if SCORE["#raycast.x_rot"] == -1:
        set_transform(1, 3, -2)
    if SCORE["#raycast.y_rot"] == 3:
      if SCORE["#raycast.x_rot"] == -1:
        set_transform(3, -1, -2)
    
    if SCORE["#raycast.y_rot"] == 0:
      if SCORE["#raycast.x_rot"] == 1:
        set_transform(-1, 3, 2)
    if SCORE["#raycast.y_rot"] == 1:
      if SCORE["#raycast.x_rot"] == 1:
        set_transform(-3, -1, 2)
    if SCORE["#raycast.y_rot"] == 2:
      if SCORE["#raycast.x_rot"] == 1:
        set_transform(1, -3, 2)
    if SCORE["#raycast.y_rot"] == 3:
      if SCORE["#raycast.x_rot"] == 1:
        set_transform(3, 1, 2)



    for i in range(3):
      if SCORE[f"#raycast.dir_vec.{i}"] < 0:
        SCORE[f"#raycast.dir.{i}"] = -1
      else:
        SCORE[f"#raycast.dir.{i}"] = 1
      SCORE[f"#raycast.next_plane.{i}"] = int(FSCALE * -0.5) * SCORE[f"#raycast.dir.{i}"]
      SCORE[f"#raycast.current.{i}"] = SCORE[f"#raycast.ray_start.{i}"]
      for j in exclude(i):
        SCORE[f"#raycast.next_plane.{i}.min.{j}"] = int(FSCALE * -0.5)
        SCORE[f"#raycast.next_plane.{i}.max.{j}"] = int(FSCALE * 0.5)
    function ~/../loop
    
  function ~/loop:
    function ~/../step
        
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
  
  function ~/align_big:
    for i in range(3):
      if SCORE[f"#raycast.next_plane"] == i:
        SCORE[f"#raycast.hit_voxel.{i}"] = SCORE[f"#raycast.next_plane.{i}"]
        for j in exclude(i):
          SCORE[f"#raycast.hit_voxel.{j}"] = SCORE[f"#raycast.next_plane.{i}.hit.{j}"]
    for i in range(3):
      SCORE[f"#raycast.hit_voxel.{i}"] -= (FSCALE//32)
      SCORE[f"#raycast.hit_voxel.{i}"] *= 16
      SCORE[f"#raycast.hit_voxel.{i}"] /= FSCALE
      SCORE[f"#raycast.hit_voxel.{i}"] += 8
      SCORE[f"#raycast.hit_voxel_ref.{i}"] = SCORE[f"#raycast.hit_voxel.{i}"]

  
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
    for i in range(3):
      SCORE[f"#raycast.hit_voxel.{i}"] *= 16
      SCORE[f"#raycast.hit_voxel.{i}"] /= FSCALE
      SCORE[f"#raycast.hit_voxel.{i}"] += 8