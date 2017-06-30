status_bar = {}

function status_bar.draw(x, y, w, h, val, max_val, fg_color, bg_color)
  local percent = (val / max_val)
  bg_color = bg_color or common_colors.black
  fg_color = fg_color or common_colors.white

  love.graphics.setColor(unpack(bg_color))
  love.graphics.rectangle("fill", x, y, w, h)

  love.graphics.setColor(unpack(fg_color))
  love.graphics.rectangle("fill", x + 2, y + 2, w * percent, h - 4)
end
