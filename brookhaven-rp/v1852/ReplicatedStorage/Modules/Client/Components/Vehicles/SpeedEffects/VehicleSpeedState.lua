local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local v = Component.new({
	Tag = "VehicleSpeedState"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._characterJanitor = self._Janitor:Add(Janitor.new())
	self._steppedJanitor = self._Janitor:Add(Janitor.new())
	self._seatJanitor = self._Janitor:Add(Janitor.new())
	self._speed = 0
	self._publishedSpeed = 0
	self._timeSinceUpdate = 0
	self._driverSeats = {}
	self._isActive = false
	self._isOccupied = false
	self._isLocalPlayerOccupant = false
	local speedThreshold = self.Instance:GetAttribute("SpeedThreshold") or 60
	local speedThresholdExit = self.Instance:GetAttribute("SpeedThresholdExit") or speedThreshold * 0.85
	local speedMax = self.Instance:GetAttribute("SpeedMax") or 150
	self._speedThreshold = speedThreshold
	self._speedThresholdExit = math.min(speedThresholdExit, speedThreshold)
	self._speedMax = math.max(speedMax, 1)
	self.OnActiveChanged = self._Janitor:Add(Signal.new())
	self.OnOccupiedChanged = self._Janitor:Add(Signal.new())
	self.OnSpeedProgressChanged = self._Janitor:Add(Signal.new())
	self.OnLocalPlayerOccupantChanged = self._Janitor:Add(Signal.new())
end

function v:Start()
	local instance = self.Instance

	for _, descendant in instance:GetDescendants() do
		self:RegisterDriverSeat(descendant)
	end

	self._Janitor:Add(instance.DescendantAdded:Connect(function(descendant)
		self:RegisterDriverSeat(descendant)
	end))
	self._Janitor:Add(Players.LocalPlayer.CharacterAdded:Connect(function(character)
		self:BindLocalCharacter(character)
	end))
	self:BindLocalCharacter(Players.LocalPlayer.Character)
end

function v:RegisterDriverSeat(vehicleSeat)
	if not vehicleSeat:IsA("VehicleSeat") then
		return
	end

	self._driverSeats[vehicleSeat] = true
	local occupantChangedConnection = vehicleSeat:GetPropertyChangedSignal("Occupant"):Connect(function()
		self:RefreshOccupied()
	end)
	self._seatJanitor:Add(occupantChangedConnection, "Disconnect", vehicleSeat)
	self:RefreshOccupied()
end

function v:BindLocalCharacter(instance)
	self._characterJanitor:Cleanup()
	self:SetLocalPlayerOccupant(false)

	if instance == nil then
		return
	end

	local humanoid = instance:WaitForChild("Humanoid")
	self._characterJanitor:Add(humanoid:GetPropertyChangedSignal("SeatPart"):Connect(function()
		self:RefreshLocalPlayerOccupant(humanoid)
	end))
	self:RefreshLocalPlayerOccupant(humanoid)
end

function v:RefreshLocalPlayerOccupant(p)
	local seatPart = p.SeatPart
	self:SetLocalPlayerOccupant(seatPart ~= nil and seatPart:IsDescendantOf(self.Instance))
end

function v:SetLocalPlayerOccupant(isLocalPlayerOccupant: boolean)
	if isLocalPlayerOccupant == self._isLocalPlayerOccupant then
		return
	end

	self._isLocalPlayerOccupant = isLocalPlayerOccupant
	self.OnLocalPlayerOccupantChanged:Fire(isLocalPlayerOccupant)
end

function v:RefreshOccupied()
	local v2 = false

	for k in self._driverSeats do
		if k.Occupant == nil then
			continue
		end

		v2 = true
		break
	end

	self:SetOccupied(v2)
end

function v:SetOccupied(isOccupied: boolean)
	if isOccupied == self._isOccupied then
		return
	end

	self._isOccupied = isOccupied
	self.OnOccupiedChanged:Fire(isOccupied)

	if isOccupied then
		self:StartStepped()
		return
	end

	self:StopStepped()
	self._speed = 0
	self._publishedSpeed = 0

	if self._isActive then
		self._isActive = false
		self.OnActiveChanged:Fire(false)
	end
end

function v:StartStepped()
	self._steppedJanitor:Cleanup()
	self._timeSinceUpdate = 0
	self._steppedJanitor:Add(RunService.Stepped:Connect(function(_, dt: number)
		self:StepSpeed(dt)
	end))
end

function v:StopStepped()
	self._steppedJanitor:Cleanup()
end

function v:StepSpeed(p: number)
	if self._isLocalPlayerOccupant then
		self._timeSinceUpdate = 0
		self:UpdateSpeed(p)
	else
		self._timeSinceUpdate += p

		if self._timeSinceUpdate < 0.1 then
			return
		end

		self:UpdateSpeed(self._timeSinceUpdate)
		self._timeSinceUpdate = 0
	end
end

function v:UpdateSpeed(p: number)
	local primaryPart = self.Instance.PrimaryPart

	if primaryPart == nil then
		return
	end

	local magnitude = primaryPart.AssemblyLinearVelocity.Magnitude
	self._speed = math.lerp(self._speed, magnitude, 1 - math.exp(-p * 10))
	self:PublishSpeedProgress()
	local isActive

	if self._isActive then
		isActive = self._speed >= self._speedThresholdExit
	else
		isActive = self._speed >= self._speedThreshold
	end

	if isActive == self._isActive then
		return
	end

	self._isActive = isActive
	self.OnActiveChanged:Fire(isActive)
end

function v:PublishSpeedProgress()
	if math.abs(self._speed - self._publishedSpeed) < 0.5 then
		return
	end

	self._publishedSpeed = self._speed
	self.OnSpeedProgressChanged:Fire(self:GetSpeedProgress())
end

function v:GetSpeed()
	return self._speed
end

function v:IsActive()
	return self._isActive
end

function v:IsOccupied()
	return self._isOccupied
end

function v:GetSpeedProgress()
	return (math.clamp(self._speed / self._speedMax, 0, 1))
end

function v:IsLocalPlayerOccupant()
	return self._isLocalPlayerOccupant
end

function v:Stop()
	self._Janitor:Destroy()
end

return v