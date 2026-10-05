local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
local tweenInfo2 = TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo3 = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 6, true)

local function randomBetween(p: number, p2: number)
	return p + math.random() * (p2 - p)
end

local function buildBubbles(data)
	local result = {}

	for i = 1, 16 do
		local frame = Instance.new("Frame")
		frame.Name = "Bubble" .. i
		frame.BackgroundTransparency = 1
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Visible = false
		frame.ZIndex = data.ZIndex + 2
		frame.Parent = data.Container
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = "Image"
		imageLabel.BackgroundTransparency = 1
		imageLabel.Image = "rbxassetid://114576230858857"
		imageLabel.ImageTransparency = 1
		imageLabel.Size = UDim2.fromScale(1, 1)
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		imageLabel.ZIndex = frame.ZIndex
		imageLabel.Parent = frame
		table.insert(result, {
			Frame = frame,
			Image = imageLabel
		})
	end

	return result
end

local function playBubbleBurst(data, bubbles)
	for i, v in ipairs(bubbles) do
		local v2 = math.floor((i - 1) / 3) * 0.1
		local v3 = v
		local v4 = i
		task.delay(v2, function()
			if not data.IsLive() or v3.Frame.Visible then
				return
			end

			local v5 = 0.09 + math.random() * 0.21
			local v6 = (v4 - 1) / 3.46 % 1
			v3.Frame.Size = UDim2.fromScale(v5, v5)
			v3.Frame.Position = UDim2.fromScale(v6, 1.25)
			v3.Frame.Visible = true
			v3.Image.ImageTransparency = 0.75 + math.random() * 0.19999999999999996
			local v7 = 0.5 - (-1 + math.random() * 2) * 0.18
			v3.Image.Position = UDim2.fromScale(v7, 0.5)
			data.Tween(v3.Image, tweenInfo3, {
				Position = UDim2.fromScale(1 - v7, 0.5)
			})
			data.Tween(v3.Frame, tweenInfo2, {
				Position = UDim2.fromScale(v6, -0.3),
				Size = UDim2.fromScale(v5 - 0.03, v5 - 0.03)
			}, function()
				v3.Frame.Visible = false
			end)
		end)
	end
end

return {
	Start = function(data)
		local v = {}

		for i = 1, 8 do
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = "Ray" .. i
			imageLabel.BackgroundTransparency = 1
			imageLabel.Image = "rbxassetid://104839841577007"
			imageLabel.ImageTransparency = 1
			imageLabel.Size = UDim2.fromScale(0.28, 1.15)
			imageLabel.AnchorPoint = Vector2.new(0.5, 0)
			imageLabel.Position = UDim2.fromScale(0.5, 0)
			imageLabel.Visible = false
			imageLabel.ZIndex = data.ZIndex + 1
			imageLabel.Parent = data.Container
			table.insert(v, imageLabel)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function release(p)
			p.Visible = false
			p.ImageTransparency = 1
			table.insert(v, p)
		end

		local bubbles = buildBubbles(data)
		data.Loop(20, function()
			playBubbleBurst(data, bubbles)
		end)
		data.Loop(0.4, function()
			task.wait(math.random() * 0.4)

			if not data.IsLive() then
				return
			end

			local v2 = table.remove(v)

			if not v2 then
				return
			end

			v2.Size = UDim2.fromScale((0.45 + math.random() * 0.55) * 0.28, 1.15 + math.random() * 0.3500000000000001)
			v2.Position = UDim2.fromScale(math.random(), -(0.08 + math.random() * 0.16999999999999998))
			v2.ImageTransparency = 1
			v2.Visible = true
			local tweenInfo4 = TweenInfo.new(2 + math.random() * 1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			data.Tween(v2, tweenInfo4, {
				ImageTransparency = 0.2
			}, function()
				if data.IsLive() then
					data.Tween(v2, tweenInfo, {
						ImageTransparency = 1
					}, function()
						release(v2) -- equivalent call inferred; original call site unknown
					end)
					return
				end

				release(v2) -- equivalent call inferred; original call site unknown
			end)
		end)
	end,
	BackingIsPrint = true
}