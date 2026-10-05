local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HotAirBalloonSpeedControls"
})
local HotAirBalloon = require(ReplicatedStorage.Modules.Client.Components.Vehicles.HotAirBalloon)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local addSpeed = self.Instance:WaitForChild("AddSpeed")
	local lowerSpeed = self.Instance:WaitForChild("LowerSpeed")
	local speed = self.Instance:WaitForChild("Speed")
	self._Janitor:Add(HotAirBalloon.OnTakeControl:Connect(function(object)
		local v2 = math.clamp(object:GetSpeed() or 5, 0, 10)
		speed.Text = tostring(v2)
		self._addSpeedConnection = self._Janitor:Add(addSpeed.Activated:Connect(function()
			local v3 = math.clamp((tonumber(speed.Text) or 5) + 1, 0, 10)

			if object:SetSpeed(v3) then
				speed.Text = tostring(v3)
				return
			end

			local speed2 = object:GetSpeed() or 5
			speed.Text = tostring(speed2)
		end))
		self._lowerSpeedConnection = self._Janitor:Add(lowerSpeed.Activated:Connect(function()
			local v3 = math.clamp((tonumber(speed.Text) or 5) - 1, 1, 10)

			if object:SetSpeed(v3) then
				speed.Text = tostring(v3)
				return
			end

			local speed2 = object:GetSpeed() or 5
			speed.Text = tostring(speed2)
		end))
		self._speedInputFocusLostConnection = self._Janitor:Add(speed.FocusLost:Connect(function()
			local v3 = math.clamp(tonumber(speed.Text) or 5, 1, 10)

			if object:SetSpeed(v3) then
				speed.Text = tostring(v3)
				return
			end

			local speed2 = object:GetSpeed() or 5
			speed.Text = tostring(speed2)
		end))
	end))
	self._Janitor:Add(HotAirBalloon.OnReleaseControl:Connect(function()
		if self._addSpeedConnection then
			self._addSpeedConnection:Disconnect()
			self._addSpeedConnection = nil
		end

		if self._lowerSpeedConnection then
			self._lowerSpeedConnection:Disconnect()
			self._lowerSpeedConnection = nil
		end

		if self._speedInputFocusLostConnection then
			self._speedInputFocusLostConnection:Disconnect()
			self._speedInputFocusLostConnection = nil
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v