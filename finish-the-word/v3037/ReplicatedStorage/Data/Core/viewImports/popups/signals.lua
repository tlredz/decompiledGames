local import = _G.import("romodel")
_G.import("animUtil")
_G.import("clientUtil")
local basic = _G.import("viewImports"):get("basic")
local TweenService = game:GetService("TweenService")
local model = import.model("CanvasGroup")

function model.init(p)
	local text = p.Text or "Missing Message"
	return {
		GroupTransparency = 1,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.new(0, 0, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0.075, 0),
		Size = UDim2.new(0.8, 0, 0.2, 0)
	}, {
		Text = import.make(basic.TextLabel, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0.95, 0, 1, 0),
			Text = string.upper(text) .. "!",
			StrokeWidth = 2,
			ZIndex = 2
		})
	}
end

function model.prespawn(instance)
	TweenService:Create(instance.Instance, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
		GroupTransparency = 0
	}):Play()
	TweenService:Create(instance.Instance, TweenInfo.new(1, Enum.EasingStyle.Elastic), {
		Size = UDim2.new(1, 0, 0.2, 0)
	}):Play()
	task.delay(3, function()
		TweenService:Create(instance.Instance, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
			GroupTransparency = 1
		}):Play()
		task.wait(0.3)
		instance:Destroy()
	end)
end

local model2 = import.model("ScreenGui")

function model2.init(_)
	return {
		DisplayOrder = 40,
		Name = "Signals",
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	}, {
		Container = import.make(basic.EmptyList, {
			Location = "TopCenter",
			Padding = UDim.new(0.03, 0),
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			Size = UDim2.new(0.35, 0, 0.2, 0)
		})
	}
end

function model2.signal(p, text)
	import.apply(p.Container, nil, { import.make(model, {
			LayoutOrder = #p.Container:GetChildren(),
			Text = text
		}) })
end

function model2.prespawn(_) end

return {
	Hud = model2
}