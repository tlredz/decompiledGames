local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local v = Component.new({
	Tag = "VehicleTeleportHome"
})

local function getCharacterRoot(instance)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart ~= nil and humanoidRootPart:IsA("BasePart") then
		return humanoidRootPart
	end

	local upperTorso = instance:FindFirstChild("UpperTorso")

	if upperTorso == nil or not upperTorso:IsA("BasePart") then
		return nil
	end

	return upperTorso
end

local function getNearestOwnedVehicle(position: Vector3)
	local vehicles = Workspace:FindFirstChild("Vehicles")

	if vehicles == nil then
		return nil
	end

	local name = Players.LocalPlayer.Name
	local v2 = 1e999
	local v3 = nil

	for _, model in vehicles:GetChildren() do
		if model:IsA("Model") == false then
			continue
		end

		local owner = model:FindFirstChild("Owner")

		if not (owner ~= nil and owner:IsA("StringValue") ~= false and owner.Value == name) then
			continue
		end

		local primaryPart = model.PrimaryPart

		if primaryPart == nil then
			continue
		end

		local magnitude = (primaryPart.Position - position).Magnitude

		if not (magnitude < v2) then
			continue
		end

		v3 = model
		v2 = magnitude
	end

	return v3
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance
	self._Janitor:Add(instance.Activated:Connect(function()
		local character = Players.LocalPlayer.Character

		if character == nil then
			return
		end

		local humanoid = character:FindFirstChild("Humanoid")

		if humanoid == nil or humanoid:IsA("Humanoid") == false then
			return
		end

		if humanoid.SeatPart ~= nil or humanoid.Sit == true then
			NotificationController.Notify("You are in a seat, please stand up to teleport")
			return
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart == nil or not humanoidRootPart:IsA("BasePart") then
			humanoidRootPart = character:FindFirstChild("UpperTorso")

			if humanoidRootPart == nil or not humanoidRootPart:IsA("BasePart") then
				humanoidRootPart = nil
			end
		end

		if humanoidRootPart == nil then
			return
		end

		local nearestOwnedVehicle = getNearestOwnedVehicle(humanoidRootPart.Position)

		if nearestOwnedVehicle == nil then
			NotificationController.Notify("You don't have a spawned vehicle to teleport to")
			return
		end

		PanelController.Close("MainGUIHandler", "MainVehicleMenu")
		local pivot = nearestOwnedVehicle:GetPivot()
		local extentsSize = nearestOwnedVehicle:GetExtentsSize()
		local v2 = pivot * CFrame.new(0, 3, -(extentsSize.Z * 0.5 + 6))
		humanoidRootPart.CFrame = CFrame.new(v2.Position, pivot.Position)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v