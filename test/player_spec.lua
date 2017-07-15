require '../Player'

describe("Player", function()
  local player = nil
  local player_name = "ahhsumx"

  require 'test/helpers/player_helper'

  before_each(function()
    player = Player.create({
      name = player_name,
      position = 1
    })
  end)

  describe("#create", function()
    it("works", function()
      assert.are.same(player_name, player.name)
    end)
  end)

  describe("#create_backpack", function()
    it("creates a backpack", function()
      assert.are.same(nil, player.backpack)

      Player.create_backpack(player)
      assert.are.same(Backpack.create(), player.backpack)
    end)
  end)

  describe("#has_backpack", function()
    it("knows if the player has a backpack", function()
      assert.is_false(Player.has_backpack(player), "player should not have backpack yet")
      Player.create_backpack(player)
      assert.is_true(Player.has_backpack(player), "player should have backpack now")
    end)
  end)

  describe("with backpack", function()
    -- fruits are intended to be some simple dummy data for adding/removing to backpack
    local fruits = {"banana", "apple", "orange", "watermelon", "cherry", "peach"}

    before_each(function()
      Player.create_backpack(player)
    end)

    describe("#upgrade_backpack", function()
      it("allows the player to upgrade the backpack", function()
        assert.is_same(Backpack.DEFAULT_PROPS.max_slots, player.backpack.max_slots)
        Player.upgrade_backpack(player, { max_slots = 1 })
        assert.is_same(Backpack.DEFAULT_PROPS.max_slots + 1, player.backpack.max_slots)
      end)
    end)

    describe("#collect_gold", function()
      it("allows the player to collect gold", function()
        local initial_gold = player.backpack.gold
        Player.collect_gold(player, 5)
        assert.are.same(initial_gold + 5, player.backpack.gold)
      end)
    end)

    describe("#num_keys", function()
      it("has no keys by default", function()
        assert.are.same(0, Player.num_keys(player)) 
      end)

      it("returns the number of keys in the backpack", function()
        player.backpack.keys = 8
        assert.are.same(8, Player.num_keys(player))
      end)
    end)

    describe("#give_key", function()
      it("gives one key by default", function()
        Player.give_key(player)
        assert.are.same(1, player.backpack.keys, "should have given 1 key by default")
      end)

      it("can give any amount of keys", function()
        Player.give_key(player, 5)
        assert.are.same(5, player.backpack.keys, "should have given 5 keys")
      end)
    end)

    describe("#create_key", function()
      it("won't create a key unless the player has enough gold", function()
        local created = Player.create_key(player)
        assert.is_false(created, "create_key should have returned false")
        assert.are.same(0, player.backpack.keys)
      end)

      it("creates a key when the player has enough gold", function()
        Player.collect_gold(player, Player.GOLD_REQS.create_key)
        local created = Player.create_key(player)
        assert.is_true(created, "create_key should have returned true")
        assert.are.same(1, player.backpack.keys, "player should now have a key in their backpack")
      end)
    end)

    describe("#use_key", function()
      it("does nothing if the player doesn't have any keys", function()
        local num_keys = Player.num_keys(player)
        Player.use_key(player)
        assert.are.same(num_keys, Player.num_keys(player))
      end)

      it("uses a key if the player has one", function()
        local amount = 77
        Player.give_key(player, amount)
        Player.use_key(player)
        assert.are.same(amount - 1, Player.num_keys(player))
      end)
    end)

    describe("#add_item_to_backpack", function()
      it("can add an item", function()
        Player.add_item_to_backpack(player, fruits[1])
        assert.are.same(fruits[1], player.backpack.slots[1])
      end)

      it("can add two items and the 2nd one ends up first", function()
        Player.add_item_to_backpack(player, fruits[1])
        Player.add_item_to_backpack(player, fruits[2])
        assert.are.same(fruits[2], player.backpack.slots[1])
        assert.are.same(fruits[1], player.backpack.slots[2])
      end)
    end) 

    describe("#remove_item_from_backpack", function()
      it("removes and returns an item", function()
        Player.add_item_to_backpack(player, fruits[1])
        assert.are.same(fruits[1], player.backpack.slots[1])
        local removed = Player.remove_item_from_backpack(player, 1)
        assert.are.same(fruits[1], removed, "removed item is not what was expected")
        assert.are.same(false, player.backpack.slots[1], "backpack slot should now be empty")
      end)
    end)

    describe("#drop_item_from_backpack", function()
      it("can drop an item", function()
        Player.add_item_to_backpack(player, fruits[1])
        Player.add_item_to_backpack(player, fruits[2])
        assert.are.same(fruits[2], Player.drop_item_from_backpack(player))
        assert.are.same(fruits[1], player.backpack.slots[1])
      end)
    end)

    describe("#swap_item_from_backpack", function()
      it("can swap an item", function()
        for i = 1, 2 do
          player.backpack.slots[i] = fruits[i]
        end

        local removed_item = Player.swap_item_from_backpack(player, fruits[3])
        assert.are.same(fruits[1], removed_item, "removed item is not what was expected")
        assert.are.same(fruits[3], player.backpack.slots[1], "new item was not swapped in to place")
      end)

      it("can swap even if the slot is empty", function()
        local removed_item = Player.swap_item_from_backpack(player, fruits[4])
        assert.are.same(false, removed_item)
        assert.are.same(fruits[4], player.backpack.slots[1])
      end)
    end)

    describe("#collect_wood", function()
      it("collects wood", function()
        local num_wood = player.backpack.wood
        Player.collect_wood(player, 1)
        assert.are.same(num_wood + 1, player.backpack.wood)
      end)
    end)

    describe("#collect_food", function()
      it("collects food", function()
        Player.collect_food(player, fruits[1])
        assert.are.same(fruits[1], player.backpack.food[1])
        assert.are.same(1, #player.backpack.food)
      end)
    end)

    describe("#eat_food", function()
      local food_item = nil

      before_each(function()
        food_item = { type = "apple", value = 1 }
      end)

      it("can not eat food without food in the backpack", function()
        assert.are.same(0, #player.backpack.food)
        local ate = Player.eat_food(player)
        assert.are.same(false, ate)
        assert.are.same(0, #player.backpack.food)
      end)

      it("can eat food", function()
        Player.collect_food(player, food_item)
        local ate = Player.eat_food(player)
        assert.are.same(food_item, ate, "didn't get expected item back")
        assert.are.same(0, #player.backpack.food, "player should have no food remaining")
      end)

      it("gains energy from food", function()
        local energy = player.energy
        Player.collect_food(player, food_item)
        Player.eat_food(player)
        assert.are.same(energy + food_item.value, player.energy, "player should have more energy now")
      end)

      it("allows the player to eat more than one food at a time", function()
        local energy = player.energy
        local amount = 3
        for i = 1, amount do
          Player.collect_food(player, food_item)
          energy = energy + food_item.value
        end

        Player.eat_food(player, amount)
        assert.are.same(energy, player.energy)
      end)
    end)

    describe("#create_tool", function()
      local wood_reqs = Player.WOOD_REQS

      describe("axe", function()
        it("can not create an axe without enough wood", function()
          local created = Player.create_tool(player, "axe")
          assert.is_false(created)
          assert.is_false(Player.has_tool(player, "axe"))
        end)

        it("can create an axe with enough wood", function()
          player.backpack.wood = wood_reqs.create_axe
          local created = Player.create_tool(player, "axe")
          assert.is_truthy(created)
          assert.is_true(Player.has_tool(player, "axe"))
        end)

        it("can not create an axe if the player already has one", function()
          give_player_tool(player, "axe")
          player.backpack.wood = wood_reqs.create_axe
          local created = Player.create_tool(player, "axe")
          assert.is_false(created)
          assert.is_true(Player.has_tool(player, "axe"))
        end)
      end)

      describe("pickaxe", function()
        it("can not create a pickaxe without enough wood", function()
          local created = Player.create_tool(player, "pickaxe")
          assert.is_false(created)
          assert.is_false(Player.has_tool(player, "pickaxe"))
        end)

        it("can create a pickaxe with enough wood", function()
          player.backpack.wood = wood_reqs.create_pickaxe
          local created = Player.create_tool(player, "pickaxe")
          assert.is_truthy(created)
          assert.is_true(Player.has_tool(player, "pickaxe"))
        end)

        it("can not create a pickaxe if the player already has one", function()
          give_player_tool(player, "pickaxe")
          player.backpack.wood = wood_reqs.create_pickaxe
          local created = Player.create_tool(player, "pickaxe")
          assert.is_false(created)
          assert.is_true(Player.has_tool(player, "pickaxe"))
        end)
      end)

      describe("shovel", function()
        it("can not create a shovel without enough wood", function()
          local created = Player.create_tool(player, "shovel")
          assert.is_false(created)
          assert.is_false(Player.has_tool(player, "shovel"))
        end)

        it("can create a shovel with enough wood", function()
          player.backpack.wood = wood_reqs.create_shovel
          local created = Player.create_tool(player, "shovel")
          assert.is_truthy(created)
          assert.is_true(Player.has_tool(player, "shovel"))
        end)

        it("can not create a shovel if the player already has one", function()
          give_player_tool(player, "shovel")
          player.backpack.wood = wood_reqs.create_shovel
          local created = Player.create_tool(player, "shovel")
          assert.is_false(created)
          assert.is_true(Player.has_tool(player, "shovel"))
        end)
      end)
    end)

    describe("#create_tent", function()
      it("can not create a tent without wood", function()
        local created = Player.create_tent(player)
        assert.is_false(created)
        assert.are.same(0, player.backpack.tents)
      end)

      it("can create a tent", function()
        player.backpack.wood = Player.WOOD_REQS.create_tent
        local created = Player.create_tent(player)
        assert.is_truthy(created)
        assert.are.same(1, player.backpack.tents)
      end)
    end)

  end) -- end 'with backpack' tests

  it("#set_position", function()
    assert.are.same(1, player.position)
    Player.set_position(player, 77)
    assert.are.same(77, player.position)
  end)

  it("#move_to", function()
    assert.are.same(1, player.position)
    Player.move_to(player, 77)
    assert.are.same(77, player.position)
  end)

  describe("#has_tool", function()
    local tools_list = {"axe", "duct tape"}
    
    before_each(function()
      for i, t in pairs(tools_list) do
        give_player_tool(player, t)
      end
    end)

    it("returns true when the player has a tool", function()
      for i, t in pairs(tools_list) do
        assert.is_true(Player.has_tool(player, t))
      end
    end)

    it("returns false when the player doesn't have a tool", function()
      assert.is_false(Player.has_tool(player, "pencil"))
    end)
  end)


  describe("#use_tool", pending())

  describe("#sleep", pending())
  describe("#wake_up", pending())
  describe("#log_msg", pending())
end)
