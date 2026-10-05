local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedDataHelper = require(ReplicatedStorage.shared.modules.SharedDataHelper)
local Signal = require(ReplicatedStorage.packages.Signal)
local FischUtils = require(ReplicatedStorage.shared.utils.FischUtils)
local v, v2

if RunService:IsServer() then
	local Net = require(ReplicatedStorage.packages.Net)
	v = Net:RemoteEvent("KeeperLevel/LevelUp")
	v2 = Net:RemoteEvent("KeeperLevel/Progress")
else
	v = nil
	v2 = nil
end

local Level = {
	MAX_LEVEL = 5,
	XP_PER_LEVEL = 150,
	OnLevelUp = Signal.new(),
	ZONES = {
		["Keepers Altar"] = true,
		["Enchanted Crevice"] = true
	}
}

function Level.IsInKeeperZone(p)
	local playerZone = FischUtils.GetPlayerZone(p)
	return playerZone and Level.ZONES[playerZone] or false
end

function Level.GetXPForLevel(p: number)
	return p * Level.XP_PER_LEVEL
end

function Level.GetLevel(p)
	return SharedDataHelper.indexNewFormat(p, { "StatuesSecret", "Keeper", "Level" }) or 0
end

function Level.GetXP(p)
	return SharedDataHelper.indexNewFormat(p, { "StatuesSecret", "Keeper", "XP" }) or 0
end

function Level.GetXPForNextLevel(p: number)
	if Level.MAX_LEVEL <= p then
		return nil
	end

	return Level.GetXPForLevel(p + 1)
end

function Level.GetActiveKeeperboundCount(p)
	local indexNewFormat = SharedDataHelper.indexNewFormat(p, { "Rods" })

	if not indexNewFormat then
		return 0
	end

	local count = 0

	for _, v3 in indexNewFormat do
		if v3.keeperboundActive then
			count += 1
		end
	end

	return count
end

function Level.CanActivateKeeperbound(p)
	local level = Level.GetLevel(p)
	return not (level <= 0) and Level.GetActiveKeeperboundCount(p) < level
end

function Level.GiveXP(player, p: number)
	assert(RunService:IsServer(), "GiveXP can only be called on the server")

	if p <= 0 then
		return
	end

	local ServerScriptService = game:GetService("ServerScriptService")
	local DataService = require(ServerScriptService.server.legacyServices.DataService)
	local profile = DataService:GetProfile(player)

	if not profile then
		return
	end

	local statuesSecret = profile.Data.NewFormat.StatuesSecret

	if not (statuesSecret and statuesSecret.Keeper) then
		return
	end

	local keeper = statuesSecret.Keeper

	if keeper.Level >= Level.MAX_LEVEL then
		return
	end

	local level = keeper.Level
	keeper.XP += p
	local v3 = false

	while keeper.Level < Level.MAX_LEVEL and not (Level.GetXPForLevel(keeper.Level + 1) > keeper.XP) do
		keeper.Level += 1
		v3 = true
	end

	if v3 and v then
		v:FireClient(player, level, keeper.Level, keeper.XP)
		Level.OnLevelUp:Fire(player, level, keeper.Level)
		task.delay(0.7, function()
			local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local fx = require(ReplicatedStorage.shared.modules.fx)
			local clone = ReplicatedStorage.resources.replicated.fx.lvlup:Clone()
			clone.Enabled = false
			clone.Parent = humanoidRootPart
			clone:Emit(math.random(30, 56))
			Debris:AddItem(clone, 4)
			fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.player.levelup, humanoidRootPart, false)
		end)
	elseif v2 then
		v2:FireClient(player, p, keeper.XP, keeper.Level)
	end
end

return Level