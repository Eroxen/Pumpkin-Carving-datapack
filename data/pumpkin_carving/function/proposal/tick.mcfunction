scoreboard players remove @e[type=interaction,tag=pumpkin_carving.proposal,scores={pumpkin_carving.calc=1..}] pumpkin_carving.calc 1
kill @e[type=interaction,tag=pumpkin_carving.proposal,scores={pumpkin_carving.calc=..0}]
execute unless entity @e[type=interaction,tag=pumpkin_carving.proposal] run scoreboard players set proposals_exist pumpkin_carving.calc 0