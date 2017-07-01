Cell = {}

local inspect = require("inspect")

require 'copy'

local DEFAULT_PROPS = {
  idx = -1,
  type = "empty", 
}

Cell.DEFAULT_CELL_PROPS = {
  default = {},
  empty = { flowered = false },
  door = { connecting_map_idx = -1 }
}

function Cell.create(props)
  props = props or DEFAULT_PROPS
  local cell = shallowcopy(props)

  cell.cell_props = Cell.default_cell_props_for(cell.type)

  -- cell props that were passed in need added back now
  -- because they were just overwritten
  if props.cell_props then
    for k, v in pairs(props.cell_props) do
      cell.cell_props[k] = v
    end
  end

  return cell
end

function Cell.default_cell_props_for(type)
  if Cell.DEFAULT_CELL_PROPS[type] then
    return deepcopy(Cell.DEFAULT_CELL_PROPS[type])
  else
    return deepcopy(Cell.DEFAULT_CELL_PROPS.default)  
  end
end

function Cell.disguise(cell, disguise_as)
  cell.cell_props.disguised_as = disguise_as
end

function Cell.undisguise(cell)
  cell.cell_props.disguised_as = nil
end

function Cell.is_disguised(cell)
  if cell.cell_props.disguised_as then
    return true
  else
    return false
  end
end
