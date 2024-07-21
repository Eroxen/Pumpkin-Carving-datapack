execute as @e[type=interaction,tag=pumpkin_carving.pumpkin] at @s run function pumpkin_carving:pumpkin/api/delete
kill @e[tag=pumpkin_carving.entity]

clear @a *[minecraft:custom_data~{pumpkin_carving:{}}]
execute as @e[type=item] if items entity @s contents *[minecraft:custom_data~{pumpkin_carving:{}}] run kill @s

data remove storage pumpkin_carving:calc const

scoreboard objectives remove pumpkin_carving.calc

function pumpkin_carving:signature
function eroxified2:core/api/disable_signature

tellraw @a {"text":"[Pumpkin Carving] Uninstalled datapack. If you renamed the datapack file, make sure to disable it manually using /datapack disable.","color":"gold"}