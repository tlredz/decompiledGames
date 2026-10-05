local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	colorPulse = function(instance, pulseTime: number, items, items2)
		if instance.Name:find("^glow_") then
			return
		end

		instance:SetAttribute("PulseTime", pulseTime)

		if items then
			for k, item in items do
				instance:SetAttribute(`PulseColor{k}`, item)
			end
		end

		if items2 then
			for k, item in items2 do
				instance:SetAttribute(`PulseTrans{k}`, item)
			end
		end

		instance:AddTag("ColorPulse")
	end,
	ORIGINAL_COLOR = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Symbol"))("ORIGINAL_COLOR")
}