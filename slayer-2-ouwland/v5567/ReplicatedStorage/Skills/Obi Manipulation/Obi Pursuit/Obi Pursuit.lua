local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local Platform_Handler = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Controllers"):WaitForChild("Platform_Handler"))
local ManuelCancel = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Gameplay"):WaitForChild("ManuelCancel"))
local FovHandler = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("FovHandler"))
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local maid = cleanit.new()
local Config = require(script.Parent.Config)
local tweenInfo = TweenInfo.new(Config.DASH_ACCEL_DUR, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local ObiPursuit = {
	Id = 0
}

function ObiPursuit.Hold(player)
	local id = ObiPursuit.Id
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
	local getvaluesfolder = Utility.getvaluesfolder(character)
	maid.FovInstance = FovHandler.NewFOVInstance(script.Name, character, 10, nil, 1)
	maid:Add(task.delay(0.2, function()
		if ObiPursuit.Id == id and maid.FovInstance then
			vfxUtility.Cam(maid.FovInstance, 0.9, 60)
		end
	end))
	local boolValue = Instance.new("BoolValue")
	boolValue.Name = "NR"
	boolValue.Parent = getvaluesfolder
	DebrisModule:AddItem(boolValue, Config.HOLD_LOCK_DURATION)
	maid:Add(boolValue)
	local attachment = Instance.new("Attachment", humanoidRootPart)
	attachment.Name = "skill_stand_still"
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = attachment
	linearVelocity.Name = "bv"
	linearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	linearVelocity.MaxAxesForce = createVector(40000, 0, 40000)
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
	linearVelocity.VectorVelocity = createVector(0, 0, 0)
	linearVelocity.Parent = attachment
	DebrisModule:AddItem(attachment, Config.HOLD_LOCK_DURATION)
	maid:Add(attachment)
	task.delay(Config.DASH_START_AT, function()
		if ObiPursuit.Id == id and linearVelocity and linearVelocity:IsDescendantOf(humanoidRootPart) then
			TweenService:Create(linearVelocity, tweenInfo, {
				VectorVelocity = Vector3.new(0, 0, -Config.DASH_SPEED)
			}):Play()
		end
	end)
	local mousepos = Platform_Handler.mousepos()
	local alignOrientationWithAttachment, v = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			AlignType = Enum.AlignType.PrimaryAxisParallel,
			Responsiveness = 40,
			MaxTorque = 10000,
			CFrame = Utility.SafeLookAt(humanoidRootPart.Position, mousepos, humanoidRootPart.CFrame)
		}
	)
	DebrisModule:AddItem(v, Config.HOLD_LOCK_DURATION)
	maid:Add(v)
	maid:Connect(RunService.RenderStepped, function(_)
		mousepos = Platform_Handler.mousepos()

		if not v:FindFirstChild("Cancel") then
			alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
				humanoidRootPart.Position,
				mousepos,
				alignOrientationWithAttachment.CFrame
			)
		end
	end)
	local track = character:FindFirstChild("Humanoid"):FindFirstChildWhichIsA("Animator"):LoadAnimation(script.startup)
	maid.Anim = track
	local ribbons = character:FindFirstChild("Accessories") and character.Accessories:FindFirstChild("Ribbons")
	local animController = ribbons and ribbons:FindFirstChild("AnimController")

	if animController then
		animController:FindFirstChild("Animator")
	end

	task.delay(Config.HOLD_FREEZE_AT, function()
		if ObiPursuit.Id == id and track and track.IsPlaying then
			track:AdjustSpeed(0)
		end
	end)
	track:Play()
end

local tweenInfo2 = TweenInfo.new(Config.STOP_DECEL_DUR, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

function ObiPursuit.UnHold(player)
	local id = ObiPursuit.Id
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
	Utility.getvaluesfolder(character)

	if humanoidRootPart:FindFirstChild("skill_look_at") then
		local boolValue = Instance.new("BoolValue")
		boolValue.Name = "Cancel"
		boolValue.Value = true
		boolValue.Parent = humanoidRootPart:FindFirstChild("skill_look_at")
	end

	if humanoidRootPart:FindFirstChild("skill_stand_still") and humanoidRootPart:FindFirstChild("skill_stand_still"):FindFirstChildWhichIsA("LinearVelocity") then
		TweenService:Create(
			humanoidRootPart:FindFirstChild("skill_stand_still"):FindFirstChildWhichIsA("LinearVelocity"),
			tweenInfo2,
			{
				VectorVelocity = createVector(0, 0, 0)
			}
		):Play()
	end

	local v, v2 = ManuelCancel.new(player, Config.SLASH_ANIM_DUR)
	maid:Add(v2)
	v:Connect(function()
		if player and player.Parent == game.Players then
			ObiPursuit.Id = 0
		end

		ObiPursuit.Cancel(player)
		v2()
	end)
	local animator = character:FindFirstChild("Humanoid"):FindFirstChildWhichIsA("Animator")

	if maid.Anim and maid.Anim.IsPlaying then
		maid.Anim:Stop()
	end

	local track = animator:LoadAnimation(script.slash)
	maid.Anim = track
	track:Play()

	if maid.FovInstance then
		vfxUtility.Cam(maid.FovInstance, Config.SLASH_ANIM_DUR, 70)
	end

	task.wait(Config.SLASH_RECOVERY)

	if ObiPursuit.Id ~= id then
		return
	end

	ObiPursuit.Cancel(player)
end

function ObiPursuit.Cancel(_)
	maid:Clean()
end

return ObiPursuit