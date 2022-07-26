local parse_value = require("overseer.form").parse_value

describe("parse_value", function()
  describe("when param type is table", function()
    ---@return overseer.TableParam
    local get_schema = function()
      return {
        type = "table",
        key_subtype = {
          type = "string",
        },
        value_subtype = {
          type = "string",
        },
        delimiter = ",",
        key_value_delimiter = "=",
      }
    end

    it("should return (false, nil) when given an invalid input", function()
      local schema = get_schema()

      local invalid_values = {
        { "no value", "Missing value." },
        { "=no key", "Missing key." },
        { "FOO=foo BAR=bar", "Wrong delimiter." },
      }

      for _, value in ipairs(invalid_values) do
        local success, result = parse_value(schema, value[1])

        assert.is_false(success, invalid_values[2])
        assert.is_nil(result)
      end
    end)

    it("should parse valid input", function()
      local schema = get_schema()

      local valid_values = {
        { "foo=bar", { foo = "bar" } },
        { "foo=bar,baz=qux", { foo = "bar", baz = "qux" } },
        { "foo=bar,baz=qux,quux=corge", { foo = "bar", baz = "qux", quux = "corge" } },
      }

      for _, value in ipairs(valid_values) do
        local success, result = parse_value(schema, value[1])

        assert.is_true(success)
        assert.same(value[2], result)
      end
    end)

    it("should return (false, nil) when key type is invalid", function()
      local schema = get_schema()

      schema.key_subtype = {
        type = "number",
      }

      local invalid_value = "foo=bar"
      local success, result = parse_value(schema, invalid_value)

      assert.is_false(success)
      assert.is_nil(result)
    end)
  end)
end)
