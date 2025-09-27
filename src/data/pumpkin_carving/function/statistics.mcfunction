import eroxified2:format as eroxified2_format

from pumpkin_carving:utils import snake_case_to_words, measure_text_width, text_padding, register_scoreboard_objective
from collections import defaultdict
STATS = ["pumpkins_carved", "voxels_carved", "voxels_filled"]

### API ###
function ~/load:
  for stat in STATS:
    scoreboard objectives add register_scoreboard_objective(f"pumpkin_carving.stats.{stat}") dummy

function ~/show_dialog:
  data modify storage pumpkin_carving:calc internal.temp set value {body:[]}
  data modify storage eroxified2:api format.input set value {value:0,width:10}
  scoreboard players set #internal.temp pumpkin_carving.calc 0
  for stat in STATS:
    execute store result storage eroxified2:api format.input.value int 1 run scoreboard players get @s f"pumpkin_carving.stats.{stat}"
    function eroxified2:format/api/int_space_pad_front
    padding = text_padding(150 - measure_text_width(snake_case_to_words(stat)))
    data modify storage pumpkin_carving:calc internal.temp.body append value {type:"minecraft:plain_message",width:300,contents:{text:snake_case_to_words(stat),extra:[padding]}}
    data modify storage pumpkin_carving:calc internal.temp.body[-1].contents.extra append from storage eroxified2:api format.output
    execute if score #internal.temp pumpkin_carving.calc matches 1 run data modify storage pumpkin_carving:calc internal.temp.body[-1].contents.color set value "gray"
    execute store success score #internal.temp pumpkin_carving.calc if score #internal.temp pumpkin_carving.calc matches 0

  function ~/show with storage pumpkin_carving:calc internal.temp
  function ~/show:
    $dialog show @s {type:"minecraft:notice",title:{translate:"gui.stats"},body:$(body),action:{label:{translate:"gui.done"},action:{type:"minecraft:show_dialog",dialog:"pumpkin_carving:main_menu"}}}

### INTERNAL ###