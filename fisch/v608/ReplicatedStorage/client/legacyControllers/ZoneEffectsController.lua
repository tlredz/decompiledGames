local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Workspace")
local localizedevents = require(ReplicatedStorage.shared.modules.library.localizedevents)
local module = require("./ZoneController")
local v = {}
local v2 = {}
local currentZoneName = module.CurrentZoneName

local function isInZone(p)
	for _, activeZone in p.ActiveZones do
		if activeZone == currentZoneName then
			return true
		end
	end

	return false
end

local function shouldBeActive(p)
	local attribute = workspace:GetAttribute(p.AttributeName)

	if not attribute then
		return attribute
	end

	for _, activeZone in p.ActiveZones do
		if activeZone == currentZoneName then
			return true
		end
	end

	attribute = false
	return false
end

local function evaluate(data)
	local v3 = v[data.Name]

	if not v3 then
		return
	end

	local v4 = v2[data.Name]
	local attribute = workspace:GetAttribute(data.AttributeName)

	if attribute then
		local flag = true

		for _, activeZone in data.ActiveZones do
			if activeZone ~= currentZoneName then
				continue
			end

			attribute = true
			flag = false
			break
		end

		if flag then
			attribute = false
		end
	end

	if attribute and not v4 then
		v2[data.Name] = v3.new()
	elseif not attribute and v4 then
		v4:Destroy()
		v2[data.Name] = nil
	end
end

return {
	Start = function(_)
		for _, moduleScript in script:GetChildren() do
			if not moduleScript:IsA("ModuleScript") then
				continue
			end

			local v3 = v
			local name = moduleScript.Name
			local module2 = require(moduleScript)
			v3[name] = module2
		end

		for _, localizedevent in localizedevents do
			if not v[localizedevent.Name] then
				continue
			end

			local v3 = localizedevent
			workspace:GetAttributeChangedSignal(localizedevent.AttributeName):Connect(function()
				evaluate(v3)
			end)
		end

		module:ObserveZone(function(p: string)
			currentZoneName = p

			for _, localizedevent in localizedevents do
				evaluate(localizedevent)
			end
		end)
	end
}