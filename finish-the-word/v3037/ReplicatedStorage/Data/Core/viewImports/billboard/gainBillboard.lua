local createVector = vector.create
local import = _G.import("romodel")
local import2 = _G.import("mathUtil")
local import3 = _G.import("clientUtil")
local import4 = _G.import("iconData")
local basic = _G.import("viewImports"):get("basic")
local TweenService = game:GetService("TweenService")
local model = import.model("ScreenGui")

function model.init(_)
	return {
		Name = "CurrencyGainPopup",
		ResetOnSpawn = false
	}, {
		List = import.make(basic.List, {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0.7, 0, 0.35, 0),
			Size = UDim2.new(0.5, 0, 0.05, 0),
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 8)
		}, {
			Icon = import.make(basic.ImageLabel, {
				BackgroundTransparency = 1,
				LayoutOrder = 1,
				Size = UDim2.new(1, 0, 1, 0),
				Image = import4.Cash
			}),
			GainLabel = import.make(basic.TextLabel, {
				LayoutOrder = 2,
				Size = UDim2.new(1, 0, 1, 0),
				Text = "+0 Cash",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextXAlignment = Enum.TextXAlignment.Left,
				StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
				StrokeWidth = 0.05
			})
		})
	}
end

function model.spawn(data)
	local target = data.Target or 0
	local instance = data.List.Instance
	local instance2 = data.List.GainLabel.Instance
	TweenService:Create(instance, TweenInfo.new(1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.7, 0, 0.25, 0)
	}):Play()
	task.spawn(function()
		import3.sound("Coins21")

		for i = 0, 1, 0.06666666666666667 do
			if not data.Instance then
				return
			end

			instance2.Text = "+" .. import2.formatNumber((math.floor(target * i))) .. " Cash"
			import3.sound("Pop3")
			task.wait(0.1)
		end

		if data.Instance then
			instance2.Text = "+" .. import2.formatNumber(target) .. " Cash"
		end
	end)
	task.delay(2.5, function()
		if not data.Instance then
			return
		end

		data.Instance:Destroy()
	end)
end

local model2 = import.model("BillboardGui")

function model2.init(data)
	local old = data.Old
	local gain = data.Gain
	local xpToRatio = import2.xpToRatio(old, data.MaxXp, data.LevelGrowth)
	local v = import2.xpToRatio(old + gain, data.MaxXp, data.LevelGrowth) < xpToRatio and 0 or xpToRatio
	return {
		Name = "XpGainBillboard",
		AlwaysOnTop = true,
		Size = UDim2.new(4.5, 0, 2.25, 0),
		StudsOffset = data.StudsOffset or createVector(0, 4.5, 0)
	}, {
		GainLabel = import.make(basic.TextLabel, {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(1, 0, 1, 0),
			Size = UDim2.new(1, 0, 0.35, 0),
			Text = "+" .. data.Gain .. " XP",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			StrokeWidth = 0.05,
			ZIndex = 2
		}),
		Track = import.make(import.wrap(basic.Stroke, basic.Corner), {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, 0),
			Size = UDim2.new(0.9, 0, 0.3, 0),
			BackgroundColor3 = Color3.fromRGB(25, 25, 25),
			CornerRadius = UDim.new(1, 0),
			StrokeWidth = 2
		}, {
			XPText = import.make(basic.TextLabel, {
				ZIndex = 2,
				Size = UDim2.new(1, 0, 1, 0),
				StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
				StrokeWidth = 0.075,
				Text = "10/1000"
			}),
			Fill = import.make(import.wrap(basic.Corner, basic.Gradient), {
				Size = UDim2.new(v, 0, 1, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				CornerRadius = UDim.new(1, 0),
				GradientColor = ColorSequence.new(Color3.fromRGB(238, 223, 107), Color3.fromRGB(255, 85, 0)),
				GradientRotation = 90
			})
		})
	}
end

function model2.spawn(data)
	local v = math.clamp(data.Old + data.Gain, 0, data.MaxXp)
	local xpToRatio, v2, v3 = import2.xpToRatio(v, data.MaxXp, data.LevelGrowth)
	TweenService:Create(
		data.Track.Fill.Instance,
		TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		{
			Size = UDim2.new(xpToRatio, 0, 1, 0)
		}
	):Play()
	task.spawn(function()
		local v4 = v - v2

		for i = 0, 1, 0.05 do
			data.Track.XPText.Text = string.format("%s/%s", math.floor(v4 * i), v3 - v2)
			task.wait(0.075)
		end
	end)
	task.delay(0, function()
		if not data.Instance then
			return
		end

		TweenService:Create(
			data.GainLabel.Instance,
			TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{
				Position = UDim2.new(1, 0, 0.6, 0)
			}
		):Play()
	end)
	task.delay(2, function()
		if not data.Instance then
			return
		end

		data.Instance:Destroy()
	end)
end

return {
	Xp = model2,
	Currency = model
}