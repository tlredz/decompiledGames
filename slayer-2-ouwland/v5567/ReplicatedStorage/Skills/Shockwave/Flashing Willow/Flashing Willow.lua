local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local client = CAM.Client
local global = CAM.Global
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local maid = cleanit.new()
local Platform_Handler = require(client.Controllers.Platform_Handler)
local Utility = require(global.Utility)
local SkillAimMarker = require(client.Modules.Effects.SkillAimMarker)
local RaycastHelper = require(global.RaycastHelper)
local ManuelCancel = require(global.Subsets.Gameplay.ManuelCancel)
local Config = require(script.Parent.Config)
local FlashingWillow = {
	Id = 0
}
local v = {
	startupTrack = nil,
	aimMarker = nil,
	mover = nil
}
local flashingWillowGroundVariant = script.FlashingWillowGroundVariant

local function updateAim(character, rootPart, p)
	local mousepos = Platform_Handler.mousepos()
	local v2 = math.min(Config.MOUSE_RANGE, (mousepos - rootPart.Position).Magnitude)
	local maximizeRayClient, v3 = RaycastHelper.MaximizeRayClient(rootPart.Position, mousepos, v2, false, 3)

	if not v3 then
		maximizeRayClient, v3 = RaycastHelper.MaximizeRayClient(
			rootPart.Position,
			mousepos,
			v2,
			false,
			3,
			18,
			nil,
			RaycastHelper.Crater
		)

		if not v3 then
			return mousepos
		end
	end

	local position = maximizeRayClient or mousepos

	if p then
		p.CFrame = Utility.SafeLookAt(rootPart.Position, position, p.CFrame)
	else
		rootPart.CFrame = Utility.SafeLookAt(rootPart.Position, position, rootPart.CFrame)
	end

	local child = character:FindFirstChild(Config.POS_PART_NAME)

	if child then
		child.CFrame = CFrame.lookAt(position, position + v3.Unit)
		child.bp.Position = position
	end

	if v.aimMarker then
		v.aimMarker:Update({
			position = position
		})
	end

	return position
end

function FlashingWillow.Hold(player)
	maid:Clean()
	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	local rootPart = humanoid and humanoid.RootPart
	local animator = humanoid and humanoid:FindFirstChild("Animator")
	local id = FlashingWillow.Id
	v.startupTrack = animator:LoadAnimation(flashingWillowGroundVariant)
	maid:Add(v.startupTrack)
	v.startupTrack:Play()
	local getvaluesfolder = Utility.getvaluesfolder(character)
	maid:Add(Utility.AddValue(getvaluesfolder, "NR", 5))
	maid:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", 5))
	maid:Add(Utility.AddValue(getvaluesfolder, "skill_stand_still", 5))
	v.aimMarker = SkillAimMarker.new({
		Dot = true
	})
	maid:Add(v.aimMarker)
	local v2 = updateAim(character, rootPart)
	local alignOrientationWithAttachment, v3 = Utility.CreateAlignOrientationWithAttachment(rootPart, "skill_look_at", {
		Responsiveness = 70,
		MaxTorque = 500000,
		CFrame = Utility.SafeLookAt(rootPart.Position, v2, rootPart.CFrame)
	})
	maid:Add(v3)
	maid:Add(alignOrientationWithAttachment)
	maid:Connect(RunService.PostSimulation, function()
		updateAim(character, rootPart, alignOrientationWithAttachment)
	end)
	task.wait(Config.FREEZE_MARK)

	if FlashingWillow.Id ~= id then
		return
	end

	v.startupTrack:AdjustSpeed(0)
end

local Players = game:GetService("Players")
local getvaluesfolder = Utility.getvaluesfolder(Players.LocalPlayer, true)

function FlashingWillow.UnHold(p)
	local id = FlashingWillow.Id

	if v.startupTrack then
		v.startupTrack:AdjustSpeed(1)
	end

	v.aimMarker:Destroy()
	v.aimMarker = nil
	local RELEASE_DELAY = Config.RELEASE_DELAY
	maid:Add(Utility.AddValue(getvaluesfolder, "NR", RELEASE_DELAY))
	local v2, v3 = ManuelCancel.new(p, RELEASE_DELAY)
	v2:Connect(function()
		FlashingWillow.Id = -1
		FlashingWillow.Cancel(p)
	end)
	task.wait(RELEASE_DELAY)

	if FlashingWillow.Id ~= id then
		return
	end

	v3()
	FlashingWillow.Cancel(p)
end

function FlashingWillow.Cancel(player)
	maid:Clean()
	local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
end

return FlashingWillow