gem = {}

gem_types = { "gold", "food", "empty", "gem_orange", "gem_blue", "gem_green", "tree", "water" }

unmoveable_gem_types = { "chest", "door_up", "door_down", "tree_sapling" }

require "colors"

gem_weights = {
  empty = 1,
  gold = .6,
  gem_blue = 1,
  gem_green = 1,
  gem_orange = 1,
  food = .5,
  -- stone = .5,
  water = .5,
  tree = .1,
  mushrooms = .01,
}

gem_images = {}

function gem.load_images()
  gem_images = {
    gem = love.graphics.newImage("images/gems/gem2.png"),
    gem2 = love.graphics.newImage("images/gems/gem3.png"),
    tree = love.graphics.newImage("images/gems/tree.png"),
    tree_fruited = love.graphics.newImage("images/gems/tree_fruited.png"),
    tree_sapling = love.graphics.newImage("images/gems/tree_sapling.png"),
    gold = love.graphics.newImage("images/gems/gold2.png"),
    stone = love.graphics.newImage("images/gems/stone.png"),
    food = love.graphics.newImage("images/gems/food.png"),
    water = love.graphics.newImage("images/gems/water.png"),
    door_up = love.graphics.newImage("images/gems/stairs_up.png"),
    door_down = love.graphics.newImage("images/gems/stairs_down.png"),
    mushrooms = love.graphics.newImage("images/gems/mushrooms.png"),
    grass = love.graphics.newImage("images/gems/grass2.png"),
    chest = love.graphics.newImage("images/gems/chest.png"),
    flowers = love.graphics.newImage("images/gems/flowers.png"),
  }
end

function gems_list(weights)
  weights = weights or gem_weights

  local gems = {}
  local sample_size = 100

  for gtype, weight in pairs(weights) do
    for i=1, (sample_size * weight) do
      table.insert(gems, gtype)
    end
  end

  return gems
end

function random_gem(gems)
  if (gems) then
    return gems[math.random(table.getn(gems))]
  else
    return gem_types[math.random(table.getn(gem_types))]
  end
end

function gem.draw_gem(g, x, y, width_or_rad, props, cell_id)
  props = props or {}

  if props.disguised_as then
    g = props.disguised_as
  end

  love.graphics.setColor(unpack(gem.get_color_for(g)))

  if string.match(g, "gem_") then
    if cell_id and cell_id % 3 == 0 then
      love.graphics.draw(gem_images.gem, x + 1, y + 1)
    else
      love.graphics.draw(gem_images.gem2, x + 1, y + 1)
    end
  elseif g == "food" then
    love.graphics.draw(gem_images.food, x + 7, y + 7)
  elseif g == "empty" then
    if props.flowered then
      rotation = 0
      if cell_id % 2 == 0 then
        rotation = math.pi / 2
      elseif cell_id % 3 == 0 then
        rotation = math.pi / 2 * -1
      end
      love.graphics.draw(gem_images.flowers, x + 17, y + 17, rotation, 1, 1, 16, 16)
    end
  elseif gem_images[g] then
    if g == "tree" and props.fruited then
      love.graphics.draw(gem_images.tree_fruited, x + 4, y + 4)
    else
      love.graphics.draw(gem_images[g], x + 1, y + 1)
    end
  else
    gem_size = width_or_rad * .3 -- 9 
    love.graphics.circle("fill", x + width_or_rad / 2, y + width_or_rad / 2, gem_size)
  end
end

function gem.get_color_for(g)
  return gem_colors[g] or gem_colors["default"]
end

function gem.can_be_moved(type)
  for i, gtype in pairs(unmoveable_gem_types) do
    if gtype == type then
      return false
    end
  end

  return true
end


