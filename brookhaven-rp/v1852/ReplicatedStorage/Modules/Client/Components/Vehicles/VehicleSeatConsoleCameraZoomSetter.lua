local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Input = require(ReplicatedStorage.Packages.Input)
local v = Component.new({
	Tag = "VehicleSeatConsoleCameraZoomSetter"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance
	self.cleanupHandle = nil
	local v2 = false
	self._Janitor:Add(instance:GetPropertyChangedSignal("Occupant"):Connect(function()
		local character = Players.LocalPlayer.Character

		if not character then
			return
		end

		local occupant = instance.Occupant

		if occupant then
			if occupant.Parent ~= character then
				return
			end

			v2 = true
			self.originalMinZoomDistance = Players.LocalPlayer.CameraMinZoomDistance
			self.originalMaxZoomDistance = Players.LocalPlayer.CameraMaxZoomDistance
			local fixedZoomDistance = self.Instance:GetAttribute("FixedZoomDistance")
			local preferredInput = Input.PreferredInput

			if preferredInput == "Gamepad" then
				Players.LocalPlayer.CameraMinZoomDistance = fixedZoomDistance
				Players.LocalPlayer.CameraMaxZoomDistance = fixedZoomDistance
			end

			self.cleanupHandle = preferredInput.Observe(function(p)
				if p == "Gamepad" then
					Players.LocalPlayer.CameraMinZoomDistance = fixedZoomDistance
					Players.LocalPlayer.CameraMaxZoomDistance = fixedZoomDistance
				else
					Players.LocalPlayer.CameraMinZoomDistance = self.originalMinZoomDistance
					Players.LocalPlayer.CameraMaxZoomDistance = self.originalMaxZoomDistance
				end
			end)
		elseif v2 and self.cleanupHandle then
			Players.LocalPlayer.CameraMinZoomDistance = self.originalMinZoomDistance
			Players.LocalPlayer.CameraMaxZoomDistance = self.originalMaxZoomDistance
			self.cleanupHandle()
			self.cleanupHandle = nil
		end
	end))
end

function v:Stop()
	if self.cleanupHandle then
		self.cleanupHandle()
		self.cleanupHandle = nil
	end

	self._Janitor:Destroy()
end

return v