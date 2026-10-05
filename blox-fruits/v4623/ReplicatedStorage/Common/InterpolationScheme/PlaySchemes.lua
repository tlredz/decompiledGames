local GetSchemesFor = require(script.Parent.GetSchemesFor)

local function PlaySchemesOnInstance(instance)
	local timeLength = instance:GetAttribute("TimeLength")

	if instance:GetAttribute("IsPlaying") == true then
		warn("Cannot play Schemes on a currently playing instance : " .. instance:GetFullName())
		return
	end

	instance:SetAttribute("IsPlaying", true)
	local v, v2 = GetSchemesFor(instance)

	if v then
		local delayBeforePlay = instance:GetAttribute("DelayBeforePlay")

		if delayBeforePlay == 0 then
			for _, v3 in pairs(v) do
				v3.Play(instance, timeLength, v2)
			end
		else
			task.spawn(function()
				task.wait(delayBeforePlay)

				for _, v3 in pairs(v) do
					v3.Play(instance, timeLength, v2)
				end
			end)
		end
	end
end

local function PlaySchemes(value)
	if typeof(value) == "Instance" then
		PlaySchemesOnInstance(value)
		return value:GetAttribute("TimeLength") + value:GetAttribute("DelayBeforePlay")
	end

	if typeof(value) ~= "table" then
		return
	end

	local v = 0

	for _, item in ipairs(value) do
		local timeLength = item:GetAttribute("TimeLength")

		if timeLength == nil then
			continue
		end

		PlaySchemesOnInstance(item)
		local delayBeforePlay = item:GetAttribute("DelayBeforePlay")

		if v < timeLength + delayBeforePlay then
			v = timeLength + delayBeforePlay
		end
	end

	return v
end

return PlaySchemes