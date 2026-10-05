local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("TweenService")
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
local UpperSmash = {
	Id = 0
}
local v2 = {}
local v3 = nil
local v4 = nil
local clone = nil
local v5 = nil
local v6 = nil

function UpperSmash.Hold(player)
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
	local track = animator:LoadAnimation(script.Activate)
	track:Play()
	v2.activateAnimation = track
	local id = UpperSmash.Id
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
	end)
	task.delay(Config.HOLD_FREEZE_AT, function()
		if UpperSmash.Id == id then
			track:AdjustSpeed(0)
		end
	end)
	task.wait(Config.MIN_HOLD_DUR)
end

function UpperSmash.UnHold(player)
	local character = player.Character
	local id = UpperSmash.Id
	local humanoid = character:FindFirstChild("Humanoid")

	if not (humanoid.RootPart and humanoid and humanoid:FindFirstChild("Animator")) then
		return
	end

	local v7, _ = ManuelCancel.new(player, 1.5)
	v7:Connect(function()
		id = -1
		UpperSmash.Cancel(player)
	end)
	local getvaluesfolder = Utility.getvaluesfolder(player)
	local _ = os.clock() - v2.startClock
	v5 = Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.RELEASE_LOCK_DURATION)
	v6 = Utility.AddValue(getvaluesfolder, "NR", Config.RELEASE_LOCK_DURATION)
	v:Clean()
	v2.activateAnimation:AdjustSpeed(1)
	task.wait(Config.RELEASE_WAIT)

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
		v6 = nil
	end
end

function UpperSmash.Cancel(_)
	v:Clean()

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
		v6 = nil
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

return UpperSmash