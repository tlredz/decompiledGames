local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SharedDataHelper = require(ReplicatedStorage.shared.modules.SharedDataHelper)
local Signal = require(ReplicatedStorage.packages.Signal)
local FischUtils = require(ReplicatedStorage.shared.utils.FischUtils)
local v, v2

if RunService:IsServer() then
	local Net = require(ReplicatedStorage.packages.Net)
	v = Net:RemoteEvent("IdolFavor/LevelUp")
	v2 = Net:RemoteEvent("IdolFavor/Progress")
else
	v = nil
	v2 = nil
end

local SharedIdolFavor = {
	MAX_LEVEL = 100,
	XP_PER_LEVEL = 95,
	OnLevelUp = Signal.new(),
	OnFavorGained = Signal.new(),
	ZONES = {
		Skycrest = true,
		["Abaia Hunt"] = true,
		["Abaia's Chamber"] = true
	}
}

function SharedIdolFavor.IsInSkycrestZone(p)
	local playerZone = FischUtils.GetPlayerZone(p)
	return playerZone and SharedIdolFavor.ZONES[playerZone] or false
end

local v3 = {}

function SharedIdolFavor.GetXPForLevel(p: number)
	return p * SharedIdolFavor.XP_PER_LEVEL
end

function SharedIdolFavor.GetLevel(p)
	return SharedDataHelper.indexNewFormat(p, { "Skycrest", "Favor", "Level" }) or 0
end

function SharedIdolFavor.GetXP(p)
	return SharedDataHelper.indexNewFormat(p, { "Skycrest", "Favor", "XP" }) or 0
end

function SharedIdolFavor.GetXPForNextLevel(p: number)
	if SharedIdolFavor.MAX_LEVEL <= p then
		return nil
	end

	return SharedIdolFavor.GetXPForLevel(p + 1)
end

function SharedIdolFavor.HasLevel(p, p2: number)
	return p2 <= SharedIdolFavor.GetLevel(p)
end

function SharedIdolFavor.SetGainModifier(p, p2: string, p3: number?)
	assert(RunService:IsServer(), "SetGainModifier can only be called on the server")
	local v4 = v3[p]

	if not v4 then
		if p3 == nil then
			return
		end

		v4 = {}
		v3[p] = v4
	end

	v4[p2] = p3
end

function SharedIdolFavor.GetGainMultiplier(p)
	local v4 = 1
	local v5 = v3[p]

	if v5 then
		for _, v6 in v5 do
			v4 *= v6
		end
	end

	return v4
end

function SharedIdolFavor.GiveFavor(player, p: number, flag: boolean?)
	assert(RunService:IsServer(), "GiveFavor can only be called on the server")

	if p <= 0 then
		return
	end

	local ServerScriptService = game:GetService("ServerScriptService")
	local DataService = require(ServerScriptService.server.legacyServices.DataService)
	local newFormat = DataService:GetNewFormat(player)

	if not newFormat then
		return
	end

	local favor = newFormat.Skycrest.Favor

	if favor.Level >= SharedIdolFavor.MAX_LEVEL then
		return
	end

	if not flag then
		p = math.floor(p * SharedIdolFavor.GetGainMultiplier(player) + 0.5)
	end

	if p <= 0 then
		return
	end

	local level = favor.Level
	favor.XP += p
	local v4 = false

	while favor.Level < SharedIdolFavor.MAX_LEVEL do
		local xPForLevel = SharedIdolFavor.GetXPForLevel(favor.Level + 1)

		if favor.XP < xPForLevel then
			break
		end

		favor.Level += 1
		favor.XP -= xPForLevel
		v4 = true
	end

	SharedIdolFavor.OnFavorGained:Fire(player, p)

	if v4 and v then
		v:FireClient(player, level, favor.Level, favor.XP, p)
		SharedIdolFavor.OnLevelUp:Fire(player, level, favor.Level)
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
		v2:FireClient(player, p, favor.XP, favor.Level)
	end
end

if RunService:IsServer() then
	Players.PlayerRemoving:Connect(function(player)
		v3[player] = nil
	end)
end

return SharedIdolFavor