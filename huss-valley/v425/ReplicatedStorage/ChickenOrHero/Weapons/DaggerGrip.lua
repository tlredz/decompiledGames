local DaggerConfig = require(script.Parent.DaggerConfig)
return table.freeze({
	c0 = function(instance)
		local gripC0 = instance:GetAttribute("GripC0") or CFrame.identity
		local gripInwardStuds = instance:GetAttribute("GripInwardStuds")

		if type(gripInwardStuds) ~= "number" then
			gripInwardStuds = DaggerConfig.GripInwardStuds or 0
		end

		return CFrame.new(-math.clamp(gripInwardStuds, -1, 1), 0, 0) * gripC0
	end
})