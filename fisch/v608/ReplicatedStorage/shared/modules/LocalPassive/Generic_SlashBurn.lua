game:GetService("RunService")
local module = require("./PassiveHandler")
local color = Color3.fromRGB(255, 110, 40)
local GenericSlashBurn = {
	Morph = function(p, instance, object)
		local config = p.config
		local modifier = object:CreateModifier("progressefficiency", "add")
		local v = config.ProgressSpeed / 100
		local fish = instance:FindFirstChild("fish")
		local icon = fish and fish:FindFirstChild("icon")
		local imageColor3 = icon and icon.ImageColor3
		p.reelTrove:Connect(object.OnSlash, function(p2: string)
			if config.AllowedSources and not table.find(config.AllowedSources, p2) then
				return
			end

			modifier.Value = v
		end)
		p.reelTrove:Connect(object.OnLogicStep, function(p2: number)
			if object.isPaused or not object.active then
				return
			end

			modifier.Value = math.max(modifier.Value - config.Decay / 100 * p2, 0)

			if icon and icon.Parent then
				icon.ImageColor3 = imageColor3:Lerp(color, modifier.Value / v)
			end
		end)

		if icon then
			p.reelTrove:Add(function()
				if icon.Parent then
					icon.ImageColor3 = imageColor3
				end
			end)
		end
	end
}
setmetatable(GenericSlashBurn, module)
return GenericSlashBurn