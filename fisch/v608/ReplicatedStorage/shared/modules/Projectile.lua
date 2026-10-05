local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Packages.Signal)
local v = {
	Head = true,
	["Left Arm"] = true,
	["Right Arm"] = true,
	["Left Leg"] = true,
	["Right Leg"] = true
}
local Projectile = {}
Projectile.__index = Projectile

local function fillDefaults(options)
	local v2 = options or {}
	v2.Timestamp = v2.Timestamp or workspace:GetServerTimeNow()
	v2.Speed = v2.Speed or 100
	v2.Range = v2.Range or 1500
	v2.Acceleration = v2.Acceleration or Vector3.new(0, -workspace.Gravity, 0)

	if v2.RaycastParams then
		return v2
	end

	v2.RaycastParams = RaycastParams.new()
	v2.RaycastParams.FilterType = Enum.RaycastFilterType.Exclude
	v2.RaycastParams.RespectCanCollide = false
	v2.RaycastParams.IgnoreWater = true

	if v2.IgnoreList then
		v2.RaycastParams:AddToFilter(v2.IgnoreList)
	end

	return v2
end

function Projectile.new(vector: Vector3, vector2: Vector3, p)
	local v2 = fillDefaults(p)
	local self = setmetatable({
		_initialPos = vector,
		_hb = nil,
		_travelled = 0,
		autoCleanUp = false,
		Data = v2,
		Velocity = vector2 * v2.Speed,
		Position = vector,
		Hit = Signal.new(),
		Stepped = Signal.new()
	}, Projectile)
	self:Begin()
	return self
end

function Projectile:_Hit(raycastResult: RaycastResult, p)
	self:Stop()
	self.Hit:Fire(raycastResult, p)

	if self.autoCleanUp and self.Data.Model then
		self.Data.Model:Destroy()
	end
end

function Projectile:_Raycast(p, p2)
	local raycastResult = workspace:Raycast(p, p2, self.Data.RaycastParams)

	if raycastResult then
		local instance = raycastResult.Instance

		if instance.CanCollide or v[instance.Name] then
			return raycastResult
		end

		if not instance.CanCollide then
			self.Data.RaycastParams:AddToFilter(instance)
			return self:_Raycast(p, p2)
		end
	end
end

function Projectile:Begin()
	if self._hb then
		return
	end

	local position = self.Position

	if self.Data.Model then
		self.Data.Model:PivotTo(CFrame.lookAlong(self.Position, self.Velocity))
	end

	self._hb = RunService.Heartbeat:Connect(function(_)
		local velocity = self.Velocity
		local acceleration = self.Data.Acceleration
		local v2 = workspace:GetServerTimeNow() - self.Data.Timestamp
		local v3 = self.Position + (velocity * v2 + 0.5 * acceleration * v2 ^ 2)
		local unit = (v3 - position).Unit

		if self.Data.Model then
			self.Data.Model:PivotTo(CFrame.lookAlong(v3, unit))
		end

		self._travelled += (v3 - position).Magnitude
		local _Raycast = self:_Raycast(position, v3 - position, self.Data.RaycastParams)

		if _Raycast then
			self:_Hit(_Raycast)
		elseif self._travelled > self.Data.Range then
			self:_Hit(nil)
		else
			self.Stepped:Fire(v3)
		end

		position = v3
	end)
end

function Projectile:Stop()
	if self._hb then
		self._hb:Disconnect()
	end
end

return Projectile