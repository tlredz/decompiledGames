local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Players")
local legacyControllers = ReplicatedStorage.client.legacyControllers
local DataController = require(legacyControllers.DataController)
local modules = ReplicatedStorage.shared.modules
local LuminescentCavern = require(modules.LuminescentCavern)
local module = require("@self/VFX")
local module2 = require("@self/LocalDataState")
local module3 = require("@self/CrimsonCavern")
local v = false
local v2 = false
local v3 = false
local LuminescentCavernController = {
	EstablishedEnumKeys = {}
}

function LuminescentCavernController.Start(_)
	if not LuminescentCavern.IsEnabled then
		return
	end

	DataController.PlayerDataReplicator:Observe({ "LuminescentCavern" }, LuminescentCavernController._OnDataChanged)
	require("@self/Components")
	module3:Init()
end

function LuminescentCavernController._OnDataChanged(p)
	if not p then
		return
	end

	local function isPedestalsCompleted(p2)
		if not (p2 and p2.KeystoneData.RequiredKeystones) then
			return false
		end

		for k, _ in p2.KeystoneData.RequiredKeystones do
			if not p2.KeystoneData.PlacedKeystones[k] then
				return false
			end
		end

		return true
	end

	if not v2 then
		v2 = true
		local flag

		if p and p.KeystoneData.RequiredKeystones then
			local flag2 = true

			for k, _ in p.KeystoneData.RequiredKeystones do
				if p.KeystoneData.PlacedKeystones[k] then
					continue
				end

				flag = false
				flag2 = false
				break
			end

			if flag2 then
				flag = true
			end
		else
			flag = false
		end

		if flag then
			v = true
		end
	end

	if not v then
		local flag

		if p and p.KeystoneData.RequiredKeystones then
			local flag2 = true

			for k, _ in p.KeystoneData.RequiredKeystones do
				if p.KeystoneData.PlacedKeystones[k] then
					continue
				end

				flag = false
				flag2 = false
				break
			end

			if flag2 then
				flag = true
			end
		else
			flag = false
		end

		if flag then
			v = true
			module.CameraShake()
			local tagged = CollectionService:GetTagged(LuminescentCavern.Enums.CollectionService.SeaMine)

			for _, v4 in tagged do
				module.SeaMineExplosion(v4)
			end
		end
	end

	if p.KeystoneData.CrimsonCavernUnlocked and not v3 then
		v3 = true
		module3:OnUnlocked()
	end

	module2:set(p)
end

return LuminescentCavernController