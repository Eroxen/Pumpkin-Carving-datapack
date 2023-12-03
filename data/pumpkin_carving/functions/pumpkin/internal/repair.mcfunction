scoreboard players operation #byte pumpkin_carving.calc += #bit pumpkin_carving.calc
execute store result storage pumpkin_carving:calc macro.byte int 1 run scoreboard players get #byte pumpkin_carving.calc

scoreboard players set #cmd pumpkin_carving.calc 256
scoreboard players operation #cmd pumpkin_carving.calc *= #face.block pumpkin_carving.calc
scoreboard players operation #cmd pumpkin_carving.calc += #byte pumpkin_carving.calc
scoreboard players add #cmd pumpkin_carving.calc 1000
execute store result storage pumpkin_carving:calc macro.cmd int 1 run scoreboard players get #cmd pumpkin_carving.calc

function pumpkin_carving:pumpkin/internal/set_block_data with storage pumpkin_carving:calc macro

playsound minecraft:block.mud.place block @a[distance=..8]
execute on target if predicate pumpkin_carving:survival_or_adventure run function eroxified2:item/api/decrement_mainhand