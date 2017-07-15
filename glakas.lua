require "colors"

glakas = {
  rows = 8,
  columns = 15,
  grid_size = 40,
  x = 40,
  y = 40,
  grid = {},
  weighted_gems_pool = {},
  total_cells = 0,
  player_steps = 0,
  rooms = {},
  num_rooms = 1,
  current_room = 0,
  room_props = {},
}

item_chance = {
  none = 0,
  very_low = .1,
  low = .25,
  medium = .5,
  high = .75,
  very_high = 1,
}

firstmap = {
  columns = 26,
  rows = 18, 
  grid_size = 34,
  num_rooms = 4,
  rooms = {},
}

firstmap.rooms[1] = {
  forests = 2,
  lakes_and_trees = 2,
  mushrooms = false,
  chests = 1,
  disguise_doors = false,
  gem_weights = {
    empty = 3,
    gold = item_chance.very_low,
    gem_blue = item_chance.medium,
    gem_green = item_chance.low,
    gem_orange = item_chance.low,
    food = item_chance.low,
    water = item_chance.very_low,
    tree = item_chance.low,
  }
}

firstmap.rooms[2] = {
  mushrooms = true,
  forests = 1,
  chests = 0,
  disguise_doors = true,
  gem_weights = {
    empty = 2,
    gold = item_chance.medium,
    gem_blue = item_chance.medium,
    gem_green = item_chance.medium,
    gem_orange = item_chance.medium,
    food = item_chance.low,
    water = item_chance.very_low,
    tree = item_chance.low,
  }
}

firstmap.rooms[3] = {
  mushrooms = true,
  forests = 1,
  streams = 3,
  chests = 0,
  disguise_doors = true,
  gem_weights = {
    empty = 2,
    gold = item_chance.medium,
    gem_blue = item_chance.medium,
    gem_green = item_chance.medium,
    gem_orange = item_chance.medium,
    food = item_chance.low,
    water = item_chance.none,
    tree = item_chance.very_low,
  }
}

firstmap.rooms[4] = {
  mushrooms = true,
  forests = 4,
  chests = 2,
  disguise_doors = true,
  gem_weights = {
    empty = 2,
    gold = item_chance.high,
    gem_blue = item_chance.low,
    gem_green = item_chance.high,
    gem_orange = item_chance.high,
    food = item_chance.low,
    water = item_chance.very_low,
    tree = item_chance.very_low,
  }
}

require("cell")

function glakas.create_map(props)
  glakas.rows = props.rows
  glakas.columns = props.columns
  glakas.grid_size = props.grid_size
  glakas.total_cells = glakas.rows * glakas.columns - 1
  glakas.num_rooms = props.num_rooms
  glakas.rooms = {}

  for f = 1, props.num_rooms do
    print("create room "..f)
    local room_props = props.rooms[f]
    local weights = nil
    if room_props.gem_weights then
      weights = room_props.gem_weights
    end
    glakas.weighted_gems_pool = gems_list(weights)

    local room = {
      room_idx = f,
      rows = glakas.rows,
      columns = glakas.columns,
      total_cells = 0,
      total_chests = props.chests,
      grid = {},
      room_props = {
        mushrooms = room_props.mushrooms or false
      },
    }

    room.total_cells = room.rows * room.columns - 1

    for i = 0, room.total_cells, 1 do
      local gem_type = random_gem(glakas.weighted_gems_pool)
      local cell = {
        idx = i,
        gem = gem_type,
        x = xpos_for(i),
        y = ypos_for(i),
        width = glakas.grid_size,
        height = glakas.grid_size,
        cell_props = glakas.cell_props_for(gem_type),
      }

      if cell.gem == "empty" then
        if math.random(15) == 2 then
          -- cell.cell_props.flowered = true
        end
      end

      room.grid[i] = cell
    end

    for i = 1, room_props.chests do
      glakas.spawn_chest(room.grid[math.random(room.total_cells)])
    end

    if room_props.lakes_and_trees and room_props.lakes_and_trees > 0 then
      glakas.create_lakes_and_trees(room_props.lakes_and_trees, room)
    elseif room_props.streams and room_props.streams > 0 then
      for i = 0, room_props.streams do
        glakas.create_stream(room, math.random(room.total_cells), math.random(4) + 4)
      end
    elseif room_props.forests > 0 then
      for i = 1, room_props.forests do
        local forest_size = math.random(2) + 1
        if math.random(13) % 3 == 0 then
          forest_size = forest_size + 1
        end
        -- make a forest that starts in the first row somewhere
        local forest_pos = math.random(room.total_cells - 12)
        glakas.create_forest(forest_size, forest_pos, room)
      end
    end


    if f < props.num_rooms then
      local random_cell_idx = math.random(room.total_cells)
      print("making door down for room "..f.." at "..random_cell_idx)
      glakas.spawn_door_down(room.grid[random_cell_idx])

      if room_props.disguise_doors then
        local disguises = { "gem_orange", "gem_blue", "gem_green", "food" }
        glakas.disguise_cell(room.grid[random_cell_idx], disguises[math.random(table.getn(disguises))])
      end
    end

    if f > 1 then
      print("making door up for room "..f)
      glakas.spawn_door_up(room.grid[math.random(room.total_cells)])
    end

    glakas.rooms[f] = room
  end
end

function glakas.go_to_room(room_idx)
  if room_idx < 1 or room_idx > glakas.num_rooms then
    print("go_to_room got room_idx out of bounds")
  end

  local room_dir = ""
  if room_idx > glakas.current_room then
    room_dir = "down"
  else
    room_dir = "up"
  end
  glakas.load_room(room_idx)

  local doors = {}
  if room_dir == "down" then
    doors = glakas.get_cells_of_type("door_up")
  else
    doors = glakas.get_cells_of_type("door_down")
  end

  if table.getn(doors) > 0 then
    player.pos = doors[1].idx
  end
end

function glakas.load_room(room_idx)
  if glakas.rooms[room_idx] then
    print("loading room "..room_idx)
    glakas.current_room = room_idx
    local room = glakas.rooms[room_idx]
    glakas.grid = room.grid
    glakas.columns = room.columns
    glakas.rows = room.rows
  else
    print("room "..room_idx.." could not be loaded")
  end
end

function glakas.get_current_room()
  return glakas.rooms[glakas.current_room]
end

function glakas.draw_map()
  love.graphics.setColor(80, 80, 80)
  love.graphics.rectangle("line", glakas.x, glakas.y, glakas.columns * glakas.grid_size, glakas.rows * glakas.grid_size)
  love.graphics.setColor(unpack(common_colors.gray))
  love.graphics.rectangle("fill", glakas.x, glakas.y, glakas.columns * glakas.grid_size, glakas.rows * glakas.grid_size)
  for i, c in pairs(glakas.grid) do
    glakas.draw_cell(c) 
  end
end

function glakas.draw_cell(cell)
  if cell.gem == nil then
    return false
  end

  love.graphics.setColor(unpack(common_colors.white))
  love.graphics.draw(gem_images.grass, cell.x + 1, cell.y + 1)

  -- give the cell a container
  if cell.idx == player.pos then
    love.graphics.setColor(255, 255, 5, 250)
    love.graphics.rectangle("line", cell.x, cell.y, cell.width, cell.height)
  else
    love.graphics.setColor(255, 255, 255, 50)
  end
  -- love.graphics.rectangle("line", cell.x, cell.y, cell.width, cell.height)

  gem.draw_gem(cell.gem, cell.x, cell.y, cell.width, cell.cell_props, cell.idx)
end

function glakas.draw_player(player)
  local xpos = xpos_for(player.pos) + glakas.grid_size / 2
  local ypos = ypos_for(player.pos) + glakas.grid_size / 2

  love.graphics.setColor(215, 215, 215, 200)
  love.graphics.circle("fill", xpos, ypos, player.size)
  love.graphics.setColor(15, 15, 15)
  love.graphics.circle("line", xpos, ypos, player.size)
end

require "world"

function glakas.increment_steps()
  glakas.player_steps = glakas.player_steps + 1

  local player_cell = glakas.player_cell()
  if glakas.cell_props(player_cell).disguised_as then
    print("cell "..player_cell.idx.." is actually a "..player_cell.gem..", but was disguised as a "..glakas.cell_props(player_cell).disguised_as)
    glakas.undisguise(player_cell.idx)
  end

  for key, val in pairs(world.step_triggers) do
    if glakas.player_steps % val == 0 then
      if world[key] then
        world[key]()
      end
    end
  end

  return false
end

