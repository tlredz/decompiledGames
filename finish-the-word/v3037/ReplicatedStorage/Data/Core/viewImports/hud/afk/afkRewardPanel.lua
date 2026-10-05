local import = _G.import("romodel")
_G.import("iterUtil")
_G.import("itemModules")
local import2 = _G.import("viewImports")
local basic = import2:get("basic")
local react = import2:get("react")
local model = import.model(basic.ScrollingList, react.Reactive)

function model.init(data)
	return {
		Position = data.Position or UDim2.new(0.075, 0, 0.06, 0),
		Size = UDim2.new(0.91, 0, 0.92, 0),
		AnchorPoint = data.AnchorPoint or Vector2.new(0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Wraps = true,
		FillDirection = Enum.FillDirection.Horizontal,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		Padding = UDim.new(0.02, 0),
		ScrollBarThickness = 5,
		ZIndex = 5,
		KeyChains = data.KeyChains,
		SavedChanged = data.SavedChanged
	}
end

local model2 = import.model(basic.EmptyElement, basic.ConstrainedElement)

function model2.init(data)
	return {
		Size = UDim2.new(1, 0, 0.92, 0),
		AspectRatio = 0.7789855072463768
	}, {
		Background = import.make("ImageLabel", {
			BackgroundTransparency = 1,
			Location = "Center",
			Position = UDim2.new(-0.04, 0, -0.04, 0),
			Size = UDim2.new(1.09, 0, 1.09, 0),
			Image = "rbxassetid://105153741436112",
			ImageColor3 = Color3.new(0, 0, 0)
		}),
		Subtitle = import.make(basic.TextLabel, {
			Position = UDim2.new(0, 0, -0.02, 0),
			Size = UDim2.new(1, 0, 0.08, 0),
			Text = data.Title,
			TextXAlignment = Enum.TextXAlignment.Left,
			StrokeWidth = 2,
			ZIndex = 5
		}),
		RewardScrollingFrame = import.make(model, {
			KeyChains = data.KeyChains,
			SavedChanged = data.SavedChanged
		}, data.Children or {})
	}
end

return {
	RewardList = model2
}