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

function Tool.needs_repair(tool)
  return tool.durability < (tool.max_durability * Tool.NEEDS_REPAIR_THRESHOLD)
end

function Tool.repair(tool, amount)
  amount = amount or 1
  tool.durability = math.min(tool.max_durability, tool.durability + amount)
end

function Tool.use(tool)
  if tool.durability - tool.energy_cost < 1 then
    return false
  end

  tool.durability = math.max(0, tool.durability - tool.energy_cost)
  tool.times_used = tool.times_used + 1
end

function Tool.upgrade(tool, property, amount)
  amount = amount or 1
  if property == "level" then
    tool.level = tool.level + amount
  elseif property == "durability" or property == "max_durability" then
    tool.max_durability = tool.max_durability + amount
  elseif property == "match_distance" then
    tool.match_distance = tool.match_distance + amount
  end
end
