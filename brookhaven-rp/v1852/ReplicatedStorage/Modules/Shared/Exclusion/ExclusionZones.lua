local createVector = vector.create
local ExclusionZones = {}
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ExclusionZoneUtil = require(ReplicatedStorage.Modules.Shared.Utils.ExclusionZoneUtil)
local v = {}
local v2 = {}
local flag = false

local function addZone(part)
	if v2[part] ~= nil then
		return
	end

	table.insert(v, {
		part = part,
		groups = ExclusionZoneUtil.parseGroups((part:GetAttribute(ExclusionZoneUtil.GROUPS_ATTRIBUTE)))
	})
	v2[part] = #v
end

local function removeZone(p)
	local v3 = v2[p]

	if v3 == nil then
		return
	end

	local count = #v
	local v4 = v[count]
	v[v3] = v4
	v2[v4.part] = v3
	v[count] = nil
	v2[p] = nil
end

local function trackTag(tag: string, fn)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function onAdded(part)
		if part:IsA("BasePart") and fn(part) then
			addZone(part)
		end
	end

	CollectionService:GetInstanceAddedSignal(tag):Connect(onAdded)
	CollectionService:GetInstanceRemovedSignal(tag):Connect(removeZone)

	for _, v3 in CollectionService:GetTagged(tag) do
		onAdded(v3) -- equivalent call inferred; original call site unknown
	end
end

function ExclusionZones.GetRestrictedEntryDistance(p: string, vector2: Vector3, vector3: Vector3, p2: number)
	local v3 = nil

	for _, v4 in v do
		if v4.groups[p] == nil then
			continue
		end

		local part = v4.part
		local segmentEntryDistance = ExclusionZoneUtil.getSegmentEntryDistance(
			part.CFrame,
			part.Size,
			vector2,
			vector3,
			p2
		)

		if segmentEntryDistance == nil then
			continue
		end

		v3 = segmentEntryDistance
		p2 = v3
		v3 = p2
	end

	return v3
end

function ExclusionZones.IsPointRestricted(p: string, vector2: Vector3)
	return ExclusionZones.GetRestrictedEntryDistance(p, vector2, createVector(0, 1, 0), 0) ~= nil
end

function ExclusionZones.start()
	if flag then
		return
	end

	flag = true
	trackTag(ExclusionZoneUtil.CLIENT_ZONE_TAG, function()
		return true
	end)
	trackTag(ExclusionZoneUtil.DYNAMIC_ZONE_TAG, function(instance)
		return instance:IsDescendantOf(workspace)
	end)
end

return ExclusionZones