game:GetService("RunService")
local module = require("./PassiveHandler")
local BreezeCaster = {
	Morph = function(p, _, object)
		local config = p.config
		object:AddModifier("barMoveSpeed", "multiply", config.BarSpeedMultiplier or 1.75)
		local v = math.clamp(config.FishPullStrength or 0.35, 0, 1)
		p.reelTrove:Add(object.core.fish.OnMovementAttempted:BindAtPriority(500, function(p2, p3, p4, p5)
			if p2 then
				return p2, p3 + (object.barPosition - p3) * v, p4, p5
			end

			return p2, p3, p4, p5
		end))
		local shakeIntensity = config.ShakeIntensity or 0.035
		local shakeStep = config.ShakeStep or 0.03
		p.reelTrove:Add(task.spawn(function()
			if not object.ready then
				object.OnReady:Wait()
			end

			object.fx:Shake(object.reel_bar, shakeIntensity, 1e999, shakeStep, false, 1)
		end))
		p.reelTrove:Add(function()
			local reel_bar = object.reel_bar
			local rootPosition = reel_bar and reel_bar:GetAttribute("RootPosition")

			if rootPosition then
				reel_bar.Position = rootPosition
			end
		end)
	end
}
setmetatable(BreezeCaster, module)
return BreezeCaster