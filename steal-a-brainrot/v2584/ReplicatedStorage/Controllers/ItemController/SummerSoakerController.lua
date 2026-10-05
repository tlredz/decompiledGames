local createVector = vector.create
local Players = game:GetService("Players")
game:GetService("Lighting")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local _ = localPlayer.PlayerScripts
local _ = workspace.CurrentCamera
playerGui:WaitForChild("ToolsScreen")
local CharacterController = require(ReplicatedStorage.Controllers.CharacterController)
local ServerAuthority = require(ReplicatedStorage.Shared.ServerAuthority)
require(ReplicatedStorage.Shared.ServerAuthority.IcedWalkSimulation)
local _ = CharacterController.Controls
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages.Net)
local remoteEvent = Net:RemoteEvent("UseItem")
local v = 0
local v2 = createVector(0, 0, 0)

-- equivalent calls inferred from this helper; original call sites unknown
local function isIced()
	local character = localPlayer.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if not humanoid then
		return
	end

	local icedUntil = humanoid:GetAttribute("IcedUntil")
	local serverTimeNow = workspace:GetServerTimeNow()
	return typeof(icedUntil) == "number" and serverTimeNow < icedUntil or serverTimeNow < v
end

remoteEvent.OnClientEvent:Connect(function(p, p2, _)
	if p ~= "IcedWalk" then
		return
	end

	local v3 = workspace:GetServerTimeNow() + p2

	if v < v3 then
		v = v3
	end
end)
RunService.RenderStepped:Connect(function(dt)
	if ServerAuthority.isEnabled() then
		return
	end

	local character = localPlayer.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if not humanoid then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	-- equivalent call inferred; original call site unknown
	if isIced() then
		local moveDirection = humanoid.MoveDirection
		local vector2 = Vector3.new(moveDirection.X, 0, moveDirection.Z)

		if vector2.Magnitude > 0 then
			local v3 = vector2.Unit * 26
			local v4 = 1 - math.exp(-10 * dt)
			v2 = v2:Lerp(v3, v4)
		else
			local v3 = math.exp(-1.4 * dt)
			v2 *= v3
		end

		local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
		humanoidRootPart.AssemblyLinearVelocity = Vector3.new(v2.X, assemblyLinearVelocity.Y, v2.Z)
	elseif v2.Magnitude > 0 then
		v2 = createVector(0, 0, 0)
	end
end)
return {}