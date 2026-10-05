game:GetService("RunService")
game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
local FloatieRise = {
	Morph = function(p, _, object)
		task.spawn(function()
			object:WaitUntilReady()
			local v = (p.config.MaxProgressSpeedBonus or 50) / 100
			local v2 = (p.config.MaxForcedProgressSpeedBonus or 10) / 100
			local v3 = (p.config.MaxTrueProgressSpeedBonus or 10) / 100
			local floatOffset = p.config.FloatOffset or 0.25
			local modifier = object:CreateModifier("progressefficiency", "add")
			local modifier2 = object:CreateModifier("progressefficiency", "force_add")
			local modifier3 = object:CreateModifier("trueprogressefficiency", "add")
			local reel_bar = object.reel_bar
			local position = reel_bar and reel_bar.Position

			if position then
				p.reelTrove:Add(function()
					if reel_bar and reel_bar.Parent then
						reel_bar.Position = position
					end
				end)
			end

			p.reelTrove:Add(object.OnLogicStep:Connect(function()
				if not object.active then
					return
				end

				local v4 = math.clamp(object.progress / 100, 0, 1)
				modifier.Value = v * v4
				modifier2.Value = v2 * v4
				modifier3.Value = v3 * v4

				if position then
					reel_bar.Position = position - UDim2.fromScale(0, floatOffset * v4)
				end
			end))
		end)
	end
}
setmetatable(FloatieRise, module)
return FloatieRise