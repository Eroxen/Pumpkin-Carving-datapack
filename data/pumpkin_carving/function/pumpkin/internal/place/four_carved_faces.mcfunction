setblock ~ ~ ~ barrier
$execute align xyz run summon minecraft:interaction ~0.5 ~0.01 ~0.5 {width:1.02f,height:0.98f,response:1b,Tags:["eroxified2.interaction","pumpkin_carving.pumpkin"],Passengers:[\
{id:"minecraft:marker",Tags:["pumpkin_carving.pumpkin"],data:$(marker_data)},\
{id:"minecraft:item_display",width:1f,height:1f,Tags:["pumpkin_carving.pumpkin","pumpkin_carving.model","pumpkin_carving.model.root"],Rotation:[0f,0f],item:{id:"minecraft:pumpkin_seeds",components:{"minecraft:custom_model_data":100}},transformation:{left_rotation:[0f,0f,0f,1f],right_rotation:[0f,0f,0f,1f],translation:[0f,0.49f,0f],scale:[1f,1f,1f]},Passengers:$(passengers)}\
]}