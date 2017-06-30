function player.move_to(new_pos)
  local start_pos = player.pos

  if new_pos < 0 then
    new_pos = 0
  elseif new_pos >= table.getn(glakas.grid) then
    new_pos = table.getn(glakas.grid)
  end

  if new_pos ~= start_pos and player.can_move_to(new_pos) then
    player.pos = new_pos
    player.num_steps = player.num_steps + 1
    if player.num_steps % 11 == 0 then
      player.energy = player.energy - 1
    end
    player.last_move_time = love.timer.getTime() * 1000
    -- this gives the player the ability to use a tool as soon as they move
    player.last_tool_time = 0
    glakas.increment_steps()
  end
end

function player.can_move_to(new_pos)
  local cell = glakas.grid[new_pos]

  -- throttle move speed
  if love.timer.getTime() * 1000 < player.last_move_time + 200 then
    return false
  end

  return cell.gem ~= "stone" and cell.gem ~= "water"
end

function player.move_east()
  local next_pos = player.pos + 1
  if next_pos % glakas.columns ~= 0 then
    player.move_to(next_pos)
  end
end

function player.move_west()
  local next_pos = player.pos - 1
  if next_pos % glakas.columns < glakas.columns - 1 then
    player.move_to(next_pos)
  end
end

function player.move_north()
  local next_pos = player.pos - glakas.columns
  if next_pos > -1 then
    player.move_to(next_pos)
  end
end

function player.move_south()
  local next_pos = player.pos + glakas.columns
  if next_pos <= table.getn(glakas.grid) then
    player.move_to(next_pos)
  end
end
