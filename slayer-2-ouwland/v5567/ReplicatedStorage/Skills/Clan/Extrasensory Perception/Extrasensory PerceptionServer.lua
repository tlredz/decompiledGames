local ReplicatedStorage = game:GetService("ReplicatedStorage")
local global = ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global")
local Utility = require(global:WaitForChild("Utility"))
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local ManuelCancel = require(global.Subsets.Gameplay.ManuelCancel)
local Config = require(script.Parent.Config)
local ExtrasensoryPerceptionServer = {
	Id = {}
}

function ExtrasensoryPerceptionServer.Hold(player, _, _)
	local character = player.Character

	if character == nil then
		return false
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return false
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.LOCK)
	EffectsEvent.ToAllInRange(player, "ActivationVFX", character)
	local v = ExtrasensoryPerceptionServer.Id[player.UserId]
	local v2, v3 = ManuelCancel.new(player, Config.LOCK)
	v2:Connect(function()
		v = -1
		v3()
	end)
	task.wait(Config.LOCK)

	if v ~= ExtrasensoryPerceptionServer.Id[player.UserId] or humanoidRootPart.Parent == nil then
		v3()
		return false
	end

	Utility.AddDodges(character, Config.DODGES, Config.DODGE_WINDOW, true, script.Parent.Name)
	v3()
	return true
end

function ExtrasensoryPerceptionServer.Cancel(p, _, _)
	if p == nil then
	end
end

return ExtrasensoryPerceptionServer