local Players = game:GetService("Players")
local Util = require(game.ReplicatedStorage:WaitForChild("Util"))
local Global = require(game.ReplicatedStorage.Global)
local v = { "Enemies", "SeaBeasts" }
local localPlayer = Players.LocalPlayer
local v2 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function isAlive(model)
	local humanoid = model:FindFirstChildOfClass("Humanoid")

	if humanoid then
		return humanoid.Health > 0
	end

	local health = model:FindFirstChild("Health")
	return not (health and health:IsA("IntValue")) or health.Value > 0
end

local function isEngaged()
	for _, childName in v do
		local child = workspace:FindFirstChild(childName)

		if not child then
			continue
		end

		for _, model in child:GetChildren() do
			if not (model:IsA("Model") and model:GetAttribute("BossEngagedWith") == localPlayer.UserId) then
				continue
			end

			-- equivalent call inferred; original call site unknown
			if isAlive(model) then
				return true
			end
		end
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function musicMuted()
	local isMusicMuted = Global.isMusicMuted

	if type(isMusicMuted) ~= "function" then
		return false
	end

	local success, result = pcall(isMusicMuted)
	return success and result == true
end

local function setMusic(engaged: boolean)
	if engaged == (v2 ~= nil) then
		return
	end

	if engaged then
		local v3 = Util.Sound:Play("BossMisc.BossBattleMusic", nil, {
			fadeIn = 1.5
		})
		v3.Looped = true
		v2 = v3
	else
		local v3 = v2
		v2 = nil

		if v3 then
			Util.Sound:FadeOut(v3, 2.5)
		end
	end
end

while true do
	local engaged = isEngaged()

	if engaged then
		local v3 = musicMuted() -- equivalent call inferred; original call site unknown
		engaged = not v3
	end

	setMusic(engaged)
	task.wait(0.35)
end