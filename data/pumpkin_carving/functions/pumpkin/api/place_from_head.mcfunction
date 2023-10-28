data modify storage pumpkin_carving:calc item_data set from storage eroxified:api place_player_head_block.item_used.tag.pumpkin_data
data modify storage pumpkin_carving:calc marker_data set value {north:[],east:[],south:[],west:[]}
scoreboard players set #temp pumpkin_carving.calc 0
execute if entity @s[y_rotation=-135..-45] run scoreboard players set #temp pumpkin_carving.calc 1
execute if entity @s[y_rotation=-45..45] run scoreboard players set #temp pumpkin_carving.calc 2
execute if entity @s[y_rotation=45..135] run scoreboard players set #temp pumpkin_carving.calc 3

execute if score #temp pumpkin_carving.calc matches 0 run data modify storage pumpkin_carving:calc marker_data.south set from storage pumpkin_carving:calc item_data.front
execute if score #temp pumpkin_carving.calc matches 0 run data modify storage pumpkin_carving:calc marker_data.west set from storage pumpkin_carving:calc item_data.left
execute if score #temp pumpkin_carving.calc matches 0 run data modify storage pumpkin_carving:calc marker_data.north set from storage pumpkin_carving:calc item_data.back
execute if score #temp pumpkin_carving.calc matches 0 run data modify storage pumpkin_carving:calc marker_data.east set from storage pumpkin_carving:calc item_data.right

execute if score #temp pumpkin_carving.calc matches 1 run data modify storage pumpkin_carving:calc marker_data.west set from storage pumpkin_carving:calc item_data.front
execute if score #temp pumpkin_carving.calc matches 1 run data modify storage pumpkin_carving:calc marker_data.north set from storage pumpkin_carving:calc item_data.left
execute if score #temp pumpkin_carving.calc matches 1 run data modify storage pumpkin_carving:calc marker_data.east set from storage pumpkin_carving:calc item_data.back
execute if score #temp pumpkin_carving.calc matches 1 run data modify storage pumpkin_carving:calc marker_data.south set from storage pumpkin_carving:calc item_data.right

execute if score #temp pumpkin_carving.calc matches 2 run data modify storage pumpkin_carving:calc marker_data.north set from storage pumpkin_carving:calc item_data.front
execute if score #temp pumpkin_carving.calc matches 2 run data modify storage pumpkin_carving:calc marker_data.east set from storage pumpkin_carving:calc item_data.left
execute if score #temp pumpkin_carving.calc matches 2 run data modify storage pumpkin_carving:calc marker_data.south set from storage pumpkin_carving:calc item_data.back
execute if score #temp pumpkin_carving.calc matches 2 run data modify storage pumpkin_carving:calc marker_data.west set from storage pumpkin_carving:calc item_data.right

execute if score #temp pumpkin_carving.calc matches 3 run data modify storage pumpkin_carving:calc marker_data.east set from storage pumpkin_carving:calc item_data.front
execute if score #temp pumpkin_carving.calc matches 3 run data modify storage pumpkin_carving:calc marker_data.south set from storage pumpkin_carving:calc item_data.left
execute if score #temp pumpkin_carving.calc matches 3 run data modify storage pumpkin_carving:calc marker_data.west set from storage pumpkin_carving:calc item_data.back
execute if score #temp pumpkin_carving.calc matches 3 run data modify storage pumpkin_carving:calc marker_data.north set from storage pumpkin_carving:calc item_data.right


data modify storage pumpkin_carving:calc passengers set value []

data modify storage pumpkin_carving:calc list set from storage pumpkin_carving:calc marker_data.north
data modify storage pumpkin_carving:calc macro set value {face:"north",rotation:[180f,0f]}
execute if data storage pumpkin_carving:calc list[0] run function pumpkin_carving:pumpkin/internal/place/list_to_dict
execute if data storage pumpkin_carving:calc list[0] run data modify storage pumpkin_carving:calc macro merge from storage pumpkin_carving:calc dict
execute if data storage pumpkin_carving:calc list[0] run function pumpkin_carving:pumpkin/internal/place/carved_face with storage pumpkin_carving:calc macro
execute unless data storage pumpkin_carving:calc list[0] run function pumpkin_carving:pumpkin/internal/place/uncarved_face with storage pumpkin_carving:calc macro

data modify storage pumpkin_carving:calc list set from storage pumpkin_carving:calc marker_data.east
data modify storage pumpkin_carving:calc macro set value {face:"east",rotation:[270f,0f]}
execute if data storage pumpkin_carving:calc list[0] run function pumpkin_carving:pumpkin/internal/place/list_to_dict
execute if data storage pumpkin_carving:calc list[0] run data modify storage pumpkin_carving:calc macro merge from storage pumpkin_carving:calc dict
execute if data storage pumpkin_carving:calc list[0] run function pumpkin_carving:pumpkin/internal/place/carved_face with storage pumpkin_carving:calc macro
execute unless data storage pumpkin_carving:calc list[0] run function pumpkin_carving:pumpkin/internal/place/uncarved_face with storage pumpkin_carving:calc macro

data modify storage pumpkin_carving:calc list set from storage pumpkin_carving:calc marker_data.south
data modify storage pumpkin_carving:calc macro set value {face:"south",rotation:[0f,0f]}
execute if data storage pumpkin_carving:calc list[0] run function pumpkin_carving:pumpkin/internal/place/list_to_dict
execute if data storage pumpkin_carving:calc list[0] run data modify storage pumpkin_carving:calc macro merge from storage pumpkin_carving:calc dict
execute if data storage pumpkin_carving:calc list[0] run function pumpkin_carving:pumpkin/internal/place/carved_face with storage pumpkin_carving:calc macro
execute unless data storage pumpkin_carving:calc list[0] run function pumpkin_carving:pumpkin/internal/place/uncarved_face with storage pumpkin_carving:calc macro

data modify storage pumpkin_carving:calc list set from storage pumpkin_carving:calc marker_data.west
data modify storage pumpkin_carving:calc macro set value {face:"west",rotation:[90f,0f]}
execute if data storage pumpkin_carving:calc list[0] run function pumpkin_carving:pumpkin/internal/place/list_to_dict
execute if data storage pumpkin_carving:calc list[0] run data modify storage pumpkin_carving:calc macro merge from storage pumpkin_carving:calc dict
execute if data storage pumpkin_carving:calc list[0] run function pumpkin_carving:pumpkin/internal/place/carved_face with storage pumpkin_carving:calc macro
execute unless data storage pumpkin_carving:calc list[0] run function pumpkin_carving:pumpkin/internal/place/uncarved_face with storage pumpkin_carving:calc macro

function pumpkin_carving:pumpkin/internal/place/four_carved_faces with storage pumpkin_carving:calc