from beet import Model, ItemModel
import numpy as np

def voxel_model(xmin, ymin, zmin, xmax, ymax, zmax):
  def side_texture(depth, side1, side2):
    if depth == 0:
      return "#0"
    if depth == 14 and side1[0] >= 2 and side1[1] <= 14 and side2[0] >= 2 and side2[1] <= 14:
      return "#2"
    return "#4"
  def top_texture(depth, side1, side2):
    if depth == 0:
      return "#1"
    if depth == 14 and side1[0] >= 2 and side1[1] <= 14 and side2[0] >= 2 and side2[1] <= 14:
      return "#3"
    return "#4"
  model = {
    "parent": "pumpkin_carving:item/pumpkin",
    "elements": [
      {
        "from": [xmin, ymin, zmin],
        "to": [xmax,ymax,zmax],
        "faces": {
          "north": {"uv": [16-xmax,16-ymax,16-xmin,16-ymin], "texture": side_texture(zmin, (xmin, xmax), (ymin, ymax))},
          "east": {"uv": [16-zmax,16-ymax,16-zmin,16-ymin], "texture": side_texture(16-xmax, (ymin, ymax), (zmin, zmax))},
          "south": {"uv": [xmin,16-ymax,xmax,16-ymin], "texture": side_texture(16-zmax, (xmin, xmax), (ymin, ymax))},
          "west": {"uv": [zmin,16-ymax,zmax,16-ymin], "texture": side_texture(xmin, (ymin, ymax), (zmin, zmax))},
          "up": {"uv": [xmin,zmin,xmax,zmax], "texture": top_texture(16-ymax, (xmin, xmax), (zmin, zmax))},
          "down": {"uv": [xmin,16-zmax,xmax,16-zmin], "texture": top_texture(ymin, (xmin, xmax), (zmin, zmax))}
        }
      }
    ]
  }
  return model

def generate_voxel_model(draft, xmin, ymin, zmin, xmax, ymax, zmax):
  path = f"pumpkin_carving:item/pumpkin/{xmin}_{ymin}_{zmin}_{xmax}_{ymax}_{zmax}"
  draft.assets[path] = Model(voxel_model(xmin, ymin, zmin, xmax, ymax, zmax))
  return path

class VoxelGroup:
  def __init__(self, xmin, ymin, zmin, xmax, ymax, zmax, name):
    self.min = np.array([xmin, ymin, zmin])
    self.max = np.array([xmax, ymax, zmax])
    self.name = name
  
  @property
  def volume(self):
    return np.prod(self.max - self.min)
  
  def size(self, axis):
    return int(self.max[axis] - self.min[axis])
  
  def voxel_bounds(self, axis):
    return (int(self.min[axis]), int(self.max[axis]-1))
  
  @property
  def bounds(self):
    b = []
    for side in "min", "max":
      for i in range(3):
        b.append(int(getattr(self, side)[i]))
    return b

  def iterate_voxels(self):
    for z in np.arange(self.min[2], self.max[2]):
      for y in np.arange(self.min[1], self.max[1]):
        for x in np.arange(self.min[0], self.max[0]):
          yield int(x), int(y), int(z)
  
  def generate_composite_model(self, draft, flag_offset, string_offset):
    flags = 0
    strings = 1

    child_models = []
    for x, y, z in self.iterate_voxels():
      child_models.append({
        "type": "minecraft:condition",
        "property": "minecraft:custom_model_data",
        "index": flags + flag_offset,
        "on_true": {
          "type": "minecraft:model",
          "model": generate_voxel_model(draft, x, y, z, x+1, y+1, z+1)
        },
        "on_false": {
          "type": "minecraft:empty"
        }
      })
      flags += 1

    main_model = {
      "type": "minecraft:select",
      "property": "minecraft:custom_model_data",
      "index": string_offset,
      "cases": [
        {
          "when": "full",
          "model": {
            "type": "minecraft:model",
            "model": generate_voxel_model(draft, *self.bounds)
          }
        },
        {
          "when": "mixed",
          "model": {
            "type": "minecraft:composite",
            "models": child_models
          }
        }
      ],
      "fallback": {
        "type": "minecraft:empty"
      }
    }
    return main_model, flag_offset+flags, string_offset+strings

def generate_main_groups():
  bounds = [(0,2),(2,14),(14,16)]
  for z in range(3):
    for y in range(3):
      for x in range(3):
        if not (x == 1 and y == 1 and z == 1):
          name = f"{x}{y}{z}"
          xbounds = bounds[x]
          ybounds = bounds[y]
          zbounds = bounds[z]
          yield VoxelGroup(xbounds[0], ybounds[0], zbounds[0], xbounds[1], ybounds[1], zbounds[1], name)

class ModelOrdering:
  main_groups = list(generate_main_groups())
  total_volume = np.sum([g.volume for g in main_groups])




def beet_default(ctx):
  with ctx.generate.draft() as draft:
    # draft.cache("pumpkin_models", "v1")
    print("Generating!")

    draft.assets["pumpkin_carving:item/pumpkin"] = Model({
      "parent": "minecraft:block/block",
      "textures": {
        "0": "minecraft:block/pumpkin_side",
        "1": "minecraft:block/pumpkin_top",
        "2": "pumpkin_carving:block/pumpkin_inside_side",
        "3": "pumpkin_carving:block/pumpkin_inside_top",
        "4": "pumpkin_carving:block/pumpkin_slice"
      }
    })

    composite_models = []
    flag_offset = 0
    string_offset = 0
    for group in ModelOrdering.main_groups:
      model, flag_offset, string_offset = group.generate_composite_model(draft, flag_offset, string_offset)
      composite_models.append(model)
    draft.assets["pumpkin_carving:custom_pumpkin"] = ItemModel({
      "model": {
        "type": "minecraft:composite",
        "models": composite_models
      }
    })
    

    