local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("../ZoneController")
local module2 = require("../LightingController")
local color = Color3.fromRGB(138, 138, 138)
local color2 = Color3.fromRGB(140, 142, 222)
return {
	Start = function(_)
		local cycle = ReplicatedStorage:WaitForChild("world"):WaitForChild("cycle")
		cycle.Changed:Connect(function()
			module2.UpdateLighting(14)
		end)
		module2.HookLighting:BindAtPriority(0, function(p)
			local currentZone = module.CurrentZone

			if currentZone and currentZone:FindFirstChild("underground") and currentZone.underground.Value then
				return p
			end

			local lighting = p.Lighting
			local ambient

			if cycle.Value == "Night" then
				ambient = color2
			else
				ambient = color
			end

			lighting.Ambient = ambient
			return p
		end)
	end
}