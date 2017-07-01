World = {}
local inspect = require("inspect")

require "Map"
require "Player"
require "copy"

local DEFAULT_PROPS = {
  num_maps = 0,
  time = { ticks = 0 },
  maps = {},
  current_map_idx = 0,
  player = nil,
}

function World.create(props)
  props = props or {}

  local new_world = {}

  new_world = deepcopy(DEFAULT_PROPS)

  for k, v in pairs(props) do
    new_world[k] = v
  end

  props.map_props = props.map_props or {}

  if new_world.num_maps > 0 then
    for i = 1, new_world.num_maps do
      World.create_map(new_world, props.map_props[i])
    end 
  end

  new_world.num_maps = #new_world.maps

  return new_world
end

function World.create_map(world, props)
  local map = Map.create(props)
  map.idx = #world.maps + 1
  table.insert(world.maps, map)
end

function World.create_player(world, props)
  world.player = Player.create(props)

  if world.num_maps > 0 then
    world.player.position = 1
  end
end

function World.get_player_position(world)
  return {
    current_map = world.current_map_idx,
    current_cell_idx = world.player.position,
    current_cell = World.get_player_cell(world),
  }
end

function World.get_player_cell(world)
  return Map.get_cell(World.get_current_map(world), world.player.position)
end

function World.get_current_map(world)
  return world.maps[world.current_map_idx]
end

function World.get_maps(world)
  return world.maps
end

function World.load_map(world, map_id)
  world.current_map_idx = map_id
end

function World.update(world)
  world.time.ticks = world.time.ticks + 1

  for i, map in pairs(world.maps) do
    Map.update(map, world)
  end
end
