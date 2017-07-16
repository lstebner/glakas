Map = {}

require "helpers/copy"
require "Cell"

local DEFAULT_PROPS = {
  rows = 7,
  cols = 12,
  grid_size = 40,
}

function Map.create(props)
  props = props or shallowcopy(DEFAULT_PROPS)

  local new_map = {
    rows = props.rows or 0,
    cols = props.cols or 0,
    total_cells = 0,
    cells = {},
    grid_size = props.grid_size,
    impassable_cell_types = {},
  }

  Map.create_cells(new_map, new_map.rows * new_map.cols, props.cells)

  return new_map
end

function Map.create_cells(map, amount, cell_type)
  cell_type = cell_type or "empty"
  local init_cells = false
  if type(cell_type) == "table" then
    init_cells = true
  end

  for i = 1, amount do
    -- a list of cell_types was passed in
    if init_cells and cell_type[i] then
      Map.create_cell(map, cell_type[i])
    -- a single cell_type was passed in
    elseif init_cells == false then
      Map.create_cell(map, cell_type)
    -- a list of cell types was passed in but we ran out of indexes
    -- so everything else gets made empty
    else
      Map.create_cell(map, "empty")
    end
  end
end

function Map.create_cell(map, cell_type)
  local new_cell_id = #map.cells + 1
  local props = {
    idx = new_cell_id,
    type = cell_type,
  }

  table.insert(map.cells, Cell.create(props))
  map.total_cells = #map.cells
end

function Map.get_cell(map, idx)
  if idx < 1 or idx > #map.cells then
    -- print("Map.get_cell idx of "..idx.." is out of range")
    return nil
  end

  return map.cells[idx]
end

function Map.empty_cell(map, idx)
  Map.reset_cell(map, idx, "empty")
end

function Map.reset_cell(map, idx, type, props)
  props = props or {}
  props.idx = idx
  props.type = type

  if map.cells[idx] then
    map.cells[idx] = Cell.create(props)
  else
    return false
  end
end

function Map.create_door(map, idx, connecting_map_idx, disguise_door)
  disguise_door = disguise_door or false

  if map.cells[idx] then
    local cell_props = {
      connecting_map_idx = connecting_map_idx 
    }
    Map.reset_cell(map, idx, "door", { cell_props = cell_props })

    if disguise_door then
      -- todo: add back random disguises
      local disguise = "gem_blue"
      Cell.disguise(Map.get_cell(map, idx), disguise)
    end
  else
    return false
  end
end

function Map.get_cells(map, cell_ids)
  if cell_ids then
    local cells = {}
    for i, id in pairs(cell_ids) do
      local cell = Map.get_cell(map, id)
      if cell then
        table.insert(cells, cell)
      end
    end
    return cells
  else
    return map.cells
  end
end

function Map.get_cells_of_type(map, type)
  local cells = {}
  for i, cell in pairs(map.cells) do
    if cell.type == type then
      table.insert(cells, cell)
    end
  end

  return cells
end

function Map.get_neighboring_cells(map, idx)
  local neighbors = {}

  if idx < map.cols or idx % map.cols > 1 then
    table.insert(neighbors, idx + 1)
  end

  if idx > 1 or idx % map.cols == 1 then
    table.insert(neighbors, idx - 1)
  end

  if idx > map.cols then
    table.insert(neighbors, idx - map.cols)
  end

  if idx < map.total_cells - map.cols then
    table.insert(neighbors, idx + map.cols)
  end

  return Map.get_cells(map, neighbors)
end

function Map.get_surrounding_cells(map, idx)
  local surrounding = {}

  if idx < map.cols or idx % map.cols > 1 then
    table.insert(surrounding, idx + 1)
  end

  if idx > 1 or idx % map.cols == 1 then
    table.insert(surrounding, idx - 1)
  end

  if idx > map.cols then
    table.insert(surrounding, idx - map.cols)
    table.insert(surrounding, idx - map.cols + 1)

    if idx % map.cols > 0 then
      table.insert(surrounding, idx - map.cols - 1)
    end
  end

  if idx < map.total_cells - map.cols then
    table.insert(surrounding, idx + map.cols)
    table.insert(surrounding, idx + map.cols + 1)

    if idx % map.cols > 1 then
      table.insert(surrounding, idx + map.cols - 1)
    end
  end

  return Map.get_cells(map, surrounding)
end

function Map.update(map, world)
end

function Map.can_player_move_to(map, new_pos, player)
  local cell = Map.get_cell(map, new_pos)

  if cell then
    if cell.idx == player.position then
      return false
    end

    if map.impassable_cell_types then
      for i, t in pairs(map.impassable_cell_types) do
        if cell.type == t then
          return false
        end
      end
    end

    return true
  end

  return false
end

function Map.move_player(map, player, dir)
  if dir == "east" or dir == "e" then
    local next_pos = player.position + 1
    if player.position % map.cols ~= 0 then
      Player.move_to(player, next_pos)
    end
  end

  if dir == "west" or dir == "w" then
    local next_pos = player.position - 1
    if next_pos % map.cols < map.cols - 1 then
      Player.move_to(player, next_pos)
    end
  end

  if dir == "north" or dir == "n" then
    local next_pos = player.position - map.cols
    if next_pos > -1 then
      Player.move_to(player, next_pos)
    end
  end

  if dir == "south" or dir == "s" then
    local next_pos = player.position + map.cols
    if next_pos <= #map.cells then
      Player.move_to(player, next_pos)
    end
  end
end
