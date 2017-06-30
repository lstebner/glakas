
function glakas.create_forest(size, start_pos, room)
  start_pos = start_pos or 1
  size = size or 3

  print("create "..size.."x"..size.." forest at "..start_pos)

  for i=1, size do
    for k=1, size do
      local tree_idx = start_pos + i + (k * room.columns)
      if room.grid[tree_idx] and room.grid[tree_idx].gem ~= "water" then
        glakas.spawn_tree(room.grid[tree_idx])
      end
    end
  end
end

function glakas.spawn_tree(cell)
  local chance_to_fruit = 15
  if cell then
    if cell.gem == "tree_sapling" then
      print("tree sapling "..cell.idx.." has grown in to a tree!")
    else
      print("spawn tree at "..cell.idx)
    end

    cell.gem = "tree"
    cell.cell_props = glakas.cell_props_for("tree")

    if math.random(100) < chance_to_fruit then
      cell.cell_props.fruited = true
    end
  else
    print("error: spawn tree called with nil cell")
  end
end

function glakas.fruit_tree(cell)
  if cell == nil then
    return print("fruit_tree called with nil cell")
  end
  
  -- this should never happen, but something glitches sometimes and it does :(
  if cell.cell_props == nil then
    cell.cell_props = glakas.cell_props_for("tree")
  end

  cell.cell_props.fruited = true
end

function glakas.spawn_tree_sapling(cell)
  if cell then
    print("spawn tree sapling at "..cell.idx)
    cell.gem = "tree_sapling"
    cell.cell_props = glakas.cell_props_for("tree_sapling")
  else
    print("error: spawn tree sapling called with nil cell")
  end
end

function glakas.grow_tree(cell, how_much)
  local max_tree_size = 3

  if cell.gem ~= "tree" then
    return print("tried to call grow_tree on a cell that is not a tree")
  elseif cell.cell_props == nil then
    return print("grow_tree called on a tree with nil cell_props. id: "..cell.idx)
  elseif cell.cell_props.size >= max_tree_size then
    return print("tree at "..cell.idx.." is already as big as it can get")
  else
    print("tree at "..cell.idx.." grows by "..how_much)
  end

  how_much = how_much or 1

  cell.cell_props.size = cell.cell_props.size + how_much

  if cell.cell_props.size > max_tree_size then
    cell.cell_props.size = max_tree_size
  end
end

function glakas.grow_tree_sapling(cell)
  cell.cell_props.size = cell.cell_props.size + 1

  if cell.cell_props.size >= 10 then
    glakas.spawn_tree(cell)
  end
end

