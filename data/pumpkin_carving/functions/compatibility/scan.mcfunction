execute unless data storage eroxified:compatibility installed[{name:"eroxified"}] run data modify storage pumpkin_carving:calc error_message set value '{"text":"Warning: Pumpkin Carving has detected that the required library Eroxified is not installed! You can download it ","color":"red","extra":[{"text":"here","color":"aqua","underlined":true,"hoverEvent":{"action":"show_text","contents":[{"text":"planetminecraft.com"}]},"clickEvent":{"action":"open_url","value":"https://www.planetminecraft.com/data-pack/eroxified/"}}]}'

scoreboard players set eroxified_version pumpkin_carving.calc 0
scoreboard players set op pumpkin_carving.calc 0
execute if data storage eroxified:compatibility installed[{name:"eroxified"}] store result score eroxified_version pumpkin_carving.calc run data get storage eroxified:compatibility installed[{name:"eroxified"}].version 1
execute if data storage eroxified:compatibility installed[{name:"eroxified"}] run scoreboard players set op pumpkin_carving.calc 1000000
execute if data storage eroxified:compatibility installed[{name:"eroxified"}] run scoreboard players operation eroxified_version.1 pumpkin_carving.calc = eroxified_version pumpkin_carving.calc
execute if data storage eroxified:compatibility installed[{name:"eroxified"}] run scoreboard players operation eroxified_version.1 pumpkin_carving.calc /= op pumpkin_carving.calc
execute if data storage eroxified:compatibility installed[{name:"eroxified"}] run scoreboard players operation eroxified_version.2 pumpkin_carving.calc = eroxified_version pumpkin_carving.calc
execute if data storage eroxified:compatibility installed[{name:"eroxified"}] run scoreboard players operation eroxified_version.2 pumpkin_carving.calc %= op pumpkin_carving.calc
execute if data storage eroxified:compatibility installed[{name:"eroxified"}] run scoreboard players set op pumpkin_carving.calc 1000
execute if data storage eroxified:compatibility installed[{name:"eroxified"}] run scoreboard players operation eroxified_version.2 pumpkin_carving.calc /= op pumpkin_carving.calc
execute if data storage eroxified:compatibility installed[{name:"eroxified"}] run scoreboard players operation eroxified_version.3 pumpkin_carving.calc = eroxified_version pumpkin_carving.calc
execute if data storage eroxified:compatibility installed[{name:"eroxified"}] run scoreboard players operation eroxified_version.3 pumpkin_carving.calc %= op pumpkin_carving.calc
execute if data storage eroxified:compatibility installed[{name:"eroxified"}] unless score eroxified_version pumpkin_carving.calc matches 1001000.. run data modify storage pumpkin_carving:calc error_message set value '{"text":"Warning: Pumpkin Carving has detected that the required library Eroxified is installed, but is outdated! (Version ","color":"red","extra":[{"score":{"name":"eroxified_version.1","objective":"pumpkin_carving.calc"}},{"text":"."},{"score":{"name":"eroxified_version.2","objective":"pumpkin_carving.calc"}},{"text":"."},{"score":{"name":"eroxified_version.3","objective":"pumpkin_carving.calc"}},{"text":" < 1.1.0). You can download the latest version "},{"text":"here","color":"aqua","underlined":true,"hoverEvent":{"action":"show_text","contents":[{"text":"planetminecraft.com"}]},"clickEvent":{"action":"open_url","value":"https://www.planetminecraft.com/data-pack/eroxified/"}}]}'
execute if data storage eroxified:compatibility installed[{name:"eroxified"}] if score eroxified_version pumpkin_carving.calc matches 1001000.. run scoreboard players set eroxified_installed pumpkin_carving.calc 1