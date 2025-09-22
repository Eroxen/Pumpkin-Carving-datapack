from eroxified2:core import run_at_pack_load
from pumpkin_carving:utils import register_scoreboard_objective

run_at_pack_load()

function pumpkin_carving:statistics/load
function pumpkin_carving:config/load
scoreboard objectives add register_scoreboard_objective("pumpkin_carving.calc") dummy
scoreboard objectives add register_scoreboard_objective("pumpkin_carving.dialog") trigger
scoreboard objectives add register_scoreboard_objective("pumpkin_carving.config") dummy

### ensure sufficient command chain length ###
execute store result score maxCommandChainLength pumpkin_carving.calc run gamerule maxCommandChainLength
execute unless score maxCommandChainLength pumpkin_carving.calc matches 100000.. run gamerule maxCommandChainLength 100000