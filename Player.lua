Player = {}

local DEFAULT_PROPS = {
  name = "hero",
  position = 0,
}

function Player.create(props)
  props = props or DEFAULT_PROPS
  local new_player = {}

  for k, v in pairs(props) do
    new_player[k] = v
  end

  return new_player
end
