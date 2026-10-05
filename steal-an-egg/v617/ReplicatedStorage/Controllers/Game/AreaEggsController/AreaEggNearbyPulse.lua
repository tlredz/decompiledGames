local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local EggGrowthAnimation = require(ReplicatedStorage.Shared.Eggs.EggGrowthAnimation)
local Player = require(ReplicatedStorage.Shared.Player)
local AreaEggNearbyPulse = {}
AreaEggNearbyPulse.__index = AreaEggNearbyPulse
AreaEggNearbyPulse.__class = "AreaEggNearbyPulse"

function AreaEggNearbyPulse.new(player)
	t.strict(t.instanceIsA("Player"))(player)
	local self = setmetatable({}, AreaEggNearbyPulse)
	self._player = player
	self._random = Random.new()
	self._registeredByUid = {}
	self._nextPulseAt = nil
	return self
end

function AreaEggNearbyPulse:_scheduleNextFor(p: string, p2: number)
	local v = assert(self._registeredByUid[p], (`Area egg {p} must be registered before scheduling`))
	local nextPulseAt = p2 + self._random:NextNumber(6, 25)
	v.NextPulseAt = nextPulseAt
	local _nextPulseAt = self._nextPulseAt

	if _nextPulseAt == nil or nextPulseAt < _nextPulseAt then
		self._nextPulseAt = nextPulseAt
	end
end

function AreaEggNearbyPulse:_recomputeNextPulseAt()
	local nextPulseAt = nil

	for _, v in pairs(self._registeredByUid) do
		if nextPulseAt == nil or v.NextPulseAt < nextPulseAt then
			nextPulseAt = v.NextPulseAt
		end
	end

	self._nextPulseAt = nextPulseAt
end

function AreaEggNearbyPulse:_collectClosest(vector: Vector3)
	local result = {}
	local v = {}

	for k, v2 in pairs(self._registeredByUid) do
		if not (v2.Model.Parent ~= nil and v2.Root.Parent ~= nil) then
			continue
		end

		local vector2 = v2.Root.Position - vector
		local dot = vector2:Dot(vector2)

		if dot > 122500 then
			continue
		end

		local v3 = #result + 1

		for i, v5 in ipairs(v) do
			if not (dot < v5) then
				continue
			end

			v3 = i
			break
		end

		if not (v3 <= 8) then
			continue
		end

		table.insert(result, v3, k)
		table.insert(v, v3, dot)

		if not (#result > 8) then
			continue
		end

		table.remove(result)
		table.remove(v)
	end

	return result
end

function AreaEggNearbyPulse:Bind(p: string, instance, p2: number)
	t.strict(t.string)(p)
	t.strict(t.instanceIsA("Model"))(instance)
	t.strict(t.number)(p2)
	self:Unbind(p)
	local primaryPart = instance.PrimaryPart
	assert(primaryPart ~= nil, (`Rendered area egg {p} must have a PrimaryPart`))
	local v = {
		Model = instance,
		Root = primaryPart,
		Animation = EggGrowthAnimation.new(instance, instance:GetPivot(), 2),
		NextPulseAt = 0
	}
	self._registeredByUid[p] = v
	self:_scheduleNextFor(p, p2)
	return function()
		if self._registeredByUid[p] == v then
			self:Unbind(p)
		end
	end
end

function AreaEggNearbyPulse:Unbind(p: string)
	t.strict(t.string)(p)
	local v = self._registeredByUid[p]

	if v == nil then
		return
	end

	local v2 = v.NextPulseAt == self._nextPulseAt
	self._registeredByUid[p] = nil
	v.Animation:Destroy()

	if v2 then
		self:_recomputeNextPulseAt()
	end
end

function AreaEggNearbyPulse:Step(p: number)
	t.strict(t.number)(p)
	local _nextPulseAt = self._nextPulseAt

	if _nextPulseAt == nil or p < _nextPulseAt then
		return
	end

	local part = Player.FindRootPart(self._player)
	local v = {}

	if part ~= nil then
		assert(part:IsA("BasePart"), "Local HumanoidRootPart must be a BasePart")

		for _, v2 in ipairs(self:_collectClosest(part.Position)) do
			v[v2] = true
		end
	end

	self._nextPulseAt = nil

	for k, v2 in pairs(self._registeredByUid) do
		if v2.NextPulseAt <= p then
			self:_scheduleNextFor(k, p)

			if v[k] then
				v2.Animation:SetBasePivot(v2.Model:GetPivot())
				v2.Animation:Play()
			end
		elseif self._nextPulseAt == nil or v2.NextPulseAt < self._nextPulseAt then
			self._nextPulseAt = v2.NextPulseAt
		end
	end
end

return AreaEggNearbyPulse