Player = {}

require "Backpack"
require "Tool"
require "State"

Player.DEFAULT_PROPS = {
  name = "hero",
  position = 1,
  energy = 30,
  max_energy = 60,
  size = 6,
}

Player.ENERGY_REQS = {
  pickaxe = 1,
  axe = 1,
  shovel = 1,
  hand = .5, 
}

Player.WOOD_REQS = {
  create_axe = 4,
  create_pickaxe = 5,
  create_shovel = 4,
  create_tent = 8,
}

Player.GOLD_REQS = {
  create_key = 9,
}

Player.STATES = {
  standing = 1,
  sleeping = 2,
}

Player.DEFAULT_STATE = Player.STATES.standing

function Player.create(props)
  props = props or {}

  local new_player = {
    cur_map_idx = 0,
    backpack = nil,
    last_move_time = 0,
    last_tool_time = 0,
    num_tents_built = 0,
    num_steps = 0,
    tools = {},
    msg_log = {},
    state = State.create({ current_state = Player.DEFAULT_STATE }),
  }

  for i, prps in pairs({Player.DEFAULT_PROPS, props}) do
    for k, v in pairs(prps) do
      new_player[k] = v
    end
  end

  return new_player
end

function Player.create_backpack(player)
  player.backpack = Backpack.create()
end

function Player.upgrade_backpack(player, upgrades)
  Backpack.upgrade(player.backpack, upgrades)
end

function Player.collect_gold(player, amount)
  amount = amount or 1
  if player.backpack == nil then
    return false
  end

  Backpack.add_gold(player.backpack, amount)
end

function Player.has_backpack(player)
  return player.backpack ~= nil
end

function Player.num_keys(player)
  if Player.has_backpack(player) then
    return player.backpack.keys
  end

  return 0
end

function Player.give_key(player, amount)
  amount = amount or 1

  if Player.has_backpack(player) then
    Backpack.add_key(player.backpack, amount)
  end

  return false
end

function Player.create_key(player)
  if Player.has_backpack(player) then
    if player.backpack.gold >= Player.GOLD_REQS.create_key then
      Backpack.remove_gold(player.backpack, Player.GOLD_REQS.create_key)  
      Backpack.add_key(player.backpack, 1)
      return true
    end
  end

  return false
end

function Player.use_key(player, amount)
  amount = amount or 1

  if amount > 0 and Player.num_keys(player) >= amount then
    player.backpack.keys = player.backpack.keys - amount
  end

  return false
end

function Player.set_position(player, pos)
  player.position = pos
end

function Player.move_to(player, pos)
  player.position = pos
end

function Player.add_item_to_backpack(player, item)
  if Player.has_backpack(player) then
    Backpack.add_item(player.backpack, item)
    return true
  end

  return false
end

function Player.remove_item_from_backpack(player, item_idx)
  item_idx = item_idx or 1
  if Player.has_backpack(player) then
    return Backpack.remove_item(player.backpack, item_idx)
  end

  return false
end

function Player.drop_item_from_backpack(player)
  if Player.has_backpack(player) then
    return Player.remove_item_from_backpack(player, 1)
  end

  return false
end

function Player.swap_item_from_backpack(player, new_item)
  if Player.has_backpack(player) then
    return Backpack.swap_item(player.backpack, 1, new_item)
  end

  return false
end

function Player.collect_food(player, food_item)
  if Player.has_backpack(player) then
    return Backpack.add_food(player.backpack, {food_item}, true)
  end
end

function Player.eat_food(player, amount)
  amount = amount or 1

  if Player.has_backpack(player) then
    local food_item = Backpack.remove_food(player.backpack, 1)

    if food_item then
      local energy = food_item.energy or 1
      Player.give_energy(player, energy)

      if amount > 1 then
        Player.eat_food(player, amount - 1)
      else
        return food_item
      end
    end
  end

  return false
end

function Player.collect_wood(player, amount)
  if Player.has_backpack(player) then
    Backpack.add_wood(player.backpack, amount)
  end
end

function Player.create_tool(player, tool_name)
  if Player.has_backpack(player) == false or Player.has_tool(player, tool_name) then
    return false
  end

  local key = "create_"..tool_name
  local wood_req = Player.WOOD_REQS[key]

  if wood_req and player.backpack.wood >= wood_req then
    Backpack.remove_wood(player.backpack, wood_req)
    local new_tool = Tool.create({ name = tool_name })
    table.insert(player.tools, new_tool)

    return new_tool
  end

  return false
end

function Player.has_tool(player, tool_name)
  for i, tool in pairs(player.tools) do
    if tool.name and tool.name == tool_name then
      return true
    end
  end

  return false
end

function Player.create_tent(player)
  if Player.has_backpack(player) then
    if player.backpack.wood >= Player.WOOD_REQS.create_tent then
      Backpack.add_tent(player.backpack)
      Backpack.remove_wood(player.backpack, Player.WOOD_REQS.create_tent)
      player.num_tents_built = player.num_tents_built + 1
      return true
    end
  end

  return false
end

function Player.open_chest(player, chest)
  local got_items = false

  if Player.has_backpack(player) then
    if player.backpack.keys >= chest.cell_props.num_locks then
      Backpack.remove_key(player.backpack, chest.cell_props.num_locks)
      got_items = shallowcopy(chest.cell_props.stored_items)
      chest.cell_props.stored_items = {}
    end
  end

  return got_items
end

function Player.log_msg(player, msg)
  if msg then
    if type(msg) == "table" then
      for i, m in pairs(msg) do
        table.insert(player.msg_log, m)
      end
    else
      table.insert(player.msg_log, msg)
    end
  end
end

function Player.update(player)
  State.update(player.state)
end

function Player.go_to_sleep(player)
  local inspect = require 'helpers/inspect'
  if Player.has_backpack(player) then
    if player.backpack.tents > 0 then
      Backpack.remove_tent(player.backpack, 1)
      State.change_state(player.state, Player.STATES.sleeping)
    end
  end

  return false
end

function Player.give_energy(player, amount)
  amount = amount or 1
  Player.set_energy(player, player.energy + amount)
end

function Player.take_energy(player, amount)
  amount = amount or 1
  Player.set_energy(player, player.energy - amount)
end

function Player.set_energy(player, amount)
  player.energy = math.min(player.max_energy, math.max(0, amount))
end

function Player.upgrade_max_energy(player, new_limit)
  player.max_energy = math.max(1, new_limit)
end

function Player.wake_up(player, next_state)
  next_state = next_state or Player.DEFAULT_STATE

  if player.state.current_state == Player.STATES.sleeping then
    State.change_state(player.state, next_state)
    Player.give_energy(player, player.max_energy * .35)
  end
end






