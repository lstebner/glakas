local inspect = require("inspect")

require("status_bar")

function player.draw_log()
  love.graphics.setColor(unpack(common_colors.white))

  local num_logs = table.getn(player.log)

  if num_logs == 0 then
    return
  end

  local x = love.graphics.getWidth() - 230
  local y = 40
  local log_string = ""

  for i = math.max(num_logs - 15, 1), num_logs do
    log_string = log_string.."\n"..player.log[i]
  end

  love.graphics.printf(log_string, x, y, 200)
end

function player.draw_backpack(x_offset, y_offset)
  x_offset = x_offset or 0
  y_offset = y_offset or 0

  for i = 0, player.backpack_size do
    gem.draw_gem(player.backpack[i].type, x_offset, y_offset + (40 * i), 20)
  end
end

function player.draw_hud(x_offset, y_offset)
  x_offset = x_offset or 40
  y_offset = y_offset or 20

  love.graphics.setColor(unpack(common_colors.white))
  love.graphics.print("energy", x_offset, y_offset)
  local fg_color = nil
  if player.energy < 8 then
    fg_color = common_colors.red
  end
  status_bar.draw(x_offset + 50, y_offset + 3, 50, 10, player.energy, player.max_energy, fg_color)

  love.graphics.setColor(unpack(common_colors.white))
  love.graphics.print("pos "..player.pos, love.graphics.getWidth() - 140, 8)
  love.graphics.print("standing on "..glakas.grid[player.pos].gem, love.graphics.getWidth() - 200, 20)
  love.graphics.print("room "..glakas.current_room, love.graphics.getWidth() - 200, 8)

  if player.has_axe > 0 then
    love.graphics.print("axe:", x_offset)
    status_bar.draw(x_offset + 30, 3, 40, 10, player.axe, player.axe_max_repair)
  end

  if player.has_pickaxe > 0 then
    love.graphics.print("pickaxe:", x_offset + 100)
    status_bar.draw(x_offset + 180, 3, 40, 10, player.pickaxe, player.pickaxe_max_repair)
  end

  love.graphics.setColor(unpack(gem_colors.gold))
  love.graphics.print(player.gold, x_offset + 160, y_offset)

  love.graphics.setColor(unpack(gem_colors.tree))
  love.graphics.print(player.wood, x_offset + 200, y_offset)

  love.graphics.setColor(unpack(gem_colors.gem_orange))
  love.graphics.print("gems: "..player.gems_destroyed, x_offset + 250)
end
