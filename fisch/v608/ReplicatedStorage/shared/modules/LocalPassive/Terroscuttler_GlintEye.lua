game:GetService("ReplicatedStorage")
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local module = require("./PassiveHandler")
local quad = Enum.EasingStyle.Quad
local out = Enum.EasingDirection.Out
local TerroscuttlerGlintEye = {
	Morph = function(p, _, data)
		local fish = data.reel_bar:FindFirstChild("fish")

		if not fish then
			return
		end

		local clone = fish:Clone()
		clone.Name = "GlintEyeGhost"

		for _, child in clone:GetChildren() do
			if child.Name == "sparkles" or child.Name == "stroke" then
				child:Destroy()
			end
		end

		local icon = clone:FindFirstChild("icon")

		if icon and icon:IsA("ImageLabel") then
			icon.Visible = true
			icon.ImageTransparency = 1
		end

		clone.BackgroundTransparency = 1
		clone.Visible = true
		clone.ZIndex = math.max(fish.ZIndex - 1, 1)
		clone.Parent = data.reel_bar
		p.reelTrove:Add(clone)
		local scale = fish.Position.Y.Scale
		local now = 0
		local currentTarget = data.core.fish.CurrentTarget
		local v = currentTarget
		local v2 = currentTarget
		p.reelTrove:Add(data.OnFishMove:Connect(function(p2: number, _: number)
			currentTarget = v2
			v = p2
			now = tick()
		end))
		p.reelTrove:Add(data.OnRenderStep:Connect(function()
			if not data.active then
				clone.Visible = false
				return
			end

			clone.Visible = true
			local v3 = tick() - now
			local value = TweenService:GetValue(math.clamp(v3 / 0.22, 0, 1), quad, out)
			v2 = currentTarget + (v - currentTarget) * value
			clone.Position = UDim2.fromScale(v2, scale)
			clone.BackgroundTransparency = 1 + -0.30000000000000004 * value

			if icon and icon:IsA("ImageLabel") then
				icon.ImageTransparency = 1 + -0.65 * value
			end
		end))
	end
}
setmetatable(TerroscuttlerGlintEye, module)
return TerroscuttlerGlintEye