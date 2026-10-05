local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
game:GetService("CollectionService")
local CAM = ReplicatedStorage.CAM
local client = CAM.Client
local global = CAM.Global
local Platform_Handler = require(client.Controllers.Platform_Handler)
local ManuelCancel = require(global.Subsets.Gameplay.ManuelCancel)
local cleanit = require(game.ReplicatedStorage.Packages.cleanit)
local maid = cleanit.new()
local Utility = require(global.Utility)
local DebrisModule = require(CAM.DebrisModule)
local Config = require(script.Parent.Config)
local WhirlPool = {
	Id = 0
}
local v = {}
Random.new()
local v2 = nil
local v3 = nil

function WhirlPool.Hold(player)
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

	v.startClock = os.clock()
	local track = animator:LoadAnimation(script.Activate)
	track:Play()
	v.activateAnimation = track
	local id = WhirlPool.Id
	task.delay(Config.HOLD_FREEZE_AT, function()
		if WhirlPool.Id == id then
			v.activateAnimation:AdjustSpeed(0)
		end
	end)
	local add = maid:Add(script.Parent.Parent.Parent.holder.skill_stand_still:Clone())
	add.Parent = rootPart
	local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
	local alignOrientationWithAttachment, v4 = Utility.CreateAlignOrientationWithAttachment(rootPart, "skill_look_at", {
		AlignType = Enum.AlignType.PrimaryAxisParallel,
		Responsiveness = 75,
		MaxTorque = 3000,
		CFrame = Utility.SafeLookAt(rootPart.Position, mousepos, rootPart.CFrame)
	})
	maid:Add(v4)
	maid:Connect(RunService.Heartbeat, function(_: number)
		mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
		alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
			rootPart.Position,
			mousepos,
			alignOrientationWithAttachment.CFrame
		)
	end)
end

function WhirlPool.UnHold(player)
	local character = player.Character
	local id = WhirlPool.Id
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = humanoid.RootPart

	if not (rootPart and humanoid) then
		return
	end

	local animator = humanoid:FindFirstChild("Animator")

	if not animator then
		return
	end

	local v4, _ = ManuelCancel.new(player, 3)
	v4:Connect(function()
		id = -1
		WhirlPool.Cancel(player)
	end)
	local getvaluesfolder = Utility.getvaluesfolder(player)
	local v5 = os.clock() - v.startClock
	v2 = Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.RELEASE_LOCK_DUR)
	v3 = Utility.AddValue(getvaluesfolder, "NR", Config.RELEASE_LOCK_DUR)

	if v5 < Config.HOLD_DURATION then
		maid:Clean()
		v.activateAnimation:AdjustSpeed(1)
		task.wait(Config.TAP_RECOVER_DUR)
	else
		v.activateAnimation:Stop()
		maid:Clean()
		local clone = script.Parent.Parent.Parent.holder.skill_stand_still:Clone()
		clone.Parent = rootPart
		DebrisModule:AddItem(clone, Config.BASIN_DASH_DUR + 0.1)
		local linearVelocity = clone.LinearVelocity
		local track = animator:LoadAnimation(script.Basin)
		track:Play(nil, nil, 2)
		v.Release_Animation = track

		if id ~= WhirlPool.Id then
			return
		end

		task.wait(Config.BASIN_DASH_DELAY)

		if id ~= WhirlPool.Id then
			return
		end

		linearVelocity.VectorVelocity = rootPart.CFrame.LookVector * Config.BASIN_DASH_SPEED * createVector(1, 0, 1)
		TweenService:Create(linearVelocity, TweenInfo.new(Config.BASIN_DASH_DUR, Enum.EasingStyle.Sine), {
			VectorVelocity = createVector(0, 0, 0)
		}):Play()
		task.wait(Config.BASIN_DASH_DUR)
	end

	if v3 ~= nil then
		v3:Destroy()
	end

	if v2 ~= nil then
		v2:Destroy()
	end
end

function WhirlPool.Cancel(_)
	maid:Clean()

	if v.activateAnimation then
		v.activateAnimation:Stop()
		v.activateAnimation:Destroy()
	end

	if v3 ~= nil then
		v3:Destroy()
		v3 = nil
	end

	if v2 ~= nil then
		v2:Destroy()
		v2 = nil
	end

	if v.Release_Animation then
		v.Release_Animation:Stop()
		v.Release_Animation:Destroy()
	end
end

return WhirlPool