local class = {}
class.__index = class

function class.new(min: number, max: number, kp: number, ki: number, kd: number)
	local self = setmetatable({}, class)
	self._min = min
	self._max = max
	self._kp = kp
	self._ki = ki
	self._kd = kd
	self._lastError = 0
	self._integralSum = 0
	return self
end

function class:Reset()
	self._lastError = 0
	self._integralSum = 0
end

function class:Calculate(p: number, p2: number, p3: number)
	local lastError = p - p2
	local v2 = self._kp * lastError
	self._integralSum += lastError * p3
	local v3 = self._ki * self._integralSum
	local v4 = (lastError - self._lastError) / p3
	local v5 = self._kd * v4
	local v6 = math.clamp(v2 + v3 + v5, self._min, self._max)
	self._lastError = lastError
	return v6
end

function class:Debug(name: string, p)
	local RunService = game:GetService("RunService")

	if not RunService:IsStudio() or self._debug then
		return
	end

	local folder = Instance.new("Folder")
	folder.Name = name
	folder:AddTag("PIDDebug")

	local function Bind(attributeName, p2)
		folder:SetAttribute(attributeName, self[p2])
		folder:GetAttributeChangedSignal(attributeName):Connect(function()
			self[p2] = folder:GetAttribute(attributeName)
			self:Reset()
		end)
	end

	folder:SetAttribute("MinMax", NumberRange.new(self._min, self._max))
	folder:GetAttributeChangedSignal("MinMax"):Connect(function()
		local minMax = folder:GetAttribute("MinMax")
		self._min = minMax.Min
		self._max = minMax.Max
		self:Reset()
	end)
	folder:SetAttribute("kP", self._kp)
	local v = "_kp"
	local v2 = "kP"
	folder:GetAttributeChangedSignal("kP"):Connect(function()
		self[v] = folder:GetAttribute(v2)
		self:Reset()
	end)
	folder:SetAttribute("kI", self._ki)
	local v3 = "_ki"
	local v4 = "kI"
	folder:GetAttributeChangedSignal("kI"):Connect(function()
		self[v3] = folder:GetAttribute(v4)
		self:Reset()
	end)
	folder:SetAttribute("kD", self._kd)
	local v5 = "_kd"
	local v6 = "kD"
	folder:GetAttributeChangedSignal("kD"):Connect(function()
		self[v5] = folder:GetAttribute(v6)
		self:Reset()
	end)
	folder:SetAttribute("Output", self._min)
	local calculated = 0

	function self.Calculate(p2, p3, p4, ...)
		calculated = class.Calculate(p2, p3, p4, ...)
		folder:SetAttribute("Output", calculated)
		return calculated
	end

	local thread = nil
	folder:SetAttribute("ShowDebugger", false)
	folder:GetAttributeChangedSignal("ShowDebugger"):Connect(function()
		if thread then
			task.cancel(thread)
		end

		if folder:GetAttribute("ShowDebugger") then
			thread = task.delay(0.1, function()
				thread = nil

				if folder:GetAttribute("ShowDebugger") then
					folder:SetAttribute("ShowDebugger", false)
					warn("Install the PID Debug plugin: https://create.roblox.com/store/asset/16279661108/PID-Debug")
				end
			end)
		end
	end)
	folder.Parent = p or workspace
	self._debug = folder
end

function class:Destroy()
	if self._debug then
		self._debug:Destroy()
		self._debug = nil
	end
end

return {
	new = class.new
}