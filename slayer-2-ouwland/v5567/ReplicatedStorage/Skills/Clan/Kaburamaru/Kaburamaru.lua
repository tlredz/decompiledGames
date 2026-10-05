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
local Platform_Handler = require(CAM.Client.Controllers.Platform_Handler)
local SkillAimMarker = require(CAM.Client.Modules.Effects.SkillAimMarker)
local DebrisModule = require(CAM:WaitForChild("DebrisModule"))
local Config = require(script.Parent.Config)
local Kaburamaru = {
	Id = 0
}
local localPlayer = Players.LocalPlayer
local getvaluesfolder = Utility.getvaluesfolder(localPlayer, true)
local skill_stand_still = skills:WaitForChild("holder"):WaitForChild("skill_stand_still")

function Kaburamaru.Hold(player)
	if player == nil then
		return
	end

	local character = player.Character

	if character == nil then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoid == nil or humanoidRootPart == nil then
		return
	end

	maid:Clean()
	local id = Kaburamaru.Id
	local clone = skill_stand_still:Clone()
	clone.Parent = humanoidRootPart
	maid:Add(clone)
	DebrisModule:AddItem(clone, Config.MAX_AIM + Config.ENDLAG)
	maid:Add(Utility.AddValue(getvaluesfolder, "NR", Config.MAX_AIM + Config.ENDLAG))
	local holdLooped = script:FindFirstChild("HoldLooped")
	local animator = humanoid:FindFirstChildOfClass("Animator")

	if holdLooped ~= nil and animator ~= nil then
		local track = animator:LoadAnimation(holdLooped)
		track.Looped = true
		maid:Add(track)
		track:Play()
	end

	local alignOrientationWithAttachment, v = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			AlignType = Enum.AlignType.PrimaryAxisParallel,
			Responsiveness = 75,
			MaxTorque = 3000
		}
	)
	maid:Add(alignOrientationWithAttachment)
	maid:Add(v)
	local v2 = SkillAimMarker.new({
		Dot = true,
		Highlight = true
	})
	maid:Add(v2)
	maid:Connect(RunService.PostSimulation, function()
		if id ~= Kaburamaru.Id then
			return
		end

		local maximizeRayClient, _, _, target = RaycastHelper.MaximizeRayClient(
			humanoidRootPart.Position,
			Platform_Handler.mousepos(Config.MOUSE_RANGE),
			Config.AIM_RANGE,
			true,
			Config.SPHERECAST_RADIUS,
			Config.DOWNCAST
		)
		alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
			humanoidRootPart.Position,
			maximizeRayClient,
			alignOrientationWithAttachment.CFrame
		)
		v2:Update({
			position = maximizeRayClient,
			target = target
		})
	end)
end

function Kaburamaru.UnHold(player, _: Vector3?, _: boolean?)
	maid:Clean()
	local character = player and player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	local release = script:FindFirstChild("Release")

	if release ~= nil and animator ~= nil then
		animator:LoadAnimation(release):Play()
	end
end

function Kaburamaru.Switch(player)
	if player == nil then
		return
	end

	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")

	if humanoid == nil then
		return
	end

	local kaburamaruBind = script:FindFirstChild("KaburamaruBind")
	local animator = humanoid:FindFirstChildOfClass("Animator")

	if kaburamaruBind == nil or animator == nil then
		return
	end

	local track = animator:LoadAnimation(kaburamaruBind)
	track:Play()
	DebrisModule:AddItem(track, Config.ENDLAG)
end

function Kaburamaru.Cancel(_)
	maid:Clean()
end

return Kaburamaru