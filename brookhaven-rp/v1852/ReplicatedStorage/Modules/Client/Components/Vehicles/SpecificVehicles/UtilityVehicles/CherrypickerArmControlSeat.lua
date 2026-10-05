local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Players = game:GetService("Players")
local v = Component.new({
	Tag = "CherrypickerArmControlSeat"
})

function v:Construct()
	assert(
		self.Instance:IsA("VehicleSeat"),
		"The CherrypickerArmControlSeat component must be attached to a VehicleSeat instance."
	)
	self._Janitor = Janitor.new()
	self.seatedJanitor = self._Janitor:Add(Janitor.new())
end

function v:IsLocalPlayerInSeat()
	return self.Instance.Occupant == (Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Humanoid"))
end

function v:ObtainTruckComponentInstance()
	local instance = self.Instance

	while instance and not instance:HasTag("CherrypickerTruckArm") do
		instance = instance.Parent
	end

	return instance
end

function v:OccupantChanged()
	self.seatedJanitor:Cleanup()

	if self:IsLocalPlayerInSeat() then
		local flag = false
		self.seatedJanitor:Add(self.Instance:GetPropertyChangedSignal("Steer"):Connect(function()
			if flag then
				return
			end

			while self.Instance.Steer ~= 0 do
				flag = true
				Remotes.fireServerComponentUnreliable(
					self.truckComponentInstance,
					"RotateArm",
					math.sign(self.Instance.Steer) * 1.047197551196333
				)
				task.wait(0.0833)
			end

			flag = false
		end))
		local flag2 = false
		self.seatedJanitor:Add(self.Instance:GetPropertyChangedSignal("Throttle"):Connect(function()
			if flag2 then
				return
			end

			while self.Instance.Throttle ~= 0 do
				flag2 = true
				Remotes.fireServerComponentUnreliable(
					self.truckComponentInstance,
					"RaiseArm",
					math.sign(self.Instance.Throttle) * 1.047197551196333
				)
				task.wait(0.0833)
			end

			flag2 = false
		end))
	end
end

function v:Start()
	self.truckComponentInstance = self:ObtainTruckComponentInstance()
	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("Occupant"):Connect(function()
		warn("OccupantChanged", self.Instance.Occupant)
		self:OccupantChanged()
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v