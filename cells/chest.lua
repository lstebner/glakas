function glakas.spawn_chest(cell)
  if cell then
    cell.gem = "chest"
    cell.cell_props = glakas.cell_props_for("chest")
  else
    print("spawn chest called with nil cell")
  end
end
