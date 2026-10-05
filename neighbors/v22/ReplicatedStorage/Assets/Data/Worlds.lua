local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Global = require(script.Parent.Global)
local Worlds = {
	Neighborhood = {
		Display = "Normal Servers",
		Order = 1,
		Thumbnail = 13295838581,
		Description = "Just a normal neighborhood server!",
		MaxPlayers = Players.MaxPlayers,
		PlaceId = 12699642568,
		NonVoiceId = 13108856598,
		TestPlaceId = 12022882036,
		AdultPlaceId = 14236925335
	},
	Custom = {
		Display = "Custom Servers",
		Order = 999,
		Thumbnail = 13416997913,
		Description = "Custom servers!",
		MaxPlayers = Players.MaxPlayers,
		PlaceId = 0,
		NonVoiceId = 0,
		TestPlaceId = 0,
		AdultPlaceId = 0
	}
}

if game.GameId == Global.TestGameId then
	for _, v in next, Worlds, nil do
		v.PlaceId = v.TestPlaceId
		v.NonVoiceId = v.TestPlaceId
	end
elseif game.GameId == Global.AdultGameId then
	for _, v in next, Worlds, nil do
		v.PlaceId = v.AdultPlaceId
		v.NonVoiceId = v.AdultPlaceId
	end
end

for k, v in next, Worlds, nil do
	v.Name = k
end

local neighborhood = Worlds.Neighborhood
neighborhood.GameId = game.GameId

-- equivalent calls inferred from this helper; original call sites unknown
local function updatePlaceIds()
	local Places = require(script.Places)
	neighborhood.CustomId = Places.Places.Custom
	neighborhood.NonVoiceId = Places.Places.NON_VC or neighborhood.NonVoiceId
end

if not RunService:IsStudio() then
	task.spawn(updatePlaceIds)
	return Worlds
end

updatePlaceIds() -- equivalent call inferred; original call site unknown
return Worlds