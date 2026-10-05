local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local Global = require(ReplicatedStorage:WaitForChild("Global"))
local localPlayer = Players.LocalPlayer

while not Global.PersistentLoaded and localPlayer.TeamColor == BrickColor.White() do
	task.wait()
end

local effectContainer = ReplicatedStorage:WaitForChild("EffectContainer", 999999)

if not (effectContainer and effectContainer:WaitForChild("WorldCountdown", 999999)) then
	return
end

local v = nil

local function sync()
	local worldEventCountdownStart = tonumber(workspace:GetAttribute("WorldEventCountdownStart"))

	if not workspace:GetAttribute("WorldEventCountdownActive") or not worldEventCountdownStart or worldEventCountdownStart == v then
		return
	end

	v = worldEventCountdownStart
	Effect.new("WorldCountdown"):play({
		StartTime = worldEventCountdownStart,
		TriggerTime = tonumber(workspace:GetAttribute("WorldEventCountdownTrigger")) or worldEventCountdownStart + 300,
		PreludeLead = tonumber(workspace:GetAttribute("WorldEventCountdownPreludeLead")) or 60,
		DisplayOnly = workspace:GetAttribute("WorldEventCountdownDisplayOnly") == true
	})
end

workspace:GetAttributeChangedSignal("WorldEventCountdownStart"):Connect(sync)
workspace:GetAttributeChangedSignal("WorldEventCountdownActive"):Connect(sync)
sync()