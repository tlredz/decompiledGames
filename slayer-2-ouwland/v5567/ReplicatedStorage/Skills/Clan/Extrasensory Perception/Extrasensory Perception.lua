local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local global = ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global")
local skills = ReplicatedStorage:WaitForChild("Skills")
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local maid = cleanit.new()
local Utility = require(global:WaitForChild("Utility"))
local Config = require(script.Parent.Config)
local ExtrasensoryPerception = {
	Id = 0
}
local localPlayer = Players.LocalPlayer
local getvaluesfolder = Utility.getvaluesfolder(localPlayer, true)
local skill_stand_still = skills:WaitForChild("holder"):WaitForChild("skill_stand_still")

function ExtrasensoryPerception.Hold(player)
	if player == nil then
		return false
	end

	local character = player.Character

	if character == nil then
		return false
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoidRootPart == nil or humanoid == nil then
		return false
	end

	maid:Clean()
	local id = ExtrasensoryPerception.Id
	local clone = skill_stand_still:Clone()
	clone.Parent = humanoidRootPart
	maid:Add(clone)
	maid:Add(Utility.AddValue(getvaluesfolder, "NR", Config.LOCK))
	local extrasensoryPerception = script:FindFirstChild("ExtrasensoryPerception") or script:FindFirstChild("Animation")
	local animator = humanoid:FindFirstChild("Animator")

	if extrasensoryPerception ~= nil and animator ~= nil then
		local track = animator:LoadAnimation(extrasensoryPerception)
		maid:Add(track)
		track:Play()
	end

	task.wait(Config.LOCK)

	if id ~= ExtrasensoryPerception.Id then
		return true
	end

	maid:Clean()
	return true
end

function ExtrasensoryPerception.Cancel(_)
	maid:Clean()
end

return ExtrasensoryPerception