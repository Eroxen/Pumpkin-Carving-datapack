$data modify storage pumpkin_carving:calc macro set value {face:$(face)}
$data modify storage pumpkin_carving:calc macro.rotation set from storage pumpkin_carving:calc const.rotations.$(face)
$data modify entity @s data.$(face) set value [255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255]

$execute as @e[type=item_display,tag=pumpkin_carving.model,tag=pumpkin_carving.model.root.$(face),distance=..0.1,limit=1] run function eroxified2:entity/api/kill_stack
function pumpkin_carving:pumpkin/internal/place/sliced_face with storage pumpkin_carving:calc macro
execute on vehicle run ride @e[type=item_display,tag=pumpkin_carving.model.new,distance=..0.1,limit=1] mount @s
tag @e[type=item_display,tag=pumpkin_carving.model.new] remove pumpkin_carving.model.new