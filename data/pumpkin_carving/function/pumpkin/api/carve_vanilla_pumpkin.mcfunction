function pumpkin_carving:pumpkin/api/get_clicked_pos
execute if score #face.block pumpkin_carving.calc matches -1 run return 0

execute if data storage pumpkin_carving:calc {hit_face:"west"} run function pumpkin_carving:pumpkin/internal/place/one_face_sliced {sliced_face:"west",sliced_rotation:[90f,0f],unsliced_face_1:"south",unsliced_rotation_1:[0f,0f],unsliced_face_2:"north",unsliced_rotation_2:[180f,0f],unsliced_face_3:"east",unsliced_rotation_3:[270f,0f]}
execute if data storage pumpkin_carving:calc {hit_face:"east"} run function pumpkin_carving:pumpkin/internal/place/one_face_sliced {sliced_face:"east",sliced_rotation:[270f,0f],unsliced_face_1:"south",unsliced_rotation_1:[0f,0f],unsliced_face_2:"west",unsliced_rotation_2:[90f,0f],unsliced_face_3:"north",unsliced_rotation_3:[180f,0f]}
execute if data storage pumpkin_carving:calc {hit_face:"north"} run function pumpkin_carving:pumpkin/internal/place/one_face_sliced {sliced_face:"north",sliced_rotation:[180f,0f],unsliced_face_1:"south",unsliced_rotation_1:[0f,0f],unsliced_face_2:"west",unsliced_rotation_2:[90f,0f],unsliced_face_3:"east",unsliced_rotation_3:[270f,0f]}
execute if data storage pumpkin_carving:calc {hit_face:"south"} run function pumpkin_carving:pumpkin/internal/place/one_face_sliced {sliced_face:"south",sliced_rotation:[0f,0f],unsliced_face_1:"west",unsliced_rotation_1:[90f,0f],unsliced_face_2:"north",unsliced_rotation_2:[180f,0f],unsliced_face_3:"east",unsliced_rotation_3:[270f,0f]}


data modify storage pumpkin_carving:calc macro set value {face:"south",block:0}
execute store result storage pumpkin_carving:calc macro.block int 1 run scoreboard players get #face.block pumpkin_carving.calc
data modify storage pumpkin_carving:calc macro.face set from storage pumpkin_carving:calc hit_face

scoreboard players set #byte pumpkin_carving.calc 255
scoreboard players set #pixel pumpkin_carving.calc 1
scoreboard players set #bit pumpkin_carving.calc 1
execute if score #face.subblock pumpkin_carving.calc matches 1 run scoreboard players set #bit pumpkin_carving.calc 2
execute if score #face.subblock pumpkin_carving.calc matches 2 run scoreboard players set #bit pumpkin_carving.calc 4
execute if score #face.subblock pumpkin_carving.calc matches 3 run scoreboard players set #bit pumpkin_carving.calc 8
execute if score #face.subblock pumpkin_carving.calc matches 4 run scoreboard players set #bit pumpkin_carving.calc 16
execute if score #face.subblock pumpkin_carving.calc matches 5 run scoreboard players set #bit pumpkin_carving.calc 32
execute if score #face.subblock pumpkin_carving.calc matches 6 run scoreboard players set #bit pumpkin_carving.calc 64
execute if score #face.subblock pumpkin_carving.calc matches 7 run scoreboard players set #bit pumpkin_carving.calc 128

execute as @e[type=interaction,tag=pumpkin_carving.pumpkin,distance=..0.1,limit=1] run function pumpkin_carving:pumpkin/internal/carve