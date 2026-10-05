local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
game:GetService("CollectionService")
local CAM = ReplicatedStorage.CAM
local client = CAM.Client
local global = CAM.Global
local Platform_Handler = require(client.Controllers.Platform_Handler)
local ManuelCancel = require(global.Subsets.Gameplay.ManuelCancel)
local cleanit = require(game.ReplicatedStorage.Packages.cleanit)
local maid = cleanit.new()
local Utility = require(global.Utility)
local getvaluesfolder = Utility.getvaluesfolder(game.Players.LocalPlayer.Name, true)
require(CAM.DebrisModule)
local Config = require(script.Parent.Config)
local WaterWheel = {
	Id = 0
}
require(ReplicatedStorage2.CAM.Client.Controllers.Platform_Handler)
local track = nil
local HOLD_MOVE_SPEED = 0
local now = 0
local track2 = nil

function WaterWheel.Hold(player)
	HOLD_MOVE_SPEED = 0

	if track2 ~= nil then
		track2:Stop()
		track2 = nil
	end

	now = os.clock()
	local character = player.Character
	local clone = script.Parent.Parent.Parent.holder.skill_stand_still:Clone()
	clone.Name = `{script.Parent.Name}-fromserver`
	clone.Parent = character.HumanoidRootPart
	clone.LinearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	clone.LinearVelocity.MaxAxesForce = createVector(20000, 20000, 20000)
	maid:Add(clone)
	local id = WaterWheel.Id
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = humanoid.RootPart

	if humanoid == nil or rootPart == nil then
		return
	end

	local animator = humanoid:FindFirstChild("Animator")

	if animator == nil then
		return
	end

	track = animator:LoadAnimation(script["Hold Pose"])
	track:Play()
	local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
	local createAlignOrientationWithAttachment = Utility.CreateAlignOrientationWithAttachment
	local v = {
		AlignType = Enum.AlignType.PrimaryAxisParallel,
		Responsiveness = 80,
		MaxTorque = 500000,
		CFrame = 0
	}
	local safeLookAt = Utility.SafeLookAt
	local position = rootPart.Position
	local X = mousepos.X
	v.CFrame = safeLookAt(position, Vector3.new(X, rootPart.Position.Y, mousepos.Z), rootPart.CFrame)
	local alignOrientationWithAttachment, v2 = createAlignOrientationWithAttachment(rootPart, "skill_look_at", v)
	maid:Add(Utility.AddValue(getvaluesfolder, "AIRDASHASD123", 10))
	maid:Add(alignOrientationWithAttachment)
	maid:Add(v2)
	maid:Connect(RunService.Heartbeat, function(_: number)
		mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
		alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
			rootPart.Position,
			Vector3.new(mousepos.X, rootPart.Position.Y, mousepos.Z),
			alignOrientationWithAttachment.CFrame
		)

		if HOLD_MOVE_SPEED > 0 then
			clone.LinearVelocity.VectorVelocity = clone.LinearVelocity.VectorVelocity:Lerp(
				alignOrientationWithAttachment.CFrame.LookVector * HOLD_MOVE_SPEED,
				0.2
			)
		end
	end)
	task.delay(Config.HOLD_DURATION, function()
		if WaterWheel.Id == id then
			track2 = humanoid.Animator:LoadAnimation(script.Hold)
			track2:Play()
			HOLD_MOVE_SPEED = Config.HOLD_MOVE_SPEED
		end
	end)
end

function WaterWheel.UnHold(player)
	if track ~= nil then
		track:Stop()
		track = nil
	end

	local selected = os.clock() - now < Config.HOLD_DURATION and 2 or nil
	task.spawn(function()
		if selected == 2 then
			local v2, _ = ManuelCancel.new(player, 1)
			v2:Connect(function()
				WaterWheel.Cancel(player)
			end)
			track2 = player.Character.Humanoid.Animator:LoadAnimation(script.Tap)
			track2:Play()
			HOLD_MOVE_SPEED = Config.TAP_DASH_SPEED
			task.wait(Config.TAP_DASH_DUR)
		elseif track2 ~= nil then
			track2:Stop()
			track2 = nil
		end

		maid:Clean()
	end)
	return selected
end

function WaterWheel.Cancel(_)
	if track ~= nil then
		track:Stop()
		track = nil
	end

	if track2 ~= nil then
		track2:Stop()
		track2 = nil
	end

	maid:Clean()
end

return WaterWheel