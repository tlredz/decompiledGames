local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "DinoCage"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._random = Random.new()
	self._lastShakeClock = -1e999
end

function v:_tryShake()
	if os.clock() - self._lastShakeClock < 30 then
		return
	end

	self._lastShakeClock = os.clock()
	local instance = self.Instance
	local pivot = instance:GetPivot()
	local lastTime = os.clock()
	self._roarSound:Play()
	self._Janitor:Add(function()
		instance:PivotTo(pivot)
	end, true, "ShakeRestore")
	local heartbeatConnection = RunService.Heartbeat:Connect(function()
		local v2 = os.clock() - lastTime

		if v2 >= 1.5 then
			self._Janitor:Remove("ShakeConnection")
			self._Janitor:Remove("ShakeRestore")
		else
			local v3 = 1 - v2 / 1.5
			local v4 = math.sin(v2 * 41) * 0.4 * v3
			local v5 = math.sin(v2 * 57) * 0.4 * 0.5 * v3
			local v6 = math.sin(v2 * 33) * 0.4 * v3
			local v7 = math.sin(v2 * 47) * 0.012217304763960306 * v3
			instance:PivotTo(pivot * CFrame.new(v4, v5, v6) * CFrame.Angles(0, 0, v7))
		end
	end)
	self._Janitor:Add(heartbeatConnection, "Disconnect", "ShakeConnection")
end

function v:Start()
	local instance = self.Instance
	local touch = instance:WaitForChild("Touch")
	self._roarSound = instance:WaitForChild("Roof"):WaitForChild("Roar")
	self._Janitor:Add(touch.Touched:Connect(function(otherPart)
		local parent = otherPart.Parent

		if parent == nil or Players:GetPlayerFromCharacter(parent) == nil then
			return
		end

		self:_tryShake()
	end))
	local thread = task.spawn(function()
		while true do
			task.wait(self._random:NextNumber(30, 90))
			self:_tryShake()
		end
	end)
	self._Janitor:Add(function()
		task.cancel(thread)
	end)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v