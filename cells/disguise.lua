function glakas.disguise_cell(cell, disguise_as)
  if cell then
    print("disguising cell "..cell.idx.." as "..disguise_as)
    cell.cell_props.disguised_as = disguise_as
  else
    print("disguise cell called with nil cell")
  end
end
