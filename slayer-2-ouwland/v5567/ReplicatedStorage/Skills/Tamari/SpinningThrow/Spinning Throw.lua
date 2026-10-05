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
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local Config = require(script.Parent.Config)
local SpinningThrow = {
	Id = 0
}
local v2 = {
	holdStart = 0,
	barrageStartTime = 0,
	holdActive = false,
	barrageStarted = false,
	barrageComplete = false,
	holdTrack = nil,
	aimMarker = nil
}
local skill_stand_still = skills.holder.skill_stand_still
local spinningThrowBarrage = script.SpinningThrowBarrage
local spinningThrowSingular = script.SpinningThrowSingular

local function updateAim(character, rootPart, alignOrientationWithAttachment)
	local mousepos = Platform_Handler.mousepos(Config.AIM_RANGE)

	if alignOrientationWithAttachment then
		alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
			rootPart.Position,
			Vector3.new(mousepos.X, rootPart.Position.Y, mousepos.Z),
			alignOrientationWithAttachment.CFrame
		)
	end

	local child = character:FindFirstChild(Config.POS_PART_NAME)

	if child then
		child.Position = mousepos
		child.bp.Position = mousepos
	end

	if v2.aimMarker then
		v2.aimMarker:Update({
			position = mousepos
		})
	end

	return mousepos
end

function SpinningThrow.Hold(player)
	v:Clean()
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = humanoid.RootPart
	local animator = humanoid:FindFirstChild("Animator")
	local id = SpinningThrow.Id
	v2.holdStart = os.clock()
	v2.holdActive = true
	v2.barrageStarted = false
	v2.barrageComplete = false
	local clone = skill_stand_still:Clone()
	clone.LinearVelocity.VectorVelocity = createVector(0, 0, 0)
	clone.Parent = rootPart
	v:Add(clone)
	v2.aimMarker = SkillAimMarker.new({
		Dot = true,
		Highlight = true
	})
	v:Add(v2.aimMarker)
	local mousepos = Platform_Handler.mousepos(Config.AIM_RANGE)
	local child = character:FindFirstChild(Config.POS_PART_NAME)

	if child then
		child.Position = mousepos
		child.bp.Position = mousepos
	end

	if v2.aimMarker then
		v2.aimMarker:Update({
			position = mousepos
		})
	end

	local alignOrientationWithAttachment, v3 = Utility.CreateAlignOrientationWithAttachment(rootPart, "skill_look_at", {
		Responsiveness = 70,
		MaxTorque = 500000,
		CFrame = CFrame.lookAt(rootPart.Position, (Vector3.new(mousepos.X, rootPart.Position.Y, mousepos.Z)))
	})
	v:Add(v3)
	v:Add(alignOrientationWithAttachment)
	v:Connect(RunService.PostSimulation, function()
		updateAim(character, rootPart, alignOrientationWithAttachment)
	end)
	local track = animator:LoadAnimation(spinningThrowSingular)
	track:Play()
	track:AdjustSpeed(0)
	v2.holdTrack = track
	task.delay(Config.HOLD_THRESHOLD, function()
		if not v2.holdActive or SpinningThrow.Id ~= id or v2.barrageStarted then
			return
		end

		v2.barrageStarted = true
		v2.barrageStartTime = os.clock()

		if v2.holdTrack then
			v2.holdTrack:Stop()
			v2.holdTrack:Destroy()
			v2.holdTrack = nil
		end

		local track2 = animator:LoadAnimation(spinningThrowBarrage)
		track2:Play()
		v:Add(track2)
		local total = 0

		for _, v4 in Config.BARRAGE_THROW_GAPS do
			total += v4
		end

		task.wait(total)

		if SpinningThrow.Id ~= id then
			return
		end

		v2.barrageComplete = true
		v:Remove(track2)
		v:Clean()
	end)
end

function SpinningThrow.UnHold(p)
	v2.holdActive = false

	if v2.barrageStarted then
		if v2.barrageComplete then
			return
		end

		local v3 = os.clock() - v2.barrageStartTime
		local v4 = Config.BARRAGE_MIN_HOLD - v3

		if v4 > 0 then
			task.wait(v4)

			if v2.barrageComplete then
				return
			end
		end

		SpinningThrow.Id = -1
		SpinningThrow.Cancel(p)
	else
		local id = SpinningThrow.Id
		local v3, v4 = ManuelCancel.new(p, Config.SINGULAR_THROW_TIME)
		v3:Connect(function()
			SpinningThrow.Id = -1
			SpinningThrow.Cancel(p)
		end)

		if v2.holdTrack then
			v2.holdTrack:AdjustSpeed(1)
		end

		task.wait(Config.SINGULAR_THROW_TIME)
		v2.holdTrack = nil

		if SpinningThrow.Id ~= id then
			return
		end

		v4()
		SpinningThrow.Cancel(p)
	end
end

function SpinningThrow.Cancel(_)
	if v2.holdTrack then
		v2.holdTrack:Stop()
		v2.holdTrack:Destroy()
		v2.holdTrack = nil
	end

	v:Clean()
end

return SpinningThrow