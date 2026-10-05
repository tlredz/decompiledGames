local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local skills = ReplicatedStorage.Skills
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local v = cleanit.new()
local Utility = require(CAM.Global.Utility)
local Platform_Handler = require(CAM.Client.Controllers.Platform_Handler)
local SkillAimMarker = require(CAM.Client.Modules.Effects.SkillAimMarker)
local Config = require(script.Parent.Config)
local Meteor = {
	Id = 0
}
local skill_stand_still = skills.holder.skill_stand_still
local tamariMeteor = script.TamariMeteor

local function updateAim(character, rootPart, object, p)
	local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
	local position = rootPart.Position
	local vector2 = Vector3.new(mousepos.X - position.X, 0, mousepos.Z - position.Z)

	if vector2.Magnitude > Config.AIM_RANGE then
		mousepos = Vector3.new(position.X, mousepos.Y, position.Z) + vector2.Unit * Config.AIM_RANGE
	end

	if p then
		local vector3 = Vector3.new(mousepos.X, position.Y, mousepos.Z)
		p.CFrame = CFrame.lookAt(position, vector3)
	end

	local child = character:FindFirstChild(Config.POS_PART_NAME)

	if child then
		child.Position = mousepos
		child.bp.Position = mousepos
	end

	if object then
		object:Update({
			position = mousepos
		})
	end
end

function Meteor.Hold(player)
	v:Clean()
	local id = Meteor.Id
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = humanoid.RootPart
	local animator = humanoid:FindFirstChild("Animator")
	local clone = skill_stand_still:Clone()
	clone.LinearVelocity.VectorVelocity = createVector(0, 0, 0)
	clone.Parent = rootPart
	v:Add(clone)
	local v2 = SkillAimMarker.new({
		Dot = true
	})
	v:Add(v2)
	updateAim(character, rootPart, v2)
	local alignOrientationWithAttachment, v3 = Utility.CreateAlignOrientationWithAttachment(rootPart, "skill_look_at", {
		Responsiveness = 70,
		MaxTorque = 500000,
		CFrame = Utility.SafeLookAt(rootPart.Position, rootPart.Position + rootPart.CFrame.LookVector, rootPart.CFrame)
	})
	v:Add(v3)
	v:Add(alignOrientationWithAttachment)
	v:Connect(RunService.PostSimulation, function()
		updateAim(character, rootPart, v2, alignOrientationWithAttachment)
	end)
	task.wait(0.25)

	if Meteor.Id ~= id then
		return
	end

	local track = animator:LoadAnimation(tamariMeteor)
	v:Add(track)
	track:Play()
end

function Meteor.UnHold(p)
	local id = Meteor.Id
	task.wait(Config.THROW_INTERVAL)

	if Meteor.Id ~= id then
		return
	end

	Meteor.Cancel(p)
end

function Meteor.Cancel(_)
	v:Clean()
end

return Meteor