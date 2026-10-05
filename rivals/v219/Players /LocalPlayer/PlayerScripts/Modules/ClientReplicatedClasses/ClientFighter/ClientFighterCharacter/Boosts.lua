local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Modules.Signal)
local v = {
	Speed = true
}
local Boosts = {}
Boosts.__index = Boosts

function Boosts.new(clientFighterCharacter)
	local self = setmetatable({}, Boosts)
	self.BoostsChanged = Signal.new()
	self.ClientFighterCharacter = clientFighterCharacter
	self._boosts = {}
	self:_Init()
	return self
end

function Boosts:GetBoostByName(value)
	assert(typeof(value) == "string", "Argument 1 invalid, expected a string, got " .. tostring(value))
	self:_ClearExpiredBoosts()
	return self._boosts[value]
end

function Boosts:GetBoost(p)
	assert(v[p], "Argument 1 invalid, got " .. tostring(p))
	self:_ClearExpiredBoosts()
	local total = 0

	for _, _boost in pairs(self._boosts) do
		if _boost.Type == p then
			total += _boost.Boost
		end
	end

	return total
end

function Boosts:SetBoost(p2, value, value2, value3, p3)
	assert(v[p2], "Argument 1 invalid, got " .. tostring(p2))
	assert(typeof(value) == "string", "Argument 2 invalid, expected a string, got " .. tostring(value))
	assert(typeof(value2) == "number", "Argument 3 invalid, expected a number, got " .. tostring(value2))
	assert(typeof(value3) == "number", "Argument 4 invalid, expected a number, got " .. tostring(value3))
	assert(not p3 or typeof(p3) == "boolean", "Argument 5 invalid, expected a boolean or nil, got " .. tostring(p3))
	self._boosts[value] = {
		Type = p2,
		Window = tick() + value2,
		Boost = value3
	}

	if not p3 then
		self.BoostsChanged:Fire()
	end
end

function Boosts:RemoveBoost(value, p2)
	assert(typeof(value) == "string", "Argument 1 invalid, expected a string, got " .. tostring(value))
	assert(not p2 or typeof(p2) == "boolean", "Argument 2 invalid, expected a boolean or nil, got " .. tostring(p2))

	if not self._boosts[value] then
		return
	end

	self._boosts[value] = nil

	if not p2 then
		self.BoostsChanged:Fire()
	end
end

function Boosts.Update(_, _, _) end

function Boosts:Destroy()
	self.BoostsChanged:Destroy()
end

function Boosts:_ClearExpiredBoosts()
	local flag = false

	for k, _boost in pairs(self._boosts) do
		if not (tick() > _boost.Window) then
			continue
		end

		self:RemoveBoost(k, true)
		flag = true
	end

	if flag then
		self.BoostsChanged:Fire()
	end
end

function Boosts:_Init() end

return Boosts