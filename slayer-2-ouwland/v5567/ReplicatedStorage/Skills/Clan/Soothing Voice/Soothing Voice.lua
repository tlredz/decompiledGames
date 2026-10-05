local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local global = CAM:WaitForChild("Global")
local skills = ReplicatedStorage:WaitForChild("Skills")
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local maid = cleanit.new()
local Utility = require(global:WaitForChild("Utility"))
local DebrisModule = require(CAM:WaitForChild("DebrisModule"))
local Config = require(script.Parent.Config)
local SoothingVoice = {
	Id = 0
}
local localPlayer = Players.LocalPlayer
local getvaluesfolder = Utility.getvaluesfolder(localPlayer, true)
local skill_stand_still = skills:WaitForChild("holder"):WaitForChild("skill_stand_still")
local track = nil

function SoothingVoice.Hold(player)
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
	local id = SoothingVoice.Id
	local WINDUP = Config.WINDUP
	local clone = skill_stand_still:Clone()
	clone.Parent = humanoidRootPart
	maid:Add(clone)
	DebrisModule:AddItem(clone, WINDUP)
	maid:Add(Utility.AddValue(getvaluesfolder, "NR", WINDUP))
	local animation = script:FindFirstChild("Animation")
	local animator = humanoid:FindFirstChild("Animator")

	if animation ~= nil and animator ~= nil then
		if track ~= nil then
			track:Stop()
		end

		track = animator:LoadAnimation(animation)
		track:Play()
	end

	task.wait(WINDUP)

	if id ~= SoothingVoice.Id then
		return true
	end

	maid:Clean()
	return true
end

function SoothingVoice.Cancel(_)
	if track ~= nil then
		track:Stop()
		track = nil
	end

	maid:Clean()
end

return SoothingVoice