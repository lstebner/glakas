State = {}

require 'helpers/copy'

local DEFAULT_PROPS = {
  current_state = nil,
  previous_state = nil,
  next_state = nil,
  on_state_changed = nil,
  just_changed = false,
}

function State.create(props)
  props = props or shallowcopy(DEFAULT_PROPS)
  return props
end

function State.update(state)
  if state.next_state and state.next_state ~= state.current_state then
    state.previous_state = state.current_state
    state.current_state = state.next_state
    state.next_state = nil
    state.just_changed = true

    if state.on_state_changed then
      state.on_state_changed(state)
    end
  elseif state.just_changed then
    state.just_changed = false
  end
end

function State.change_state(state, new_state)
  state.next_state = new_state
end
