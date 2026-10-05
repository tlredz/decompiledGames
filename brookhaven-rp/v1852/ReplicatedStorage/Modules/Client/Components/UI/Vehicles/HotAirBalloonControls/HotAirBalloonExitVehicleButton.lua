local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HotAirBalloonExitVehicleButton"
})
local HotAirBalloon = require(ReplicatedStorage.Modules.Client.Components.Vehicles.HotAirBalloon)
local UserInputService = game:GetService("UserInputService")

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self._connection = nil
	local instance = self.Instance
	self._Janitor:Add(HotAirBalloon.OnTakeControl:Connect(function(object)
		self._connection = self._Janitor:Add(instance.MouseButton1Click:Connect(function()
			object:ExitVehicle()
		end))
		self._spacebarConnection = self._Janitor:Add(UserInputService.InputEnded:Connect(function(input, gameProcessed)
			if input.KeyCode == Enum.KeyCode.Space and not gameProcessed then
				object:ExitVehicle()
			end
		end))
	end))
	self._Janitor:Add(HotAirBalloon.OnReleaseControl:Connect(function(_)
		if self._connection then
			self._connection:Disconnect()
			self._connection = nil
		end

		if self._spacebarConnection then
			self._spacebarConnection:Disconnect()
			self._spacebarConnection = nil
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v