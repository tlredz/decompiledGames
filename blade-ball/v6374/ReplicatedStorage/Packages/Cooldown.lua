local Players = game:GetService("Players")
local Cooldown = {}
Cooldown.__index = Cooldown

function Cooldown.new(timeBetween)
	local object = setmetatable({}, Cooldown)
	object._list = {}
	object._timeList = {}
	object._timeBetween = timeBetween
	Players.PlayerRemoving:Connect(function(player)
		object:Remove(player)
	end)
	return object
end

function Cooldown:CanFire(p)
	return not self._list[p] or (self._timeList[p] or self._timeBetween) <= tick() - self._list[p]
end

function Cooldown:SetTimeBetween(p2, p3)
	self._timeList[p2] = p3
end

function Cooldown:AddTimestamp(instance)
	self._list[instance] = tick()

	if typeof(instance) == "Instance" then
		self:_watchInstance(instance)
	end
end

function Cooldown:Remove(p2)
	self._list[p2] = nil
	self._timeList[p2] = nil
end

function Cooldown:_watchInstance(player)
	if not player:IsA("Player") then
		player.Destroying:Connect(function()
			self:Remove(player)
		end)
	end
end

return Cooldown