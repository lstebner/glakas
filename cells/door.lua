function glakas.spawn_door_down(cell)
  if cell then
    cell.gem = "door_down"
    cell.cell_props = glakas.cell_props_for("door")
  else
    print("spawn door down called with nil cell")
  end
end

function glakas.spawn_door_up(cell)
  if cell then
    cell.gem = "door_up"
    cell.cell_props = glakas.cell_props_for("door")
  else
    print("spawn door up called with nil cell")
  end
end
