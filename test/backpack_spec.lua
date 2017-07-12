require '../Backpack'

local inspect = require("inspect")

describe("Backpack", function()
  local backpack = nil
  require 'test/helpers/backpack_helper'

  before_each(function()
    backpack = Backpack.create()
  end)

  describe("#create", function()
    it("works", function()
      assert.are.same(0, backpack.gold)
      -- all items should be false
      local false_items = {}
      for i = 1, backpack.max_slots do
        table.insert(false_items, false)
      end

      assert.are.same(false_items, backpack.slots)
    end)
  end)

  describe("#upgrade", function()
    it("can be upgraded", function()
      local max_slots = backpack.max_slots
      Backpack.upgrade(backpack, { max_slots = 1 })
      assert.are.same(max_slots + 1, backpack.max_slots)
    end)

    it("can upgrade multiple properties at once", function()
      local max_slots = backpack.max_slots
      local max_wood = backpack.max_wood
      local amount = 5
      Backpack.upgrade(backpack, { max_slots = amount, max_wood = amount } )
      assert.are.same(max_slots + amount, backpack.max_slots)
      assert.are.same(max_wood + amount, backpack.max_wood)
    end)
  end)

  describe("#get_item", function()
    it("returns false when there is no item", function()
      assert.are.same(false, Backpack.get_item(backpack, 1))
    end)

    it("returns nil when the index is out of range", function()
      assert.are.same(nil, Backpack.get_item(backpack, 0))
      assert.are.same(nil, Backpack.get_item(backpack, backpack.max_slots + 1))
    end)

    it("returns the expected item", function()
      backpack.slots[1] = "potato"
      backpack.slots[2] = "sweet potato"

      assert.are.same("potato", Backpack.get_item(backpack, 1))
      assert.are.same("sweet potato", Backpack.get_item(backpack, 2))
    end)
  end)

  it("#get_first_item", function()
    assert.are.same(false, Backpack.get_first_item(backpack))
    backpack.slots[1] = "imo"
    backpack.slots[2] = "yaki imo"
    assert.are.same("imo", Backpack.get_first_item(backpack))
  end)

  it("#get_last_item", function()
    assert.are.same(false, Backpack.get_last_item(backpack))
    backpack.slots[1] = "imo"
    backpack.slots[backpack.max_slots] = "yaki imo"
    assert.are.same("yaki imo", Backpack.get_last_item(backpack))
  end)

  describe("#get_items", function()
    it("returns all items", function()
      local add_items = { "carrot", "potato", "mushroom" }
      for k, v in pairs(add_items) do
        Backpack.add_item(backpack, v)
      end

      assert.are.same({"mushroom", "potato", "carrot"}, Backpack.get_items(backpack))
    end)

    it("returns only slots with items", function()
      Backpack.add_item(backpack, "carrot")
      assert.are.same({"carrot"}, Backpack.get_items(backpack))
    end)
  end)

  it("#num_items", function()
    assert.are.same(0, Backpack.num_items(backpack))

    Backpack.add_item(backpack, "fish")
    assert.are.same(1, Backpack.num_items(backpack))

    for i = 1, backpack.max_slots do
      Backpack.add_item(backpack, "fish")
    end

    assert.are.same(backpack.max_slots, Backpack.num_items(backpack))
  end)

  it("#num_slots", function()
    assert.are.same(Backpack.DEFAULT_PROPS.max_slots, Backpack.num_slots(backpack))    
  end)

  it("#num_empty_slots", function()
    assert.are.same(Backpack.DEFAULT_PROPS.max_slots, Backpack.num_empty_slots(backpack))
    Backpack.add_item(backpack, "corn")
    assert.are.same(Backpack.DEFAULT_PROPS.max_slots - 1, Backpack.num_empty_slots(backpack))
    for i = 1, Backpack.DEFAULT_PROPS.max_slots do
      Backpack.add_item(backpack, "corn")
    end
    assert.are.same(0, Backpack.num_empty_slots(backpack))
  end)

  describe("#add_item", function()
    local items = {"apple", "grapes", "banana"}

    it("should always add items to the first slot", function()
      Backpack.add_item(backpack, items[1])
      assert.are.same(items[1], backpack.slots[1])
      Backpack.add_item(backpack, items[2])
      assert.are.same(items[2], backpack.slots[1])
    end)

    it("can't add items when already full", function()
      for i = 1, backpack.max_slots do
        Backpack.add_item(backpack, items[i])
      end

      assert.are.same(false, Backpack.add_item(backpack, "eggs"))
    end)
  end)

  describe("#is_full", function()
    it("is empty by default", function()
      assert.are.same(false, Backpack.is_full(backpack))
    end)

    it("is not full with less than the max items", function()
      Backpack.add_item(backpack, "fries")
      assert.are.same(false, Backpack.is_full(backpack))
    end)

    it("knows when it is filled up", function()
      for i = 1, backpack.max_slots do
        Backpack.add_item(backpack, "corn")
      end
      assert.are.same(true, Backpack.is_full(backpack))
    end)
  end)

  describe("#shift_slots", function()
    local items = {"apples", "carrots", "mangos"}

    it("can shift items down", function()
      fill_backpack(backpack, {false, items[1], items[2]})

      Backpack.shift_slots(backpack, "down")

      assert.are.same(items[1], backpack.slots[1])
      assert.are.same(items[2], backpack.slots[2])
      assert.are.same(false, backpack.slots[3])
    end)

    it("can shift down when only the middle is empty", function()
      fill_backpack(backpack, {items[1], false, items[3]})
      Backpack.shift_slots(backpack, "down")
      assert.are.same(items[1], backpack.slots[1])
      assert.are.same(items[3], backpack.slots[2])
      assert.are.same(false, backpack.slots[3])
    end)

    it("can shift items up", function()
      fill_backpack(backpack, {items[1], items[2], false})

      Backpack.shift_slots(backpack, "up")

      assert.are.same(false, backpack.slots[1])
      assert.are.same(items[1], backpack.slots[2])
      assert.are.same(items[2], backpack.slots[3])
    end)

    it("won't shift when backpack is full", function()
      fill_backpack(backpack)
      assert.are.same(false, Backpack.shift_slots(backpack, "up"))
      assert.are.same(false, Backpack.shift_slots(backpack, "down"))
    end)
  end)

  describe("#remove_item", function()
    it("can remove an item", function()
      backpack.slots[1] = "apple"
      local removed_item = Backpack.remove_item(backpack, 1)
      assert.are.same("apple", removed_item)
      assert.are.same(false, backpack.slots[1])
    end)

    it("shifts other items after something is removed", function()
      backpack.slots[1] = "apple"
      backpack.slots[2] = "banana"
      local removed_item = Backpack.remove_item(backpack, 1)
      assert.are.same("apple", removed_item)
      assert.are.same("banana", backpack.slots[1])
      assert.are.same(false, backpack.slots[2])
    end)

    it("can remove from any index", function()
      fill_backpack(backpack, {"apple", "banana", "carrots"})
      local removed_item = Backpack.remove_item(backpack, 3)
      assert.are.same(removed_item, "carrots")
      assert.are.same(false, backpack.slots[3])
    end)
  end)

  describe("#swap_item", function()
    it("can swap out an item", function()
      fill_backpack(backpack, {"apple", "banana", "carrots"})
      local removed_item = Backpack.swap_item(backpack, 1, "watermelon")
      assert.are.same("watermelon", backpack.slots[1], "expected backpack to contain the new item")
      assert.are.same("apple", removed_item, "removed item is an unexpected item")
    end)
  end)

  it("#add_gold", function()
    local num_gold = backpack.gold
    local add_amount = 99
    Backpack.add_gold(backpack, add_amount)
    assert.are.same(num_gold + add_amount, backpack.gold)
  end)

  describe("#remove_gold", function()
    it("can remove gold", function()
      Backpack.add_gold(backpack, 100)
      local num_gold = backpack.gold
      local remove_amount = 10
      Backpack.remove_gold(backpack, remove_amount)
      assert.are.same(num_gold - remove_amount, backpack.gold)
    end)

    it("does not allow gold to go negative", function()
      Backpack.add_gold(backpack, 1)
      Backpack.remove_gold(backpack, backpack.max_gold)
      assert.is_true(backpack.gold > -1, "gold should not be negative")
    end)
  end)

  describe("#add_food", function()
    it("can add food", function()
      local num_food = #backpack.food
      local add_foods = list_of_foods()
      local added = Backpack.add_food(backpack, add_foods)
      assert.are.same(add_foods[1], backpack.food[1])
      assert.are.same(num_food + #add_foods, #backpack.food)
      assert.are.same(true, added)
    end)

    it("can not add more than max_food", function()
      local add_foods = list_of_foods(backpack.max_food * 2)
      Backpack.add_food(backpack, add_foods)
      assert.are.same(backpack.max_food, #backpack.food)
    end)

    it("returns false if no more food can fit", function()
      local add_foods = list_of_foods(backpack.max_food)
      Backpack.add_food(backpack, add_foods)
      assert.are.same(false, Backpack.add_food(backpack, list_of_foods(1)))
    end)

    it("returns the food that could not be added", function()
      local add_foods = list_of_foods(backpack.max_food - 1)
      Backpack.add_food(backpack, add_foods)
      local add_more_foods = list_of_foods(backpack.max_food)
      local leftovers = Backpack.add_food(backpack, add_more_foods)
      assert.are.same(#leftovers, backpack.max_food - 1)
      assert.are.same(#backpack.food, backpack.max_food)
    end)

    it("won't add any if all_or_nothing", function()
      local num_food = backpack.max_food - 2
      local add_foods = list_of_foods(num_food)
      Backpack.add_food(backpack, add_foods)
      local add_more_foods = list_of_foods(backpack.max_food)
      local added = Backpack.add_food(backpack, add_more_foods, true)
      assert.are.same(false, added, "add_food should have returned false")
      assert.are.same(num_food, #backpack.food, "backpack should still have "..num_food.." food in it")
    end)
  end)

  describe("#remove_food", function()
    it("can remove food", function()
      local add_foods = list_of_foods(backpack.max_food)
      Backpack.add_food(backpack, add_foods)
      local num_food = #backpack.food
      local removed_food = Backpack.remove_food(backpack, 1)
      assert.are.same(num_food - 1, #backpack.food)
      assert.are.same(removed_food, add_foods[#add_foods])
    end)

    it("returns false for an invalid index", function()
      local add_foods = list_of_foods(1)
      Backpack.add_food(backpack, add_foods)
      assert.is_false(Backpack.remove_food(backpack, 5), "expected false for empty index")
      assert.is_false(Backpack.remove_food(backpack, -1), "expected false for -1")
      assert.is_false(Backpack.remove_food(backpack, 10), "expected false for out of bounds index")
    end)
  end)

  describe("#add_key", function()
    it("can add a key", function()
      local num_keys = backpack.keys
      Backpack.add_key(backpack)
      assert.are.same(num_keys + 1, backpack.keys)
    end)

    it("can add more than one key", function()
      local num_keys = backpack.keys
      Backpack.add_key(backpack, 2)
      assert.are.same(num_keys + 2, backpack.keys)
    end)
  end)

  describe("#remove_key", function()
    it("can remove a key", function()
      Backpack.add_key(backpack, 5)
      local num_keys = backpack.keys
      Backpack.remove_key(backpack, 1)
      assert.are.same(num_keys - 1, backpack.keys)
    end)

    it("does not allow keys to go negative", function()
      Backpack.add_key(backpack, 1)
      Backpack.remove_key(backpack, 99)
      assert.is_true(backpack.keys > -1, "keys should not be negative")
    end)
  end)

  describe("#add_wood", function()
    it("can add wood", function()
      local num_wood = backpack.wood
      local amount = 5
      Backpack.add_wood(backpack, amount)
      assert.are.same(backpack.wood, num_wood + amount)
    end)

    it("can not add more than max_wood allows", function()
      Backpack.add_wood(backpack, backpack.max_wood * 100)
      assert.are.same(backpack.wood, backpack.max_wood)
    end)

    it("can add partial amounts and return the leftovers when adding too much wood", function()
      local extra = Backpack.add_wood(backpack, backpack.max_wood + 1, false)
      assert.are.same(1, extra)
    end)
  end)

  describe("#remove_wood", function()
    it("can remove wood", function()
      backpack.wood = backpack.max_wood
      Backpack.remove_wood(backpack, 1)
      assert.are.same(backpack.max_wood - 1, backpack.wood)
    end)

    it("can not remove more wood than it has", function()
      backpack.wood = 1
      local num_removed = Backpack.remove_wood(backpack, 2)
      assert.are.same(1, num_removed)
      assert.are.same(0, backpack.wood)
    end)
  end)
end)
