require 'helpers/copy'
local inspect = require("helpers/inspect")

Tool = {}

local DEFAULT_PROPS = {
  type = nil,
  name = "",
  energy_cost = 0,
  durability = 1,
  max_durability = 1,
  times_used = 0,
  level = 1,
  match_distance = 2,
}

Tool.NEEDS_REPAIR_THRESHOLD = .5

function Tool.create(props)
  props = extend(DEFAULT_PROPS, props or {})

  return props
end
