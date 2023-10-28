data modify storage pumpkin_carving:calc macro set value {from:[-0.5d,-0.01d,-0.5d],to:[0.5d,0.99d,0.5d]}
data modify storage pumpkin_carving:calc macro.origin set from entity @s Pos
execute on attacker run data modify storage pumpkin_carving:calc macro.rotation set from entity @s Rotation
execute on attacker at @s anchored eyes positioned ^ ^ ^ run function eroxified:api/math/ray/intersect_box with storage pumpkin_carving:calc macro

scoreboard players set #face.x pumpkin_carving.calc 1000
scoreboard players operation #face.y pumpkin_carving.calc = math.ray.hit.y eroxified.api

execute if score math.ray.hit_face eroxified.api matches 0 run scoreboard players operation #face.x pumpkin_carving.calc = math.ray.hit.z eroxified.api
execute if score math.ray.hit_face eroxified.api matches 4 run scoreboard players operation #face.x pumpkin_carving.calc -= math.ray.hit.x eroxified.api
execute if score math.ray.hit_face eroxified.api matches 5 run scoreboard players operation #face.x pumpkin_carving.calc = math.ray.hit.x eroxified.api
execute if score math.ray.hit_face eroxified.api matches 1 run scoreboard players operation #face.x pumpkin_carving.calc -= math.ray.hit.z eroxified.api

data modify storage pumpkin_carving:calc hit_face set value "south"
execute if score math.ray.hit_face eroxified.api matches 0 run data modify storage pumpkin_carving:calc hit_face set value "west"
execute if score math.ray.hit_face eroxified.api matches 1 run data modify storage pumpkin_carving:calc hit_face set value "east"
execute if score math.ray.hit_face eroxified.api matches 4 run data modify storage pumpkin_carving:calc hit_face set value "north"

scoreboard players operation #face.x pumpkin_carving.calc *= #const.16 pumpkin_carving.calc
scoreboard players operation #face.x pumpkin_carving.calc /= #const.1000 pumpkin_carving.calc
scoreboard players operation #face.y pumpkin_carving.calc *= #const.16 pumpkin_carving.calc
scoreboard players operation #face.y pumpkin_carving.calc /= #const.1000 pumpkin_carving.calc

scoreboard players operation #face.block pumpkin_carving.calc = #face.x pumpkin_carving.calc
scoreboard players operation #face.block pumpkin_carving.calc -= #const.2 pumpkin_carving.calc
scoreboard players operation #face.block pumpkin_carving.calc /= #const.4 pumpkin_carving.calc
scoreboard players operation #temp pumpkin_carving.calc = #face.y pumpkin_carving.calc
scoreboard players operation #temp pumpkin_carving.calc -= #const.2 pumpkin_carving.calc
scoreboard players operation #temp pumpkin_carving.calc /= #const.2 pumpkin_carving.calc
scoreboard players operation #temp pumpkin_carving.calc *= #const.3 pumpkin_carving.calc
scoreboard players operation #face.block pumpkin_carving.calc += #temp pumpkin_carving.calc
execute unless score #face.x pumpkin_carving.calc matches 2..13 run scoreboard players set #face.block pumpkin_carving.calc -1
execute unless score #face.y pumpkin_carving.calc matches 2..13 run scoreboard players set #face.block pumpkin_carving.calc -1

scoreboard players operation #face.subblock pumpkin_carving.calc = #face.x pumpkin_carving.calc
scoreboard players operation #face.subblock pumpkin_carving.calc -= #const.2 pumpkin_carving.calc
scoreboard players operation #face.subblock pumpkin_carving.calc %= #const.4 pumpkin_carving.calc
scoreboard players operation #temp pumpkin_carving.calc = #face.y pumpkin_carving.calc
scoreboard players operation #temp pumpkin_carving.calc %= #const.2 pumpkin_carving.calc
scoreboard players operation #temp pumpkin_carving.calc *= #const.4 pumpkin_carving.calc
scoreboard players operation #face.subblock pumpkin_carving.calc += #temp pumpkin_carving.calc

#tellraw @a [{"score":{"name":"#face.x","objective":"pumpkin_carving.calc"}},{"text":" "},{"score":{"name":"#face.y","objective":"pumpkin_carving.calc"}}]
#tellraw @a [{"score":{"name":"#face.block","objective":"pumpkin_carving.calc"}},{"text":" "},{"score":{"name":"#face.subblock","objective":"pumpkin_carving.calc"}}]