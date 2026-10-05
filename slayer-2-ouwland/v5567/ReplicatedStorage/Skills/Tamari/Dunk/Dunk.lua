local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local skills = ReplicatedStorage.Skills
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local maid = cleanit.new()
local cleanit2 = require(ReplicatedStorage.Packages.cleanit)
local maid2 = cleanit2.new()
local Utility = require(CAM.Global.Utility)
local Platform_Handler = require(CAM.Client.Controllers.Platform_Handler)
local SkillAimMarker = require(CAM.Client.Modules.Effects.SkillAimMarker)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local ProjectileHoming = require(CAM.Global.Subsets.Gameplay.ProjectileHoming)
local Config = require(script.Parent.Config)
local Dunk = {
	Id = 0
}
local v = {
	startupTrack = nil,
	loopTrack = nil,
	aimMarker = nil,
	lock = nil
}
local skill_stand_still = skills.holder.skill_stand_still
local dunkStartup = script.DunkStartup
local dunkLoop = script.DunkLoop
local dunkHit = script.DunkHit

local function updateAim(character, rootPart, p)
	local mousepos = Platform_Handler.mousepos(Config.AIM_RANGE)
	local position = rootPart.Position
	local v2 = position.Y + Config.UPDRAFT_HEIGHT
	local vector2 = Vector3.new(mousepos.X, math.min(mousepos.Y, v2), mousepos.Z)
	local vector3 = Vector3.new(vector2.X, position.Y, vector2.Z)

	if p then
		p.CFrame = CFrame.lookAt(position, vector3)
	end

	local child = character:FindFirstChild(Config.POS_PART_NAME)

	if child then
		child.Position = vector2
		child.bp.Position = vector2
	end

	local target

	if v.lock then
		target = v.lock:Update(position, vector2)
	end

	if v.aimMarker then
		v.aimMarker:Update({
			position = vector2,
			target = target
		})
	end

	return vector2
end

function Dunk.Hold(player)
	maid:Clean()
	maid2:Clean()
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = humanoid.RootPart
	local animator = humanoid:FindFirstChild("Animator")
	local id = Dunk.Id
	v.startupTrack = animator:LoadAnimation(dunkStartup)
	maid:Add(v.startupTrack)
	v.startupTrack:Play()
	local clone = skill_stand_still:Clone()
	clone.LinearVelocity.VectorVelocity = createVector(0, 0, 0)
	clone.Parent = rootPart
	maid:Add(clone)
	v.aimMarker = SkillAimMarker.new({
		Dot = true,
		Highlight = {
			FillColor = Color3.fromRGB(255, 150, 60),
			OutlineColor = Color3.fromRGB(255, 205, 140),
			FillTransparency = 0.65
		}
	})
	maid2:Add(v.aimMarker)
	v.lock = ProjectileHoming.NewLock({
		Script = script,
		Caster = character,
		Range = Config.AIM_RANGE,
		Radius = Config.AIM_PICK_RADIUS,
		Downcast = Config.AIM_DOWNCAST,
		Select = true
	})
	maid2:Add(function()
		v.lock = nil
	end)
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
	maid2:Add(v3)
	maid2:Add(alignOrientationWithAttachment)
	maid2:Connect(RunService.PostSimulation, function()
		updateAim(character, rootPart, alignOrientationWithAttachment)
	end)
	task.wait(Config.STARTUP_DURATION)

	if Dunk.Id ~= id then
		return
	end

	v.startupTrack:Stop()
	v.loopTrack = animator:LoadAnimation(dunkLoop)
	maid:Add(v.loopTrack)
	v.loopTrack:Play()
end

function Dunk.UnHold(player)
	local id = Dunk.Id
	ManuelCancel.new(player, Config.RELEASE_DURATION):Connect(function()
		Dunk.Id = -1
		Dunk.Cancel(player)
	end)
	maid:Clean()
	local character = player.Character
	local animator = character:FindFirstChild("Humanoid"):FindFirstChild("Animator")
	local getvaluesfolder = Utility.getvaluesfolder(character)
	maid:Add(Utility.AddValue(getvaluesfolder, "skill_stand_still", Config.RELEASE_DURATION))
	maid:Add(Utility.AddValue(getvaluesfolder, "NR", Config.RELEASE_DURATION))
	local track = animator:LoadAnimation(dunkHit)
	maid:Add(track)
	track:Play()
	task.wait(Config.HIT_TIMING)

	if Dunk.Id ~= id then
		return
	end

	maid2:Clean()
	v.aimMarker = nil
	task.wait(Config.RELEASE_DURATION - Config.HIT_TIMING)

	if Dunk.Id ~= id then
		return
	end

	Dunk.Cancel(player)
end

function Dunk.Cancel(_)
	maid:Clean()
	maid2:Clean()
	v.startupTrack = nil
	v.loopTrack = nil
	v.aimMarker = nil
end

return Dunk