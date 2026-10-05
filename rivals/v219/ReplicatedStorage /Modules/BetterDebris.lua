local RunService = game:GetService("RunService")
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self._items = {}
	self:_Init()
	return self
end

function class:AddItem(p2, p3)
	if p2 then
		self._items[p2] = tick() + p3
	end
end

function class:_Init()
	RunService.Heartbeat:Connect(function()
		local v = {}

		for k, _item in pairs(self._items) do
			if not (_item < tick()) then
				continue
			end

			k:Destroy()
			v[k] = true
		end

		for k in pairs(v) do
			self._items[k] = nil
		end
	end)
end

return class._new()