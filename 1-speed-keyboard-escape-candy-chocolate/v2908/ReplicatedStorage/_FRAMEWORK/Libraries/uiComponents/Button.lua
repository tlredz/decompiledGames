local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local VideUtil = require(script.Parent.Parent.Basics.VideUtil)
local create = Vide.create
local defaulted = VideUtil.defaulted
local colorSequence = ColorSequence.new(Color3.fromRGB(255, 200, 60), Color3.fromRGB(211, 124, 0))
local rbxassetfontsfamiliesGothamSSmjson = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy)

local function Button(data)
	local uDim = UDim.new(data.PaddingX or 0.08, 0)
	local uDim2 = UDim.new(data.PaddingY or 0.18, 0)
	return create("TextButton")({
		Name = data.Name or "Button",
		Size = defaulted(data.Size, UDim2.fromScale(1, 1)),
		Position = data.Position,
		AnchorPoint = data.AnchorPoint,
		LayoutOrder = data.LayoutOrder or 0,
		ZIndex = data.ZIndex or 1,
		Visible = defaulted(data.Visible, true),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Text = "",
		MouseButton1Click = data.OnActivated,
		MouseEnter = data.OnMouseEnter,
		MouseLeave = data.OnMouseLeave,
		create("UIGradient")({
			Color = defaulted(data.Gradient, colorSequence),
			Rotation = defaulted(data.GradientRotation, 90)
		}),
		create("UIStroke")({
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = defaulted(data.StrokeColor, Color3.fromRGB(120, 70, 0)),
			Thickness = defaulted(data.StrokeThickness, 0.04),
			StrokeSizingMode = 1
		}),
		create("UICorner")({
			CornerRadius = defaulted(data.CornerRadius, UDim.new(0.25, 0))
		}),
		create("UIPadding")({
			PaddingTop = uDim2,
			PaddingBottom = uDim2,
			PaddingLeft = uDim,
			PaddingRight = uDim
		}),
		create("TextLabel")({
			Name = "ButtonText",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			FontFace = rbxassetfontsfamiliesGothamSSmjson,
			Text = defaulted(data.Text, ""),
			TextColor3 = defaulted(data.TextColor, Color3.fromRGB(255, 255, 255)),
			TextScaled = true,
			ZIndex = 2,
			create("UIStroke")({
				Color = defaulted(data.TextStrokeColor, Color3.fromRGB(20, 20, 20)),
				Thickness = 0.03,
				StrokeSizingMode = 1
			})
		})
	})
end

return Button