local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local intersection = t.intersection(t.numberMinExclusive(-1e999), t.numberMaxExclusive(1e999))
local v = {
	{
		attribute = "CooldownEndTime",
		kind = "number",
		blank = 0
	},
	{
		attribute = "CooldownDuration",
		kind = "number",
		blank = 0
	},
	{
		attribute = "CooldownActive",
		kind = "boolean",
		blank = false
	}
}
local strict = t.strict(intersection)
local strict2 = t.strict(t.instanceIsA("Tool"))
local ToolCooldown = {}

local function readyAtOf(instance)
	local cooldownEndTime = instance:GetAttribute("CooldownEndTime")

	if type(cooldownEndTime) == "number" then
		return cooldownEndTime
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function markIdle(instance)
	instance:SetAttribute("CooldownActive", false)
	instance:SetAttribute("CooldownDuration", 0)
	instance:SetAttribute("CooldownEndTime", 0)
end

function ToolCooldown.PrimeTool(instance)
	strict2(instance)

	for _, v2 in v do
		if typeof(instance:GetAttribute(v2.attribute)) == v2.kind then
			continue
		end

		instance:SetAttribute(v2.attribute, v2.blank)
	end
end

function ToolCooldown.IsRunning(instance)
	strict2(instance)
	local cooldownEndTime

	if instance:GetAttribute("CooldownActive") then
		cooldownEndTime = instance:GetAttribute("CooldownEndTime")

		if type(cooldownEndTime) ~= "number" then
			cooldownEndTime = nil
		end
	end

	return cooldownEndTime ~= nil and workspace:GetServerTimeNow() < cooldownEndTime
end

function ToolCooldown.SecondsRemaining(instance)
	strict2(instance)
	local cooldownEndTime

	if ToolCooldown.IsRunning(instance) then
		cooldownEndTime = instance:GetAttribute("CooldownEndTime")

		if type(cooldownEndTime) ~= "number" then
			cooldownEndTime = nil
		end
	end

	if cooldownEndTime == nil then
		return 0
	end

	return (math.max(0, cooldownEndTime - workspace:GetServerTimeNow()))
end

function ToolCooldown.Begin(instance, cooldownDuration: number)
	strict2(instance)
	strict(cooldownDuration)
	assert(cooldownDuration >= 0)
	local v2 = workspace:GetServerTimeNow() + cooldownDuration
	instance:SetAttribute("CooldownDuration", cooldownDuration)
	instance:SetAttribute("CooldownEndTime", v2)
	instance:SetAttribute("CooldownActive", true)
	task.delay(cooldownDuration, function()
		if instance and instance.Parent and instance:GetAttribute("CooldownEndTime") == v2 then
			markIdle(instance) -- equivalent call inferred; original call site unknown
		end
	end)
end

function ToolCooldown.Cancel(instance)
	strict2(instance)
	markIdle(instance) -- equivalent call inferred; original call site unknown
end

return ToolCooldown