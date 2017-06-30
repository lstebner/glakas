function handle_input(dt)
  local start_pos = player.pos

  if love.keyboard.isDown("right") or love.keyboard.isDown("l") then
    player.move_east()
  elseif love.keyboard.isDown("left") or love.keyboard.isDown("h") then
    player.move_west()
  end

  if love.keyboard.isDown("up") or love.keyboard.isDown("k") then
    player.move_north()
  elseif love.keyboard.isDown("down") or love.keyboard.isDown("j") then
    player.move_south()
  end
end

function love.keypressed(key)
  if key == "space" then
    if glakas.is_player_on("door") then
      player.open_door()
    else
      player.use_tool()
    end
  elseif key == "v" then
    player.place_gem_from_backpack()
  elseif key == "d" then
    player.swap_gem_with_backpack()
  elseif key == "f" then
    player.pick_up_gem()
  elseif key == "a" then
    if player.has_axe == 0 then
      player.create_axe()
    end
  elseif key == "s" then
    if player.has_pickaxe == 0 then
      player.create_pickaxe()
    end
  elseif key == "e" then
    player.create_key()
  elseif key == "r" then
    player.repair_tool("pickaxe", 1)
    player.repair_tool("axe", 1)
  elseif key == "t" then
    player.build_tent()
  end
end
