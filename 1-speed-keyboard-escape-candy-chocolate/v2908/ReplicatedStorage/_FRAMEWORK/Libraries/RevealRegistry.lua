local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlaceRegistry = require(ReplicatedStorage.Config.PlaceRegistry)
local v = PlaceRegistry.getGroupName() == "CCWorlds"
local v2 = {}
local RevealRegistry = {}

function RevealRegistry.isAllRevealed()
	return v
end

function RevealRegistry.isRevealed(p: string)
	return v or v2[p] == true
end

function RevealRegistry.setRevealed(p: string, flag: boolean)
	if flag then
		v2[p] = true
	else
		v2[p] = nil
	end
end

return RevealRegistry