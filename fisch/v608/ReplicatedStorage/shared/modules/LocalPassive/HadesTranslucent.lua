local RunService = game:GetService("RunService")
game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
local HadesTranslucent = {
	Morph = function(p, _, data)
		local reel_bar = data.reel_bar

		if not reel_bar then
			return
		end

		local transparenciesByInstance = {}
		local imageTransparenciesByInstance = {}
		local textTransparenciesByInstance = {}
		local transparenciesByInstance2 = {}

		local function cacheDescendant(instance)
			if instance:GetAttribute("HadesTranslucentIgnore") then
				return
			end

			if instance:IsA("GuiObject") then
				transparenciesByInstance[instance] = instance.Transparency
			end

			if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
				imageTransparenciesByInstance[instance] = instance.ImageTransparency
			end

			if instance:IsA("TextLabel") or instance:IsA("TextButton") then
				textTransparenciesByInstance[instance] = instance.TextTransparency
			end

			if instance:IsA("UIStroke") then
				transparenciesByInstance2[instance] = instance.Transparency
			end
		end

		for _, descendant in ipairs(reel_bar:GetDescendants()) do
			cacheDescendant(descendant)
		end

		cacheDescendant(reel_bar)
		p.reelTrove:Add(reel_bar.DescendantAdded:Connect(function(descendant)
			task.defer(cacheDescendant, descendant)
		end))
		local startAlpha = p.config.StartAlpha or 1
		local endAlpha = p.config.EndAlpha or 0.08
		local curveExponent = p.config.CurveExponent or 1.6
		p.reelTrove:Add(RunService.RenderStepped:Connect(function()
			if not data.active then
				return
			end

			local v = math.clamp((data.progress or 0) / 100, 0, 1) ^ curveExponent
			local v2 = startAlpha + (endAlpha - startAlpha) * v

			for k, v3 in pairs(transparenciesByInstance) do
				if k.Parent then
					k.Transparency = 1 - (1 - v3) * v2
				end
			end

			for k, v3 in pairs(imageTransparenciesByInstance) do
				if k.Parent then
					k.ImageTransparency = 1 - (1 - v3) * v2
				end
			end

			for k, v3 in pairs(textTransparenciesByInstance) do
				if k.Parent then
					k.TextTransparency = 1 - (1 - v3) * v2
				end
			end

			for k, v3 in pairs(transparenciesByInstance2) do
				if k.Parent then
					k.Transparency = 1 - (1 - v3) * v2
				end
			end
		end))
	end
}
setmetatable(HadesTranslucent, module)
return HadesTranslucent