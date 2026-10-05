local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CAM = ReplicatedStorage.CAM
local client = CAM.Client
local global = CAM.Global
local Platform_Handler = require(client.Controllers.Platform_Handler)
local ManuelCancel = require(global.Subsets.Gameplay.ManuelCancel)
local cleanit = require(game.ReplicatedStorage.Packages.cleanit)
local v = cleanit.new()
local Utility = require(global.Utility)
local Config = require(script.Parent.Config)
local FlameTiger = {
	Id = 0
}
local v2 = {}
Random.new()
local clone = nil
local v3 = nil
local v4 = nil
local v5 = nil
local v6 = nil

function FlameTiger.Hold(player)
	local character = player.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = humanoid.RootPart

	if not (rootPart and humanoid) then
		return
	end

	local animator = humanoid:FindFirstChild("Animator")

	if not animator then
		return
	end

	local id = FlameTiger.Id
	v2.startClock = os.clock()
	local track = animator:LoadAnimation(script.Activate)
	track:Play(nil, nil, 1.3)
	v2.activateAnimation = track
	clone = script.Parent.Parent.Parent.holder.skill_stand_still:Clone()
	clone.Parent = rootPart
	local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
	v3, v4 = Utility.CreateAlignOrientationWithAttachment(rootPart, "skill_look_at", {
		AlignType = Enum.AlignType.PrimaryAxisParallel,
		Responsiveness = 75,
		MaxTorque = 3000,
		CFrame = Utility.SafeLookAt(rootPart.Position, mousepos, rootPart.CFrame)
	})
	local flag = false
	v:Connect(RunService.Heartbeat, function(_: number)
		mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
		v3.CFrame = Utility.SafeLookAt(rootPart.Position, mousepos, v3.CFrame)

		if flag then
			local lookVector = v3.CFrame.LookVector
			local v7 = lookVector - vector.create(0, lookVector.Y, 0)
			clone.LinearVelocity.VectorVelocity = clone.LinearVelocity.VectorVelocity:Lerp(
				v7 * Config.HOLD_DRIFT_SPEED,
				0.15
			)
		end
	end)
	task.delay(Config.HOLD_DURATION, function()
		if id ~= FlameTiger.Id then
			return
		end

		v2.activateAnimation:Stop()
		local track2 = animator:LoadAnimation(script.Hold)
		v2.activateAnimation = track2
		track2:Play(nil, nil, Config.HOLD_ANIM_SPEED)
		flag = true
		task.wait(Config.GAP_START)

		if id ~= FlameTiger.Id then
			return
		end

		track2:AdjustSpeed(Config.GAP_ANIM_SPEED)
		task.wait(Config.GAP_END - Config.GAP_START)

		if id ~= FlameTiger.Id then
			return
		end

		track2:AdjustSpeed(Config.HOLD_ANIM_SPEED)
	end)
end

function FlameTiger.UnHold(player, p)
	local character = player.Character
	local id = FlameTiger.Id
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = humanoid.RootPart

	if not (rootPart and humanoid and humanoid:FindFirstChild("Animator")) then
		return
	end

	ManuelCancel.new(player, 3):Connect(function()
		id = -1
		FlameTiger.Cancel(player)
	end)
	local getvaluesfolder = Utility.getvaluesfolder(player)
	local v7 = os.clock() - v2.startClock
	v5 = Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.RELEASE_LOCK_DURATION)
	v6 = Utility.AddValue(getvaluesfolder, "NR", Config.RELEASE_LOCK_DURATION)
	local v8 = clone

	if v7 < Config.HOLD_DURATION then
		v:Clean()
		v2.activateAnimation.TimePosition = Config.HOLD_DURATION
		local cframe = CFrame.lookAt(rootPart.Position, (vector.create(p.X, rootPart.Position.Y, p.Z)))
		v3.CFrame = cframe
		task.wait(Config.TAP_DASH_DELAY)

		if v8 ~= nil and v8.Parent ~= nil then
			v8.LinearVelocity.VectorVelocity = cframe.LookVector * Config.TAP_DASH_SPEED
			TweenService:Create(v8.LinearVelocity, TweenInfo.new(Config.TAP_DASH_DECAY), {
				VectorVelocity = createVector(0, 0, 0)
			}):Play()
			task.wait(Config.TAP_DASH_DECAY)
		end
	else
		v:Clean()
		v2.activateAnimation:Stop(0.25)

		if v8 ~= nil and v8.Parent ~= nil then
			TweenService:Create(v8.LinearVelocity, TweenInfo.new(Config.HELD_RELEASE_DECAY), {
				VectorVelocity = createVector(0, 0, 0)
			}):Play()
			task.wait(Config.HELD_RELEASE_DECAY)
		end
	end

	if v4 ~= nil then
		v4:Destroy()
		v4 = nil
	end

	if clone ~= nil then
		clone:Destroy()
		clone = nil
	end

	if v6 ~= nil then
		v6:Destroy()
		v6 = nil
	end

	if v5 ~= nil then
		v5:Destroy()
		v5 = nil
	end
end

function FlameTiger.Cancel(_)
	v:Clean()

	if clone ~= nil then
		clone:Destroy()
		clone = nil
	end

	if v4 ~= nil then
		v4:Destroy()
		v4 = nil
	end

	if v2.activateAnimation then
		v2.activateAnimation:Stop()
		v2.activateAnimation:Destroy()
	end

	if v6 ~= nil then
		v6:Destroy()
		v6 = nil
	end

	if v5 ~= nil then
		v5:Destroy()
		v5 = nil
	end
end

return FlameTiger