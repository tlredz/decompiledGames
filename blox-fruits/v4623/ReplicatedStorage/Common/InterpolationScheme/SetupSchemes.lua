local GetSchemesFor = require(script.Parent.GetSchemesFor)

local function SetupSchemesOnInstance(instance)
	if instance:GetAttribute("TimeLength") then
		warn("Resetting InterpolationScheme attributes for " .. instance:GetFullName())
	end

	instance:SetAttribute("TimeLength", 1)
	instance:SetAttribute("IsPlaying", false)
	instance:SetAttribute("Keypoints", 20)
	instance:SetAttribute("DelayBeforePlay", 0)
	local schemesFor = GetSchemesFor(instance)

	if schemesFor then
		for _, v2 in pairs(schemesFor) do
			v2.Setup(instance)
		end
	else
		instance:SetAttribute("TimeLength", nil)
		instance:SetAttribute("IsPlaying", nil)
		instance:SetAttribute("Keypoints", nil)
		instance:SetAttribute("DelayBeforePlay", nil)
	end
end

local function SetupSchemes(value)
	if typeof(value) == "Instance" then
		SetupSchemesOnInstance(value)
	elseif typeof(value) == "table" then
		for _, item in ipairs(value) do
			SetupSchemesOnInstance(item)
		end
	end
end

return SetupSchemes