game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local packages = ReplicatedStorage.packages
require(packages.Net)
require(packages.Signal)
require(packages.Trove)
local _ = ReplicatedStorage.shared.modules
local utils = ReplicatedStorage.shared.utils
require(utils.GeneralUtils)
require(utils.NumberUtils)
local ZoneController = require(ReplicatedStorage.client.legacyControllers.ZoneController)
local StabilizerController = require(ReplicatedStorage.client.legacyControllers.StabilizerController)
local v = {
	Enum.HumanoidStateType.Running,
	Enum.HumanoidStateType.GettingUp,
	Enum.HumanoidStateType.Jumping,
	Enum.HumanoidStateType.Freefall,
	Enum.HumanoidStateType.FallingDown
}
local humanoid = nil
local humanoidRootPart = nil
local v2 = nil
local stateEnabledChangedConnection = nil
local v3 = false
local v4 = {
	Tidebreaker = true,
	Frostbreaker = true,
	["Gravity Coil"] = true,
	["Velocity Coil"] = true,
	["Shamrock Coil"] = true,
	["Snowy Gravity Coil"] = true,
	Hyperbike = true,
	["Ro-torcycle"] = true,
	["Halloween Roped"] = true
}
local FakeWaterController = {}

function FakeWaterController.Tick(_: number)
	if not v3 or humanoid == nil or humanoidRootPart == nil or humanoid.Health <= 0 then
		return
	end

	local assemblyMass = humanoidRootPart.AssemblyMass

	if not math.isfinite(assemblyMass) or humanoidRootPart:IsGrounded() then
		return
	end

	if v2 ~= nil and v2.Parent ~= humanoidRootPart then
		FakeWaterController.Enable()
		return
	end

	local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
	local isEnabled = StabilizerController.IsEnabled()

	if humanoid:GetStateEnabled(Enum.HumanoidStateType.Swimming) and not humanoid.SeatPart then
		for _, v5 in ipairs(v) do
			humanoid:SetStateEnabled(v5, false)
		end

		humanoid:ChangeState(Enum.HumanoidStateType.Swimming)

		if humanoid.Jump and not isEnabled then
			humanoidRootPart.AssemblyLinearVelocity = Vector3.new(
				assemblyLinearVelocity.X,
				math.clamp(assemblyLinearVelocity.Y, 0, 25),
				assemblyLinearVelocity.Z
			)
		end

		v2.BuoyancyForce.Force = Vector3.new(0, workspace.Gravity * assemblyMass, 0)
	else
		v2.BuoyancyForce.Force = Vector3.new(0, workspace.Gravity * assemblyMass * (isEnabled and 1 or 0.9), 0)
	end

	local tool = localPlayer.Character and localPlayer.Character:FindFirstChildWhichIsA("Tool")
	local v5

	if tool == nil then
		v5 = false
	else
		v5 = v4[tool.Name]
	end

	v2.ResistForce.Force = assemblyLinearVelocity * -assemblyMass * Vector3.new(4, isEnabled and 0 or v5 and 4 or 1, 4)

	if isEnabled then
		humanoidRootPart.AssemblyLinearVelocity = Vector3.new(
			assemblyLinearVelocity.X,
			StabilizerController.GetVerticalVelocity(),
			assemblyLinearVelocity.Z
		)
	end

	local bobber = tool and tool:FindFirstChild("bobber")

	if bobber and bobber:IsA("BasePart") then
		local fakeWaterBobberPhysics = bobber:FindFirstChild("FakeWaterBobberPhysics")

		if not fakeWaterBobberPhysics then
			fakeWaterBobberPhysics = script.FakeWaterBobberPhysics:Clone()
			fakeWaterBobberPhysics.Parent = bobber
		end

		local assemblyMass2 = bobber.AssemblyMass
		fakeWaterBobberPhysics.LinearVelocity.MaxAxesForce = Vector3.new(
			assemblyMass2 * 10,
			assemblyMass2 * workspace.Gravity * 2,
			assemblyMass2 * 10
		)
		fakeWaterBobberPhysics.LinearVelocity.VectorVelocity = Vector3.new(
			0,
			bobber:GetAttribute("HasFish") and 0 or 4,
			0
		)
	end
end

function FakeWaterController.Enable()
	if stateEnabledChangedConnection then
		stateEnabledChangedConnection:Disconnect()
		stateEnabledChangedConnection = nil
	end

	local character = localPlayer.Character

	if not character then
		return
	end

	v3 = true
	humanoid = character:WaitForChild("Humanoid")
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if not (humanoid and humanoidRootPart) then
		return
	end

	humanoid:SetAttribute("InFakeWater", true)

	if v2 and v2.Parent ~= humanoidRootPart then
		v2:Destroy()
		v2 = nil
	end

	if not v2 then
		local clone = script.FakeWaterPhysics:Clone()
		clone.Parent = humanoidRootPart
		v2 = clone
	end

	if humanoid:GetStateEnabled(Enum.HumanoidStateType.Swimming) then
		for _, v5 in ipairs(v) do
			humanoid:SetStateEnabled(v5, false)
		end

		humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
	end

	if stateEnabledChangedConnection then
		stateEnabledChangedConnection:Disconnect()
		stateEnabledChangedConnection = nil
	end

	stateEnabledChangedConnection = humanoid.StateEnabledChanged:Connect(function(p, p2)
		if p == Enum.HumanoidStateType.Swimming and not p2 then
			for _, v5 in ipairs(v) do
				humanoid:SetStateEnabled(v5, true)
			end

			humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	end)
end

function FakeWaterController.Disable()
	if stateEnabledChangedConnection then
		stateEnabledChangedConnection:Disconnect()
		stateEnabledChangedConnection = nil
	end

	local character = localPlayer.Character

	if not character then
		return
	end

	v3 = false
	humanoid = character:WaitForChild("Humanoid")
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	if not (humanoid and humanoidRootPart) then
		return
	end

	humanoid:SetAttribute("InFakeWater", false)

	if v2 then
		v2:Destroy()
		v2 = nil
	end

	for _, v5 in ipairs(v) do
		humanoid:SetStateEnabled(v5, true)
	end

	humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
end

function FakeWaterController.SetState(flag: boolean)
	if flag == v3 then
		return
	end

	if flag then
		FakeWaterController.Enable()
	else
		FakeWaterController.Disable()
	end
end

function FakeWaterController.Start(_)
	ZoneController:ObserveZone(function(_, instance)
		FakeWaterController.SetState(instance ~= nil and instance:HasTag("FakeUnderwaterZone"))
	end)
	RunService.PreSimulation:Connect(FakeWaterController.Tick)
end

return FakeWaterController