require '../Tool'

describe("Tool", function()
  local tool = nil

  before_each(function()
    tool = Tool.create()
  end)

  describe("#create", function()
    it("can create a Tool", function()
      assert.is_truthy(tool)
    end)

    it("can take props", function()
      tool = Tool.create({
        match_distance = 10,
        name = "axe",
      })

      assert.are.same(10, tool.match_distance)
      assert.are.same("axe", tool.name)
    end)
  end)

  describe("#needs_repair", function()
    it("does not need repair when durability is > Tool.NEEDS_REPAIR_THRESHOLD", function()
      tool.durability = tool.max_durability
      assert.is_false(Tool.needs_repair(tool))
    end)

    it("does need repair when durability is < Tool.NEEDS_REPAIR_THRESHOLD", function()
      tool.durability = 0
      assert.is_true(Tool.needs_repair(tool))
    end)
  end)

  describe("#repair", function()
    it("can not repair past max_durability", function()
      tool.durability = tool.max_durability
      Tool.repair(tool, 100)
      assert.are.same(tool.max_durability, tool.durability)
    end)

    it("can repair an items durability", function()
      tool.durability = 1
      tool.max_durability = 10
      Tool.repair(tool, 1)
      assert.are.same(2, tool.durability)
    end)
  end)

  describe("#use", function()
    it("loses durability when it's used", function()
      tool.durability = 10
      tool.max_durability = 10
      tool.energy_cost = 1
      Tool.use(tool)
      assert.are.same(9, tool.durability)
    end)

    it("returns false when it can no longer be used", function()
      tool.durability = 1
      tool.energy_cost = 2
      local used = Tool.use(tool)
      assert.is_false(used)
    end)

    it("keeps track of times used", function()
      local times_used = tool.times_used
      tool.durability = 10
      tool.max_durability = 10
      Tool.use(tool)
      assert.are.same(times_used + 1, tool.times_used)
      Tool.use(tool)
      assert.are.same(times_used + 2, tool.times_used)
    end)
  end)

  describe("#upgrade", function()
    it("can upgrade level", function()
      Tool.upgrade(tool, "level")
      assert.are.same(2, tool.level)
    end)

    it("can upgrade durability", function()
      local d = tool.max_durability
      Tool.upgrade(tool, "max_durability", 10)
      assert.are.same(d + 10, tool.max_durability)
    end)

    it("can upgrade match_distance", function ()
      local d = tool.match_distance
      Tool.upgrade(tool, "match_distance", 1)
      assert.are.same(d + 1, tool.match_distance)
    end)
  end)
end)
