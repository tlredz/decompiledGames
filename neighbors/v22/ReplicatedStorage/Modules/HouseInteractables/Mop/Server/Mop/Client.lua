local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Network = require(ReplicatedStorage.Modules.Network)
local House = require(ReplicatedStorage.Modules.Neighbors.House)
local Config = require(script.Parent:WaitForChild("Config"))
local localPlayer = Players.LocalPlayer
local animator = (localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("Humanoid"):WaitForChild("Animator")
local parent = script.Parent
local animations = ReplicatedStorage.Assets.Animations
local mop = script.Parent:WaitForChild("Model"):WaitForChild("Mop")
local currentHouse = House:GetCurrentHouse()
local events = script.Parent:WaitForChild("Events")
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams.FilterDescendantsInstances = { currentHouse.Model.Server.Stains }
local tracksByName = {}
local now = -1e999
local thread = nil

local function Activate()
	if now + Config.COOLDOWN > tick() then
		return
	end

	now = tick()
	tracksByName.MopAction:Play()
	mop.Mopping:Play()
	mop.Mopping.PlaybackSpeed += math.random(30, 45) / 100
	thread = coroutine.create(function()
		while task.wait(Config.UPDATE_RATE) do
			local partBoundsInRadius = workspace:GetPartBoundsInRadius(
				mop.Position,
				Config.DETECTION_RADIUS,
				overlapParams
			)

			if not partBoundsInRadius[1] then
				continue
			end

			task.wait(Config.CLEAN_WAITTIME)

			if not partBoundsInRadius[1].Parent then
				continue
			end

			Network:fire("CleanHouseStain", partBoundsInRadius[1])
			break
		end
	end)
	coroutine.resume(thread)
	task.wait(Config.CLEAN_DURATION)
	coroutine.close(thread)
	mop.Mopping.PlaybackSpeed = 1
	tracksByName.MopAction:Stop()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Deactivate()
	for _, v in tracksByName do
		v:Stop()
	end

	if thread then
		coroutine.close(thread)
	end
end

for _, animation in animations.Mop:GetChildren() do
	tracksByName[animation.Name] = animator:LoadAnimation(animation)
end

parent.Activated:Connect(Activate)
parent.Unequipped:Connect(Deactivate)
parent.Destroying:Connect(function()
	for _, v in tracksByName do
		v:Stop()
		v:Destroy()
	end
end)
currentHouse.LeftHouse:Once(function()
	if not script.Parent then
		return
	end

	Deactivate() -- equivalent call inferred; original call site unknown
	events.RemoveTool:FireServer()
end)