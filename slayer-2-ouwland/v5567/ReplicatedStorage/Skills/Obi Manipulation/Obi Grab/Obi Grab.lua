local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("TweenService")
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local Platform_Handler = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Controllers"):WaitForChild("Platform_Handler"))
local ManuelCancel = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Gameplay"):WaitForChild("ManuelCancel"))
local FovHandler = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("FovHandler"))
local ServerClientPortal = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("ServerClientPortal"))
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local Config = require(script.Parent.Config)
local gameSettings = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("gameSettings"))
local v = cleanit.new()
local ObiGrab = {
	Id = 0
}

function ObiGrab.Hold(player)
	local id = ObiGrab.Id
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
	local getvaluesfolder = Utility.getvaluesfolder(character)
	v.FovInstance = FovHandler.NewFOVInstance(script.Name, character, 10, nil, 1)
	vfxUtility.Cam(v.FovInstance, 0.4, 60)
	local boolValue = Instance.new("BoolValue")
	boolValue.Name = "NR"
	boolValue.Parent = getvaluesfolder
	DebrisModule:AddItem(boolValue, Config.HOLD_LOCK_DURATION)
	v:Add(boolValue)
	local attachment = Instance.new("Attachment", humanoidRootPart)
	attachment.Name = "skill_stand_still"
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = attachment
	linearVelocity.Name = "bv"
	linearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	linearVelocity.MaxAxesForce = Vector3.new(gameSettings.skillStandStillForce, 0, gameSettings.skillStandStillForce)
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
	linearVelocity.VectorVelocity = createVector(0, 0, 0)
	linearVelocity.Parent = attachment
	DebrisModule:AddItem(attachment, Config.HOLD_LOCK_DURATION)
	v:Add(attachment)
	local mousepos = Platform_Handler.mousepos()
	local alignOrientationWithAttachment, v2 = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			AlignType = Enum.AlignType.PrimaryAxisParallel,
			Responsiveness = 30,
			MaxTorque = 10000,
			CFrame = Utility.SafeLookAt(humanoidRootPart.Position, mousepos, humanoidRootPart.CFrame)
		}
	)
	DebrisModule:AddItem(v2, Config.HOLD_LOCK_DURATION)
	v:Add(v2)
	v:Connect(RunService.RenderStepped, function(_)
		mousepos = Platform_Handler.mousepos()

		if not v2:FindFirstChild("Cancel") then
			alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
				humanoidRootPart.Position,
				mousepos,
				alignOrientationWithAttachment.CFrame
			)
		end
	end)
	v.Anim = character:FindFirstChild("Humanoid"):FindFirstChildWhichIsA("Animator"):LoadAnimation(script.ObiGrabAttempt)
	task.delay(Config.HOLD_FREEZE_AT, function()
		if ObiGrab.Id == id and v.Anim and v.Anim.IsPlaying then
			v.Anim:AdjustSpeed(0)
		end
	end)

	if v.Anim then
		v.Anim:Play()
	end
end

function ObiGrab.UnHold(player)
	local id = ObiGrab.Id
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
	Utility.getvaluesfolder(character)

	if humanoidRootPart:FindFirstChild("skill_look_at") then
		local boolValue = Instance.new("BoolValue")
		boolValue.Name = "Cancel"
		boolValue.Value = true
		boolValue.Parent = humanoidRootPart:FindFirstChild("skill_look_at")
	end

	ServerClientPortal.Link(script.Parent.Name, Config.GRAB_PORTAL_WINDOW):Once(function()
		local fOVInstance = FovHandler.NewFOVInstance(script.Name, character, 3.55, 60, 2)
		vfxUtility.Cam(fOVInstance, 0.1, 90)
		task.wait(0.65)

		if fOVInstance.Parent == nil or character.Parent == nil then
			return
		end

		vfxUtility.Cam(fOVInstance, 0.7, 60)
		task.wait(0.9)

		if fOVInstance.Parent == nil or character.Parent == nil then
			return
		end

		vfxUtility.Cam(fOVInstance, 0.1, 90)
		task.wait(1)

		if fOVInstance.Parent == nil or character.Parent == nil then
			return
		end

		vfxUtility.Cam(fOVInstance, 1, 70)
		DebrisModule:AddItem(fOVInstance, 1)
	end)
	local v2, v3 = ManuelCancel.new(player, Config.UNHOLD_DUR)
	v:Add(v3)
	v2:Connect(function()
		if player and player.Parent == game.Players then
			ObiGrab.Id = 0
		end

		ObiGrab.Cancel(player)
		v3()
	end)
	character:FindFirstChild("Humanoid"):FindFirstChildWhichIsA("Animator")

	if v.Anim and v.Anim.IsPlaying then
		v.Anim:AdjustSpeed(1)
	end

	if v.FovInstance then
		vfxUtility.Cam(v.FovInstance, Config.UNHOLD_DUR, 70)
	end

	task.wait(Config.UNHOLD_DUR)

	if ObiGrab.Id ~= id then
		return
	end

	ObiGrab.Cancel(player)
end

function ObiGrab.Cancel(_)
	v:Clean()
end

return ObiGrab