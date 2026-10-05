local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Conch = require(ReplicatedStorage.Packages.Conch)
local Net = require(ReplicatedStorage.Packages.Net)
local indexes = {}

if RunService:IsServer() then
	local ServerScriptService = game:GetService("ServerScriptService")
	local EggBalancing = require(ServerScriptService.Services.JumpLTMService.EggBalancing)

	for _, v in EggBalancing.GetIslands() do
		for _, v2 in v do
			table.insert(indexes, v2.Index)
		end
	end

	Net:Handle("JumpEgg/RequestList", function()
		return indexes
	end)
else
	indexes = Net:Invoke("JumpEgg/RequestList")
end

return Conch.register_type("JumpEgg", Conch.args.enum_new(indexes))