function xcoord_for(idx)
  return idx % glakas.columns
end

function ycoord_for(idx)
  return math.floor(idx / glakas.columns)
end

function xpos_for(idx)
  return xcoord_for(idx) * glakas.grid_size + glakas.x
end

function ypos_for(idx)
  return ycoord_for(idx) * glakas.grid_size + glakas.y
end
