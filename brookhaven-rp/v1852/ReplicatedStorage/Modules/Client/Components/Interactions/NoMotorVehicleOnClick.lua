local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local TagsUtil = require(ReplicatedStorage.Modules.Shared.Utils.TagsUtil)
local NoMotorVehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.NoMotorVehicleController)
local v = Component.new({
	Tag = "NoMotorVehicleOnClick"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local vehicle = self.Instance:GetAttribute("Vehicle")
	local clickDetector = self.Instance:FindFirstChild("ClickDetector", true)

	if not vehicle then
		warn("No vehicle name attribute found on " .. self.Instance.Name)
	elseif clickDetector then
		self._Janitor:Add(clickDetector.MouseClick:Connect(function()
			local ancestor = TagsUtil.FindAncestorByTag(self.Instance, "VehicleRoot")

			if ancestor then
				local playerObject = ancestor:FindFirstChild("PlayerObject")

				if playerObject and playerObject.Value ~= Players.LocalPlayer then
					return
				end
			end

			local spawnColor = self.Instance:GetAttribute("SpawnColor")
			local player8Handler = Players.LocalPlayer.PlayerGui:WaitForChild("Player8Handler")
			local humanoid = Players.LocalPlayer.Character:WaitForChild("Humanoid")
			player8Handler.TempHIP.Value = humanoid.HipHeight
			NoMotorVehicleController.RequestNoMotorVehicle(vehicle, nil, spawnColor)
		end))
	else
		warn("No click detector found on " .. self.Instance.Name)
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v