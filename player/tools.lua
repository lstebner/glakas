function player.create_axe()
  if player.wood < wood_reqs.create_axe then
    player.log_msg("not enough wood to create axe")
    return false
  else
    player.log_msg("\naxe created!")
    player.log_msg("the axe can chop down surrounding trees without needing to move")
    player.log_msg("press 'space' to chop")
  end

  player.wood = player.wood - wood_reqs.create_axe
  player.axe = player.axe_max_repair
  player.has_axe = 1
end

function player.create_pickaxe()
  if player.wood < wood_reqs.create_pickaxe then
    player.log_msg("not enough wood to create pickaxe")
    return false
  else
    player.log_msg("\npickaxe created!")
    player.log_msg("the pickaxe can mine gems. it mines all surrounding gems at the same time.")
    player.log_msg("press 'space' to mine gems")
    player.log_msg("press 'c' to pick up gems")
    player.log_msg("press 'v' to put them down if spot is empty")
    player.log_msg("press 'x' to swap the gem you're on, for the first one in your backpack")
    player.log_msg("\nusing tools is tiring so don't forget to eat!")
  end

  player.wood = player.wood - wood_reqs.create_pickaxe
  player.pickaxe = player.pickaxe_max_repair
  player.has_pickaxe = 1
end

function player.create_shovel()
  if player.wood < wood_reqs.create_shovel then
    player.log_msg("not enough wood to create shovel")
    return false
  end

  player.wood = player.wood - wood_reqs.create_shovel
  player.shovel = 10
  player.has_shovel = 1
end

function player.tool_needs_repair(tool)
  if tool == "axe" then
    return player.axe < 1
  elseif tool == "pickaxe" then
    return player.pickaxe < 1
  elseif tool == "shovel" then
    return player.shovel < 1
  end

  return false
end

function player.repair_tool(tool, how_much)
  if player.wood < 1 then
    player.log_msg("not enough wood to repair tool")
    return false
  end

  how_much = how_much or 1
  local used_wood = 0
  local wood_value = 4 -- each one piece of wood gives this much repair value to tools
  local tool_was_repaired = false

  if player.wood < how_much then
    how_much = player.wood
  end

  if tool == "axe" and player.has_axe > 0 then
    player.axe = player.axe + how_much * wood_value
    tool_was_repaired = true
  elseif tool == "pickaxe" and player.has_pickaxe > 0 then
    player.pickaxe = player.pickaxe + how_much * wood_value
    tool_was_repaired = true
  end

  if tool_was_repaired then
    player.wood = player.wood - how_much
  else
    player.log_msg(tool.." could not be repaired")
  end

  return tool_was_repaired
end

function player.use_tool()
  if love.timer.getTime() * 1000 < player.last_tool_time + 500 then
    return false
  end

  local cell = glakas.grid[player.pos]
  local cell_props = cell.cell_props
  local use_tool = nil
  local energy_required = 0

  if cell.gem == "empty" then
    return false
  elseif cell.gem == "chest" then
    return player.open_chest(cell)
  elseif cell.gem == "food" then
    return player.eat_food(cell)
  elseif cell.gem == "mushrooms" then
    return player.collect_mushrooms(cell)
  elseif cell.gem == "tree_sapling" then
    return player.log_msg("tree saplings cannot be harvested until they grow in to trees")
  elseif cell.gem == "tree" then
    if player.has_axe > 0 then
      use_tool = "axe"
    else
      use_tool = "hand"
      if one_time_alerts.create_axe == 0 then
        one_time_alerts.create_axe = 1
        player.log_msg "\nonce you get the axe, you can chop trees more efficiently\n"
      end
    end
  else
    if player.has_pickaxe > 0 then
      use_tool = "pickaxe"
    else
      player.log_msg "you don't have the pickaxe yet"
    end
  end

  local energy_required = player.energy_reqs[use_tool]

  if player.tool_needs_repair(use_tool) then
    player.log_msg(use_tool.." needs repaired")

    local tool_repaired = player.repair_tool(use_tool, 1)
    if tool_repaired == false then
      return false
    else
      player.log_msg(use_tool.." was repaired")
    end
  end

  if use_tool == nil then
    return false
  end

  if player.energy <= energy_required then
    player.log_msg("\nyou are out of energy!")
    return false
  end

  local matches = {}
  local spawn_food = {}
  if use_tool == "hand" then
    matches = {cell}
  else
    matches = glakas.all_matching_cells(cell)

    if use_tool == "axe" then
      player.axe = player.axe - 1
    elseif use_tool == "pickaxe" then
      player.pickaxe = player.pickaxe - 1
    end
  end

  local num_matches = table.getn(matches)
  local log_string = ""

  if glakas.is_player_on("gem") and num_matches < 2 then
    print "must match at least 2 gems"
    return false
  end

  player.use_energy(energy_required)
  player.last_tool_time = love.timer.getTime() * 1000

  if cell.gem == "gold" then
    local gold_collected = num_matches
    if num_matches > 2 and math.random(12) % 3 == 0 then
      gold_collected = gold_collected + num_matches - 2
    end

    glakas.clear_cells(matches)

    return player.collect_gold(gold_collected)
  end

  for i, c in pairs(matches) do
    if c.gem == "tree" then
      log_string = " wood collected"
      if c.cell_props == nil then
        print("trying to collect wood, but "..c.idx.." has no cell_props")
        player.collect_wood(1)
      else
        player.collect_wood(c.cell_props.size)
        if c.cell_props.fruited then
          table.insert(spawn_food, c.idx)
          player.log_msg "that tree had some fruit growing on it!"
        end
      end
    elseif c.gem ~= nil and string.match(c.gem, "gem_") then
      log_string = " gems destroyed"
      player.gem_destroyed(cell.gem)
    end
  end

  glakas.clear_cells(matches)

  player.log_msg(num_matches.." "..log_string)

  -- 5 is the most matches possible at once, it leaves a tree or food in place
  if num_matches == 5 then
    if use_tool == "axe" or math.random(5) % 2 == 0 then
      table.insert(spawn_food, player.pos)
    else
      glakas.spawn_tree(glakas.player_cell())
      player.log_msg "a tree appears!"
    end
  elseif cell_props and cell_props.fruited then
    glakas.spawn_food(glakas.grid[player.pos])
    player.log_msg "that tree had some fruit growing on it!"
  else
    glakas.empty_cell(glakas.grid[player.pos])
  end

  if table.getn(spawn_food) > 0 then
    for i, idx in pairs(spawn_food) do
      glakas.spawn_food(glakas.grid[idx])
    end

    player.log_msg "some food appears!"
  end
end
