local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleUnderglowSizeIncrementButton"
})

-- equivalent calls inferred from this helper; original call sites unknown
local function round(p: number)
	return math.round(p * 100) / 100
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
	local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
	local instance = self.Instance

	if not (instance:IsA("TextButton") or instance:IsA("ImageButton")) then
		warn("VehicleUnderglowSizeIncrementButton must be a TextButton or ImageButton")
		return
	end

	local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)

	local function doIncrement(currentDrivingVehicleModel)
		if VehicleController.GetCurrentDrivingVehicleModel() ~= currentDrivingVehicleModel then
			return
		end

		local incrementValue = self.Instance:GetAttribute("IncrementValue")

		if not incrementValue then
			warn("IncrementValue attribute not found")
			return
		end

		local property = self.Instance:GetAttribute("Property")

		if not property then
			warn("Property attribute not found")
			return
		end

		local vehicleCollide

		if currentDrivingVehicleModel:FindFirstChild("Body") then
			local body = currentDrivingVehicleModel:FindFirstChild("Body")

			if not body then
				warn("Body not found")
				return
			end

			vehicleCollide = body:FindFirstChild("VehicleCollide")

			if not vehicleCollide then
				warn("Vehicle collide not found")
				return
			end
		else
			vehicleCollide = currentDrivingVehicleModel:FindFirstChild("UnderglowHolder")
		end

		local underglowLengthFactor = vehicleCollide:FindFirstChild("UnderglowLengthFactor", true)
		local underglowWidthFactor = vehicleCollide:FindFirstChild("UnderglowWidthFactor", true)

		if property == "UnderglowLengthFactor" then
			local v2 = math.max(0.1, (math.min(4, round(round(underglowLengthFactor.Value) + round(incrementValue)))))
			VehicleController.SetUnderglowSize(v2, underglowWidthFactor.Value)
		elseif property == "UnderglowWidthFactor" then
			local v2 = math.max(0.1, (math.min(4, round(round(underglowWidthFactor.Value) + round(incrementValue)))))
			VehicleController.SetUnderglowSize(underglowLengthFactor.Value, v2)
		end
	end

	self._Janitor:Add(instance.MouseButton1Click:Connect(function()
		local currentDrivingVehicleModel = VehicleController.GetCurrentDrivingVehicleModel()

		if currentDrivingVehicleModel == nil then
			return
		end

		if GamepassController.IsOwned(Gamepasses.VEHICLE_CUSTOMIZATION) then
			doIncrement(currentDrivingVehicleModel)
			return
		end

		local vehicleName = currentDrivingVehicleModel:GetAttribute("vehicleName")
		GamepassController.Show(
			Gamepasses.VEHICLE_CUSTOMIZATION,
			nil,
			"car underglow",
			nil,
			nil,
			nil,
			"Vehicle Underglow",
			vehicleName,
			function()
				doIncrement(currentDrivingVehicleModel)
			end
		)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v