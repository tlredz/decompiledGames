local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local HotAirBalloon = require(ReplicatedStorage.Modules.Client.Components.Vehicles.HotAirBalloon)
local v = Component.new({
	Tag = "HotAirBalloonPanel"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance
	local hotAirBalloonColors = instance:WaitForChild("HotAirBalloonColors")
	local hotAirBalloonSpeedControls = instance:WaitForChild("HotAirBalloonSpeedControls")
	self._Janitor:Add(HotAirBalloon.OnTakeControl:Connect(function(_)
		self._colorsConnection = self._Janitor:Add(hotAirBalloonColors:GetPropertyChangedSignal("Visible"):Connect(function()
			if hotAirBalloonColors.Visible then
				hotAirBalloonSpeedControls.Visible = false
			end
		end))
		self._speedConnection = self._Janitor:Add(hotAirBalloonSpeedControls:GetPropertyChangedSignal("Visible"):Connect(function()
			if hotAirBalloonSpeedControls.Visible then
				hotAirBalloonColors.Visible = false
			end
		end))
	end))
	self._Janitor:Add(HotAirBalloon.OnReleaseControl:Connect(function(_)
		if self._colorsConnection then
			self._colorsConnection:Disconnect()
			self._colorsConnection = nil
		end

		if self._speedConnection then
			self._speedConnection:Disconnect()
			self._speedConnection = nil
		end

		hotAirBalloonColors.Visible = false
		hotAirBalloonSpeedControls.Visible = false
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v