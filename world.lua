world = {}

world.step_triggers = {
  spawn_tree_sapling = 101,
  fruit_tree = 63,
  grow_tree_saplings = 25,
  grow_trees = 75,
  grow_mushrooms = 66,
}

function world.spawn_tree_sapling()
  local empty_cells = glakas.get_cells_of_type("empty")
  glakas.spawn_tree_sapling(empty_cells[math.random(table.getn(empty_cells))])
end

function world.grow_trees()
  local trees = glakas.get_cells_of_type("tree")
  for i, t in pairs(trees) do
    if math.random(13) % 6 == 0 then
      glakas.grow_tree(t, 1)
    end
  end
end

function world.fruit_tree()
  local trees = glakas.get_cells_of_type("tree")
  glakas.fruit_tree(trees[math.random(table.getn(trees))])
end

function world.grow_tree_saplings()
  local saplings = glakas.get_cells_of_type("tree_sapling")
  for i, cell in pairs(saplings) do
    glakas.grow_tree_sapling(cell)
  end
end

function world.grow_mushrooms()
  if glakas.get_current_room().room_props.mushrooms ~= true then
    print("mushrooms cannot grow in this room")
    return false
  end

  local water = glakas.get_cells_of_type("water")
  local surrounding = glakas.get_surrounding_cells(water[math.random(table.getn(water))])
  for k, s in pairs(surrounding) do
    if s.gem == "empty" and math.random(30) == 3 then
      return glakas.spawn_mushrooms(s)
    end
  end
end


