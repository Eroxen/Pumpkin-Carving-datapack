$execute on passengers if entity @s[type=marker] unless data entity @s data.$(face)[$(block)] run function pumpkin_carving:pumpkin/internal/slice_new_face {face:$(face)}
$execute on passengers if entity @s[type=marker] run data modify entity @s data.$(face)[$(block)] set value $(byte)
$data modify entity @e[type=item_display,tag=pumpkin_carving.model,tag=pumpkin_carving.model.$(face).$(block),distance=..0.1,limit=1] item.tag.CustomModelData set value $(cmd)