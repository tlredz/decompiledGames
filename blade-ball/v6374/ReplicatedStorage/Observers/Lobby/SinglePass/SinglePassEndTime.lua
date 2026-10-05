local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local FFlagClient = require(ReplicatedStorage.ClientGameModules.FFlagClient)
local SinglePassFFlags = require(ReplicatedStorage.Shared.SinglePass.SinglePassFFlags)
local v = nil
local v2 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function updateEndTime(instance, endTime)
	instance:SetAttribute("EndTime", endTime)
end

local function updateFlags()
	local endTime = SinglePassFFlags:Get("EndTime") or 0
	v = endTime

	for _, v3 in ipairs(v2) do
		updateEndTime(v3, endTime) -- equivalent call inferred; original call site unknown
	end
end

FFlagClient.DataUpdatedEvent:Connect(updateFlags)
task.spawn(updateFlags)
return Observers.observeTag("SinglePassEndTime", function(instance)
	table.insert(v2, instance)

	if v then
		updateEndTime(instance, v) -- equivalent call inferred; original call site unknown
	end

	return function()
		local index = table.find(v2, instance)

		if index then
			table.remove(v2, index)
		end
	end
end, { workspace })