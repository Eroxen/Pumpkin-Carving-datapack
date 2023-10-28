data remove storage pumpkin_carving:calc marker_data
execute on passengers if entity @s[type=marker] run data modify storage pumpkin_carving:calc marker_data set from entity @s data

function pumpkin_carving:pumpkin/api/get_attacked_pos
function pumpkin_carving:pumpkin/internal/recursive_kill

setblock ~ ~ ~ air
execute align xyz positioned ~0.5 ~0.5 ~0.5 run particle minecraft:block minecraft:pumpkin ~ ~ ~ 0.2 0.2 0.2 0 19
execute align xyz positioned ~0.5 ~0.5 ~0.5 run playsound minecraft:block.wood.break block @a[distance=..16]

data modify storage pumpkin_carving:calc item_data set value {front:[],left:[],right:[],back:[]}
execute if data storage pumpkin_carving:calc {hit_face:"north"} run data modify storage pumpkin_carving:calc item_data.front set from storage pumpkin_carving:calc marker_data.north
execute if data storage pumpkin_carving:calc {hit_face:"north"} run data modify storage pumpkin_carving:calc item_data.left set from storage pumpkin_carving:calc marker_data.east
execute if data storage pumpkin_carving:calc {hit_face:"north"} run data modify storage pumpkin_carving:calc item_data.back set from storage pumpkin_carving:calc marker_data.south
execute if data storage pumpkin_carving:calc {hit_face:"north"} run data modify storage pumpkin_carving:calc item_data.right set from storage pumpkin_carving:calc marker_data.west

execute if data storage pumpkin_carving:calc {hit_face:"east"} run data modify storage pumpkin_carving:calc item_data.front set from storage pumpkin_carving:calc marker_data.east
execute if data storage pumpkin_carving:calc {hit_face:"east"} run data modify storage pumpkin_carving:calc item_data.left set from storage pumpkin_carving:calc marker_data.south
execute if data storage pumpkin_carving:calc {hit_face:"east"} run data modify storage pumpkin_carving:calc item_data.back set from storage pumpkin_carving:calc marker_data.west
execute if data storage pumpkin_carving:calc {hit_face:"east"} run data modify storage pumpkin_carving:calc item_data.right set from storage pumpkin_carving:calc marker_data.north

execute if data storage pumpkin_carving:calc {hit_face:"south"} run data modify storage pumpkin_carving:calc item_data.front set from storage pumpkin_carving:calc marker_data.south
execute if data storage pumpkin_carving:calc {hit_face:"south"} run data modify storage pumpkin_carving:calc item_data.left set from storage pumpkin_carving:calc marker_data.west
execute if data storage pumpkin_carving:calc {hit_face:"south"} run data modify storage pumpkin_carving:calc item_data.back set from storage pumpkin_carving:calc marker_data.north
execute if data storage pumpkin_carving:calc {hit_face:"south"} run data modify storage pumpkin_carving:calc item_data.right set from storage pumpkin_carving:calc marker_data.east

execute if data storage pumpkin_carving:calc {hit_face:"west"} run data modify storage pumpkin_carving:calc item_data.front set from storage pumpkin_carving:calc marker_data.west
execute if data storage pumpkin_carving:calc {hit_face:"west"} run data modify storage pumpkin_carving:calc item_data.left set from storage pumpkin_carving:calc marker_data.north
execute if data storage pumpkin_carving:calc {hit_face:"west"} run data modify storage pumpkin_carving:calc item_data.back set from storage pumpkin_carving:calc marker_data.east
execute if data storage pumpkin_carving:calc {hit_face:"west"} run data modify storage pumpkin_carving:calc item_data.right set from storage pumpkin_carving:calc marker_data.south

execute align xyz positioned ~0.5 ~0.5 ~0.5 run loot spawn ~ ~ ~ loot pumpkin_carving:custom_carved_pumpkin