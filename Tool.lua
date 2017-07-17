Tool = {}

local DEFAULT_PROPS = {
  type = nil,
  energy_cost = 0,
  durability = 1,
  max_durability = 1,
  times_used = 0,
  level = 1,
}

Tool.NEEDS_REPAIR_THRESHOLD = .5

function Tool.create(props)
  return props
end
