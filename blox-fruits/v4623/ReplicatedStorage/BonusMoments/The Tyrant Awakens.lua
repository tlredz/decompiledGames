require(game.ReplicatedStorage.Controllers.BonusMomentsController.Types)
local Util = require(game.ReplicatedStorage.Util)
local v = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function stopAmbience()
	local v2 = v
	v = nil

	if not v2 then
		return
	end

	pcall(function()
		Util.Sound:FadeOut(v2, 2.5)
	end)
end

local function startAmbience(vector: Vector3)
	stopAmbience() -- equivalent call inferred; original call site unknown
	local success, result = pcall(function()
		return Util.Sound:Play("UpperSkySFX.BF_UpperSky_Temple_Dark_Shaking_Angry_Ambience_01", vector, 20, 1, 0.7, 2)
	end)

	if not success or typeof(result) ~= "Instance" or not result:IsA("Sound") then
		return
	end

	result.Looped = true
	v = result
end

local TheTyrantAwakens = {}

function TheTyrantAwakens.OnLoad(maid)
	stopAmbience() -- equivalent call inferred; original call site unknown
	maid:GiveTask(stopAmbience)
end

TheTyrantAwakens.RemoteEvents = {
	Awakened = function(_, p)
		if typeof(p) == "Vector3" then
			startAmbience(p)
		else
			warn("[The Tyrant Awakens] no arena centre to anchor the ambience to")
		end
	end
}

function TheTyrantAwakens.OnComplete(_, _, _)
	local v2 = v
	v = nil

	if not v2 then
		return
	end

	pcall(function()
		Util.Sound:FadeOut(v2, 2.5)
	end)
end

return TheTyrantAwakens