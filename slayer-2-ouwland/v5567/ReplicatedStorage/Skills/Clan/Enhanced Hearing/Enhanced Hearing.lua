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
local EnhancedHearing = {
	Id = 0
}
local localPlayer = Players.LocalPlayer
local getvaluesfolder = Utility.getvaluesfolder(localPlayer, true)
local skill_stand_still = skills:WaitForChild("holder"):WaitForChild("skill_stand_still")

function EnhancedHearing.Hold(player)
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
	local id = EnhancedHearing.Id
	local clone = skill_stand_still:Clone()
	clone.Parent = humanoidRootPart
	maid:Add(clone)
	DebrisModule:AddItem(clone, Config.WINDUP)
	maid:Add(Utility.AddValue(getvaluesfolder, "NR", Config.WINDUP))
	local enhancedHearing = script:FindFirstChild("EnhancedHearing") or script:FindFirstChild("Animation")
	local animator = humanoid:FindFirstChild("Animator")
	local track

	if enhancedHearing == nil or animator == nil then
		track = nil
	else
		track = animator:LoadAnimation(enhancedHearing)
		maid:Add(track)
		track:Play()
		track.Stopped:Once(function()
			track:Destroy()
		end)
	end

	task.wait(Config.WINDUP)

	if id ~= EnhancedHearing.Id then
		return true
	end

	if track ~= nil then
		maid:Remove(track)
	end

	maid:Clean()
	return true
end

function EnhancedHearing.Cancel(_)
	maid:Clean()
end

return EnhancedHearing