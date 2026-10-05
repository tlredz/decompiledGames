local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Conch = require(ReplicatedStorage.Packages.Conch)
local Net = require(ReplicatedStorage.Packages.Net)
local result = {}

if RunService:IsServer() then
	local ServerStorage = game:GetService("ServerStorage")
	local ServerScriptService = game:GetService("ServerScriptService")
	local Animals = require(ReplicatedStorage.Datas.Animals)
	local TempAdminAccess = require(ServerStorage.Modules.TempAdminAccess)
	local CommandsService = require(ServerScriptService.Services.CommandsService)

	for k, animal in Animals do
		if not animal.LuckyBlock then
			table.insert(result, k)
		end
	end

	Net:Handle("SpawnAmountBrainrot/RequestList", function(p)
		if CommandsService:GetRoleAsync(p) == "TempAdmin" then
			return TempAdminAccess.GetSpawnStockList()
		end

		return result
	end)
else
	result = Net:Invoke("SpawnAmountBrainrot/RequestList")
end

return Conch.register_type("SpawnAmountBrainrot", Conch.args.enum_new(result))