require '../Map'

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

  describe("#create_cells", function()
    local map = nil

    before_each(function()
      map = Map.create({})
    end)

    it("can create cells", function()
      assert.are.same(0, map.total_cells, "expected 0 cells")
      Map.create_cells(map, 1)
      assert.are.same(1, map.total_cells, "expected 1 cell")
      Map.create_cells(map, 4, "water")
      assert.are.same(5, map.total_cells, "expected 5 cells")
      assert.are.same("water", map.cells[5].type)
    end)

    it("makes all cells empty by default", function()
      Map.create_cells(map, 3)
      for k, v in pairs(map.cells) do
        assert.are.same("empty", v.type)
      end
    end)

    it("can make all cells any specified type", function()
      local expected_type = "cats"
      Map.create_cells(map, 3, expected_type)
      for k, v in pairs(map.cells) do
        assert.are.same(expected_type, v.type)
      end
    end)

    it("can take a list of types to iterate over", function()
      local expected_types = {"water", "grass", "grass", "cat"}
      Map.create_cells(map, 4, expected_types)
      for k, v in pairs(map.cells) do
        assert.are.same(expected_types[k], v.type)
      end
    end)

    it("will make empty cells if the list isn't long enough", function()
      local expected_types = {"water", "grass"}
      local empty_cells = 0
      Map.create_cells(map, 4, expected_types)
      for k, v in pairs(map.cells) do
        if expected_types[k] then
          assert.are.same(expected_types[k], v.type)
        else
          empty_cells = empty_cells + 1
          assert.are.same("empty", v.type)
        end
      end

      assert.are.same(2, empty_cells, "expected 2 empty cells")
    end)
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

  describe("#reset_cell", function()
    local map = nil
    local cell = nil

    before_each(function()
      map = Map.create({})
      Map.create_cell(map, "bogus_type")
    end)

    it("can make a cell of any type", function()
      cell = Map.get_cell(map, 1)
      assert.are.same("bogus_type", cell.type, "expected bogus_type")
      assert.are.same(cell.cell_props, Cell.DEFAULT_CELL_PROPS.default, "expected default cell_props")
    end)

    it("can reset a cell", function()
      Map.reset_cell(map, 1, "empty")
      cell = Map.get_cell(map, 1)
      assert.are.same("empty", cell.type, "expected cell to now be empty")
      assert.are.same(cell.cell_props, Cell.DEFAULT_CELL_PROPS.empty, "expected cell to have 'empty' props")
    end)
  end)

  it("#empty_cell", function()
    local map = Map.create({})
    Map.create_cells(map, 2, "water")
    assert.are.same("water", Map.get_cell(map, 1).type)
    Map.empty_cell(map, 1)
    assert.are.same("empty", Map.get_cell(map, 1).type)
    assert.are.same("water", Map.get_cell(map, 2).type)
  end)

  describe("#create_door", function()
    local map = nil

    before_each(function()
      map = Map.create({})
      Map.create_cells(map, 4, "empty")
    end)

    it("can create a door", function()
      Map.create_door(map, 1, 2)
      assert.are.same("door", map.cells[1].type, "expected cell to be a 'door'")
      assert.are.same(2, map.cells[1].cell_props.connecting_map_idx, "unexpected connecting_map_idx")
    end)

    it("can create a disguised door", function()
      Map.create_door(map, 2, 3, true)
      assert.is_true(Cell.is_disguised(Map.get_cell(map, 2)), "expected door to be disguised")
    end)
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

  describe("#move_player", function()
    require '../Player'

    local player = nil
    local map = nil

    before_each(function()
      player = Player.create()
      map = Map.create()
    end)

    it("player can not move west from the left column", function()
      Player.set_position(player, 1)
      Map.move_player(map, player, "weest")
      assert.are.same(1, player.position)
    end)

    it("player can move west", function()
      Player.set_position(player, 2)
      Map.move_player(map, player, "west")
      assert.are.same(1, player.position)
    end)

    it("player can not move east from the right column", function()
      Player.set_position(player, map.cols)
      Map.move_player(map, player, "east")
      assert.are.same(map.cols, player.position)
    end)

    it("player can move east", function()
      Player.set_position(player, 1)
      Map.move_player(map, player, "east")
      assert.are.same(2, player.position)
    end)

    it("player can not move north from the top column", function()
      Player.set_position(player, 1)
      Map.move_player(map, player, "north")
      assert.are.same(1, player.position)
    end)

    it("player can move north", function()
      Player.set_position(player, map.cols + 1)
      Map.move_player(map, player, "north")
      assert.are.same(1, player.position)
    end)

    it("player can not move south from the bottom column", function()
      Player.set_position(player, map.total_cells - 1)
      Map.move_player(map, player, "south")
      assert.are.same(map.total_cells - 1, player.position)
    end)

    it("player can move south", function()
      Player.set_position(player, 1)
      Map.move_player(map, player, "south")
      assert.are.same(map.cols + 1, player.position)
    end)
  end)
end)
