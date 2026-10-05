local VehicleSpeedUtil = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local t = require(ReplicatedStorage.Packages.t)
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local AdFeatures = require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
VehicleSpeedUtil.DEFAULT_MAX_SPEED = 55
VehicleSpeedUtil.PREMIUM_MAX_SPEED = 75
VehicleSpeedUtil.VEHICLE_UPGRADE_MAX_SPEED = 100
VehicleSpeedUtil.VEHICLE_SPEED_UNLOCKED_MAX_SPEED = 200

function VehicleSpeedUtil.GetMaxSpeedForPlayer(p)
	if RunService:IsServer() then
		if v.IsOwned(p, Gamepasses.VEHICLE_SPEED_UNLOCKED) or v4.IsFeatureUnlocked(p, "CarSpeed200") then
			return 200
		end

		if v.IsOwned(p, Gamepasses.VEHICLE_UPGRADE) or v4.IsFeatureUnlocked(p, "CarSpeed") then
			return 100
		end

		if v.IsOwnedLegacy(p, Gamepasses.PREMIUM) then
			return 75
		end
	else
		if v2.IsOwned(Gamepasses.VEHICLE_SPEED_UNLOCKED) or v3.IsFeatureUnlocked(
			AdFeatures.VEHICLE_SPEED_MAX.id,
			Gamepasses.VEHICLE_SPEED_UNLOCKED
		) then
			return 200
		end

		if v2.IsOwned(Gamepasses.VEHICLE_UPGRADE) or v3.IsFeatureUnlocked(
			AdFeatures.VEHICLE_SPEED_UPGRADE.id,
			Gamepasses.VEHICLE_UPGRADE
		) then
			return 100
		end

		if v2.IsOwnedLegacy(Gamepasses.PREMIUM) then
			return 75
		end
	end

	return 55
end

function VehicleSpeedUtil.NormalizeMaxSpeed(p, p2: number)
	if not t.number(p2) then
		return 25
	end

	if VehicleSpeedUtil.GetMaxSpeedForPlayer(p) < p2 then
		return VehicleSpeedUtil.GetMaxSpeedForPlayer(p)
	end

	if p2 < 10 then
		return 10
	end

	return p2
end

function VehicleSpeedUtil.FrameworkInit() end

function VehicleSpeedUtil.FrameworkStart()
	if RunService:IsServer() then
		local ServerScriptService = game:GetService("ServerScriptService")
		local GamepassService = require(ServerScriptService.Modules.PlayerData.GamepassService)
		v = GamepassService
		local UnlockablesService = require(ServerScriptService.Modules.PlayerData.UnlockablesService)
		v4 = UnlockablesService
	else
		local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
		v3 = UnlockableController
		local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
		v2 = GamepassController
	end
end

return VehicleSpeedUtil