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

    self.children = None
    size = self.max - self.min
    if np.prod(size) > 2:
      longest_axis = np.argmax(size)
      longest_size = size[longest_axis]
      # split along longest axis
      splits = 2
      if longest_size == 12:
        splits = 3
      split_length = longest_size // splits
      children = []
      for i in range(splits):
        child_min = self.min.copy()
        child_min[longest_axis] = self.min[longest_axis] + i * split_length
        child_max = self.max.copy()
        child_max[longest_axis] = self.min[longest_axis] + (i+1) * split_length
        children.append(VoxelGroup(*child_min, *child_max, f"{self.name}.{i}"))
      self.children = children
  
  @property
  def volume(self):
    return int(np.prod(self.max - self.min))
  
  def _num_descendants(self):
    if self.children is None:
      return 1
    return 1 + sum([c._num_descendants() for c in self.children])
  
  @property
  def num_descendants(self):
    return sum([c._num_descendants() for c in self.children])
  
  def size(self, axis):
    return int(self.max[axis] - self.min[axis])
  
  def voxel_bounds(self, axis):
    return (int(self.min[axis]), int(self.max[axis]-1))
  
  def index_of_voxel(self, x, y, z):
    i = int(self.size(0) * self.size(1) * (z - self.min[2]) + self.size(0) * (y - self.min[1]) + (x - self.min[0]))
    return i
  
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
  
  def _generate_composite_model(self, draft, flag_offset, string_offset, top_group):
    child_models = []
    if self.children is None:
      # children are single voxels
      for x, y, z in self.iterate_voxels():
        child_models.append({
          "type": "minecraft:condition",
          "property": "minecraft:custom_model_data",
          "index": flag_offset + top_group.index_of_voxel(x, y, z),
          "on_true": {
            "type": "minecraft:model",
            "model": generate_voxel_model(draft, x, y, z, x+1, y+1, z+1)
          },
          "on_false": {
            "type": "minecraft:empty"
          }
        })
    else:
      # children are subgroups
      for child in self.children:
        child_model, flag_offset, string_offset = child._generate_composite_model(draft, flag_offset, string_offset, top_group)
        child_models.append(child_model)
    
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
    string_offset += 1
    return main_model, flag_offset, string_offset
  
  def generate_composite_model(self, draft, flag_offset, string_offset):
    child_models = []
    old_string_offset = string_offset
    string_offset += 1
    for child in self.children:
      child_model, flag_offset, string_offset = child._generate_composite_model(draft, flag_offset, string_offset, self)
      child_models.append(child_model)

    main_model = {
      "type": "minecraft:select",
      "property": "minecraft:custom_model_data",
      "index": old_string_offset,
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
    flag_offset += self.volume
    return main_model, flag_offset, string_offset

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
  total_groups = np.sum([g.num_descendants + 1 for g in main_groups])


def beet_default(ctx):
  with ctx.generate.draft() as draft:
    draft.cache("pumpkin_models", "v4")
    print("Generating models")

    draft.assets["pumpkin_carving:item/pumpkin"] = Model({
      "parent": "minecraft:block/block",
      "textures": {
        "0": "minecraft:block/pumpkin_side",
        "1": "minecraft:block/pumpkin_top",
        "2": "pumpkin_carving:block/pumpkin_inside_side",
        "3": "pumpkin_carving:block/pumpkin_inside_top",
        "4": "pumpkin_carving:block/pumpkin_slice"
      },
      "display": {
        "head": {
            "rotation": [ 0, 0, 0 ],
            "translation": [ 0, 0, 0],
            "scale":[ 1.05, 1.05, 1.05 ]
        }
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
    

    