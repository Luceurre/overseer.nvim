---@alias overseer.Param overseer.StringParam|overseer.BoolParam|overseer.NumberParam|overseer.IntParam|overseer.ListParam|overseer.EnumParam|overseer.OpaqueParam|overseer.TableParam

---@class overseer.TableParam : overseer.BaseParam
---@field type? "table"
---@field key_subtype? overseer.Param
---@field value_subtype? overseer.Param
---@field delimiter? string
---@field key_value_delimiter? string
---@field default? table

---@class overseer.BaseParam
---@field name? string
---@field desc? string
---@field long_desc? string
---@field validate? fun(value: any): boolean
---@field optional? boolean
local Param = {}

function Param:child()
  local child = {}
  setmetatable(child, self)
  self.__index = self

  return child
end

---@param opts overseer.BaseParam
function Param:new(opts)
  local instance = opts or {}
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function Param:render_value(value)
  return tostring(value)
end

function Param:render_field(prefix, name, value)
  local str_value = self:render_value(value)
  return string.format("%s%s: %s", prefix, name, str_value)
end

function Param:validate_type(_)
  return false
end

function Param:parse_field(prefix, name, line)
  local label = string.format("%s%s: ", prefix, name)
  if string.sub(line, 1, string.len(label)) ~= label then
    return false
  end
  local value = string.sub(line, string.len(label) + 1)
  return self:parse_value(value)
end

function Param:parse_value(_)
  return false, nil
end

---@class overseer.StringParam : overseer.BaseParam
---@field type? "string"
---@field default? string
local StringParam = Param:child()

function StringParam:validate_type(value)
  return type(value) == "string"
end

function StringParam:parse_value(value)
  return true, value
end

---@class overseer.IntParam : overseer.BaseParam
---@field type? "integer"
---@field default? number
local IntParam = Param:child()

function IntParam:validate_type(value)
  return type(value) == "number"
end

function IntParam:parse_value(value)
  local num = tonumber(value)
  if num then
    return true, num
  end

  return Param:parse_value(value)
end

---@class overseer.OpaqueParam : overseer.BaseParam
---@field type? "opaque"
---@field default? any
local OpaqueParam = Param:child()

function OpaqueParam:validate_type(_)
  return true
end

function OpaqueParam:parse_value(_)
  return false
end

---@class overseer.ListParam : overseer.BaseParam
---@field type? "list"
---@field subtype? overseer.Param
---@field delimiter? string
---@field default? table
local ListParam = Param:child()

function ListParam:validate_type(value)
  return type(value) == "table" and vim.tbl_islist(value)
end

function ListParam:parse_value(value)
  local values = vim.split(value, "%s*" .. self.delimiter .. "%s*")
  local success
  for i, v in ipairs(values) do
    success, values[i] = self.subtype:parse_value(v)
    if not success then
      return false, nil
    end
  end
  return true, values
end

function ListParam:render_value(value)
  local rendered_values = {}
  for _, v in ipairs(value) do
    table.insert(rendered_values, self.subtype:render_value(v))
  end
  return table.concat(rendered_values, self.delimiter)
end

---@class overseer.BoolParam : overseer.BaseParam
---@field type "boolean"
---@field default? boolean
local BooleanParam = Param:child()

function BooleanParam:validate_type(value)
  return type(value) == "boolean"
end

function BooleanParam:parse_value(value)
  if string.match(value, "^ye?s?") or string.match(value, "^tr?u?e?") then
    return true, true
  elseif string.match(value, "^no?") or string.match(value, "^fa?l?s?e?") then
    return true, false
  end

  return Param:parse_value(value)
end

---@class overseer.EnumParam : overseer.BaseParam
---@field type? "enum"
---@field default? string
---@field choices string[]
local EnumParam = Param:child()

function EnumParam:validate_type(value)
  return type(value) == "string" and vim.tbl_contains(self.choices, value)
end

function EnumParam:parse_value(value)
  local key = "^" .. value:lower()
  local best
  for _, v in ipairs(self.choices) do
    if v == value then
      return true, v
    elseif v:lower():match(key) then
      best = v
    end
  end
  return best ~= nil, best
end

---@class overseer.NumberParam : overseer.BaseParam
---@field type "number"
---@field default? number
local NumberParam = Param:child()

function NumberParam:validate_type(value)
  return type(value) == "number" and math.floor(value) == value
end

function NumberParam:parse_value(value)
  local num = tonumber(value)
  if num then
    return true, math.floor(num)
  end

  return Param:parse_value(value)
end

-- For compatibility with old config files
---@param table_param overseer.Param
local function convert_table_to_param(table_param)
  if table_param.type == "string" then
    return StringParam:new(table_param)
  elseif table_param.type == "boolean" then
    return BooleanParam:new(table_param)
  elseif table_param.type == "number" then
    return NumberParam:new(table_param)
  elseif table_param.type == "list" then
    table_param.subtype = convert_table_to_param(table_param.subtype)
    return ListParam:new(table_param)
  elseif table_param.type == "enum" then
    return EnumParam:new(table_param)
  elseif table_param.type == "opaque" then
    return OpaqueParam:new(table_param)
  elseif table_param.type == "integer" then
    return IntParam:new(table_param)
  end

  error("Unknown param type: " .. table_param.type)
end

---@param param_tables table<string, overseer.Param>
---@return overseer.Param[]
local convert_tables_to_params = function(param_tables)
  local params = {}
  for key, table_param in pairs(param_tables) do
    local param = convert_table_to_param(table_param)
    params[key] = param
  end
  return params
end

return {
  Param = Param,
  StringParam = StringParam,
  BoolParam = BooleanParam,
  NumberParam = NumberParam,
  IntParam = IntParam,
  ListParam = ListParam,
  EnumParam = EnumParam,
  OpaqueParam = OpaqueParam,
  convert_tables_to_params = convert_tables_to_params,
}
