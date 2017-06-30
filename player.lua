
local inspect = require("inspect")

player = {
  pos = 1,
  floor = 1,
  gold = 0,
  backpack = {},
  backpack_size = 2,
  energy = 20,
  max_energy = 75,
  last_move_time = -500,
  last_tool_time = -1000,
  num_steps = 0,
  size = 6,
  pickaxe = 0,
  pickaxe_max_repair = 30,
  has_pickaxe = 0,
  axe = 0,
  axe_max_repair = 12,
  has_axe = 0,
  shovel = 0,
  has_shovel = 0,
  gems_destroyed = 0,
  wood = 0,
  keys = 0,
  log = {},
  mushrooms = 0,
  tents_built = 0,
}

player.energy_reqs = {
  pickaxe = 1,
  axe = 1,
  hand = 1,
  shovel = 1,
}

wood_reqs = {
  create_axe = 3,
  create_pickaxe = 4,
  create_shovel = 3,
  build_tent = 10,
}

energy_vals = {
  food = 4,
  mushrooms = 6,
}

gold_reqs = {
  key = 10
}

one_time_alerts.create_axe = 0
one_time_alerts.mine_gold = 0

require("player.backpack")
require("player.movement")
require("player.tools")
require("player.render")

function player.use_energy(how_much)
  how_much = how_much or 0
  player.energy = player.energy - how_much
end

function player.eat_food(cell)
  if cell.gem ~= "food" then
    return false
  end

  if player.energy >= player.max_energy then
    return player.log_msg("you can't eat any more, you're stuffed!")
  end

  player.log_msg "\nyum! energy restored"
  player.energy = player.energy + energy_vals.food
  glakas.empty_cell(cell)
end

function player.pick_up_gem()
  if love.timer.getTime() * 1000 < player.last_tool_time + 300 then
    return
  end

  player.last_tool_time = love.timer.getTime() * 1000

  local cell = glakas.grid[player.pos]

  if gem.can_be_moved(cell.gem) == false then
    player.log_msg("\ncannot pick up "..cell.gem)
    return false
  end
  
  if cell.gem == "empty" then
    return false
  elseif cell.gem == "food" then
    return player.eat_food(cell)
  end

  local cell_gem = cell.gem
  local cell_props = cell.cell_props
  glakas.empty_cell(cell)

  -- backpack is full
  if player.backpack[player.backpack_size] ~= "empty" then
    player.log_msg("dropped "..player.backpack[player.backpack_size].type)
    player.drop_item_from_backpack(player.backpack_size, cell)
  end

  if player.backpack[0].type ~= "empty" then
    player.shift_backpack_items("up")
  end

  player.log_msg("picked up "..cell_gem)
  player.put_item_in_backpack(0, cell_gem, cell_props)
end

function player.collect_mushrooms()
  local cell = glakas.grid[player.pos]

  if cell.gem ~= "mushrooms" then
    return false
  end

  player.mushrooms = player.mushrooms + 1
  player.energy = player.energy + energy_vals.mushrooms
  player.log_msg("you collect some mushrooms. these would make a tasty soup...")
  glakas.empty_cell(cell)
end

function player.gem_destroyed(gem)
  player.gems_destroyed = player.gems_destroyed + 1
end

function player.collect_wood(how_much)
  how_much = how_much or 1
  player.wood = player.wood + how_much

  if player.has_axe < 1 and player.wood >= wood_reqs.create_axe then
    player.log_msg "\nyou have enough wood to create an axe!"
    player.log_msg "press 'a' to create an axe"
  elseif player.has_pickaxe < 1 and player.wood >= wood_reqs.create_pickaxe then
    player.log_msg "\nyou have enough wood to create a pickaxe!"
    player.log_msg "press 's' to create a pickaxe"
  end
end

function player.collect_gold(how_much)
  if player.gold == 0 and one_time_alerts.mine_gold == 0 then
    player.log_msg("\nmine gold to buy keys and backpack upgrades!")
    player.log_msg("keys cost 10 gold")
    player.log_msg("backpack upgrades cost 50 gold")
  end

  player.log_msg(how_much.." gold collected")
  player.gold = player.gold + how_much
end

function player.create_key()
  if player.gold < gold_reqs.key then
    player.log_msg("not enough gold to create a key")
    return false
  else
    player.log_msg("key created")
  end

  player.gold = player.gold - gold_reqs.key
  player.keys = player.keys + 1
end

function player.open_chest(cell)
  if player.keys < 1 and player.gold < gold_reqs.key then
    player.log_msg "not enough keys to open chest!"
    return false
  else
    player.log_msg "you smelt a key out of some gold you're carrying to create a key to open the chest"
    player.create_key()
  end

  player.log_msg "\nplayer opens chest...\nbut nothing happens"
  -- todo: create chests 
  glakas.empty_cell(cell)
end

function player.log_msg(msg)
  table.insert(player.log, msg)
end

function player.open_door()
  print "open door"
  local cell = glakas.player_cell()

  if cell.gem == "door_down" then
    glakas.go_to_room(glakas.current_room + 1)
  elseif cell.gem == "door_up" then
    glakas.go_to_room(glakas.current_room - 1)
  end
end

function player.build_tent()
  if player.wood < wood_reqs.build_tent then
    return player.log_msg("you don't have enough wood to build a tent!")
  else
    player.log_msg("you build a tent and take a short nap to re-energize")
  end

  player.tents_built = player.tents_built + 1
  player.wood = player.wood - wood_reqs.build_tent
  player.energy = player.energy + math.ceil(player.energy * .3)
  -- todo: make player change state to napping and actually wait some period of time
  player.log_msg("\nyou finish your nap and feel re-energized! back to work now")
end



