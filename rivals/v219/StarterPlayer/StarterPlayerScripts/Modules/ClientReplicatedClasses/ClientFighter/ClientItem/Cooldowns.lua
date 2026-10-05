local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Signal = require(ReplicatedStorage.Modules.Signal)
local Cooldowns = {}
Cooldowns.__index = Cooldowns

function Cooldowns.new(clientItem)
	local self = setmetatable({}, Cooldowns)
	self.CooldownAdded = Signal.new()
	self.CooldownRemoved = Signal.new()
	self.ClientItem = clientItem
	self.Cooldowns = {}
	self:_Init()
	return self
end

function Cooldowns:Get(p2)
	for k, cooldown in pairs(self.Cooldowns) do
		if cooldown.Name == p2 then
			return cooldown, k
		end
	end
end

function Cooldowns:Create(image, duration, name, isReversed)
	if self._destroyed then
		return
	end

	self:Clear(name)

	if not name then
		return
	end

	local v = {
		Name = name,
		ID = HttpService:GenerateGUID(),
		Start = tick(),
		Finish = tick() + duration,
		Duration = duration,
		IsReversed = isReversed,
		Image = image,
		Cleanup = {},
		GetVariables = nil
	}

	function v.GetVariables()
		local v2 = v.Finish - tick()
		local v3 = (tick() - v.Start) / v.Duration

		if not v.IsReversed then
			v3 = 1 - v3
		end

		return v2, v3, v.IsReversed and 1 or 0
	end

	table.insert(self.Cooldowns, v)
	self.CooldownAdded:Fire(v)
	task.delay(duration, function()
		local v2 = self:Get(name)

		if v2 and v2.ID == v.ID then
			self:Clear(name)
		end
	end)
end

function Cooldowns:Clear(p)
	local v, v2 = self:Get(p)

	if not v then
		return
	end

	for _, v3 in pairs(v.Cleanup) do
		v3:Destroy()
	end

	table.remove(self.Cooldowns, v2)
	self.CooldownRemoved:Fire(v)
end

function Cooldowns:Destroy()
	self.CooldownAdded:Destroy()
	self.CooldownRemoved:Destroy()

	for i = #self.Cooldowns, 1, -1 do
		self:Clear(self.Cooldowns[i].Name)
	end
end

function Cooldowns:_Init() end

return Cooldowns