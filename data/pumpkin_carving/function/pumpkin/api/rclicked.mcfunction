scoreboard players set #right_click_action pumpkin_carving.calc 0
execute on target if predicate pumpkin_carving:holding_sword run scoreboard players set #right_click_action pumpkin_carving.calc 1
execute on target if predicate pumpkin_carving:holding_pumpkin_seeds run scoreboard players set #right_click_action pumpkin_carving.calc 2

execute unless score #right_click_action pumpkin_carving.calc matches 1.. run return 0

function pumpkin_carving:pumpkin/api/get_clicked_pos

execute if score #face.block pumpkin_carving.calc matches -1 run return 0

data modify storage pumpkin_carving:calc macro set value {face:"south",block:0}
execute store result storage pumpkin_carving:calc macro.block int 1 run scoreboard players get #face.block pumpkin_carving.calc
data modify storage pumpkin_carving:calc macro.face set from storage pumpkin_carving:calc hit_face
function pumpkin_carving:pumpkin/internal/get_block_data with storage pumpkin_carving:calc macro

scoreboard players set #bit pumpkin_carving.calc 1
execute if score #face.subblock pumpkin_carving.calc matches 1 run scoreboard players set #bit pumpkin_carving.calc 2
execute if score #face.subblock pumpkin_carving.calc matches 2 run scoreboard players set #bit pumpkin_carving.calc 4
execute if score #face.subblock pumpkin_carving.calc matches 3 run scoreboard players set #bit pumpkin_carving.calc 8
execute if score #face.subblock pumpkin_carving.calc matches 4 run scoreboard players set #bit pumpkin_carving.calc 16
execute if score #face.subblock pumpkin_carving.calc matches 5 run scoreboard players set #bit pumpkin_carving.calc 32
execute if score #face.subblock pumpkin_carving.calc matches 6 run scoreboard players set #bit pumpkin_carving.calc 64
execute if score #face.subblock pumpkin_carving.calc matches 7 run scoreboard players set #bit pumpkin_carving.calc 128
scoreboard players set #bit2 pumpkin_carving.calc 2
scoreboard players operation #bit2 pumpkin_carving.calc *= #bit pumpkin_carving.calc

scoreboard players operation #pixel pumpkin_carving.calc = #byte pumpkin_carving.calc
scoreboard players operation #pixel pumpkin_carving.calc %= #bit2 pumpkin_carving.calc
scoreboard players operation #pixel pumpkin_carving.calc /= #bit pumpkin_carving.calc

execute if score #pixel pumpkin_carving.calc matches 1 if score #right_click_action pumpkin_carving.calc matches 1 run function pumpkin_carving:pumpkin/internal/carve
execute if score #pixel pumpkin_carving.calc matches 0 if score #right_click_action pumpkin_carving.calc matches 2 run function pumpkin_carving:pumpkin/internal/repair