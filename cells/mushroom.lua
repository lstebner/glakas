function glakas.spawn_mushrooms(cell)
  if cell then
    cell.gem = "mushrooms"
    cell.cell_props = glakas.cell_props_for("mushrooms")
    print("mushrooms spawned at "..cell.idx)
  else
    print("spawn mushroom called with nil cell")
  end
end
