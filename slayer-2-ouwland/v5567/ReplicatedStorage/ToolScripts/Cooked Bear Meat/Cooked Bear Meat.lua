local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local ManuelCancel = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.ManuelCancel)
local localPlayer = Players.LocalPlayer
local getvaluesfolder = Utility.getvaluesfolder(localPlayer)
local data = Utility.GetData(localPlayer, true)
local track = nil
local v = nil
local v2 = nil
local now = 0
local thread = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function releaseRefs()
	track = nil

	if v ~= nil then
		v:Destroy()
		v = nil
		v2:Destroy()
		v2 = nil
	end

	thread = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cancelCleanup()
	if track ~= nil then
		track:Stop()
	end

	releaseRefs() -- equivalent call inferred; original call site unknown
end

local CookedBearMeat = {}

function CookedBearMeat.MouseDown(instance, p: string)
	if instance == nil then
		return
	end

	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	if humanoid == nil or humanoid.Health <= 0 or not Checker.check(localPlayer) or getvaluesfolder == nil then
		return
	end

	if not (data ~= nil and Utility.HeldItem(data, p) ~= nil) then
		return
	end

	now = os.clock()
	local v3, v4 = ManuelCancel.new(localPlayer, 5)
	v3:Connect(function()
		if thread then
			task.cancel(thread)
		end

		cancelCleanup() -- equivalent call inferred; original call site unknown
	end)
	v = Utility.AddValue(getvaluesfolder, "pause_gameplay", 1.5)
	v2 = Utility.AddValue(getvaluesfolder, "JumpingDisabled", 1.5)
	local eatAnimation = script:FindFirstChild("EatAnimation")

	if eatAnimation ~= nil then
		track = humanoid.Animator:LoadAnimation(eatAnimation)
		track:Play()
	end

	thread = task.spawn(function()
		task.wait(1)

		if humanoid.Health <= 0 then
			v4()

			if track ~= nil then
				track:Stop()
			end
		else
			v4()
		end

		releaseRefs() -- equivalent call inferred; original call site unknown
	end)
end

function CookedBearMeat.MouseUp(_)
	if thread and os.clock() - now < 0.27 then
		task.cancel(thread)
		cancelCleanup() -- equivalent call inferred; original call site unknown
	end
end

return CookedBearMeat