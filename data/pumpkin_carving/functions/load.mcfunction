scoreboard objectives add pumpkin_carving.calc dummy

scoreboard players set #const.2 pumpkin_carving.calc 2
scoreboard players set #const.3 pumpkin_carving.calc 3
scoreboard players set #const.4 pumpkin_carving.calc 4
scoreboard players set #const.16 pumpkin_carving.calc 16
scoreboard players set #const.1000 pumpkin_carving.calc 1000

schedule function pumpkin_carving:clock_3t 3t

data modify storage pumpkin_carving:calc const set value {\
rotations:{north:[180f,0f],south:[0f,0f],east:[270f,0f],west:[90f,0f]}\
}