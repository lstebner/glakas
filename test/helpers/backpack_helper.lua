function fill_backpack(backpack, items)
  items = items or {}
  
  for i = 1, backpack.max_slots do
    local item = nil
    if i <= #items then
      item = items[i]
    else
      item = "basic item"
    end
    backpack.slots[i] = item
  end
end

function list_of_foods(how_many)
  local foods = {}
  how_many = how_many or 1

  for i = 1, how_many do
    table.insert(foods, "apple")
  end

  return foods
end
