local import = _G.import("romodel")
local import2 = _G.import("viewImports")
local basic = import2:get("basic")
local ux = import2:get("ux")
local model = import.model(basic.ImageButton, ux.Button, basic.Corner, basic.Gradient)

function model.init(options)
	local v = options or {}
	local v2 = {
		AnchorPoint = v.AnchorPoint or Vector2.new(1, 1),
		Position = v.Position or UDim2.new(1, 0, 0, 0),
		Size = v.Size,
		Scale = 0,
		AspectRatio = 0,
		LayoutOrder = 0,
		BackgroundTransparency = 0,
		AutoButtonColor = false,
		BackgroundColor3 = 0,
		BorderSizePixel = 0,
		CornerRadius = 0,
		GradientRotation = 90,
		GradientColor = 0,
		ZIndex = 0,
		MouseButton1Down = 0
	}
	local scale = v.Scale

	if not scale then
		local _ = v.Size
		scale = 0.075
	end

	v2.Scale = scale
	v2.AspectRatio = v.AspectRatio or 1.75
	v2.LayoutOrder = v.LayoutOrder
	v2.BackgroundColor3 = Color3.fromRGB(215, 25, 25)
	v2.CornerRadius = v.CornerRadius or UDim.new(0.08, 0)
	v2.GradientColor = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 60, 60)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 8, 8))
	})
	v2.ZIndex = v.ZIndex

	function v2.MouseButton1Down(p)
		if v.OnClose then
			v.OnClose(p)
		end

		local screenGui = p.Instance:FindFirstAncestorOfClass("ScreenGui")

		if screenGui then
			screenGui:Destroy()
		end
	end

	return v2, {
		XLabel = import.make(basic.TextLabel, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = v.XSize or UDim2.new(0.72, 0, 0.72, 0),
			Text = "X",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			StrokeWidth = 2
		})
	}
end

return {
	CloseButton = model
}