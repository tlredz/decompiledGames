local parent = script.Parent.Parent
require(parent.Types)
local External = require(parent.External)
local defaultProps = require(parent.Instances.defaultProps)
local applyInstanceProps = require(parent.Instances.applyInstanceProps)

local function New(list, p: string)
	if p == nil then
		External.logError("scopeMissing", nil, "instances using New", "myScope:New \"" .. list .. "\" { ... }")
	end

	return function(p2)
		local success, result = pcall(Instance.new, p)

		if not success then
			External.logError("cannotCreateClass", nil, p)
		end

		local defaultProp = defaultProps[p]

		if defaultProp ~= nil then
			for k, v in pairs(defaultProp) do
				result[k] = v
			end
		end

		table.insert(list, result)
		applyInstanceProps(list, p2, result)
		return result
	end
end

return New