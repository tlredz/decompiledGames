local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.Packages.Net)

if not RunService:IsServer() then
	return Net:Invoke("BrainrotToCraft/RequestList")
end

local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CraftingData = require(ServerStorage.Modules.CraftingData)
local CommandsService = require(ServerScriptService.Services.CommandsService)
local List = {}

for _, rarity in CraftingData.Rarities do
	for _, brainrot in rarity.Brainrots do
		table.insert(List, brainrot.Name)
	end
end

Net:Handle("BrainrotToCraft/RequestList", function(p)
	local roleAsync = CommandsService:GetRoleAsync(p)

	if roleAsync == "Dev" or roleAsync == "Lead" then
		return List
	end

	return {}
end)
return List