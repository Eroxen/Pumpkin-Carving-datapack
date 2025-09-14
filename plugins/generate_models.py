from beet import Model, ItemModel

def voxel_model(x, y, z):
  model = {
    "parent": "pumpkin_carving:item/pumpkin",
    "elements": [
      {
        "from": [x, y, z],
        "to": [x+1,y+1,z+1],
        "faces": {
          "north": {"uv": [15-x,15-y,16-x,16-y], "texture": "#0"},
          "east": {"uv": [15-z,15-y,16-z,16-y], "texture": "#0"},
          "south": {"uv": [x,15-y,x+1,16-y], "texture": "#0"},
          "west": {"uv": [z,15-y,z+1,16-y], "texture": "#0"},
          "up": {"uv": [x,z,x+1,z+1], "texture": "#0"},
          "down": {"uv": [x,15-z,x+1,16-z], "texture": "#0"}
        }
      }
    ]
  }
  return model

def face_models(face):
  for x in range(0,16):
    for y in range(0,16):
      for z in range(0,4):
        yield f"{x}_{y}_{z}", voxel_model(x, y, z)

def beet_default(ctx):
  root = "pumpkin_carving:item/pumpkin"
  with ctx.generate.draft() as draft:
    # draft.cache("pumpkin_models", "v1")
    models = list(face_models(0))
    print("Generating!")

    draft.assets[root] = Model({
      "parent": "minecraft:block/block",
      "textures": {
        "0": "minecraft:block/carved_pumpkin"
      }
    })

    for name, model in models:
      draft.assets[f"{root}/{name}"] = Model(model)
    
    i = 0
    composite_models = []
    for name, _ in models:
      composite_models.append({
        "type": "minecraft:condition",
        "property": "minecraft:custom_model_data",
        "index": i,
        "on_true": {
          "type": "minecraft:model",
          "model": f"{root}/{name}"
        },
        "on_false": {
          "type": "minecraft:empty"
        }
      })
      i += 1
    draft.assets["pumpkin_carving:custom_pumpkin"] = ItemModel({
      "model": {
        "type": "minecraft:composite",
        "models": composite_models
      }
    })
    

    