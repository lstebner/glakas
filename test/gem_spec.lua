require("../gem")

describe("gem", function()
  it("#create", function()
    pending()
  end)

  it("#can_be_moved", function()
    assert.is_true(gem.can_be_moved(gem_types[1]))
    assert.is_false(gem.can_be_moved(unmoveable_gem_types[1]))
  end)

  it("#gems_list", function()
    it("should be able to use default gem_weights", function()
      pending()
    end)

    it("should be able to use custom gem_weights", function()
      pending()
    end)
  end)

  it("#random_gems", function()
    it("should use all gem_type's by default", function()
      pending()
    end)

    it("should accept a custom list of gem_type's", function()
      pending()
    end)
  end)

  it("#get_color_for", function()
    pending()
  end)
end)
