local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
require(ReplicatedStorage.Packages.Vide.action)
local VideUtil = require(script.Parent.Parent.Basics.VideUtil)
local create = Vide.create
local defaulted = VideUtil.defaulted

local function TopBarButton(instance, p)
	local backgroundColor = defaulted(instance.BackgroundColor, Color3.fromRGB(62, 53, 170))
	local v2 = create("Frame")({
		Name = instance.Name or "TopBarButton",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = backgroundColor,
		LayoutOrder = instance.LayoutOrder or 0,
		Visible = defaulted(instance.Visible, true),
		Parent = instance.Parent,
		create("UICorner")({
			CornerRadius = UDim.new(0.3, 0)
		}),
		create("UIAspectRatioConstraint")({
			AspectRatio = 1
		}),
		create("UIStroke")({
			Color = Color3.fromRGB(0, 0, 0),
			Thickness = 0.07,
			StrokeSizingMode = 1
		}),
		create("TextButton")({
			Name = "TriggerButton",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = backgroundColor,
			Text = defaulted(instance.Emoji, ""),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextScaled = true,
			MouseButton1Click = instance.OnActivated,
			create("UICorner")({
				CornerRadius = UDim.new(0.3, 0)
			}),
			create("UIAspectRatioConstraint")({
				AspectRatio = 1
			}),
			create("UIStroke")({
				Color = Color3.fromRGB(0, 0, 0),
				Thickness = 0.1,
				StrokeSizingMode = 1
			}),
			create("UIPadding")({
				PaddingTop = UDim.new(0.075, 0),
				PaddingBottom = UDim.new(0.075, 0),
				PaddingLeft = UDim.new(0.075, 0),
				PaddingRight = UDim.new(0.075, 0)
			}),
			instance.Image and create("ImageLabel")({
				Name = "Image",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.85, 0.85),
				BackgroundTransparency = 1,
				Image = instance.Image,
				ImageColor3 = Color3.fromRGB(252, 255, 255)
			}) or nil
		}),
		p
	})
	return VideUtil.tagged(v2, "UI")
end

return TopBarButton