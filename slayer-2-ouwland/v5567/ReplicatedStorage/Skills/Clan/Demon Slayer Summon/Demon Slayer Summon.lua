local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local global = CAM:WaitForChild("Global")
local skills = ReplicatedStorage:WaitForChild("Skills")
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local maid = cleanit.new()
local Utility = require(global:WaitForChild("Utility"))
local RaycastHelper = require(global:WaitForChild("RaycastHelper"))
local DebrisModule = require(CAM:WaitForChild("DebrisModule"))
local Platform_Handler = require(CAM.Client.Controllers.Platform_Handler)
local SkillAimMarker = require(CAM.Client.Modules.Effects.SkillAimMarker)
local Config = require(script.Parent.Config)
local DemonSlayerSummon = {
	Id = 0
}
local v = nil
local localPlayer = Players.LocalPlayer
local getvaluesfolder = Utility.getvaluesfolder(localPlayer, true)
local skill_stand_still = skills:WaitForChild("holder"):WaitForChild("skill_stand_still")
local v2 = { "Whisle", "Whistle", "DemonSlayerSummon" }

local function findWhistleClip()
	for _, childName in v2 do
		local child = script:FindFirstChild(childName)

		if child ~= nil then
			return child
		end
	end

	local effects = ReplicatedStorage:FindFirstChild("Effects")
	local clans = effects and effects:FindFirstChild("Clans")
	local demonSlayerSummonVFX = clans and clans:FindFirstChild("DemonSlayerSummonVFX")

	if demonSlayerSummonVFX == nil then
		return nil
	end

	for _, childName in v2 do
		local child = demonSlayerSummonVFX:FindFirstChild(childName)

		if child ~= nil then
			return child
		end
	end

	return nil
end

function DemonSlayerSummon.Hold(player)
	if player == nil then
		return
	end

	local character = player.Character

	if character == nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoidRootPart == nil or humanoid == nil then
		return
	end

	maid:Clean()
	local id = DemonSlayerSummon.Id
	local clone = skill_stand_still:Clone()
	clone.Parent = humanoidRootPart
	maid:Add(clone)
	DebrisModule:AddItem(clone, Config.MAX_AIM + Config.LOCK)
	maid:Add(Utility.AddValue(getvaluesfolder, "NR", Config.MAX_AIM + Config.LOCK))
	v = nil
	local whistleClip = findWhistleClip()
	local animator = humanoid:FindFirstChild("Animator")

	if whistleClip ~= nil and animator ~= nil then
		local track = animator:LoadAnimation(whistleClip)
		v = track
		maid:Add(track)
		track:Play()
		track.Stopped:Once(function()
			if v == track then
				v = nil
			end

			track:Destroy()
		end)
		task.delay(Config.WHISTLE_PAUSE_AT, function()
			if id ~= DemonSlayerSummon.Id then
				return
			end

			if track.IsPlaying then
				track:AdjustSpeed(0)
			end
		end)
	end

	local alignOrientationWithAttachment, v3 = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			AlignType = Enum.AlignType.PrimaryAxisParallel,
			Responsiveness = 75,
			MaxTorque = 3000
		}
	)
	maid:Add(alignOrientationWithAttachment)
	maid:Add(v3)
	local v4 = SkillAimMarker.new({
		Highlight = true
	})
	maid:Add(v4)
	maid:Connect(RunService.PostSimulation, function()
		if id ~= DemonSlayerSummon.Id then
			return
		end

		local maximizeRayClient, _, _, target = RaycastHelper.MaximizeRayClient(
			humanoidRootPart.Position,
			Platform_Handler.mousepos(Config.MOUSE_RANGE),
			Config.TARGET_RANGE,
			true,
			Config.SPHERECAST_RADIUS,
			Config.DOWNCAST
		)
		alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
			humanoidRootPart.Position,
			maximizeRayClient,
			alignOrientationWithAttachment.CFrame
		)
		v4:Update({
			position = maximizeRayClient,
			target = target
		})
	end)
end

function DemonSlayerSummon.UnHold(player)
	local v3 = v
	v = nil

	if v3 ~= nil then
		maid:Remove(v3)
	end

	maid:Clean()

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

	local id = DemonSlayerSummon.Id
	local clone = skill_stand_still:Clone()
	clone.Parent = humanoidRootPart
	maid:Add(clone)
	DebrisModule:AddItem(clone, Config.LOCK)
	maid:Add(Utility.AddValue(getvaluesfolder, "NR", Config.LOCK))

	if v3 ~= nil and v3.IsPlaying then
		if v3.TimePosition < Config.WHISTLE_PAUSE_AT then
			v3.TimePosition = Config.WHISTLE_PAUSE_AT
		end

		v3:AdjustSpeed(1)
	end

	task.wait(Config.LOCK)

	if id ~= DemonSlayerSummon.Id then
		return false
	end

	maid:Clean()
	return false
end

function DemonSlayerSummon.Cancel(_)
	v = nil
	maid:Clean()
end

return DemonSlayerSummon