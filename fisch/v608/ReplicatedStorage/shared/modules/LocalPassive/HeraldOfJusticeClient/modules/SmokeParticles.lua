local TweenService = game:GetService("TweenService")

local function fastTween(p, p2, p3, callback)
	local tween = TweenService:Create(p, p2, p3)
	tween.Completed:Once(function()
		tween:Destroy()

		if callback then
			callback()
		end
	end)
	tween:Play()
	return tween
end

return {
	Play = function(self, options)
		local v = options or {}
		local image = v.image
		local count = v.count or 18
		local lifeMin = v.lifeMin or 0.35
		local lifeMax = v.lifeMax or 0.75
		local distMin = v.distMin or 0.08
		local distMax = v.distMax or 0.22
		local startScaleMin = v.startScaleMin or 0.25
		local startScaleMax = v.startScaleMax or 0.55
		local endScaleMin = v.endScaleMin or 0.9
		local endScaleMax = v.endScaleMax or 1.6
		local zIndex = v.zIndex or 50
		local imageTransparency = v.startTransparency == nil and 0.1 or v.startTransparency

		for _ = 1, count do
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = "SmokePuff"
			imageLabel.BackgroundTransparency = 1
			imageLabel.Image = image
			imageLabel.ImageTransparency = imageTransparency
			imageLabel.ScaleType = Enum.ScaleType.Fit
			imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			imageLabel.Position = UDim2.fromScale(0.5, 0.5)
			imageLabel.Rotation = math.random(0, 360)
			imageLabel.ZIndex = zIndex

			if v.color then
				imageLabel.ImageColor3 = v.color
			end

			imageLabel.Parent = self
			local number = Random.new():NextNumber(startScaleMin, startScaleMax)
			imageLabel.Size = UDim2.fromScale(number, number)
			local uIScale = Instance.new("UIScale")
			uIScale.Scale = 1
			uIScale.Parent = imageLabel
			local number2 = Random.new():NextNumber(0, 6.283185307179586)
			local number3 = Random.new():NextNumber(distMin, distMax)
			local v3 = math.cos(number2) * number3
			local v4 = math.sin(number2) * number3
			local number4 = Random.new():NextNumber(lifeMin, lifeMax)
			local number5 = Random.new():NextNumber(endScaleMin, endScaleMax)
			local tween = TweenService:Create(
				imageLabel,
				TweenInfo.new(number4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Position = UDim2.fromScale(0.5 + v3, 0.5 + v4),
					Rotation = imageLabel.Rotation + math.random(-120, 120),
					ImageTransparency = 1
				}
			)
			local v8 = nil
			tween.Completed:Once(function()
				tween:Destroy()

				if v8 then
					v8()
				end
			end)
			tween:Play()

			local function fn()
				imageLabel:Destroy()
			end

			local tween2 = TweenService:Create(
				uIScale,
				TweenInfo.new(number4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Scale = number5
				}
			)
			tween2.Completed:Once(function()
				tween2:Destroy()

				if fn then
					fn()
				end
			end)
			tween2:Play()
		end
	end
}