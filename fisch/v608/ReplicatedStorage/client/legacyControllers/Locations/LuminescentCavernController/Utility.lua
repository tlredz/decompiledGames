local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = ReplicatedStorage.shared.modules
require(modules.LuminescentCavern)
local v = {
	PlacementsCompleted = false,
	CrackVFXRunning = false
}
local Utility = {}

function Utility.IsPlacementsFinished(p)
	if v.PlacementsCompleted then
		return true
	end

	if not (p and p.KeystoneData and p.KeystoneData.RequiredKeystones) then
		return false
	end

	for k, _ in p.KeystoneData.RequiredKeystones do
		if not p.KeystoneData.PlacedKeystones[k] then
			return false
		end
	end

	v.PlacementsCompleted = true
	return true
end

function Utility.IsCrackVFXRunning()
	return v.CrackVFXRunning
end

function Utility.SetCrackVFXState(crackVFXRunning: boolean)
	v.CrackVFXRunning = crackVFXRunning
end

function Utility.IsKeystoneCollected(p, p2)
	return p.KeystoneData.CollectedKeystones[p2] or false
end

function Utility.IsKeystonePlaced(p, p2)
	return p.KeystoneData.PlacedKeystones[p2] or false
end

return Utility