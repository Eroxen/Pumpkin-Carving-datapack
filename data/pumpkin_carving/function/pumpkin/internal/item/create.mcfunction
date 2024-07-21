loot replace entity @s contents loot pumpkin_carving:custom_carved_pumpkin
data modify entity @s item.components."minecraft:custom_data".pumpkin_carving.patterns set from storage pumpkin_carving:calc item_data

function pumpkin_carving:pumpkin/internal/item/spawn_loot with entity @s item
kill @s