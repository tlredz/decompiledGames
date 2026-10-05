local createVector = vector.create
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
local humanoidRootPart = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function settle()
	if humanoidRootPart ~= nil and humanoidRootPart.Parent ~= nil then
		humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
		humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function releaseRefs()
	settle() -- equivalent call inferred; original call site unknown
	track = nil

	if v ~= nil then
		v:Destroy()
		v = nil
	end

	if v2 ~= nil then
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

local EvilArtOrb = {}

function EvilArtOrb.MouseDown(instance, p: string)
	if not (instance ~= nil and thread == nil) then
		return
	end

	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	if humanoid == nil or humanoid.Health <= 0 or not Checker.check(localPlayer) then
		return
	end

	if getvaluesfolder == nil or data == nil or Utility.HeldItem(data, p) == nil or data.Powers.DemonArt.Value ~= "" then
		return
	end

	now = os.clock()
	humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	settle() -- equivalent call inferred; original call site unknown
	local v3, v4 = ManuelCancel.new(localPlayer, 2)
	v3:Connect(function()
		if thread ~= nil then
			task.cancel(thread)
		end

		cancelCleanup() -- equivalent call inferred; original call site unknown
	end)
	v = Utility.AddValue(getvaluesfolder, "pause_gameplay", 2)
	v2 = Utility.AddValue(getvaluesfolder, "JumpingDisabled", 2)
	track = humanoid.Animator:LoadAnimation(script.Squeeze)
	track:Play()
	thread = task.spawn(function()
		task.wait(2)
		v4()

		if humanoid.Health <= 0 and track ~= nil then
			track:Stop()
		end

		releaseRefs() -- equivalent call inferred; original call site unknown
	end)
end

function EvilArtOrb.MouseUp(_)
	local v3 = 0.3 - (os.clock() - now)

	if v3 > 0 then
		task.wait(v3)
	end

	if thread == nil then
		return
	end

	local success, result = pcall(function()
		return track and track.TimePosition
	end)

	if success and result ~= nil and result < 0.9333333333333333 then
		task.cancel(thread)
		cancelCleanup() -- equivalent call inferred; original call site unknown
	end
end

return EvilArtOrb