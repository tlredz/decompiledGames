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
local v3 = 0.4166666666666667
local thread = nil
local humanoidRootPart = nil
local v4 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function settle()
	if humanoidRootPart ~= nil and humanoidRootPart.Parent ~= nil then
		humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
		humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	end
end

local function disarm()
	if v4 ~= nil then
		v4()
		v4 = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function releaseRefs()
	if v4 ~= nil then
		v4()
		v4 = nil
	end

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

local SmallGourd = {}

function SmallGourd.Equipped(_, _: string) end

function SmallGourd.UnEquipped(_, _: string) end

function SmallGourd.MouseDown(instance, p: string)
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

	local v5, v6

	if heldItem:FindFirstChild("Amount") == nil or heldItem.Amount.Value <= 1 then
		v5 = "FinaBlow"
		v6 = 1.6666666666666667
		v3 = 1.26
	else
		v5 = "RegularBlow"
		v6 = 1
		v3 = 0.4166666666666667
	end

	now = os.clock()
	humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	settle() -- equivalent call inferred; original call site unknown
	local v7, v8 = ManuelCancel.new(localPlayer, 5)
	v4 = v8
	v7:Connect(function()
		if thread then
			task.cancel(thread)
		end

		cancelCleanup() -- equivalent call inferred; original call site unknown
	end)
	v = Utility.AddValue(getvaluesfolder, "pause_gameplay", v6)
	v2 = Utility.AddValue(getvaluesfolder, "JumpingDisabled", v6)
	local child = script:FindFirstChild(v5)

	if child ~= nil then
		track = humanoid.Animator:LoadAnimation(child)
		track:Play()
	end

	thread = task.spawn(function()
		task.wait(v3 - 0.05)

		if v4 ~= nil then
			v4()
			v4 = nil
		end

		task.wait(v6 - (v3 - 0.05))

		if humanoid.Health <= 0 and track ~= nil then
			track:Stop()
		end

		releaseRefs() -- equivalent call inferred; original call site unknown
	end)
end

function SmallGourd.MouseUp(_, _: string)
	local v5 = 0.3 - (os.clock() - now)

	if v5 > 0 then
		task.wait(v5)
	end

	if thread and os.clock() - now < v3 - 0.05 then
		task.cancel(thread)
		cancelCleanup() -- equivalent call inferred; original call site unknown
	end
end

return SmallGourd