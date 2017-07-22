require '../State'

describe("State", function()
  describe("#create", function()
    it("can create a state with no props", function()
      local state = State.create()
      for i, k  in pairs({"current_state", "previous_state", "next_state", "on_state_changed"}) do
        assert.are.same(nil, state[k])
      end
    end)

    it("can create a state with initial state", function()
      local state = State.create({ current_state = "ghost" })
      assert.are.same("ghost", state.current_state)
    end)
  end)

  describe("#update", function()
    local state = nil

    before_each(function()
      state = State.create({ current_state = "alive" })
      state.next_state = "ghost"
    end)

    it("can change state", function()
      State.update(state)
      assert.are.same("ghost", state.current_state)
      assert.are.same("alive", state.previous_state)
      assert.are.same(nil, state.next_state)
    end)

    it("flags just_changed for one cycle after state changes", function()
      State.update(state)
      assert.is_true(state.just_changed, "expected just_changed to be true")
      State.update(state)
      assert.is_false(state.just_changed, "expected just_changed to now be false")
    end)

    it("calls on_state_changed when state changes", function()
      local s = spy.new(function() end)
      state.on_state_changed = s
      State.update(state)
      assert.spy(s).was.called()
    end)

    it("does not change state when next_state is nil", function()
      state.next_state = nil
      local s = spy.new(function() end)
      state.on_state_changed = s
      State.update(state)
      assert.are.same(nil, state.previous_state)
      assert.are.same("alive", state.current_state)
      assert.are.same(nil, state.next_state)
      assert.spy(s).was.not_called()
    end)
  end)

  describe("#change_state", function()
    local state = nil

    before_each(function()
      state = State.create()
    end)

    it("sets next_state", function()
      State.change_state(state, "walking")
      assert.are.same("walking", state.next_state)
    end)

    it("overrides itself if called multiple times", function()
      State.change_state(state, "walking")
      State.change_state(state, "standing")
      State.change_state(state, "sitting")
      State.change_state(state, nil)
      assert.are.same(nil, state.next_state)
    end)
  end)
end)



