require("../Cell")

describe("Cell", function()
  describe("#create", function()
    it("can create a cell", function()
      local cell = Cell.create()
      assert.is_truthy(cell)
    end)

    it("can take props", function()
      local cell = Cell.create({ type = "mushroom", idx = 3, cell_props = { num = 5 } })
      assert.are.same("mushroom", cell.type)
      assert.are.same(3, cell.idx)
      assert.are.same(5, cell.cell_props.num)
    end)
  end)

  describe("#get_cell_props_for", function()
    it("can retrieve cell props", function()
      local cell_props = { some = 1, custom = "stuff" }
      local cell = Cell.create({ cell_props = cell_props })
      assert.are.ame(cell_props, Cell.get_cell_props_for(cell))
    end)
  end)

  describe("#empty_cell", function()
    it("can turn a cell in to an empty cell", function()
      local cell = Cell.create({ type = "road", cell_props = { length = 5 }})
      assert.are.same("road", cell.type)
      Cell.empty_cell(cell)
      assert.are.same("empty", cell.type)
      assert.are.same(Cell.DEFAULT_CELL_PROPS.empty, cell.cell_props)
    end)
  end)

  describe("#clear_cells", function()
    it("can empty multiple cells", function()
      local cells = {}
      for i = 1, 4 do
        table.insert(cells, Cell.create({ type = "road", cell_props = { length = i }}))
      end

      Cell.clear_cells(cells)

      for i, cell in pairs(cells) do
        assert.are.same("empty", cell.type)
        assert.are.same(Cell.DEFAULT_CELL_PROPS.empty, cell.cell_props)
      end
    end)
  end)

  describe("#default_cell_props_for", function()
    it("returns the default props for an un-recognized type or type 'default'", function()
      assert.are.same(Cell.DEFAULT_CELL_PROPS.default, Cell.default_cell_props_for("default"))
      assert.are.same(Cell.DEFAULT_CELL_PROPS.default, Cell.default_cell_props_for("marbles123456"))
    end)

    it("returns the matching default props for a recognized type", function()
      for k, v in pairs(Cell.DEFAULT_CELL_PROPS) do
        assert.are.same(v, Cell.default_cell_props_for(k))
      end
    end)
  end)

  describe("disguising", function()
    local cell = nil

    before_each(function()
      cell = Cell.create({ type = "door" }) 
    end)

    function disguise_as(what)
      cell.cell_props.disguised_as = what
    end

    describe("#disguise", function()
      it("can disguise a cell", function()
        Cell.disguise(cell, "rock")
        assert.is_truthy(cell.cell_props.disguised_as)
        assert.are.same("rock", cell.cell_props.disguised_as)
      end)
    end)

    describe("undisguise", function()
      it("can undisguise a disguised cell", function()
        disguise_as("rock")
        Cell.undisguise(cell)
        assert.are.same(nil, cell.cell_props.disguised_as)
      end)
    end)

    describe("is_disguised", function()
      it("returns true when a cell is disguised", function()
        disguise_as("rock")
        assert.is_true(Cell.is_disguised(cell))
      end)

      it("returns false when a cell is not disguised", function()
        assert.is_false(Cell.is_disguised(cell))
      end)
    end)
  end)
end)
