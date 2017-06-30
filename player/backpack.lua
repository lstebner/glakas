local inspect = require("inspect")

-- initialize backpack
player.backpack[0] = { type = "empty", props = {} }
player.backpack[1] = { type = "empty", props = {} }
player.backpack[2] = { type = "empty", props = {} }
player.backpack[3] = { type = "empty", props = {} }
player.backpack[4] = { type = "empty", props = {} }

function player.upgrade_backpack()
  if player.backpack_size == table.getn(player.backpack) then
    player.log_msg("you already have the largest backpack you can carry")
    return false
  end

  player.backpack_size = player.backpack_size + 1
  player.log_msg("\nbackpack can now hold "..(player.backpack_size + 1).." items!\n")
end

function player.shift_backpack_items(dir)
  dir = dir or "down"

  if dir == "down" then
    -- if the bottom-most thing in the backpack has become empty, shift everything down
    if player.backpack[0].type == "empty" then
      for i = 1, player.backpack_size do
        if player.backpack[i].type ~= "empty" then
          player.backpack[i - 1].type = player.backpack[i].type
          player.backpack[i - 1].props = player.backpack[i].props
          player.backpack[i].type = "empty"
          player.backpack[i].props = {}
        end
      end
    end
  else -- up
    if player.backpack[player.backpack_size].type == "empty" then
      for i = player.backpack_size - 1, 0, -1 do
        player.backpack[i + 1].type = player.backpack[i].type
        player.backpack[i + 1].props = player.backpack[i].prpos
        player.backpack[i].type = "empty"
        player.backpack[i].props = {}
      end
    end
  end
end

function player.swap_gem_with_backpack()
  local cell = glakas.grid[player.pos]

  if gem.can_be_moved(cell.gem) == false then
    player.log_msg("cannot pick up "..cell.gem)
    return false
  elseif cell.gem == "empty" and player.backpack[0].type == "empty" then
    return false
  end

  local cell_gem = cell.gem
  local cell_props = cell.cell_props
  player.log_msg("swapped "..player.backpack[0].type.." for "..cell.gem)
  cell.gem = player.backpack[0].type
  cell.cell_props = player.backpack[0].props
  player.backpack[0].type = cell_gem
  player.backpack[0].props = cell_props
  player.shift_backpack_items()
end

function player.place_gem_from_backpack()
  if love.timer.getTime() * 1000 < player.last_tool_time + 300 then
    return
  end

  local cell = glakas.grid[player.pos]

  if cell.gem ~= "empty" then
    return
  end

  cell.gem = player.backpack[0].type
  cell.cell_props = player.backpack[0].props
  player.log_msg("dropped "..player.backpack[0].type)
  player.backpack[0].type = "empty"
  player.backpack[0].props = {}
  player.shift_backpack_items()
end

function player.drop_item_from_backpack(item_idx, cell)
  local drop_item = player.backpack[item_idx]
  if drop_item then
    cell.gem = drop_item.type
    cell.cell_props = drop_item.props
    player.backpack[item_idx] = { type = "empty", props = {} }
  else
    print("tried to drop item "..item_idx.." from backpack but it doesn't exist")
  end
end

function player.put_item_in_backpack(item_idx, type, props)
  if player.backpack[item_idx].type ~= "empty" then
    return print("tried to put item in backpack at "..item_idx.." but something is already there")
  end
  type = type or "empty"
  props = props or {}
  print("add to backpack "..type.." || "..inspect(props))

  player.backpack[item_idx] = { type = type, props = props }
end
