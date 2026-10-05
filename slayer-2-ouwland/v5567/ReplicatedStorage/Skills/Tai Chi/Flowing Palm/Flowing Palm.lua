local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local client = CAM.Client
local global = CAM.Global
local Platform_Handler = require(client.Controllers.Platform_Handler)
local Utility = require(global.Utility)
local ProjectileHoming = require(global.Subsets.Gameplay.ProjectileHoming)
local vfxUtility = require(client.Modules.Effects.vfxUtility)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local Config = require(script.Parent.Config)
local maid = cleanit.new()
local v = nil
local track = nil
local FlowingPalm = {}
FlowingPalm.Id = 0

function FlowingPalm.Hold(player)
	local character = player.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = humanoid and humanoid.RootPart

	if not (humanoid and rootPart) then
		return
	end

	local animator = humanoid:FindFirstChildOfClass("Animator")

	if track then
		track:Stop()
		track = nil
	end

	if animator then
		track = animator:LoadAnimation(script.FlowingPalm)
		track:Play()
		maid:Add(task.delay(Config.HOLD_FREEZE_AT, function()
			if track then
				track:AdjustSpeed(0)
			end
		end))
	end

	vfxUtility.TweenFOV(0.4, 60)
	local add = maid:Add(script.Parent.Parent.Parent.holder.skill_stand_still:Clone())
	add.Parent = rootPart
	local v2 = maid:Add(script.aimHighlight:Clone())
	v2.FillColor = Config.HIGHLIGHT_FILL
	v2.OutlineColor = Config.HIGHLIGHT_OUTLINE
	v = ProjectileHoming.NewLock({
		Script = script,
		Caster = character,
		Origin = rootPart.Position,
		Range = Config.SCAN_RADIUS,
		Radius = Config.AIM_PICK_RADIUS,
		Select = true,
		KeepUntilGone = true
	})
	maid:Add(function()
		v = nil
	end)
	local mousepos = Platform_Handler.mousepos(500)
	local createAlignOrientationWithAttachment = Utility.CreateAlignOrientationWithAttachment
	local v3 = {
		AlignType = Enum.AlignType.PrimaryAxisParallel,
		Responsiveness = 75,
		MaxTorque = 3000,
		CFrame = 0
	}
	local safeLookAt = Utility.SafeLookAt
	local position = rootPart.Position
	local X = mousepos.X
	v3.CFrame = safeLookAt(position, Vector3.new(X, rootPart.Position.Y, mousepos.Z), rootPart.CFrame)
	local alignOrientationWithAttachment, v4 = createAlignOrientationWithAttachment(rootPart, "skill_look_at", v3)
	maid:Add(v4)
	maid:Add(RunService.PostSimulation:Connect(function()
		mousepos = Platform_Handler.mousepos(500)
		alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
			rootPart.Position,
			Vector3.new(mousepos.X, rootPart.Position.Y, mousepos.Z),
			alignOrientationWithAttachment.CFrame
		)
		local v5

		if v ~= nil then
			v5 = v:Update(rootPart.Position, rootPart.Position + rootPart.CFrame.LookVector * Config.SCAN_RADIUS)
		end

		v2.FillTransparency = math.abs(math.sin(os.clock() * 15) / 2) + 0.5
		v2.Adornee = v5
		v2.Parent = v5
	end))
end

function FlowingPalm.UnHold(_)
	maid:Clean()
	local v2 = math.max(Config.WINDUP - Config.HOLD_FREEZE_AT, 0)
	maid:Add(task.delay(v2, function()
		if track then
			track:AdjustSpeed(1)
		end
	end))
	vfxUtility.TweenFOV(0.4, 70)
end

function FlowingPalm.Cancel(player)
	maid:Clean()
	warn(track, " for cancel")

	if track then
		track:Stop()
		track = nil
	end

	vfxUtility.TweenFOV(0.4, 70)
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		for _, child in humanoidRootPart:GetChildren() do
			if child.Name == "skill_stand_still" or child.Name == "skill_look_at" then
				child:Destroy()
			end
		end
	end
end

return FlowingPalm