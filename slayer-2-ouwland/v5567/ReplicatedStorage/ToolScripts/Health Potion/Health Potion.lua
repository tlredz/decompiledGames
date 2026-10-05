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

local HealthPotion = {}

function HealthPotion.MouseDown(instance, p: string)
	if instance == nil then
		return
	end

	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	if humanoid == nil or humanoid.Health <= 0 or not Checker.check(localPlayer) or getvaluesfolder == nil then
		return
	end

	if data == nil then
		return
	end

	local heldItem = Utility.HeldItem(data, p)

	if heldItem == nil then
		return
	end

	local v3 = heldItem:FindFirstChild("Amount") == nil or heldItem.Amount.Value <= 1
	now = os.clock()
	humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	settle() -- equivalent call inferred; original call site unknown
	local v4, v5 = ManuelCancel.new(localPlayer, 5)
	v4:Connect(function()
		if thread then
			task.cancel(thread)
		end

		cancelCleanup() -- equivalent call inferred; original call site unknown
	end)
	v = Utility.AddValue(getvaluesfolder, "pause_gameplay", 3)
	v2 = Utility.AddValue(getvaluesfolder, "JumpingDisabled", 3)
	track = humanoid.Animator:LoadAnimation(v3 and script.HealthPotionThrowAway or script.HealthPotionDrinkAnimation)
	track:Play()
	thread = task.spawn(function()
		task.wait(2.29)

		if humanoid.Health <= 0 then
			v5()

			if track ~= nil then
				track:Stop()
			end
		else
			v5()
		end

		releaseRefs() -- equivalent call inferred; original call site unknown
	end)
end

function HealthPotion.MouseUp(_)
	local v3 = 0.3 - (os.clock() - now)

	if v3 > 0 then
		task.wait(v3)
	end

	if thread then
		local success, result = pcall(function()
			return track and track.TimePosition
		end)

		if success and result and result < 1.5 then
			task.cancel(thread)
			cancelCleanup() -- equivalent call inferred; original call site unknown
		end
	end
end

return HealthPotion