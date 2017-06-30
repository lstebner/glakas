local inspect = require("inspect")

function glakas.cell_props_for(gtype)
  if gtype == "empty" then
    return { flowered = false }
  elseif gtype == "tree" then
    return { size = 1, fruited = false }
  elseif gtype == "tree_sapling" then
    return { size = 1 }
  elseif gtype == "door" then
    return { disguised_as = false }
  else
    return {}
  end
end

function glakas.get_cells_of_type(gtype, room)
  if room then
    print("get_cells_of_type with room")
  end
  local grid = {}
  if room then
    grid = room.grid

    if grid == nil then
      print("get_cells_of_type called with room but room has no grid")
      print(inspect(room))
    end
  else
    grid = glakas.grid
  end

  local matches = {}

  for i, cell in pairs(grid) do
    if cell.gem == gtype then
      table.insert(matches, cell)
    end
  end

  print("get_cells_of_type "..gtype.." found "..(table.getn(matches)))

  return matches
end

function glakas.empty_cell(cell)
  cell.gem = "empty"
  cell.cell_props = glakas.cell_props_for("empty")
end

function glakas.clear_cells(cells)
  for i, c in pairs(cells) do
    glakas.empty_cell(c)
  end
end

function glakas.player_cell()
  return glakas.grid[player.pos]
end

function glakas.is_player_on(cell_type)
  local cell = glakas.grid[player.pos]

  if cell_type == "gem" then
    return string.match(cell.gem, "gem_")
  elseif cell_type == "door" then
    return string.match(cell.gem, "door_")
  else
    return cell.gem == cell_type
  end 
end

function glakas.get_cell_by_idx(idx, grid)
  grid = grid or glakas.grid
  if idx < 0 or idx > table.getn(grid) then
    return false
  end

  return grid[idx]
end

function glakas.get_cells(indexes, grid)
  grid = grid or glakas.grid

  local cells = {}

  for i, idx in pairs(indexes) do
    local cell = glakas.get_cell_by_idx(idx, grid)
    if cell then
      table.insert(cells, cell)
    end
  end 

  return cells
end

function glakas.get_neighboring_cells(cell, room)
  room = room or glakas

  local neighbors = {
    cell.idx + 1,
    cell.idx - 1,
    cell.idx + room.columns,
    cell.idx - room.columns
  }

  return glakas.get_cells(neighbors, room.grid)
end

function glakas.get_surrounding_cells(cell, room)
  room = room or glakas

  local surrounding = {
    cell.idx + 1,
    cell.idx - 1,
    cell.idx + room.columns,
    cell.idx - room.columns,
    cell.idx + room.columns + 1,
    cell.idx + room.columns - 1,
    cell.idx - room.columns + 1,
    cell.idx - room.columns - 1
  }

  return glakas.get_cells(surrounding, room.grid)
end

function glakas.all_matching_cells(cell)
  local matches = {cell}
  -- check to the right
  local neighbors = glakas.get_neighboring_cells(cell)

  for i, n in pairs(neighbors) do
    if n and n.gem == cell.gem then
      table.insert(matches, n)
    end
  end

  return matches
end

function glakas.disguise_cell(cell_idx, disguise)
  if glakas.grid[cell_idx] then
    if glakas.grid[cell_idx].cell_props.disguised_as then
      return print("cell "..cell_idx.." is already disguised!")
    end

    glakas.grid[cell_idx].cell_props.disguised_as = disguise
  end
end

function glakas.undisguise(cell_idx)
  print("undisguising "..cell_idx)
  if glakas.grid[cell_idx] and glakas.grid[cell_idx].cell_props.disguised_as ~= nil then
    glakas.grid[cell_idx].cell_props.disguised_as = nil
  end
end

function glakas.cell_props(cell)
  if cell and cell.cell_props then
    return cell.cell_props
  else
    return {}
  end
end

require "cells.tree"
require "cells.food"
require "cells.door"
require "cells.disguise"
require "cells.chest"
require "cells.mushroom"
require "cells.water"
