local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.Packages.Net)

if not RunService:IsServer() then
	return Net:Invoke("BrainrotToCupid/RequestList")
end

local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CupidsMachineData = require(ServerStorage.Modules.CupidsMachineData)
local CommandsService = require(ServerScriptService.Services.CommandsService)
local List = {}

for _, recipe in CupidsMachineData.Recipes do
	table.insert(List, recipe.Name)
end

Net:Handle("BrainrotToCupid/RequestList", function(p)
	local roleAsync = CommandsService:GetRoleAsync(p)

	if roleAsync == "Dev" or roleAsync == "Lead" then
		return List
	end

	return {}
end)
return List