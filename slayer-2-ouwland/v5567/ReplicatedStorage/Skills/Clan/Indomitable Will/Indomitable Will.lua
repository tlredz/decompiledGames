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
local IndomitableWill = {
	Id = 0
}
local localPlayer = Players.LocalPlayer
local getvaluesfolder = Utility.getvaluesfolder(localPlayer, true)
local skill_stand_still = skills:WaitForChild("holder"):WaitForChild("skill_stand_still")
local v = false
local v2 = nil

local function playClip(character, childName: string, HOLD_WINDUP_SPEED: number?)
	local humanoid = character:FindFirstChild("Humanoid")
	local animator = humanoid and humanoid:FindFirstChild("Animator")
	local child = script:FindFirstChild(childName)

	if animator == nil or child == nil then
		return nil
	end

	local track = animator:LoadAnimation(child)
	track:Play()

	if HOLD_WINDUP_SPEED ~= nil then
		track:AdjustSpeed(HOLD_WINDUP_SPEED)
	end

	v2 = track
	return track
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopActive()
	if v2 ~= nil then
		v2:Stop()
		v2 = nil
	end
end

function IndomitableWill.Hold(player)
	if player == nil then
		return
	end

	local character = player.Character

	if character == nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	maid:Clean()
	v = false
	local clone = skill_stand_still:Clone()
	clone.Parent = humanoidRootPart
	maid:Add(clone)
	DebrisModule:AddItem(clone, Config.TAP_WINDOW)
	maid:Add(Utility.AddValue(getvaluesfolder, "NR", Config.TAP_WINDOW))
	stopActive() -- equivalent call inferred; original call site unknown
	local humanoid = character:FindFirstChild("Humanoid")
	local animator = humanoid and humanoid:FindFirstChild("Animator")
	local tapped = script:FindFirstChild("Tapped")

	if animator ~= nil and tapped ~= nil then
		local track = animator:LoadAnimation(tapped)
		track:Play()
		v2 = track
	end

	local id = IndomitableWill.Id
	task.delay(Config.TAP_WINDOW, function()
		if id ~= IndomitableWill.Id or v or character.Parent == nil then
			return
		end

		stopActive() -- equivalent call inferred; original call site unknown
		playClip(character, "Held", Config.HOLD_WINDUP_SPEED)
	end)
end

function IndomitableWill.UnHold(_)
	v = true
	maid:Clean()
	return true
end

function IndomitableWill.Cancel(_)
	v = true
	stopActive() -- equivalent call inferred; original call site unknown
	maid:Clean()
end

return IndomitableWill