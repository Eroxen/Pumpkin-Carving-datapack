execute align xyz positioned ~0.5 ~0.01 ~0.5 unless entity @e[type=interaction,tag=pumpkin_carving.proposal,distance=..0.1] run summon interaction ~ ~ ~ {width:1.02f,height:0.98f,response:1b,Tags:["eroxified.interaction","pumpkin_carving.proposal"]}
scoreboard players set proposals_exist pumpkin_carving.calc 1
execute align xyz positioned ~0.5 ~0.01 ~0.5 run scoreboard players set @e[type=interaction,tag=pumpkin_carving.proposal,distance=..0.1] pumpkin_carving.calc 5