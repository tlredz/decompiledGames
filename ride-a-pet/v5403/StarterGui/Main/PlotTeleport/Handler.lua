local createVector = vector.create
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local General = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("General"))
local General2 = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("General"))
local Pets = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Pets"))
require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("PetAging"))
local markers = General2.Markers or {}
local homeMarkerDistance = tonumber(markers.HomeMarkerDistance) or 150
local plotTeleportDistance = tonumber(markers.PlotTeleportDistance) or 300
local plotTeleportSpeed = tonumber(markers.PlotTeleportSpeed) or 100
local parent = script.Parent
local teleportToPlot = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("TeleportToPlot")
local hasFinishedTutorial = localPlayer:WaitForChild("SavedData"):WaitForChild("HasFinishedTutorial")
local GameSettings = require(ReplicatedStorage:WaitForChild("GameSettings"))
local v = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function SuppressTeleport(p: number)
	v = math.max(v, os.clock() + p)
	parent.Visible = false
end

ProximityPromptService.PromptButtonHoldBegan:Connect(function(p, p2)
	if p2 == localPlayer and p.Name == "Pickup" then
		SuppressTeleport((tonumber(p.HoldDuration) or 0) + 1) -- equivalent call inferred; original call site unknown
	end
end)
ProximityPromptService.PromptTriggered:Connect(function(player, p)
	if p == localPlayer and player.Name == "Pickup" then
		SuppressTeleport(1) -- equivalent call inferred; original call site unknown
	end
end)
local v2 = nil

local function FindSpawn()
	if v2 and v2.Parent then
		return v2
	end

	for _, spawnLocation in workspace:GetDescendants() do
		if not (spawnLocation:IsA("SpawnLocation") and spawnLocation.Enabled) then
			continue
		end

		v2 = spawnLocation
		return spawnLocation
	end

	return nil
end

local function FlatDistance(vector2: Vector3, vector3: Vector3)
	return ((vector3 - vector2) * createVector(1, 0, 1)).Magnitude
end

local function FastestCarriedSpeed()
	local v3 = 0
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid and localPlayer:GetAttribute("IsRiding") == true then
		v3 = math.max(v3, humanoid.WalkSpeed)
	end

	for _, v4 in { character, localPlayer:FindFirstChildOfClass("Backpack") } do
		if not v4 then
			continue
		end

		for _, tool in v4:GetChildren() do
			if not (tool:IsA("Tool") and tool:HasTag("Pet")) then
				continue
			end

			local petName = tool:GetAttribute("PetName") or tool.Name:gsub("%[.-%]%s*%+?%s*", "")
			local pet = Pets[petName]
			v3 = math.max(v3, pet and tonumber(pet.Speed) or 0)
		end
	end

	return v3
end

parent.Activated:Connect(function()
	if not parent.Visible or os.clock() < v then
		return
	end

	teleportToPlot:FireServer()
end)
local total = 0
local position = nil
RunService.Heartbeat:Connect(function(dt)
	total += dt

	if total < 0.25 then
		return
	end

	total = 0
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		parent.Visible = false
		return
	end

	local position2 = humanoidRootPart.Position
	local plot = General:GetPlot(localPlayer)
	local baseplate = plot and plot:FindFirstChild("Baseplate")

	if baseplate then
		position = baseplate.Position
	end

	local spawn = FindSpawn()
	local home = spawn and spawn:FindFirstChild("Home")

	if home then
		home.Adornee = baseplate
		home.Enabled = homeMarkerDistance <= (((baseplate or spawn).Position - position2) * createVector(1, 0, 1)).Magnitude
	end

	if hasFinishedTutorial.Value ~= true and not GameSettings.Enabled("SKIPTUTORIALONSTUDIO") then
		parent.Visible = false
		return
	end

	if os.clock() < v then
		parent.Visible = false
		return
	end

	if localPlayer:GetAttribute("IsPassenger") == true then
		parent.Visible = false
		return
	end

	local basket = localPlayer:FindFirstChild("Basket")

	if basket and #basket:GetChildren() > 0 then
		parent.Visible = false
		return
	end

	if not position then
		parent.Visible = false
		return
	end

	parent.Visible = plotTeleportDistance <= ((position - position2) * createVector(1, 0, 1)).Magnitude and FastestCarriedSpeed() < plotTeleportSpeed
end)