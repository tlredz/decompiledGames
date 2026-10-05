local BaseConfiguration = require(script.Parent:WaitForChild("BaseConfiguration"))
local parent = script.Parent.Parent.Parent
local t = require(parent.t)
local ClientConfiguration = {}
ClientConfiguration.__index = ClientConfiguration
ClientConfiguration._isClient = true
ClientConfiguration.superClass = BaseConfiguration
setmetatable(ClientConfiguration, BaseConfiguration)
local v = {
	_experienceMapping = t.table,
	_performanceSamplePercent = t.number,
	_performanceConnectSamplePercent = t.number,
	_timingsSamplePercent = t.number
}

function ClientConfiguration.new()
	return (setmetatable(BaseConfiguration.new(), ClientConfiguration))
end

function ClientConfiguration.Validate(p)
	for k, v2 in v do
		if p[k] == nil then
			continue
		end

		local v3, v4 = v2(p[k])

		if not v3 then
			error("Supplied invalid type for " .. k .. " in configuration: " .. v4)
		end
	end
end

function ClientConfiguration:ExperienceMapping(experienceMapping)
	self._experienceMapping = experienceMapping
	return self
end

function ClientConfiguration:GetExperienceMapping()
	return self._experienceMapping
end

function ClientConfiguration:PerformanceSamplePercent(performanceSamplePercent: number)
	self._performanceSamplePercent = performanceSamplePercent
	return self
end

function ClientConfiguration:GetPerformanceSamplePercent()
	return self._performanceSamplePercent
end

function ClientConfiguration:PerformanceConnectSamplePercent(performanceConnectSamplePercent: number)
	self._performanceConnectSamplePercent = performanceConnectSamplePercent
	return self
end

function ClientConfiguration:GetPerformanceConnectSamplePercent()
	return self._performanceConnectSamplePercent
end

function ClientConfiguration:TimingsSamplePercent(timingsSamplePercent: number)
	self._timingsSamplePercent = timingsSamplePercent
	return self
end

function ClientConfiguration:GetTimingsSamplePercent()
	return self._timingsSamplePercent
end

return ClientConfiguration