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
local Config = require(script.Parent.Config)
local PiercingFlesh = {
	Id = 0
}
local swing_6 = script.Swing_6
local skill_stand_still = skills.holder.skill_stand_still
local v = {
	startupTrack = nil,
	aimMarker = nil,
	aimConnection = nil
}

local function updateAim(character, rootPart, p)
	local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
	local position = rootPart.Position
	local vector2 = Vector3.new(mousepos.X, position.Y, mousepos.Z)

	if p then
		p.CFrame = CFrame.lookAt(position, vector2)
	else
		rootPart.CFrame = CFrame.lookAt(position, vector2)
	end

	local child = character:FindFirstChild(Config.POS_PART_NAME)

	if child then
		child.CFrame = CFrame.new(mousepos)
		child.bp.Position = mousepos
	end

	if v.aimMarker then
		v.aimMarker:Update({
			position = mousepos
		})
	end

	return mousepos
end

function PiercingFlesh.Hold(player)
	maid:Clean()
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = humanoid.RootPart
	local animator = humanoid:FindFirstChild("Animator")
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local id = PiercingFlesh.Id
	v.startupTrack = animator:LoadAnimation(swing_6)
	maid:Add(v.startupTrack)
	v.startupTrack:Play()
	local clone = skill_stand_still:Clone()
	clone.LinearVelocity.VectorVelocity = createVector(0, 0, 0)
	clone.Parent = rootPart
	maid:Add(clone)
	maid:Add(Utility.AddValue(getvaluesfolder, "NR", 6))
	v.aimMarker = SkillAimMarker.new({
		Dot = true
	})
	maid:Add(v.aimMarker)
	local v2 = updateAim(character, rootPart)
	local alignOrientationWithAttachment, v3 = Utility.CreateAlignOrientationWithAttachment(rootPart, "skill_look_at", {
		Responsiveness = 70,
		MaxTorque = 500000,
		CFrame = Utility.SafeLookAt(
			rootPart.Position,
			v2 or rootPart.Position + rootPart.CFrame.LookVector,
			rootPart.CFrame
		)
	})
	maid:Add(v3)
	maid:Add(alignOrientationWithAttachment)
	v.aimConnection = RunService.PostSimulation:Connect(function()
		updateAim(character, rootPart, alignOrientationWithAttachment)
	end)
	maid:Add(v.aimConnection)
	task.wait(0.2)

	if PiercingFlesh.Id ~= id then
		return
	end

	v.startupTrack:AdjustSpeed(0)
end

function PiercingFlesh.UnHold(_)
	if v.startupTrack then
		maid:Remove(v.startupTrack)
		v.startupTrack:AdjustSpeed(1)
	end

	maid:Clean()
end

function PiercingFlesh.Cancel(_)
	if v.startupTrack then
		v.startupTrack:Stop(0)
	end

	v.startupTrack = nil
	v.aimMarker = nil
	v.aimConnection = nil
	maid:Clean()
end

return PiercingFlesh