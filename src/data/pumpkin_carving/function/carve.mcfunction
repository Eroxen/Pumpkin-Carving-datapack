from pumpkin_carving:pumpkin import CustomPumpkin, CustomPumpkinBlock

function ~/init:
  setblock ~ ~ ~ crafter{components:CustomPumpkin.components}
  function f"{CustomPumpkinBlock.func_root}/detect_placed/found_block"

function ~/carve:
  say carve

function ~/fill:
  say fill