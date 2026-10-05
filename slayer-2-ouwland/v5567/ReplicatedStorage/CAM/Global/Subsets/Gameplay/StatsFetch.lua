local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Global.Types.StatsFetchTypes)
local StatsFetch = {
	SkillStats = require(script.Modules.SkillStats),
	Functions = {}
}

local function registerModule(descendant)
	local success, result = pcall(require, descendant)

	if not success then
		warn((`StatsFetch: failed to require {descendant:GetFullName()}: {result}`))
		return
	end

	if type(result) ~= "table" then
		warn((`StatsFetch: module {descendant:GetFullName()} did not return a table`))
		return
	end

	local name = descendant.Name

	if StatsFetch.Functions[name] == nil then
		StatsFetch.Functions[name] = result
	else
		warn((`StatsFetch: duplicate module name {name}`))
	end

	for k, v in result do
		if type(v) ~= "function" then
			continue
		end

		if StatsFetch[k] == nil then
			StatsFetch[k] = v
		else
			warn((`StatsFetch: function name collision at {k} from {name}`))
		end
	end
end

local descendants = script:WaitForChild("Functions"):QueryDescendants("ModuleScript")
table.sort(descendants, function(a, b)
	return a:GetFullName() < b:GetFullName()
end)

for _, descendant in descendants do
	registerModule(descendant)
end

return StatsFetch