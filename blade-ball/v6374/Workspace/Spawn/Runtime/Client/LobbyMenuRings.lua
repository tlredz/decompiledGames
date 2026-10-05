local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

while not workspace:GetAttribute("ClientModulesLoaded") do
	workspace:GetAttributeChangedSignal("ClientModulesLoaded"):Wait()
end

local UseNewLobby = require(ReplicatedStorage.Shared.UseNewLobby)

if not UseNewLobby() then
	return
end

local v = {}
local cFrames = {}
local v2 = 0
local steppedConnection = nil

local function newMenuRing(instance)
	local underglow = instance:FindFirstChild("Underglow")

	if underglow and underglow:IsA("BasePart") then
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = instance
		weldConstraint.Part1 = underglow
		weldConstraint.Parent = underglow
		underglow.Anchored = false
	end

	local cFrame = instance.CFrame
	local motor6D = Instance.new("Motor6D")
	motor6D.Part0 = workspace.Terrain
	motor6D.Part1 = instance
	motor6D.Transform = cFrame
	motor6D.Parent = instance
	instance.Anchored = false
	table.insert(v, motor6D)
	table.insert(cFrames, cFrame)
end

local function onPreSimulation(_, p: number)
	v2 = (v2 + p * -1.3962634015954636) % 6.283185307179586
	local cframe = CFrame.Angles(0, v2, 0)

	for k, v3 in v do
		v3.Transform = cFrames[k] * cframe
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateConnection()
	local character = Players.LocalPlayer.Character
	local v3 = character and character.Parent == workspace.Dead

	if v3 or not steppedConnection then
		if v3 and not steppedConnection then
			steppedConnection = RunService.Stepped:Connect(onPreSimulation)
		end
	else
		steppedConnection:Disconnect()
		steppedConnection = nil
	end
end

workspace.Dead.ChildAdded:Connect(function(child)
	if child == Players.LocalPlayer.Character then
		updateConnection() -- equivalent call inferred; original call site unknown
	end
end)
workspace.Alive.ChildAdded:Connect(function(child)
	if child == Players.LocalPlayer.Character then
		updateConnection() -- equivalent call inferred; original call site unknown
	end
end)
CollectionService:GetInstanceAddedSignal("NewLobbyMenuRing"):Connect(newMenuRing)

for _, v3 in CollectionService:GetTagged("NewLobbyMenuRing") do
	newMenuRing(v3)
end

updateConnection() -- equivalent call inferred; original call site unknown