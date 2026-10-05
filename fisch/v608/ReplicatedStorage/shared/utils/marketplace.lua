local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
require(ReplicatedStorage.shared.utils.result)
local RunService = game:GetService("RunService")
local forPlayerSafe

if RunService:IsServer() then
	local ServerScriptService = game:GetService("ServerScriptService")
	local legacyPlayerData = require(ServerScriptService.server.modules.legacyPlayerData)
	forPlayerSafe = legacyPlayerData.forPlayerSafe
else
	local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
	forPlayerSafe = legacyLocalPlayerData.fetch
end

local v = {}
Players.PlayerRemoving:Connect(function(player)
	v[player.UserId] = nil
end)
local Marketplace = {}

function Marketplace.userOwnsGamepassAsync(p, p2: number)
	if not v[p.UserId] then
		v[p.UserId] = {}
	end

	if v[p.UserId][p2] then
		return v[p.UserId][p2]
	end

	local success, result = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, p.UserId, p2)

	if not success then
		warn(result)
		return false
	end

	if v[p.UserId] then
		v[p.UserId][p2] = result
	end

	return result
end

function Marketplace.userHasGamepassAsync(p, p2: number)
	local v2 = forPlayerSafe(p)

	if v2 and v2:WaitForChild("Gamepasses"):FindFirstChild((tostring(p2))) then
		return true
	end

	return false
end

return Marketplace