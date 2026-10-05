local color = Color3.fromRGB(44, 185, 247)
local color2 = Color3.fromRGB(31, 172, 234)
return {
	TopImage = "rbxassetid://115331344652194",
	Start = function(data)
		local random = Random.new()
		local frame = Instance.new("Frame")
		frame.Name = "Sky"
		frame.Size = UDim2.fromScale(1, 1)
		frame.BackgroundColor3 = color
		frame.BorderSizePixel = 0
		frame.ZIndex = data.ZIndex
		frame.Parent = data.Container
		local zIndex = data.ZIndex + 1
		local v2 = {}
		local v3 = random:NextInteger(0, 1) == 0

		for i = 1, 6 do
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = "Petal" .. i
			imageLabel.BackgroundTransparency = 1
			imageLabel.Image = "rbxassetid://79525185536778"
			imageLabel.ImageColor3 = color2
			imageLabel.ScaleType = Enum.ScaleType.Fit
			imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			imageLabel.ZIndex = zIndex
			imageLabel.Visible = false
			local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
			uIAspectRatioConstraint.AspectRatio = 1
			uIAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Width
			uIAspectRatioConstraint.Parent = imageLabel
			imageLabel.Parent = data.Container
			v2[i] = imageLabel
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function release(p)
			p.Visible = false
			table.insert(v2, p)
		end

		local function spawn()
			local v4 = table.remove(v2)

			if not v4 then
				return
			end

			local number = random:NextNumber(0.2, 0.3)
			local number2 = random:NextNumber(7, 11)
			local v5 = v3 and 0.04 or 0.72
			local number3 = random:NextNumber(v5, v5 + 0.24)
			v3 = not v3
			v4.Size = UDim2.fromScale(number, number)
			v4.Position = UDim2.fromScale(number3, -0.35)
			v4.Visible = true
			data.Tween(v4, TweenInfo.new(number2, Enum.EasingStyle.Linear), {
				Position = UDim2.fromScale(number3, 1.35)
			}, function()
				release(v4) -- equivalent call inferred; original call site unknown
			end)
		end

		data.Loop(1.4, spawn)
	end
}