require '../Map'
local inspect = require("inspect")

describe("Map", function()
  it("#create", function()
    local map = Map.create({ rows = 2, cols = 2 })
    assert.are.same(2, map.rows, "rows")
    assert.are.same(2, map.cols, "cols")
    assert.are.same(4, map.total_cells, "total_cells")
    assert.are.same(4, #map.cells, "#map.cells")
  end)

  it("#create_cell", function()
    local map = Map.create({})
    assert.are.same(0, map.total_cells, "expected 0 cells")
    Map.create_cell(map, "empty")
    assert.are.same(1, map.total_cells, "expected 1 cell, but got "..map.total_cells)
    assert.are.same("empty", map.cells[1].type, "expected empty cell type")
    assert.are.same(1, map.cells[1].idx, "expected id 1")
  end)

  it("#create_cells", function()
    local map = Map.create({})
    assert.are.same(0, map.total_cells, "expected 0 cells")
    Map.create_cells(map, 1)
    assert.are.same(1, map.total_cells, "expected 1 cell")
    Map.create_cells(map, 4, "water")
    assert.are.same(5, map.total_cells, "expected 5 cells")
    assert.are.same("water", map.cells[5].type)
  end)

  it("#get_cell", function()
    local map = Map.create()
    local cell = Map.get_cell(map, math.random(map.total_cells))
    assert.are_not.same(nil, cell, "expected cell not to be nil")
    cell = Map.get_cell(map, -1)
    assert.are.same(nil, cell, "expected cell to be nil")
    Map.get_cell(map, map.total_cells + 1)
    assert.are.same(nil, cell, "expected cell to be nil")
  end)

  it("#reset_cell", function()
    local map = Map.create({})
    Map.create_cell(map, "bogus_type")
    local cell = Map.get_cell(map, 1)
    assert.are.same("bogus_type", cell.type, "expected bogus_type")
    assert.are.same(cell.cell_props, Cell.DEFAULT_CELL_PROPS.default, "expected default cell_props")

    Map.reset_cell(map, 1, "empty")
    cell = Map.get_cell(map, 1)

    assert.are.same("empty", cell.type, "expected cell to now be empty")
    assert.are.same(cell.cell_props, Cell.DEFAULT_CELL_PROPS.empty, "expected cell to have 'empty' props")
  end)

  it("#empty_cell", function()
    local map = Map.create({})
    Map.create_cells(map, 2, "water")
    assert.are.same("water", Map.get_cell(map, 1).type)
    Map.empty_cell(map, 1)
    assert.are.same("empty", Map.get_cell(map, 1).type)
    assert.are.same("water", Map.get_cell(map, 2).type)
  end)

  it("#create_door", function()
    local map = Map.create({})
    Map.create_cells(map, 4, "empty")
    Map.create_door(map, 1, 2)
    assert.are.same("door", map.cells[1].type, "expected cell to be a 'door'")
    assert.are.same(2, map.cells[1].cell_props.connecting_map_idx, "unexpected connecting_map_idx")

    Map.create_door(map, 2, 3, true)
    assert.is_true(Cell.is_disguised(Map.get_cell(map, 2)), "expected door to be disguised")
  end)

  describe("#get_cells", function()
    local map = nil
    local map_data = {
      rows = 2,
      cols = 2,
    }
    local expected_total_cells = map_data.rows * map_data.cols

    before_each(function()
      map = Map.create(map_data)
    end)

    it("returns all cells by default", function()
      assert.are.same(expected_total_cells, #Map.get_cells(map))
    end)

    it("can return only specified ids", function()
      local cell_ids = {1, 2}
      local cells = Map.get_cells(map, cell_ids)
      assert.are.same(#cell_ids, #cells)
      for k, c in pairs(cells) do
        assert.are_not.same(nil, cell_ids[c.idx])
      end
    end)

    it("does not return any nil cells", function()
      local cell_ids = {1, 20, 3000}
      local cells = Map.get_cells(map, cell_ids)
      assert.are.same(1, #cells)
      for k, c in pairs(cells) do
        assert.are_not.same(nil, c)
      end
    end)
  end)

  it("#get_cells_of_type", function()
    local map = Map.create()
    local first_cell_type = map.cells[1].type
    local our_count = 0
    for i, cell in pairs(map.cells) do
      if cell.type == first_cell_type then
        our_count = our_count + 1
      end
    end 

    local cells = Map.get_cells_of_type(map, first_cell_type)
    assert.are.same(our_count, #cells)

    for i, cell in pairs(cells) do
      assert.are.same(first_cell_type, cell.type)
    end
  end)

  it("#get_neighboring_cells", function()
    local map_data = { rows = 5, cols = 5 }
    local map = Map.create(map_data)
    local cells = {}

    -- check very first cells, top left
    cells = Map.get_neighboring_cells(map, 1)
    assert.are.same(#cells, 2, "neighbor check 1")

    -- check 2nd cell, has more neighbors
    cells = Map.get_neighboring_cells(map, 2)
    assert.are.same(#cells, 3, "neighbor check 2")

    -- check top right cell
    cells = Map.get_neighboring_cells(map, map_data.cols)
    assert.are.same(#cells, 2, "neighbor check 3")

    -- check bottom right cell, looking for edge cases
    cells = Map.get_neighboring_cells(map, map_data.cols * map_data.rows)
    assert.are.same(#cells, 2, "neighbor check 4")

    -- check bottom left cell
    cells = Map.get_neighboring_cells(map, map_data.cols * map_data.rows - map_data.cols)
    assert.are.same(#cells, 2, "neighbor check 5")

    -- something in the bottom row
    cells = Map.get_neighboring_cells(map, map_data.cols * map_data.rows - 2)
    assert.are.same(#cells, 3, "neighbor check 6")

    -- check a cell that should have all 4 neighbors available
    cells = Map.get_neighboring_cells(map, map_data.cols + 2)
    assert.are.same(#cells, 4, "neighbor check 7")
  end)

  it("#get_surrounding_cells", function()
    local map_data = { rows = 5, cols = 5 }
    local map = Map.create(map_data)
    local cells = Map.get_surrounding_cells(map, 1)
    assert.are.same(3, #cells, "cell count mismatch 1")

    cells = Map.get_surrounding_cells(map, 2)
    assert.are.same(5, #cells, "cell count mismatch 2")

    -- top right
    cells = Map.get_surrounding_cells(map, map_data.cols)
    assert.are.same(3, #cells, "cell count mismatch 3")

    -- bottom right
    cells = Map.get_surrounding_cells(map, map_data.rows * map_data.cols)
    assert.are.same(3, #cells, "cell count mismatch 4")

    -- bottom left 
    cells = Map.get_surrounding_cells(map, map_data.rows * map_data.cols - map_data.cols)
    assert.are.same(3, #cells, "cell count mismatch 5")

    -- something in the bottom row
    cells = Map.get_surrounding_cells(map, map_data.rows * map_data.cols - 2)
    assert.are.same(5, #cells, "cell count mismatch 6")

    cells = Map.get_surrounding_cells(map, 8)
    assert.are.same(8, #cells, "cell count mismatch 7")
  end)

  it("#update", function()
    pending()
  end)
end)
