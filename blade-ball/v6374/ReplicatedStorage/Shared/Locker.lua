local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)(script.Parent.Parent.Packages.Signal)
local Locker = {}
Locker.__index = Locker

function Locker:_updateLocked()
	local locked = self.Locked
	local locked2 = false

	for _, tag in self.Tags do
		if tag then
			locked2 = true
		end
	end

	self.Locked = locked2

	if locked ~= locked2 then
		self.StateChanged:Fire(locked2)
	end

	return locked2
end

function Locker:SetTag(p, flag: boolean?)
	self.Tags[p] = flag
	self:_updateLocked()
end

function Locker.GetTag(p, p2)
	return p.Tags[p2] and true or false
end

function Locker.new()
	return (setmetatable({
		Locked = false,
		Tags = {},
		StateChanged = v.new()
	}, Locker))
end

return Locker