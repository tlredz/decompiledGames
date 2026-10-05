local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local GridSelection = require(script.Parent.GridSelection)
local NoMotorVehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.NoMotorVehicleController)
local v = Component.new({
	Tag = "SpawnNoMotorVehicleOption"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local expect = GridSelection:WaitForInstance(self.Instance):expect()
	self._Janitor:Add(expect.OptionSelected:Connect(function(instance)
		local name = instance.Name
		local spawnColor = instance:GetAttribute("SpawnColor")

		if typeof(spawnColor) ~= "Color3" then
			spawnColor = nil
		end

		local character = Players.LocalPlayer.Character

		if character ~= nil then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			local player8Handler = Players.LocalPlayer.PlayerGui:FindFirstChild("Player8Handler")
			local tempHIP = player8Handler and player8Handler:FindFirstChild("TempHIP")

			if humanoid ~= nil and tempHIP ~= nil and tempHIP:IsA("NumberValue") then
				tempHIP.Value = humanoid.HipHeight
			end
		end

		NoMotorVehicleController.RequestNoMotorVehicle(name, nil, spawnColor)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v