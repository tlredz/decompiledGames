local Util = require(script.Parent.Parent.Shared.Util)
local enumItems = Enum.UserInputType:GetEnumItems()

for _, v in pairs(Enum.KeyCode:GetEnumItems()) do
	enumItems[#enumItems + 1] = v
end

local v = {
	Transform = function(p)
		return Util.MakeFuzzyFinder(enumItems)(p)
	end,
	Validate = function(list)
		return #list > 0
	end,
	Autocomplete = function(p)
		return Util.GetNames(p)
	end,
	Parse = function(list)
		return list[1]
	end
}
return function(registry)
	registry:RegisterType("userInput", v)
	registry:RegisterType("userInputs", Util.MakeListableType(v))
end