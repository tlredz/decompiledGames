local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local client = CAM.Client
local global = CAM.Global
local skills = ReplicatedStorage.Skills
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local maid = cleanit.new()
local Platform_Handler = require(client.Controllers.Platform_Handler)
local Utility = require(global.Utility)
local SkillAimMarker = require(client.Modules.Effects.SkillAimMarker)
local RaycastHelper = require(global.RaycastHelper)
local ManuelCancel = require(global.Subsets.Gameplay.ManuelCancel)
local Config = require(script.Parent.Config)
local DemonCore = {
	Id = 0
}
local v = {
	aimMarker = nil,
	startupTrack = nil,
	released = false
}
local skill_stand_still = skills.holder.skill_stand_still
local demonCore = script.DemonCore

local function updateAim(character, humanoidRootPart, p)
	local mousepos = Platform_Handler.mousepos()
	local maximizeRayClient, _, _, target = RaycastHelper.MaximizeRayClient(
		humanoidRootPart.Position,
		mousepos,
		Config.MOUSE_RANGE,
		true,
		3
	)
	local position2 = maximizeRayClient or mousepos
	local position

	if target then
		position = target:GetPivot().Position
	else
		position = position2
	end

	if p then
		p.CFrame = Utility.SafeLookAt(humanoidRootPart.Position, position, p.CFrame)
	else
		humanoidRootPart.CFrame = Utility.SafeLookAt(humanoidRootPart.Position, position, humanoidRootPart.CFrame)
	end

	local child = character:FindFirstChild(Config.POS_PART_NAME)

	if child then
		child.Position = position2
		child.bp.Position = position2
	end

	if v.aimMarker then
		v.aimMarker:Update({
			position = position2,
			target = target
		})
	end

	return position2, target
end

function DemonCore.Hold(player)
	maid:Clean()

	if v.startupTrack ~= nil then
		v.startupTrack:Stop(0)
		v.startupTrack:Destroy()
		v.startupTrack = nil
	end

	v.released = false
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local animator = humanoid:FindFirstChild("Animator")
	local id = DemonCore.Id
	v.startupTrack = animator:LoadAnimation(demonCore)
	v.startupTrack:Play()
	v.startupTrack:AdjustSpeed(Config.STARTUP_SPEED)
	local clone = skill_stand_still:Clone()
	clone.LinearVelocity.VectorVelocity = createVector(0, 0, 0)
	clone.Parent = humanoidRootPart
	maid:Add(clone)
	local getvaluesfolder = Utility.getvaluesfolder(character)
	maid:Add(Utility.AddValue(getvaluesfolder, "NR", 6))
	v.aimMarker = SkillAimMarker.new({
		Dot = true,
		Highlight = true
	})
	maid:Add(v.aimMarker)
	local position, v2 = updateAim(character, humanoidRootPart)
	local createAlignOrientationWithAttachment = Utility.CreateAlignOrientationWithAttachment
	local position2 = humanoidRootPart.Position

	if v2 and v2.PrimaryPart then
		position = v2.PrimaryPart.Position or position
	end

	local alignOrientationWithAttachment, v5 = createAlignOrientationWithAttachment(humanoidRootPart, "skill_look_at", {
		Responsiveness = 70,
		MaxTorque = 500000,
		CFrame = CFrame.lookAt(position2, position)
	})
	maid:Add(v5)
	maid:Add(alignOrientationWithAttachment)
	maid:Connect(RunService.PostSimulation, function()
		updateAim(character, humanoidRootPart, alignOrientationWithAttachment)
	end)
	local v6 = Config.FREEZE_MARK / Config.STARTUP_SPEED
	task.wait(v6)
	task.delay(v6, function()
		if DemonCore.Id ~= id then
			return
		end

		v.startupTrack:AdjustSpeed(0)
	end)
end

function DemonCore.UnHold(player)
	local id = DemonCore.Id
	v.released = true

	if v.startupTrack then
		if v.startupTrack.TimePosition < 0.74 then
			v.startupTrack.TimePosition = 0.74
		end

		v.startupTrack:AdjustSpeed(Config.STARTUP_SPEED)
	end

	local RELEASE_DELAY = Config.RELEASE_DELAY
	local v2, v3 = ManuelCancel.new(player, RELEASE_DELAY)
	v2:Connect(function()
		DemonCore.Id = -1

		if v.startupTrack then
			v.startupTrack:Stop()
			v.startupTrack:Destroy()
			v.startupTrack = nil
		end

		DemonCore.Cancel(player)
	end)
	task.wait(RELEASE_DELAY)

	if DemonCore.Id ~= id then
		return
	end

	DemonCore.Cancel(player)
	v3()
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local alignOrientationWithAttachment, v4 = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			Responsiveness = 70,
			MaxTorque = 500000,
			CFrame = humanoidRootPart.CFrame
		}
	)
	maid:Add(v4)
	local Debris = game:GetService("Debris")
	Debris:AddItem(v4, Config.BARRAGE_AIM_DURATION)
	local postSimulationConnection = nil
	postSimulationConnection = RunService.PostSimulation:Connect(function()
		if DemonCore.Id == id and v4.Parent ~= nil then
			updateAim(character, humanoidRootPart, alignOrientationWithAttachment)
		else
			postSimulationConnection:Disconnect()
		end
	end)
	maid:Add(function()
		postSimulationConnection:Disconnect()
	end)
end

function DemonCore.Cancel(player)
	if v.startupTrack ~= nil and not v.released then
		v.startupTrack:Stop(0)
		v.startupTrack:Destroy()
		v.startupTrack = nil
	end

	maid:Clean()
	local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
end

return DemonCore