local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local global = CAM.Global
local client = CAM.Client
local skills = ReplicatedStorage.Skills
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local v = cleanit.new()
local Utility = require(global.Utility)
local Platform_Handler = require(client.Controllers.Platform_Handler)
local ManuelCancel = require(global.Subsets.Gameplay.ManuelCancel)
local SkillAimMarker = require(CAM.Client.Modules.Effects.SkillAimMarker)
local RaycastHelper = require(global.RaycastHelper)
local Config = require(script.Parent.Config)
local FleshBarrage = {
	Id = 0
}
local v2 = {
	holdTrack = nil,
	aimMarker = nil
}
local skill_stand_still = skills.holder.skill_stand_still
local fleshBarrageStartup = script.FleshBarrageStartup
local fleshBarrageRelease = script.FleshBarrageRelease

local function updateAim(character, rootPart, p)
	local mousepos = Platform_Handler.mousepos()
	local maximizeRayClient, v3, _, target = RaycastHelper.MaximizeRayClient(
		rootPart.Position,
		mousepos,
		Config.MOUSE_RANGE,
		true,
		3
	)
	local position2 = maximizeRayClient or mousepos
	local v6 = target and createVector(0, 1, 0) or v3
	local position = rootPart.Position
	local vector2 = Vector3.new(position2.X, position.Y, position2.Z)

	if p then
		p.CFrame = CFrame.lookAt(position, vector2)
	end

	local child = character:FindFirstChild(Config.POS_PART_NAME)

	if child then
		child.CFrame = CFrame.lookAt(maximizeRayClient, maximizeRayClient + (v6 or createVector(0, 1, 0)))
		child.bp.Position = maximizeRayClient
	end

	if v2.aimMarker then
		v2.aimMarker:Update({
			position = position2,
			target = target
		})
	end

	return position2, target
end

function FleshBarrage.Hold(player)
	v:Clean()
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = humanoid.RootPart
	local animator = humanoid:FindFirstChild("Animator")
	local id = FleshBarrage.Id
	v2.holdTrack = animator:LoadAnimation(fleshBarrageStartup)
	v:Add(v2.holdTrack)
	v2.holdTrack:Play()
	local clone = skill_stand_still:Clone()
	clone.LinearVelocity.VectorVelocity = createVector(0, 0, 0)
	clone.Parent = rootPart
	v:Add(clone)
	v2.aimMarker = SkillAimMarker.new({
		Dot = true
	})
	v:Add(v2.aimMarker)
	local v3 = updateAim(character, rootPart)
	local alignOrientationWithAttachment, v4 = Utility.CreateAlignOrientationWithAttachment(rootPart, "skill_look_at", {
		Responsiveness = 70,
		MaxTorque = 500000,
		CFrame = Utility.SafeLookAt(rootPart.Position, Vector3.new(v3.X, rootPart.Position.Y, v3.Z), rootPart.CFrame)
	})
	v:Add(v4)
	v:Add(alignOrientationWithAttachment)
	v:Connect(RunService.PostSimulation, function()
		updateAim(character, rootPart, alignOrientationWithAttachment)
	end)
	task.wait(Config.HOLD_FREEZE_MARK)

	if FleshBarrage.Id ~= id then
		return
	end

	v2.holdTrack:AdjustSpeed(0)
end

function FleshBarrage.UnHold(player)
	local id = FleshBarrage.Id

	if v2.holdTrack then
		v2.holdTrack:AdjustSpeed(1)
	end

	local v3, v4 = ManuelCancel.new(player, 0.83)
	v3:Connect(function()
		FleshBarrage.Id = -1
		FleshBarrage.Cancel(player)
	end)
	v:Clean()
	local track = player.Character:FindFirstChild("Humanoid"):FindFirstChild("Animator"):LoadAnimation(fleshBarrageRelease)
	v:Add(track)
	track:Play()
	task.wait(0.83)

	if FleshBarrage.Id ~= id then
		return
	end

	v4()
	FleshBarrage.Cancel(player)
end

function FleshBarrage.Cancel(_)
	v:Clean()
end

return FleshBarrage