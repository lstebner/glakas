one_time_alerts = {}

require("coords")
require("glakas")
require("player")
require("gem")

function love.load()
  math.randomseed(os.time())

  gem.load_images()
  glakas.create_map(firstmap)
  glakas.load_room(1)
  player.pos = glakas.get_cells_of_type("tree")[1].idx

  player.log_msg "collect wood to create an Axe and Pickaxe"
  player.log_msg "press 'space' on trees to collect wood"
end

function love.update(dt)
  handle_input(dt)
end

function love.draw(dt)
  love.graphics.setBackgroundColor(unpack(common_colors.charcoal))

  glakas.draw_map()
  glakas.draw_player(player)
  player.draw_backpack()
  player.draw_hud()
  player.draw_log()
end

require "input"

