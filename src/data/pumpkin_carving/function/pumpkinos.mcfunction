from eroxified2:custom_item import CustomItem, transformer

class Pumpkinos(CustomItem):
  item_name = "Pumpkinos"
  item_model = "pumpkin_carving:pumpkinos"
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

  @transformer('lore', [])
  def add_pack_branding(cls, lore):
    return lore + [{"text":"Pumpkin Carving","color":"#e7a16b"}]