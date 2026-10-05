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
	if track ~= nil then
		track:Stop()
	end

	track = nil

	if v ~= nil then
		v:Destroy()
		v = nil
		v2:Destroy()
		v2 = nil
	end

	thread = nil
end

local Bandage = {}

function Bandage.MouseDown(instance, p: string)
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
	local v3, v4 = ManuelCancel.new(localPlayer, 3.416666666666667)
	v3:Connect(function()
		if thread then
			task.cancel(thread)
		end

		releaseRefs() -- equivalent call inferred; original call site unknown
	end)
	v = Utility.AddValue(getvaluesfolder, "pause_gameplay", 2.416666666666667)
	v2 = Utility.AddValue(getvaluesfolder, "JumpingDisabled", 2.416666666666667)
	local bandageWrapAnimation = script:FindFirstChild("BandageWrapAnimation")

	if bandageWrapAnimation ~= nil then
		track = humanoid.Animator:LoadAnimation(bandageWrapAnimation)
		track.Looped = true
		track:Play()
	end

	thread = task.spawn(function()
		task.wait(1.4166666666666667)
		v4()
		releaseRefs() -- equivalent call inferred; original call site unknown
	end)
end

function Bandage.MouseUp(_)
	if thread == nil or os.clock() - now >= 1.2666666666666668 then
		return
	end

	task.cancel(thread)
	releaseRefs() -- equivalent call inferred; original call site unknown
end

return Bandage