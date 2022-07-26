local params = require("overseer.param")

describe("Params", function()
  it("should have the same keys/values after converting from old parameter.", function()
    local old_params = {
      cmd = { type = "string" },
      env = { type = "opaque", optional = true },
      cwd = { type = "string", optional = true },
      name = { type = "string", optional = true },
      metadata = { type = "opaque", optional = true },
    }

    local new_params = params.convert_tables_to_params(old_params)

    for param_name, param in pairs(old_params) do
      for key, value in pairs(param) do
        assert.equal(new_params[param_name][key], value)
      end
    end

    for param_name, param in pairs(new_params) do
      for key, value in pairs(param) do
        if type(value) ~= "function" then
          assert.equal(
            old_params[param_name][key],
            value,
            "Param " .. param_name .. " has different value for key " .. key
          )
        end
      end
    end
  end)

  describe("IntParam", function()
    it("should parse an integer", function()
      local param = params.IntParam:new({
        name = "test",
      })

      local ok, value = param:parse_value("1")
      assert.is_true(ok)
      assert.equal(1, value)
    end)

    it("should not parse a non-integer", function()
      local param = params.IntParam:new({
        name = "test",
      })

      local ok, value = param:parse_value("a")
      assert.is_false(ok)
      assert.is_nil(value)
    end)

    it("should create a bijection between parse and display", function ()
      local param = params.IntParam:new({
        name = "test",
      })

      local number_string = "127"
      local number = 127

      local ok, value = param:parse_value(number_string)
      assert.is_true(ok)
      assert.equal(number, value)

      local display_value = param:render_value(number)
      assert.equal(number_string, display_value)
    end)
  end)

  describe("StringParam", function ()
    it("should parse a string", function ()
      local param = params.StringParam:new({
        name = "test",
      })

      local ok, value = param:parse_value("test")
      assert.is_true(ok)
      assert.equal("test", value)
    end)

    it("should create a bijection between parse and display", function ()
      local param = params.StringParam:new({
        name = "test",
      })

      local string = "test"
      local string_value = "test"

      local ok, value = param:parse_value(string)
      assert.is_true(ok)
      assert.equal(string_value, value)

      local display_value = param:render_value(string)
      assert.equal(string, display_value)
    end)
  end)
end)
