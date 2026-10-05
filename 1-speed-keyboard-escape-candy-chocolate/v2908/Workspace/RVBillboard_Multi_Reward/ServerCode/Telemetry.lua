local AnalyticsService = game:GetService("AnalyticsService")
local name = Enum.AnalyticsCustomFieldKeys.CustomField01.Name
local name2 = Enum.AnalyticsCustomFieldKeys.CustomField02.Name
local name3 = Enum.AnalyticsCustomFieldKeys.CustomField03.Name
local v = {
	Boot = true,
	RegisterOpportunity = true,
	AdStarted = true,
	AdComplete = true,
	AdIncomplete = true
}
local Telemetry = {}
Telemetry.__index = Telemetry

function Telemetry.new(data)
	local object = setmetatable({}, Telemetry)
	object._devProductId = tostring(data.DevProductId)
	object._placementId = tostring(data.PlacementId)
	object._bucket = tostring(data.Bucket)
	object._productPlacementKey = object._devProductId .. "|" .. object._placementId
	return object
end

function Telemetry:Log(p2, p3: string)
	if not v[p3] then
		return
	end

	local success, result = pcall(AnalyticsService.LogCustomEvent, AnalyticsService, p2, "RVB", nil, {
		[name] = p3,
		[name2] = self._productPlacementKey,
		[name3] = self._bucket
	})

	if not success then
		warn("[RVBillboard/Telemetry] LogCustomEvent failed — " .. tostring(result))
	end
end

function Telemetry:SetBucket(p2: string)
	self._bucket = tostring(p2)
end

function Telemetry:SetPlacementId(p)
	self._placementId = tostring(p)
	self._productPlacementKey = self._devProductId .. "|" .. self._placementId
end

function Telemetry:SetDevProductId(p)
	self._devProductId = tostring(p)
	self._productPlacementKey = self._devProductId .. "|" .. self._placementId
end

return Telemetry