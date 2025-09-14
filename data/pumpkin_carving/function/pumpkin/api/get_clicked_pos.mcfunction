data modify storage pumpkin_carving:calc macro set value {from:[-0.5d,-0.01d,-0.5d],to:[0.5d,0.99d,0.5d]}
data modify storage pumpkin_carving:calc macro.origin set from entity @s Pos
execute on target run data modify storage pumpkin_carving:calc macro.rotation set from entity @s Rotation
execute on target at @s anchored eyes positioned ^ ^ ^ run function eroxified2:math.ray/api/box/face_uv_aabb with storage pumpkin_carving:calc macro

scoreboard players operation #face.x pumpkin_carving.calc = math.ray.hit.u eroxified2.api
scoreboard players operation #face.y pumpkin_carving.calc = math.ray.hit.v eroxified2.api
scoreboard players add #face.y pumpkin_carving.calc 10
data modify storage pumpkin_carving:calc hit_face set from storage eroxified2:api math.ray.hit.face

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

#tellraw @a [{"score":{"name":"math.ray.hit.u","objective":"eroxified2.api"}},{"text":" "},{"score":{"name":"math.ray.hit.v","objective":"eroxified2.api"}}]
#tellraw @a [{"score":{"name":"#face.x","objective":"pumpkin_carving.calc"}},{"text":" "},{"score":{"name":"#face.y","objective":"pumpkin_carving.calc"}}]
#tellraw @a [{"score":{"name":"#face.block","objective":"pumpkin_carving.calc"}},{"text":" "},{"score":{"name":"#face.subblock","objective":"pumpkin_carving.calc"}}]