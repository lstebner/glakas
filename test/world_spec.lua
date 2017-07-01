require '../World'

local inspect = require("inspect")

describe("World", function()
  it("#create", function()
    local world = World.create({num_maps = 2})
    assert.is_true(world.num_maps == 2)
    assert.is_true(#world.maps == 2)
  end)

  it("#create_map", function()
    local world = World.create({ num_maps = 0 })
    assert.is_true(#world.maps == 0)
    World.create_map(world, {rows = 2, cols = 2})
    assert.is_true(#world.maps == 1)
    assert.is_true(world.maps[1].rows == 2)
  end)

  it("#create_player", function()
    local world = World.create()
    assert.is_true(world.player == nil)
    World.create_player(world, {name="traveler"})
    assert.is_true(world.player ~= nil)
    assert.is_true(world.player.name == "traveler")
  end)

  it("#load_map", function()
    local world = World.create({ num_maps = 3})
    World.load_map(world, 1)
    assert.is_true(world.current_map_idx == 1)
    World.load_map(world, 3)
    assert.is_true(world.current_map_idx == 3)
  end)

  it("#player_position", function()
    local world = World.create({ num_maps = 1})
    World.load_map(world, 1)
    World.create_player(world)
    local pos = World.get_player_position(world)
    assert.is_true(pos.current_map == 1)
    assert.is_true(pos.current_cell_idx == 1)
  end)

  it("#player_cell", function()
    local world = World.create({ num_maps = 2 })
    World.load_map(world, 1)
    World.create_player(world)
    local cell = World.get_player_cell(world)
    assert.is_true(cell.idx == 1)
  end)

  it("#current_map", function()
    local world = World.create({ num_maps = 2 })
    World.load_map(world, 2)
    local map = World.get_current_map(world)
    assert.is_true(map == world.maps[2])
  end)

  it("#maps", function()
    local world = World.create({ num_maps = 2 })
    assert.is_true(world.maps == World.get_maps(world))
  end)

  it("#update_world", function()
    local world = World.create()
    assert.is_true(world.time.ticks == 0)
    for i = 1, 5 do
      World.update(world)
    end
    assert.is_true(world.time.ticks == 5)
  end)
end)
