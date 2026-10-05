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
local v = cleanit.new()
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local Config = require(script.Parent.Config)
local gameSettings = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("gameSettings"))
local cframe = CFrame.Angles(math.rad(Config.AIM_PITCH), 0, 0)
local ObiBarrage = {
	Id = 0
}

function ObiBarrage.Hold(player)
	local id = ObiBarrage.Id
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local fOVInstance = FovHandler.NewFOVInstance(script.Name, character, 10, nil, 1)
	v.FovInstance = fOVInstance
	vfxUtility.Cam(fOVInstance, 0.5, 60)
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
	linearVelocity.VectorVelocity = createVector(0, 0, 0)
	linearVelocity.Parent = attachment
	DebrisModule:AddItem(attachment, Config.HOLD_LOCK_DURATION)
	v:Add(attachment)
	local mousepos = Platform_Handler.mousepos()
	local safeLookAt = Utility.SafeLookAt(humanoidRootPart.Position, mousepos, humanoidRootPart.CFrame)
	local alignOrientationWithAttachment, v2 = Utility.CreateAlignOrientationWithAttachment(
		humanoidRootPart,
		"skill_look_at",
		{
			Responsiveness = 20,
			MaxTorque = 10000,
			CFrame = safeLookAt * CFrame.Angles(0, 0, 0)
		}
	)
	DebrisModule:AddItem(v2, Config.HOLD_LOCK_DURATION)
	v:Add(v2)
	local v3 = 0
	local cframe2 = CFrame.Angles(0, 0, 0)
	v:Connect(RunService.RenderStepped, function(p)
		mousepos = Platform_Handler.mousepos()

		if v3 < Config.AIM_TILT_DURATION then
			v3 = math.min(v3 + p, Config.AIM_TILT_DURATION)
			local lerped = cframe2:lerp(cframe, v3 / Config.AIM_TILT_DURATION)

			if not v2:FindFirstChild("Cancel") then
				safeLookAt = Utility.SafeLookAt(humanoidRootPart.Position, mousepos, safeLookAt)
				alignOrientationWithAttachment.CFrame = safeLookAt * lerped
			end
		elseif not v2:FindFirstChild("Cancel") then
			safeLookAt = Utility.SafeLookAt(humanoidRootPart.Position, mousepos, safeLookAt)
			alignOrientationWithAttachment.CFrame = safeLookAt * cframe
		end

		local child = character:FindFirstChild("PosPart" .. script.Name .. "Server")

		if child then
			child.Position = mousepos
			child.bp.Position = mousepos
		end
	end)
	local animator = character:FindFirstChild("Humanoid"):FindFirstChildWhichIsA("Animator")
	v.Anim = animator:LoadAnimation(script.ObiBarrageStart)
	local animator2 = nil
	local ribbons = character:FindFirstChild("Accessories") and character.Accessories:FindFirstChild("Ribbons")

	if ribbons then
		local animController = ribbons:FindFirstChild("AnimController")

		if animController then
			animator2 = animController:FindFirstChild("Animator")
		end
	end

	if animator2 then
		v.Anim2 = animator2:LoadAnimation(script.ObiBarrageStart)
	end

	task.delay(Config.BARRAGE_START_AT, function()
		if ObiBarrage.Id == id then
			if v.Anim and v.Anim.IsPlaying then
				v.Anim:Stop()
			end

			local track2 = animator:LoadAnimation(script.ObiBarrageloop)
			v.Anim = track2
			track2:Play()

			if v.FovInstance then
				vfxUtility.Cam(v.FovInstance, 0.2, 90)
			end
		end
	end)

	if v.Anim then
		v.Anim:Play()
	end

	task.wait(Config.MIN_HOLD_DUR)
end

function ObiBarrage.UnHold(player)
	local id = ObiBarrage.Id
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
	Utility.getvaluesfolder(character)

	if humanoidRootPart:FindFirstChild("skill_look_at") then
		local boolValue = Instance.new("BoolValue")
		boolValue.Name = "Cancel"
		boolValue.Value = true
		boolValue.Parent = humanoidRootPart:FindFirstChild("skill_look_at")
	end

	local v2, v3 = ManuelCancel.new(player, Config.FINAL_ANIM_DUR)
	v:Add(v3)
	v2:Connect(function()
		if player and player.Parent == game.Players then
			ObiBarrage.Id = 0
		end

		ObiBarrage.Cancel(player)
		v3()
	end)
	local animator = character:FindFirstChild("Humanoid"):FindFirstChildWhichIsA("Animator")

	if v.Anim and v.Anim.IsPlaying then
		v.Anim:Stop()
	end

	local track = animator:LoadAnimation(script.ObiBarrageFinal)
	v.Anim = track
	track:Play()
	local ribbons = character:FindFirstChild("Accessories") and character.Accessories:FindFirstChild("Ribbons")
	local animController = ribbons and ribbons:FindFirstChild("AnimController")

	if animController then
		animController:FindFirstChild("Animator")
	end

	task.wait(Config.FINAL_CAM_AT)

	if id ~= ObiBarrage.Id then
		return
	end

	if v.FovInstance then
		vfxUtility.Cam(v.FovInstance, 0.5, 70)
	end

	task.wait(Config.FINAL_RECOVERY)
	ObiBarrage.Cancel(player)
end

function ObiBarrage.Cancel(_)
	v:Clean()
end

return ObiBarrage