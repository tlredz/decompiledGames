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
local v = cleanit.new()
local Utility = require(global.Utility)
require(CAM.DebrisModule)
local Config = require(script.Parent.Config)
local ArcsOfJustice = {
	Id = 0
}
local v2 = {}
local v3 = nil
local v4 = nil
local clone = nil
local v5 = nil
local v6 = nil

function ArcsOfJustice.Hold(player)
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

	v2.startClock = os.clock()
	local track = animator:LoadAnimation(script.StoneUltStart)
	track:Play()
	v2.activateAnimation = track
	local id = ArcsOfJustice.Id
	clone = script.Parent.Parent.Parent.holder.skill_stand_still:Clone()
	clone.Parent = rootPart
	local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
	v3, v4 = Utility.CreateAlignOrientationWithAttachment(rootPart, "skill_look_at", {
		AlignType = Enum.AlignType.PrimaryAxisParallel,
		Responsiveness = 75,
		MaxTorque = 3000,
		CFrame = Utility.SafeLookAt(rootPart.Position, mousepos, rootPart.CFrame)
	})
	v:Connect(RunService.Heartbeat, function(_: number)
		mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
		v3.CFrame = Utility.SafeLookAt(rootPart.Position, mousepos, v3.CFrame)
		clone.LinearVelocity.VectorVelocity = clone.LinearVelocity.VectorVelocity:Lerp(
			v3.CFrame.LookVector * Config.HOLD_DRIFT_SPEED * createVector(1, 0, 1),
			0.2
		)
	end)
	task.delay(Config.HOLD_LOOP_ANIM_AT, function()
		if ArcsOfJustice.Id ~= id then
			return
		end

		v2.activateAnimation = animator:LoadAnimation(script.StoneUltLoop)
		v2.activateAnimation:Play()
	end)
end

function ArcsOfJustice.UnHold(player)
	local character = player.Character
	local id = ArcsOfJustice.Id
	local humanoid = character:FindFirstChild("Humanoid")

	if not (humanoid.RootPart and humanoid and humanoid:FindFirstChild("Animator")) then
		return
	end

	local v7, _ = ManuelCancel.new(player, 1.5)
	v7:Connect(function()
		id = -1
		ArcsOfJustice.Cancel(player)
	end)
	local getvaluesfolder = Utility.getvaluesfolder(player)
	local _ = os.clock() - v2.startClock
	v5 = Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.RELEASE_LOCK_DURATION)
	v6 = Utility.AddValue(getvaluesfolder, "NR", Config.RELEASE_LOCK_DURATION)
	v2.activateAnimation:Stop()
	v:Clean()
	TweenService:Create(clone.LinearVelocity, TweenInfo.new(0.1), {
		VectorVelocity = createVector(0, 0, 0)
	}):Play()
	task.wait(0.1)

	if ArcsOfJustice.Id ~= id then
		return
	end

	if clone ~= nil then
		clone:Destroy()
		clone = nil
	end

	if v4 ~= nil then
		v4:Destroy()
		v4 = nil
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

function ArcsOfJustice.Cancel(_)
	v:Clean()

	if v6 ~= nil then
		v6:Destroy()
		v6 = nil
	end

	if v5 ~= nil then
		v5:Destroy()
		v5 = nil
	end

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

	if v2.Release_Animation then
		v2.Release_Animation:Stop()
		v2.Release_Animation:Destroy()
	end
end

return ArcsOfJustice