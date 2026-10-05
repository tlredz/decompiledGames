local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.UI.InWorldDialog)
local SpecialLevelEvents = {}
local v = {}
local v2 = {}

function SpecialLevelEvents.RegisterEvent(p, p2)
	v[p] = p2
end

function SpecialLevelEvents.HasSpecialEvents(p)
	return v[p] ~= nil
end

function SpecialLevelEvents.ExecuteEvents(specialEventType, instance, p)
	local v3 = v[specialEventType]

	if not v3 then
		return false
	end

	v2[instance] = {}

	if v3.hasLocalEvents then
		local v4 = ReplicatedStorage:FindFirstChild("SpecialLevelEventRemote")

		if not v4 then
			v4 = Instance.new("RemoteEvent")
			v4.Name = "SpecialLevelEventRemote"
			v4.Parent = ReplicatedStorage
		end

		task.wait(0.1)
		v4:FireAllClients("ExecuteLocalEvent", specialEventType, instance, p)
	end

	local success, result = pcall(function()
		if v3.loadDelay then
			task.wait(v3.loadDelay)
		end

		if v3.onRoomLoad then
			v3.onRoomLoad(instance, p)
		end

		if v3.setupDelay then
			task.wait(v3.setupDelay)
		end

		local v4 = v3.setupBehaviors and v3.setupBehaviors(instance, p)

		if v4 then
			table.insert(v2[instance], v4)
		end

		if v3.properties then
			for k, property in pairs(v3.properties) do
				instance:SetAttribute(k, property)
			end
		end

		instance:SetAttribute("HasSpecialEvents", true)
		instance:SetAttribute("SpecialEventType", specialEventType)
		instance.AncestryChanged:Connect(function()
			if not instance.Parent then
				SpecialLevelEvents.CleanupRoom(instance)
			end
		end)
	end)

	if success then
		return true
	end

	warn("[SpecialLevelEvents] Error executing events for", specialEventType, ":", result)
	return false
end

function SpecialLevelEvents.CleanupRoom(p)
	local v3 = v2[p]

	if v3 then
		for _, v4 in ipairs(v3) do
			local v5 = v4
			local success, result = pcall(function()
				if type(v5) == "function" then
					v5()
				elseif type(v5) == "table" and v5.cleanup then
					v5.cleanup()
				end
			end)

			if not success then
				warn("[SpecialLevelEvents] Cleanup error:", result)
			end
		end

		v2[p] = nil
	end
end

function SpecialLevelEvents.GetRegisteredLevels()
	local result = {}

	for k, _ in pairs(v) do
		table.insert(result, k)
	end

	return result
end

function SpecialLevelEvents.GetEventConfig(p)
	return v[p]
end

return SpecialLevelEvents