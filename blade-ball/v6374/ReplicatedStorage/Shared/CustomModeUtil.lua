local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)(script.Parent.CustomModeInfo)

local function mergeTables(p, items)
	for k, item in items do
		p[k] = item
	end

	return p
end

local CustomModeUtil = {
	getVariableVariables = function(p: string, p2: string, flag: boolean?)
		local result = {}
		local valueType = v.ValueTypes[p2]

		if not (flag and valueType.Properties and next(valueType.Properties)) then
			result[p] = p2
		end

		if valueType.Properties then
			for k, property in valueType.Properties do
				if not flag or property.CanWrite then
					result[`{p}.{k}`] = property.ValueType
				end
			end
		end

		return result
	end
}

function CustomModeUtil.getPossibleConditionVariables(p)
	local variableVariables = {}

	for k, variable in v.Variables do
		local variableVariables2 = CustomModeUtil.getVariableVariables(k, variable.ValueType)

		for k2, variableVariable in variableVariables2 do
			variableVariables[k2] = variableVariable
		end
	end

	if p.Extensions and p.Extensions.Variables then
		for k, variable in p.Extensions.Variables do
			local variableVariables2 = CustomModeUtil.getVariableVariables(k, variable.ValueType)

			for k2, variableVariable in variableVariables2 do
				variableVariables[k2] = variableVariable
			end
		end
	end

	return variableVariables
end

function CustomModeUtil.getPossibleResultVariables(p)
	local variableVariables = {}

	for k, variable in v.Variables do
		if not variable.CanWrite then
			continue
		end

		local variableVariables2 = CustomModeUtil.getVariableVariables(k, variable.ValueType, true)

		for k2, variableVariable in variableVariables2 do
			variableVariables[k2] = variableVariable
		end
	end

	if p.Extensions and p.Extensions.Variables then
		for k, variable in p.Extensions.Variables do
			if not variable.CanWrite then
				continue
			end

			local variableVariables2 = CustomModeUtil.getVariableVariables(k, variable.ValueType, true)

			for k2, variableVariable in variableVariables2 do
				variableVariables[k2] = variableVariable
			end
		end
	end

	return variableVariables
end

function CustomModeUtil.getTeams(p)
	if p == "Classic" then
		return { "Neutral" }
	elseif p == "Bot Battle" then
		return { "Players", "Bots" }
	elseif p == "2 Teams" then
		return { "Red", "Blue" }
	elseif p == "4 Teams" then
		return {
			"Red",
			"Blue",
			"Green",
			"Yellow"
		}
	elseif p == "1 vs All" then
		return { "One", "All" }
	end

	error((`Invalid gamemode {p}`))
end

return CustomModeUtil