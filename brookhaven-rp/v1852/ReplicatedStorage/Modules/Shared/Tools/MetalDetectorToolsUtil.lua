local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ExclusionConfig = require(ReplicatedStorage.Modules.Shared.DB.Exclusion.ExclusionConfig)
local v = { "Axe", "Hammer", "Wrench" }
local v2 = {}
local MetalDetectorToolsUtil = {}
local v3 = {
	Guns = true,
	Explosives = true,
	Military = true
}

for _, v4 in v do
	v2[v4] = true
end

MetalDetectorToolsUtil.ADDITIONAL_PROHIBITED_TOOLS = v
MetalDetectorToolsUtil.PROHIBITED_TOOLS = v

local function isInProhibitedExclusionGroup(p: string)
	if ExclusionConfig.isLoaded ~= true then
		return false
	end

	local group = ExclusionConfig.GetGroupById(p)
	return group ~= nil and v3[group] == true
end

function MetalDetectorToolsUtil.isProhibitedTool(instance)
	if v2[instance.Name] == true or instance:HasTag("GunTool") then
		return true
	end

	local name = instance.Name

	if ExclusionConfig.isLoaded ~= true then
		return false
	end

	local group = ExclusionConfig.GetGroupById(name)
	return group ~= nil and v3[group] == true
end

function MetalDetectorToolsUtil.collectProhibitedTools(instance)
	local tools = {}

	for _, tool in instance:GetChildren() do
		if tool:IsA("Tool") and MetalDetectorToolsUtil.isProhibitedTool(tool) then
			table.insert(tools, tool)
		end
	end

	return tools
end

function MetalDetectorToolsUtil.getCarriedProhibitedTools(player)
	local result = {}
	local character = player.Character

	if character ~= nil then
		for _, v4 in MetalDetectorToolsUtil.collectProhibitedTools(character) do
			table.insert(result, v4)
		end
	end

	for _, v4 in MetalDetectorToolsUtil.collectProhibitedTools(player.Backpack) do
		table.insert(result, v4)
	end

	return result
end

function MetalDetectorToolsUtil.playerCarriesProhibitedTool(player)
	local character = player.Character

	if character ~= nil then
		for _, tool in character:GetChildren() do
			if tool:IsA("Tool") and MetalDetectorToolsUtil.isProhibitedTool(tool) then
				return true
			end
		end
	end

	for _, tool in player.Backpack:GetChildren() do
		if tool:IsA("Tool") and MetalDetectorToolsUtil.isProhibitedTool(tool) then
			return true
		end
	end

	return false
end

return MetalDetectorToolsUtil