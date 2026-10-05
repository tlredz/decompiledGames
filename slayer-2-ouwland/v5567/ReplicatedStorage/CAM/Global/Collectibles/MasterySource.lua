local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local Breathings = require(ReplicatedStorage.CAM.Global.Powers.Breathings)
local DemonArts = require(ReplicatedStorage.CAM.Global.Powers.DemonArts)
local FightingStyles = require(ReplicatedStorage.CAM.Global.Powers.FightingStyles)
local Clans = require(ReplicatedStorage.CAM.Clans)
local PlayerProgression = require(ReplicatedStorage.CAM.Global.PlayerProgression)
local frozen = table.freeze({
	Mastery = false
})
local frozen2 = table.freeze({
	Mastery = false
})
return function(p: string?)
	if p == nil then
		return nil
	end

	local v = Items[p] or Breathings[p] or DemonArts[p] or FightingStyles[p]

	if v ~= nil then
		return v
	end

	if Clans.GetClan(p) ~= nil then
		return frozen
	end

	if PlayerProgression.GrantedSkills[p] == nil then
		return nil
	end

	return frozen2
end