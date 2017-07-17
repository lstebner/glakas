require '../Tool'

describe("Tool", function()
  describe("#create", function()
    it("can create a Tool", function()
      pending("todo")
    end)

    it("sets tool durability and energy cost based on type", function()
      pending("todo")
    end)
  end)

  describe("#needs_repair", function()
    it("does not need repair when it is as max durability", function()
      pending("todo")
    end)

    it("does need repair when durability is < Tool.NEEDS_REPAIR_THRESHOLD", function()
      pending("todo")
    end)
  end)

  describe("#repair", function()
    it("can not repair past max_durability", function()
      pending("todo")
    end)

    it("can repair an items durability", function()
      pending("todo")
    end)
  end)

  describe("#use", function()
    it("loses durability when it's used", function()
      pending("todo")
    end)

    it("keeps track of times used", function()
      pending("todo")
    end)
  end)

  describe("#upgrade", function()
    it("can upgrade level", function()
      pending("todo")
    end)

    it("can upgrade durability", function()
      pending("todo")
    end)
  end)
end)
