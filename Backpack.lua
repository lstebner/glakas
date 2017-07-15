require "copy"

Backpack = {}

Backpack.DEFAULT_PROPS = {
  max_slots = 3, 
  max_wood = 100,
  max_food = 5,
}

function Backpack.create(props)
  props = props or {}

  local backpack = {
    gold = 0,
    wood = 0,
    keys = 0,
    tents = 0,
    food = {},
    slots = {},
  }

  for i, prps in pairs({Backpack.DEFAULT_PROPS, props}) do
    for k, v in pairs(prps) do
      backpack[k] = v
    end
  end

  for i = 1, backpack.max_slots do
    backpack.slots[i] = false
  end

  return backpack
end

function Backpack.upgrade(backpack, props)
  for k, v in pairs(props) do
    if backpack[k] then
      backpack[k] = backpack[k] + v
    end
  end
end

function Backpack.get_item(backpack, slot_idx)
  if slot_idx < 1 or slot_idx > backpack.max_slots then
    return nil
  end

  return backpack.slots[slot_idx]
end

function Backpack.get_items(backpack)
  local items = {}
  for k, v in pairs(backpack.slots) do
    if v then
      table.insert(items, v)
    end
  end

  return items
end

function Backpack.num_items(backpack)
  local count = 0
  for k, v in pairs(backpack.slots) do
    if v then
      count = count + 1
    end
  end

  return count
end

function Backpack.get_first_item(backpack)
  return Backpack.get_item(backpack, 1)
end

function Backpack.get_last_item(backpack)
  return Backpack.get_item(backpack, backpack.max_slots)
end

function Backpack.is_full(backpack)
  local is_full = true
  for i = 1, backpack.max_slots do
    if backpack.slots[i] == false then
      is_full = false
      break
    end
  end

  return is_full
end

function Backpack.add_item(backpack, item)
  if Backpack.is_full(backpack) then
    -- print("backpack has no room for more items!")
    return false
  end

  if backpack.slots[1] ~= false then
    Backpack.shift_slots(backpack, "up")
  end

  if backpack.slots[1] == false then
    backpack.slots[1] = item
  end
end

function Backpack.remove_item(backpack, item_idx)
  local removed_item = false

  if backpack.slots[item_idx] then
    removed_item = deepcopy(backpack.slots[item_idx])
    backpack.slots[item_idx] = false
    Backpack.shift_slots(backpack, "down")
  end

  return removed_item
end

function Backpack.swap_item(backpack, item_idx, new_item)
  if item_idx < 1 or item_idx > backpack.max_slots then
    return false
  end
  
  local removed_item = false

  if backpack.slots[item_idx] then
    removed_item = backpack.slots[item_idx]
  end

  backpack.slots[item_idx] = new_item

  return removed_item
end

function Backpack.shift_slots(backpack, dir)
  -- at least one slot must be open (top or bottommost) to shift items
  if Backpack.is_full(backpack) then
    return false
  end

  dir = dir or "down"

  -- if the bottom-most thing in the backpack has become empty, shift everything down
  -- 3 becomes 2, 2 becomes 1
  if dir == "down" then
    for i = 2, backpack.max_slots do
      if backpack.slots[i] and backpack.slots[i - 1] == false then
        backpack.slots[i - 1] = deepcopy(backpack.slots[i])
        backpack.slots[i] = false
      end
      end
  -- up
  -- 1 becomes 2, 2 becomes 3
  else 
    for i = backpack.max_slots - 1, 1, -1 do
      if backpack.slots[i] then
        backpack.slots[i + 1] = deepcopy(backpack.slots[i])
        backpack.slots[i] = false
      end
    end
  end
end

function Backpack.add_gold(backpack, amount)
  backpack.gold = backpack.gold + amount
end

function Backpack.remove_gold(backpack, amount)
  amount = amount or 1
  backpack.gold = math.max(0, backpack.gold - amount)
end

function Backpack.add_key(backpack, amount)
  amount = amount or 1
  backpack.keys = backpack.keys + amount
end

function Backpack.remove_key(backpack, amount)
  amount = amount or 1
  backpack.keys = math.max(0, backpack.keys - amount) 
end

function Backpack.add_food(backpack, items, all_or_nothing)
  if #backpack.food == backpack.max_food or #items == 0 then
    return false
  end
  local inspect = require("inspect")

  local amount = #backpack.food
  local add_amount = #items
  local leftovers = {}
  all_or_nothing = all_or_nothing or false

  if amount + add_amount < backpack.max_food then
    for k, v in pairs(items) do
      table.insert(backpack.food, deepcopy(v))
    end

    return true
  elseif add_amount == 1 or all_or_nothing then
    return false
  else -- add as much as possible, return leftovers
    local can_fit = backpack.max_food - amount
    for k, v in pairs(items) do
      if k <= can_fit then
        table.insert(backpack.food, deepcopy(v))
      else
        table.insert(leftovers, v)
      end
    end

    return leftovers
  end
end

function Backpack.remove_food(backpack, food_idx)
  if food_idx < 1 or food_idx > #backpack.food then
    return false
  end

  local remove_item = backpack.food[food_idx]
  table.remove(backpack.food, food_idx)

  return remove_item
end

function Backpack.num_slots(backpack)
  return backpack.max_slots
end

function Backpack.num_empty_slots(backpack)
  local count = 0
  for k, v in pairs(backpack.slots) do
    if v == false then
      count = count + 1
    end
  end

  return count
end

function Backpack.add_wood(backpack, add_amount, all_or_nothing)
  if backpack.wood == backpack.max_wood or add_amount < 1 then
    return false
  end

  all_or_nothing = all_or_nothing or false

  local inspect = require("inspect")

  if backpack.wood + add_amount < backpack.max_wood then
    backpack.wood = backpack.wood + add_amount

    return true
  elseif add_amount == 1 or all_or_nothing then
    return false
  else 
    local can_fit = backpack.max_wood - backpack.wood
    backpack.wood = backpack.max_wood

    return add_amount - can_fit --leftover amount
  end
end

function Backpack.remove_wood(backpack, remove_amount)
  local num_wood = backpack.wood
  backpack.wood = math.max(0, backpack.wood - remove_amount)
  return math.max(0, num_wood - backpack.wood)
end

function Backpack.add_tent(backpack, amount)
  amount = amount or 1
  backpack.tents = backpack.tents + amount
end

function Backpack.remove_tent(backpack, amount)
  amount = amount or 1
  backpack.tents = math.max(0, backpack.tents - amount)
end
