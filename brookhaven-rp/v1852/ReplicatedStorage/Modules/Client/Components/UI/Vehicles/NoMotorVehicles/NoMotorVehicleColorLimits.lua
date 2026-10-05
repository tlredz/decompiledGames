local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "NoMotorVehicleColorLimits"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
	local game8Settings = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Player8Handler"):WaitForChild("Game8Settings")
	local module = require(game8Settings)
	local playersCar = module.PlayersCar
	local instance = self.Instance
	self._Janitor:Add(VehicleController.OnPlayerStartedDriving:Connect(function()
		if not VehicleController.GetCurrentNonMotorVehicle() then
			return
		end

		local colorLimits = VehicleController.GetCurrentNonMotorVehicle():FindFirstChild("ColorLimits")

		if not colorLimits then
			return
		end

		for _, guiObject in instance:GetChildren() do
			if guiObject:IsA("GuiObject") and guiObject.Name ~= "Template" then
				guiObject:Destroy()
			end
		end

		for _, child in colorLimits:GetChildren() do
			local clone = instance.Template:Clone()
			clone.Name = child.Name
			clone.BackgroundColor3 = child.Value
			clone.Parent = instance
			clone.Visible = true
			local v2 = child
			clone.Activated:Connect(function()
				playersCar:FireServer("NoMotorColor", v2.Value)
			end)
		end

		instance.UIGridLayout.CellSize = UDim2.new(1 / #colorLimits:GetChildren(), -2, 1, 0)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v