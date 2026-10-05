local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Timer = require(ReplicatedStorage.Packages.Timer)
local ExclusionConfig = require(ReplicatedStorage.Modules.Shared.DB.Exclusion.ExclusionConfig)
local ExclusionZones = require(ReplicatedStorage.Modules.Shared.Exclusion.ExclusionZones)
local v = Component.new({
	Tag = "ExclusionProjectile"
})
local object = setmetatable({}, {
	__mode = "k"
})

function v.track(instance, exclusionItemId: string, callback)
	instance:SetAttribute("ExclusionItemId", exclusionItemId)

	if callback ~= nil then
		object[instance] = callback
	end

	instance:AddTag("ExclusionProjectile")
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._isBlocked = false
	self._isStopped = false
	self._hasPendingBlock = false
end

function v:_Block(vector: Vector3, vector2: Vector3)
	if self._isBlocked then
		return
	end

	self._isBlocked = true
	local instance = self.Instance
	local v2 = object[instance]
	object[instance] = nil

	if v2 ~= nil then
		v2(vector, vector2)
	end

	instance:Destroy()
end

function v:Start()
	local instance = self.Instance
	local exclusionItemId = instance:GetAttribute("ExclusionItemId")
	assert(typeof(exclusionItemId) == "string", (`{instance:GetFullName()} is missing the ExclusionItemId attribute`))
	local group = ExclusionConfig.GetGroupById(exclusionItemId)

	if group == nil or self._isStopped then
		return
	end

	local position = instance.Position

	if ExclusionZones.IsPointRestricted(group, position) then
		self:_Block(position, instance.CFrame.LookVector)
		return
	end

	local v2 = time()
	self._Janitor:Add(Timer.simple(0.1, function()
		if self._isStopped then
			return
		end

		local v3 = time()
		local v4 = v3 - v2
		v2 = v3
		local position2 = instance.Position
		local v5 = position
		position = position2
		local v6 = position2 - v5
		local magnitude = v6.Magnitude

		if magnitude < 0.001 then
			return
		end

		local v7 = v6 / magnitude
		local v8 = magnitude / v4
		local restrictedEntryDistance = ExclusionZones.GetRestrictedEntryDistance(group, v5, v7, magnitude + v8 * 0.1)

		if restrictedEntryDistance == nil then
			return
		end

		if restrictedEntryDistance <= magnitude then
			self:_Block(v5 + v7 * restrictedEntryDistance, v7)
			return
		end

		if self._hasPendingBlock then
			return
		end

		self._hasPendingBlock = true
		self._Janitor:Add(task.delay((restrictedEntryDistance - magnitude) / v8, function()
			self._hasPendingBlock = false
			local v9 = instance.Position - position2
			local magnitude2 = v9.Magnitude

			if magnitude2 < 0.001 then
				return
			end

			local v10 = v9 / magnitude2
			local restrictedEntryDistance2 = ExclusionZones.GetRestrictedEntryDistance(
				group,
				position2,
				v10,
				magnitude2 + 2
			)

			if restrictedEntryDistance2 ~= nil then
				self:_Block(position2 + v10 * restrictedEntryDistance2, v10)
			end
		end), true)
	end))
end

function v:Stop()
	self._isStopped = true
	object[self.Instance] = nil
	self._Janitor:Destroy()
end

return v