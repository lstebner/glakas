function glakas.spawn_food(cell)
  if cell then
    cell.gem = "food"
    cell.cell_props = glakas.cell_props_for("food")
  else
    print("spawn food called with nil cell")
  end
end
