scoreboard players remove #raycast_limit pumpkin_carving.calc 1
execute if block ~ ~ ~ minecraft:pumpkin run function pumpkin_carving:proposal/raycast_hit
execute unless block ~ ~ ~ minecraft:pumpkin if score #raycast_limit pumpkin_carving.calc matches 1.. positioned ^ ^ ^0.1 run function pumpkin_carving:proposal/raycast_loop