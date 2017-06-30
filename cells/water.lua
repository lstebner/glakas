function glakas.spawn_water(cell)
  if cell then
    cell.gem = "water"
    cell.gem_props = glakas.cell_props_for("water")
  else
    print("spawn_water called with nil cell")
  end
end

function glakas.create_lakes_and_trees(amount, room)
  print("spawning lakes and trees")
  for i = 1, amount do
    glakas.create_lake(room, math.random(room.total_cells - room.columns + room.columns / 2), math.random(4) + 1)
    local water = glakas.get_cells_of_type("water", room)
    for i, c in pairs(water) do
      local neighbors = glakas.get_neighboring_cells(c, room)
      for k, n in pairs(neighbors) do
        if n.gem ~= "water" and string.match(n.gem, "door_") == nil then
          glakas.spawn_tree(n)
        end
      end
    end
  end
end

function glakas.create_lake(room, start_pos, size)
  local positions = {}
  for i = 1, size do
    for k = 1, i do
      local positions = {
        start_pos + i + ((k - 1) * room.columns),
        start_pos + i - ((k - 1) * room.columns),
        start_pos + i + ((k - 1) * room.columns) + size - k,
        start_pos + i - ((k - 1) * room.columns) + size - k,
      }

      for j, position in pairs(positions) do
        if room.grid[position] and string.match(room.grid[position].gem, "door_") then
          return true
        end

        glakas.spawn_water(room.grid[position])
      end
    end
  end
end

function glakas.create_stream(room, start_pos, size)
  local y_offset = 0
  for i = 1, size do
    if math.random(6) == 3 then
      if math.random(3) == 2 then
        y_offset = y_offset + room.columns
      else
        y_offset = y_offset - room.columns
      end
    end

    local pos = start_pos + i + y_offset

    if room.grid[pos] and string.match(room.grid[pos].gem, "door_") == nil then
      glakas.spawn_water(room.grid[pos])
    end
  end
end
