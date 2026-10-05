local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("TweenService")
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local Platform_Handler = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Controllers"):WaitForChild("Platform_Handler"))
local ManuelCancel = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Gameplay"):WaitForChild("ManuelCancel"))
local FovHandler = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("FovHandler"))
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local v = cleanit.new()
local Config = require(script.Parent.Config)
local gameSettings = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("gameSettings"))
local ObiField = {
	Id = 0
}

function ObiField.Hold(player)
	local id = ObiField.Id
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
	local getvaluesfolder = Utility.getvaluesfolder(character)
	v.FovInstance = FovHandler.NewFOVInstance(script.Parent.Name, character, 10, nil, 1)
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
	v.Anim = character:FindFirstChild("Humanoid"):FindFirstChildWhichIsA("Animator"):LoadAnimation(script.ObiFieldAttempt)
	task.delay(Config.HOLD_FREEZE_AT, function()
		if ObiField.Id == id and v.Anim and v.Anim.IsPlaying then
			v.Anim:AdjustSpeed(0)
		end
	end)

	if v.Anim then
		v.Anim:Play()
	end

	local v3, v4 = ManuelCancel.new(player, Config.HOLD_FREEZE_AT)
	v:Add(v4)
	v3:Connect(function()
		if player and player.Parent == game.Players then
			ObiField.Id = 0
		end

		ObiField.Cancel(player)
		v4()
	end)
	task.wait(Config.HOLD_FREEZE_AT)
end

function ObiField.UnHold(player)
	local id = ObiField.Id
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
	Utility.getvaluesfolder(character)

	if humanoidRootPart:FindFirstChild("skill_look_at") then
		local boolValue = Instance.new("BoolValue")
		boolValue.Name = "Cancel"
		boolValue.Value = true
		boolValue.Parent = humanoidRootPart:FindFirstChild("skill_look_at")
	end

	local v2, v3 = ManuelCancel.new(player, Config.UNHOLD_DUR)
	v:Add(v3)
	v2:Connect(function()
		if player and player.Parent == game.Players then
			ObiField.Id = 0
		end

		ObiField.Cancel(player)
		v3()
	end)
	character:FindFirstChild("Humanoid"):FindFirstChildWhichIsA("Animator")

	if v.Anim and v.Anim.IsPlaying then
		v.Anim:AdjustSpeed(1)
		v.Anim.TimePosition = Config.HOLD_FREEZE_AT
	end

	if v.FovInstance then
		vfxUtility.Cam(v.FovInstance, Config.UNHOLD_DUR, 70)
		DebrisModule:AddItem(v.FovInstance, Config.UNHOLD_DUR)
	end

	task.wait(Config.UNHOLD_DUR)

	if ObiField.Id ~= id then
		return
	end

	ObiField.Cancel(player)
end

function ObiField.Cancel(_)
	v:Clean()
end

return ObiField