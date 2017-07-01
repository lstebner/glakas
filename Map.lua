Map = {}

require "copy"

local DEFAULT_PROPS = {
  rows = 7,
  cols = 12,
  grid_size = 40,
}

function Map.create(props)
  props = props or shallowcopy(DEFAULT_PROPS)

  local new_map = {
    rows = props.rows,
    cols = props.cols,
    total_cells = 0,
    cells = {},
    grid_size = props.grid_size,
    grid = {},
  }

  new_map.total_cells = new_map.rows * new_map.cols

  for i = 0, new_map.total_cells do
    Map.create_cell(new_map, "empty")
  end

  return new_map
end

function Map.create_cell(map, cell_type)
  -- todo: Cell.create and whatnot
  local new_cell_id = #map.grid + 1
  table.insert(map.grid, {
    idx = new_cell_id,
    type = cell_type,
  })
end

function Map.update(map, world)
end
