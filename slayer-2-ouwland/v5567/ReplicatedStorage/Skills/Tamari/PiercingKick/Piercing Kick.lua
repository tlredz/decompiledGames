local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local client = CAM.Client
local global = CAM.Global
local skills = ReplicatedStorage.Skills
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local maid = cleanit.new()
local Utility = require(global.Utility)
local Platform_Handler = require(client.Controllers.Platform_Handler)
local SkillAimMarker = require(client.Modules.Effects.SkillAimMarker)
local RaycastHelper = require(global.RaycastHelper)
local ProjectileHoming = require(global.Subsets.Gameplay.ProjectileHoming)
local ManuelCancel = require(global.Subsets.Gameplay.ManuelCancel)
local Config = require(script.Parent.Config)
local PiercingKick = {
	Id = 0
}
local v = {
	startupTrack = nil,
	lock = nil
}
local skill_stand_still = skills.holder.skill_stand_still
local piercingKickStartup = script.PiercingKickStartup
local piercingKickThrow = script.PiercingKickThrow

local function updateAim(character, rootPart, object, p)
	local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
	local v2 = rootPart.Position.Y + Config.UPDRAFT_HEIGHT
	local vector2 = Vector3.new(mousepos.X, math.min(mousepos.Y, v2), mousepos.Z)

	if p then
		p.CFrame = Utility.SafeLookAt(rootPart.Position, vector2, p.CFrame)
	else
		rootPart.CFrame = Utility.SafeLookAt(rootPart.Position, vector2, rootPart.CFrame)
	end

	local child = character:FindFirstChild(Config.POS_PART_NAME)

	if child then
		local raycastResult = workspace:Raycast(
			vector2 + createVector(0, 5, 0),
			createVector(-0, -20, -0),
			RaycastHelper.Crater
		)
		local v3 = not raycastResult and createVector(0, 1, 0) or raycastResult.Normal
		child.CFrame = CFrame.lookAt(vector2, vector2 + v3)
		child.bp.Position = vector2
	end

	local target

	if v.lock then
		target = v.lock:Update(rootPart.Position, vector2)
	end

	if object then
		object:Update({
			position = vector2,
			target = target
		})
	end

	return vector2, target
end

function PiercingKick.Hold(player)
	maid:Clean()
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = humanoid.RootPart
	local animator = humanoid:FindFirstChild("Animator")
	local id = PiercingKick.Id
	v.startupTrack = animator:LoadAnimation(piercingKickStartup)
	v.startupTrack:Play()
	local clone = skill_stand_still:Clone()
	clone.LinearVelocity.VectorVelocity = createVector(0, 0, 0)
	clone.Parent = rootPart
	maid:Add(clone)
	local v2 = SkillAimMarker.new({
		Dot = true,
		Highlight = true
	})
	maid:Add(v2)
	v.lock = ProjectileHoming.NewLock({
		Script = script,
		Caster = character,
		Range = Config.MOUSE_RANGE,
		Radius = Config.AIM_PICK_RADIUS,
		Downcast = Config.AIM_DOWNCAST,
		Select = true
	})
	maid:Add(function()
		v.lock = nil
	end)
	local position, v3 = updateAim(character, rootPart, v2)
	local createAlignOrientationWithAttachment = Utility.CreateAlignOrientationWithAttachment
	local position2 = rootPart.Position

	if v3 and v3.PrimaryPart then
		position = v3.PrimaryPart.Position or position
	end

	local alignOrientationWithAttachment, v6 = createAlignOrientationWithAttachment(rootPart, "skill_look_at", {
		Responsiveness = 70,
		MaxTorque = 500000,
		CFrame = CFrame.lookAt(position2, position)
	})
	maid:Add(v6)
	maid:Add(alignOrientationWithAttachment)
	maid:Connect(RunService.PostSimulation, function()
		updateAim(character, rootPart, v2, alignOrientationWithAttachment)
	end)
	task.wait(Config.FREEZE_MARK)

	if PiercingKick.Id ~= id then
		return
	end

	v.startupTrack:AdjustSpeed(0)
end

function PiercingKick.UnHold(p)
	local id = PiercingKick.Id
	maid:Clean()

	if v.startupTrack then
		v.startupTrack:AdjustSpeed(1)
	end

	local v2, v3 = ManuelCancel.new(p, Config.UNHOLD_DURATION)
	v2:Connect(function()
		PiercingKick.Id = -1
		PiercingKick.Cancel(p)
	end)
	task.delay(Config.UNHOLD_DURATION, function()
		if PiercingKick.Id ~= id then
			return
		end

		v3()
		maid:Clean()

		if v.startupTrack then
			v.startupTrack:Stop()
			v.startupTrack:Destroy()
			v.startupTrack = nil
		end
	end)
end

function PiercingKick.Switch(player)
	maid:Clean()
	local animator = player.Character:FindFirstChild("Humanoid"):FindFirstChild("Animator")
	local id = PiercingKick.Id
	local track = animator:LoadAnimation(piercingKickThrow)
	track:Play()
	v.startupTrack = track
	task.wait(0.5)

	if PiercingKick.Id ~= id then
		return
	end

	PiercingKick.Cancel(player)
end

function PiercingKick.Cancel(_)
	maid:Clean()

	if v.startupTrack then
		v.startupTrack:Stop()
		v.startupTrack:Destroy()
		v.startupTrack = nil
	end
end

return PiercingKick