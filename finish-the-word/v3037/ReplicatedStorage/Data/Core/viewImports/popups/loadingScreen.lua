local import = _G.import("romodel")
local basic = _G.import("viewImports"):get("basic")
local rankedBackdrop = require(script.Parent.rankedBackdrop)
local tooltipData = require(script.Parent.tooltipData)
local import2 = _G.import("mathUtil")
local import3 = _G.import("iterator")
local RunService = game:GetService("RunService")
local wrapped = import.wrap("UIScale", basic.Element)
local model = import.model(basic.Corner)

function model.init(p)
	return {
		Name = p.Name,
		Size = UDim2.new(1, 0, 1, 0),
		LayoutOrder = p.LayoutOrder,
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		CornerRadius = UDim.new(1, 0),
		ZIndex = 20
	}, {
		Scale = import.make(wrapped, {
			Scale = 1
		})
	}
end

local model2 = import.model(basic.EmptyList)

function model2.init()
	return {
		Name = "Dots",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0.1, 0, 0.055, 0),
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0.14, 0)
	}, import3.gen(3, function(layoutOrder)
		local name = tostring(layoutOrder)
		return name, import.make(model, {
			Name = name,
			LayoutOrder = layoutOrder
		})
	end)
end

local model3 = import.model(basic.EmptyElement)

function model3.init(options)
	local v = options or {}
	return {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1
	}, {
		Dots = import.make(model2),
		Tooltip = import.make(import.wrap(basic.TextLabel, basic.Corner), {
			Name = "Tooltip",
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0.04, 0, 0.94, 0),
			Size = UDim2.new(0.58, 0, 0.052, 0),
			Text = v.Tooltip or import2.randomSet(tooltipData),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CornerRadius = UDim.new(0.12, 0),
			StrokeWidth = 0,
			ZIndex = 20
		}),
		BottomRight = import.make(basic.EmptyList, {
			Name = "BottomRight",
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(0.96, 0, 0.94, 0),
			Size = UDim2.new(0.28, 0, 0.115, 0),
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			Padding = UDim.new(0.08, 0)
		}, {
			Title = import.make(basic.TextLabel, {
				Name = "Title",
				Size = UDim2.new(1, 0, 0.68, 0),
				LayoutOrder = 1,
				Text = v.Title or "Teleporting",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextXAlignment = Enum.TextXAlignment.Right,
				StrokeWidth = 3,
				ZIndex = 20
			}),
			Subtext = import.make(basic.TextLabel, {
				Name = "Subtext",
				Size = UDim2.new(1, 0, 0.44, 0),
				LayoutOrder = 2,
				Text = v.Subtext or "0",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextXAlignment = Enum.TextXAlignment.Right,
				StrokeWidth = 3,
				ZIndex = 20
			})
		})
	}
end

function model3:spawn()
	self.TooltipRunning = true
	self.NextTooltip = import2.rollingUniqueRandomSet(tooltipData)
	task.spawn(function()
		while self.TooltipRunning do
			self.Tooltip:setText(self.NextTooltip())
			task.wait(6)
		end
	end)
	local dots = self.Dots
	local v = dots and import3.gen(3, function(p)
		return p, dots[tostring(p)]
	end)

	if not v then
		return
	end

	local lastTime = os.clock()
	self.WaveCon = RunService.Heartbeat:Connect(function()
		local v2 = os.clock() - lastTime

		for i, v3 in ipairs(v) do
			if not (v3 and v3.Scale) then
				continue
			end

			local v4 = (math.sin(v2 * 6 - (i - 1) * 1.35) + 1) * 0.5
			v3.Scale.Scale = v4 * 1.1 + 1
		end
	end)
end

function model3:despawn()
	self.TooltipRunning = false

	if self.WaveCon then
		self.WaveCon:Disconnect()
	end
end

local model4 = import.model("ScreenGui", basic.Ui)

function model4.init(options)
	local v = options or {}
	local props = rankedBackdrop.props(v)
	local content = v.Content or {
		Content = import.make(model3, v)
	}

	if v.ExtraContent and not v.Content then
		for k, v2 in pairs(v.ExtraContent) do
			content[k] = v2
		end
	end

	return {
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		DisplayOrder = v.DisplayOrder or 10,
		Name = "LoadingScreen",
		Location = "Center",
		AspectRatio = 1.777,
		Scale = v.Scale or 1,
		Background = props.Background,
		Background2 = props.Background2,
		Content = content
	}
end

return {
	LoadingScreen = model4
}