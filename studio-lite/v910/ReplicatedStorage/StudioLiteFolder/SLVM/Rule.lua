local Rule = {}
local v = {}
require(script.Parent:WaitForChild("Types"))
local Enum = require(script.Parent:WaitForChild("Enum"))
local enumList = Enum.EnumList
local utilities = Enum.Utilities

function Rule.new(kind, p, value2: string?)
	local isA = utilities:IsA(kind, "EnumItem")
	assert(
		isA or type(kind) == "string" or type(kind) == "number",
		"Expected SLVMEnumItem or string or number as argument #1 for 'Rule.new'"
	)
	assert(type(value2) == "string" or type(value2) == "nil", "Expected string or nil as argument #2 for 'Rule.new'")

	if not isA then
		if type(kind) == "number" then
			kind = utilities:FindEnumItemByValue(enumList.RuleType, kind)

			if not kind then
				error("Provided EnumItem value does not exist for the expected SubEnum", 2)
			end
		elseif type(kind) == "string" then
			kind = utilities:FindEnumItemByName(enumList.RuleType, kind)

			if not kind then
				error("Provided EnumItem value does not exist for the expected SubEnum", 2)
			end
		end
	end

	return table.freeze((setmetatable({
		Kind = kind,
		Data = p,
		Message = value2,
		ExtraData = {
			VariableTypeBlock = nil
		}
	}, {
		__index = v
	})))
end

function v:IsA(p2)
	return self.Kind == p2
end

return Rule