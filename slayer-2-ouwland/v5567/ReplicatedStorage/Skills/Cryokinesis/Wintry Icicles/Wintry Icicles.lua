local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local Config = require(script.Parent.Config)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local maid = cleanit.new()
local Utility = require(CAM.Global.Utility)
local Platform_Handler = require(CAM.Client.Controllers.Platform_Handler)
local SkillAimMarker = require(CAM.Client.Modules.Effects.SkillAimMarker)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local WintryIcicles = {
	Id = 0
}
local v = {
	startupTrack = nil,
	aimMarker = nil
}
local skill_stand_still = ReplicatedStorage.Skills.holder.skill_stand_still
local wintryIciclesStartup = script.WintryIciclesStartup
local wintryIciclesSwitch = script.WintryIciclesSwitch
local v2 = "PosPart" .. script.Parent.Name

local function updateAim(character, humanoidRootPart, p)
	local mousepos = Platform_Handler.mousepos()
	local v3 = math.min(Config.MOUSE_RANGE, (mousepos - humanoidRootPart.Position).Magnitude)
	local maximizeRayClient, v4 = RaycastHelper.MaximizeRayClient(
		humanoidRootPart.Position,
		mousepos,
		v3,
		false,
		1,
		nil,
		nil,
		RaycastHelper.Crater
	)

	if not v4 then
		maximizeRayClient, v4 = RaycastHelper.MaximizeRayClient(
			humanoidRootPart.Position,
			mousepos,
			v3,
			false,
			1,
			Config.GROUND_SNAP,
			nil,
			RaycastHelper.Crater
		)

		if not v4 then
			return maximizeRayClient or mousepos
		end
	end

	local position = maximizeRayClient or mousepos
	local cframe = CFrame.lookAt(position, position + v4.Unit)

	if p then
		p.CFrame = Utility.SafeLookAt(humanoidRootPart.Position, position, p.CFrame)
	else
		humanoidRootPart.CFrame = Utility.SafeLookAt(humanoidRootPart.Position, position, humanoidRootPart.CFrame)
	end

	local child = character:FindFirstChild(v2)

	if child then
		child.CFrame = cframe
		child.bp.Position = position
	end

	if v.aimMarker then
		v.aimMarker:Update({
			groundCircleCFrame = (cframe + v4.Unit * 0.5) * CFrame.Angles(1.5707963267948966, 0, 0)
		})
	end

	return position
end

function WintryIcicles.Hold(player)
	maid:Clean()
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local animator = humanoid:FindFirstChild("Animator")

	if v.startupTrack then
		v.startupTrack:Stop()
		v.startupTrack:Destroy()
		v.startupTrack = nil
	end

	local id = WintryIcicles.Id
	local track = animator:LoadAnimation(wintryIciclesStartup)
	v.startupTrack = track
	track:Play()
	local clone = skill_stand_still:Clone()
	clone.LinearVelocity.VectorVelocity = createVector(0, 0, 0)
	clone.Parent = humanoidRootPart
	maid:Add(clone)
	local getvaluesfolder = Utility.getvaluesfolder(character)
	maid:Add(Utility.AddValue(getvaluesfolder, "NR", 6))
	v.aimMarker = SkillAimMarker.new({
		GroundCircle = {
			Radius = Config.ZONE_RADIUS
		}
	})
	maid:Add(v.aimMarker)
	local v3 = updateAim(character, humanoidRootPart)
	local alignOrientationWithAttachment, v4 = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			Responsiveness = 70,
			MaxTorque = 500000,
			CFrame = Utility.SafeLookAt(humanoidRootPart.Position, v3, humanoidRootPart.CFrame)
		}
	)
	maid:Add(v4)
	maid:Add(alignOrientationWithAttachment)
	maid:Connect(RunService.PostSimulation, function()
		if id ~= WintryIcicles.Id then
			return
		end

		updateAim(character, humanoidRootPart, alignOrientationWithAttachment)
	end)
	task.wait(0.15)

	if WintryIcicles.Id ~= id then
		return
	end

	track:AdjustSpeed(0)
end

function WintryIcicles.UnHold(p)
	maid:Clean()
	local id = WintryIcicles.Id
	local startupTrack = v.startupTrack

	if startupTrack then
		startupTrack:AdjustSpeed(1)
	end

	local v3, v4 = ManuelCancel.new(p, 5)
	v3:Connect(function()
		WintryIcicles.Id = -1
		WintryIcicles.Cancel(p)
	end)
	task.wait(0.88)

	if WintryIcicles.Id ~= id then
		return
	end

	v4()
	WintryIcicles.Cancel(p)
end

function WintryIcicles.Switch(player)
	maid:Clean()
	local animator = player.Character:FindFirstChild("Humanoid"):FindFirstChild("Animator")
	local id = WintryIcicles.Id
	local track = animator:LoadAnimation(wintryIciclesSwitch)
	maid:Add(track)
	track:Play()
	task.wait(0.72)

	if WintryIcicles.Id ~= id then
		return
	end

	WintryIcicles.Cancel(player)
end

function WintryIcicles.Cancel(player)
	maid:Clean()

	if v.startupTrack then
		v.startupTrack:Stop()
		v.startupTrack:Destroy()
		v.startupTrack = nil
	end

	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
		humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	end
end

return WintryIcicles