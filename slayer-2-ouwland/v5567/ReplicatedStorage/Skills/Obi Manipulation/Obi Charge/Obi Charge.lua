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
local v = cleanit.new()
local Config = require(script.Parent.Config)
local gameSettings = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("gameSettings"))
local tweenInfo = TweenInfo.new(Config.DASH_DECEL_DUR, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local ObiCharge = {
	Id = 0
}

function ObiCharge.Hold(player)
	local id = ObiCharge.Id
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
	local getvaluesfolder = Utility.getvaluesfolder(character)
	v.FovInstance = FovHandler.NewFOVInstance(script.Parent.Name, character, 10, nil, 1)
	local boolValue = Instance.new("BoolValue")
	boolValue.Name = "NR"
	boolValue.Parent = getvaluesfolder
	DebrisModule:AddItem(boolValue, Config.HOLD_LOCK_DURATION)
	v:Add(boolValue)
	local attachment = Instance.new("Attachment", humanoidRootPart)
	attachment.Name = "skill_stand_still"
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = attachment
	linearVelocity.Name = "LinearVelocity"
	linearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	linearVelocity.MaxAxesForce = Vector3.new(gameSettings.skillStandStillForce, 0, gameSettings.skillStandStillForce)
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
	linearVelocity.VectorVelocity = createVector(0, 0, 0)
	linearVelocity.Parent = attachment
	DebrisModule:AddItem(attachment, Config.HOLD_LOCK_DURATION)
	v:Add(attachment)
	task.delay(Config.RISE_AT, function()
		if ObiCharge.Id == id and attachment then
			if v.FovInstance then
				vfxUtility.Cam(v.FovInstance, 0.1, 90)
				task.delay(1, function()
					if ObiCharge.Id ~= id or v.FovInstance == nil then
						return
					end

					vfxUtility.Cam(v.FovInstance, 1, 65)
				end)
			end

			if humanoidRootPart:FindFirstChild("air_combo_bp") then
				humanoidRootPart:FindFirstChild("air_combo_bp"):Destroy()
			end

			local position = humanoidRootPart.Position + Vector3.new(0, Config.RISE_HEIGHT, 0)
			local alignPosition = Instance.new("AlignPosition")
			alignPosition.Name = "AlignPosition"
			alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
			alignPosition.ForceLimitMode = Enum.ForceLimitMode.PerAxis
			alignPosition.MaxAxesForce = createVector(0, 400000, 0)
			alignPosition.Attachment0 = attachment
			alignPosition.Responsiveness = 25
			alignPosition.Position = position
			alignPosition.Parent = attachment
			DebrisModule:AddItem(alignPosition, Config.RISE_DURATION)
		end
	end)
	task.delay(Config.DASH_START_AT, function()
		if ObiCharge.Id == id and linearVelocity and linearVelocity:IsDescendantOf(humanoidRootPart) then
			linearVelocity.VectorVelocity = Vector3.new(0, -Config.DASH_START_FALL, -Config.DASH_START_SPEED)
			linearVelocity.MaxAxesForce = createVector(40000, 40000, 40000)
			TweenService:Create(linearVelocity, tweenInfo, {
				VectorVelocity = Vector3.new(0, 0, -Config.DASH_CRUISE_SPEED),
				MaxAxesForce = createVector(40000, 0, 40000)
			}):Play()
		end
	end)
	local mousepos = Platform_Handler.mousepos()
	local alignOrientationWithAttachment, v2 = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			AlignType = Enum.AlignType.PrimaryAxisParallel,
			Responsiveness = 40,
			MaxTorque = 10000,
			CFrame = Utility.SafeLookAt(humanoidRootPart.Position, mousepos, humanoidRootPart.CFrame)
		}
	)
	DebrisModule:AddItem(v2, 12)
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
	local animator = character:FindFirstChild("Humanoid"):FindFirstChildWhichIsA("Animator")
	v.Anim = animator:LoadAnimation(script.ObiChargeStart)
	task.delay(Config.LOOP_START_AT, function()
		if ObiCharge.Id == id then
			local track2 = animator:LoadAnimation(script.ObiChargeLoop)
			v.Anim = track2
			track2:Play()
		end
	end)

	if v.Anim then
		v.Anim:Play()
	end

	task.wait(Config.MIN_HOLD_DUR)
end

local tweenInfo2 = TweenInfo.new(Config.STOP_DECEL_DUR, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

function ObiCharge.UnHold(player)
	local id = ObiCharge.Id
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
	Utility.getvaluesfolder(character)

	if humanoidRootPart:FindFirstChild("skill_look_at") then
		local boolValue = Instance.new("BoolValue")
		boolValue.Name = "Cancel"
		boolValue.Value = true
		boolValue.Parent = humanoidRootPart:FindFirstChild("skill_look_at")
	end

	local skill_stand_still = humanoidRootPart:FindFirstChild("skill_stand_still")

	if skill_stand_still:FindFirstChildWhichIsA("LinearVelocity") then
		local tween = TweenService:Create(skill_stand_still:FindFirstChildWhichIsA("LinearVelocity"), tweenInfo2, {
			VectorVelocity = createVector(0, 0, 0)
		})
		v:Add(tween)
		tween:Play()
	end

	if skill_stand_still:FindFirstChildWhichIsA("AlignPosition") then
		skill_stand_still:FindFirstChildWhichIsA("AlignPosition"):Destroy()
	end

	local v2, v3 = ManuelCancel.new(player, Config.UNHOLD_CANCEL_WINDOW, nil, script.Parent.Name)
	v:Add(v3)
	v2:Connect(function()
		if player and player.Parent == game.Players then
			ObiCharge.Id = 0
		end

		ObiCharge.Cancel(player)
		v3()
	end)
	local animator = character:FindFirstChild("Humanoid"):FindFirstChildWhichIsA("Animator")

	if v.Anim and v.Anim.IsPlaying then
		v.Anim:Stop()
	end

	local track = animator:LoadAnimation(script.ObiChargeEnd)
	v.Anim = track
	track:Play()
	local ribbons = character:FindFirstChild("Accessories") and character.Accessories:FindFirstChild("Ribbons")
	local animController = ribbons and ribbons:FindFirstChild("AnimController")

	if animController then
		animController:FindFirstChild("Animator")
	end

	task.wait(Config.FINAL_BLAST_AT)

	if ObiCharge.Id ~= id then
		return
	end

	if v.FovInstance then
		vfxUtility.Cam(v.FovInstance, 0.1, 90)
		task.delay(1, function()
			if ObiCharge.Id ~= id or v.FovInstance == nil then
				return
			end

			vfxUtility.Cam(v.FovInstance, 1, 70)
			DebrisModule:AddItem(v.FovInstance, 1)
		end)
	end

	task.wait(Config.FINAL_RECOVERY)

	if ObiCharge.Id ~= id then
		return
	end

	v.FovInstance = nil
	v.Anim = nil
	ObiCharge.Cancel(player)
end

function ObiCharge.Cancel(_)
	v:Clean()
end

return ObiCharge