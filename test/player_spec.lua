require '../Player'

local inspect = require("inspect")

describe("Player", function()
  local player = nil
  local player_name = "ahhsumx"

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
      assert.are.same(0, Player.num_keys(player))  
      player.backpack.keys = 8
      assert.are.same(8, Player.num_keys(player))
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
        local item = "banana"
        Player.add_item_to_backpack(player, item)
        assert.are.same(item, player.backpack.slots[1])
      end)

      it("can add two items and the 2nd one ends up first", function()
        local items = {"banana", "apple"}
        Player.add_item_to_backpack(player, items[1])
        Player.add_item_to_backpack(player, items[2])
        assert.are.same(items[2], player.backpack.slots[1])
        assert.are.same(items[1], player.backpack.slots[2])
      end)
    end) 

    describe("#drop_item_from_backpack", function()
      it("can drop an item", function()
      end)
    end)

    describe("#swap_item_from_backpack", pending())
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
  describe("#create_tool", pending())
  describe("#use_tool", pending())
  describe("#collect_wood", pending())
  describe("#collect_gem", pending())
  describe("#eat_food", pending())
  describe("#collect_food", pending())
  describe("#build_tent", pending())
  describe("#sleep", pending())
  describe("#wake_up", pending())
  describe("#log_msg", pending())
end)
