local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.Common.Utils)
local v = require3(ReplicatedStorage2.Shared.MapData)
local v2 = require3(ReplicatedStorage2.ServerInfo)
local v3 = require3(ReplicatedStorage2.Shared.LTM)
local currentLTM = v3.getCurrentLTM()
local lTMServer = v2.isLTMServer()

if lTMServer then
	lTMServer = currentLTM and currentLTM.getGameMode() == "Flying"
end

v3.OnModeChange(function(p)
	lTMServer = v2.isLTMServer() and p.getGameMode() == "Flying"
end)
local localPlayer = Players.LocalPlayer
local alive = nil
local spawn = nil

local function IsPointInArea(pivot, alive2)
	local position = alive2.Position
	local halfSize = alive2.Size / 2
	return pivot.X > position.X - halfSize.X and pivot.X < position.X + halfSize.X and pivot.Y > position.Y - halfSize.Y and pivot.Y < position.Y + halfSize.Y and pivot.Z > position.Z - halfSize.Z and pivot.Z < position.Z + halfSize.Z
end

local humanoidRootPart = nil
local AntiFlingController = {}

function AntiFlingController:Reteleport()
	if not humanoidRootPart or lTMServer then
		return
	end

	local parent = humanoidRootPart.Parent

	if not parent or parent:GetAttribute("Dead") then
		return false
	end

	local position = humanoidRootPart.Position
	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	parent:PivotTo(CFrame.new(humanoidRootPart.Position + createVector(0, 2, 0)))
	humanoidRootPart.Anchored = true
	task.delay(0.25, function()
		if parent.Parent and localPlayer.Character == parent and parent:FindFirstChild("Humanoid") then
			humanoidRootPart.Anchored = false
			parent.Humanoid.PlatformStand = false
		end
	end)

	if not humanoidRootPart:IsDescendantOf(workspace.Alive) then
		humanoidRootPart:PivotTo(spawn.SpawnLocation.CFrame)
		return
	end

	local v4

	if v.RBBattles then
		v4 = (parent:GetPivot().Position - position).Magnitude < 1100
	else
		v4 = IsPointInArea(parent:GetPivot(), alive)
	end

	if v4 then
		return
	end

	local v5 = workspace.Map:GetChildren()[1]
	local FLOOR = v5:FindFirstChild("FLOOR")
	local _ = v[v5.Name]
	local spawnRadius = v5 and v5:GetAttribute("SpawnRadius")
	local pivot = v5:GetPivot()
	local v6

	if FLOOR and FLOOR:IsA("BasePart") then
		v6 = spawnRadius or math.min(FLOOR.Size.X, FLOOR.Size.Z) / 4
		pivot = FLOOR.CFrame * CFrame.new(0, FLOOR.Size.Y / 2, 0)
	else
		v6 = 10
	end

	local v7 = math.random() * 3.141592653589793 * 2
	local v8 = pivot * (Vector3.new(math.sin(v7), 0, (math.cos(v7))) * v6)
	humanoidRootPart:PivotTo(CFrame.new(v8, pivot.Position) * CFrame.new(0, 4, 0))
end

function AntiFlingController:Start()
	spawn = workspace:WaitForChild("Spawn")
	alive = workspace:WaitForChild("MapBounds"):WaitForChild("Alive")
	localPlayer.CharacterAdded:Connect(function(character)
		task.wait()
		humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	end)
	localPlayer.CharacterRemoving:Connect(function()
		humanoidRootPart = nil
	end)
	RunService.PreSimulation:Connect(function(dt)
		if not humanoidRootPart then
			return
		end

		local orientation = humanoidRootPart.Orientation

		if humanoidRootPart.AssemblyAngularVelocity.Magnitude * dt > 1 and humanoidRootPart.AssemblyLinearVelocity.Magnitude * dt > 4 or orientation.X > 20 and orientation.X < 340 or orientation.Z > 20 and orientation.Z < 340 then
			self:Reteleport()
		end
	end)

	if localPlayer.Character then
		humanoidRootPart = localPlayer.Character:WaitForChild("HumanoidRootPart")
	end

	if not lTMServer then
		-- equivalent calls inferred from this helper; original call sites unknown
		local function checkDisable()
			lTMServer = #CollectionService:GetTagged("CUSTOM_WATER_PART") > 0 or workspace:GetAttribute("CurrentlySelectedMode") == "Hovergoal"
		end

		CollectionService:GetInstanceAddedSignal("CUSTOM_WATER_PART"):Connect(checkDisable)
		CollectionService:GetInstanceRemovedSignal("CUSTOM_WATER_PART"):Connect(checkDisable)
		workspace:GetAttributeChangedSignal("CurrentlySelectedMode"):Connect(checkDisable)
		checkDisable() -- equivalent call inferred; original call site unknown
	end
end

return AntiFlingController