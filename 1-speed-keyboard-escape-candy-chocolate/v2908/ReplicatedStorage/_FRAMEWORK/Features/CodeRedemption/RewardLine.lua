local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local RowTheme = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.RowTheme)
local VideUtil = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.VideUtil)
local create = Vide.create
local defaulted = VideUtil.defaulted
local rbxassetfontsfamiliesGothamSSmjson = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy)
local rbxassetfontsfamiliesGothamSSmjson2 = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)

local function RewardLine(data)
	local styleFor = RowTheme.styleFor(VideUtil.read(defaulted(data.Variant, "Panel")))
	return create("Frame")({
		Name = data.Name or "RewardLine",
		LayoutOrder = data.LayoutOrder or 0,
		Size = defaulted(data.Size, UDim2.fromScale(1, 0.16)),
		BackgroundColor3 = defaulted(data.CardColor, styleFor.CardColor),
		create("UICorner")({
			CornerRadius = styleFor.CardCorner
		}),
		create("UIGradient")({
			Color = defaulted(data.CardGradient, styleFor.CardGradient),
			Rotation = 90
		}),
		create("UIStroke")({
			Color = defaulted(data.StrokeColor, styleFor.PlateStrokeColor),
			Thickness = 0.02,
			StrokeSizingMode = 1
		}),
		create("UIPadding")({
			PaddingLeft = UDim.new(0.02, 0),
			PaddingRight = UDim.new(0.02, 0),
			PaddingTop = UDim.new(0.08, 0),
			PaddingBottom = UDim.new(0.08, 0)
		}),
		create("ImageLabel")({
			Name = "Icon",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromScale(0.14, 1),
			BackgroundTransparency = 1,
			Image = defaulted(data.Icon, "rbxassetid://83707728604228"),
			ScaleType = Enum.ScaleType.Fit,
			create("UIAspectRatioConstraint")({
				AspectRatio = 1
			})
		}),
		create("TextLabel")({
			Name = "Title",
			AnchorPoint = Vector2.new(0, 0),
			Position = UDim2.fromScale(0.18, 0),
			Size = UDim2.fromScale(0.6, 0.55),
			BackgroundTransparency = 1,
			FontFace = rbxassetfontsfamiliesGothamSSmjson,
			Text = data.Title,
			TextColor3 = defaulted(data.TitleColor, styleFor.TitleColor),
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			create("UIStroke")({
				Color = defaulted(data.TitleStrokeColor, styleFor.TitleStrokeColor),
				Thickness = 0.1,
				StrokeSizingMode = 1
			})
		}),
		create("TextLabel")({
			Name = "Detail",
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0.18, 1),
			Size = UDim2.fromScale(0.6, 0.4),
			BackgroundTransparency = 1,
			FontFace = rbxassetfontsfamiliesGothamSSmjson2,
			Text = defaulted(data.Detail, ""),
			TextColor3 = defaulted(data.DetailColor, styleFor.SubTextColor),
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left
		}),
		create("TextLabel")({
			Name = "Amount",
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.fromScale(1, 0.5),
			Size = UDim2.fromScale(0.18, 0.55),
			BackgroundTransparency = 1,
			FontFace = rbxassetfontsfamiliesGothamSSmjson,
			Text = defaulted(data.Amount, ""),
			TextColor3 = defaulted(data.AmountColor, styleFor.AmountColor),
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Right,
			create("UIStroke")({
				Color = defaulted(data.AmountStrokeColor, styleFor.AmountStrokeColor),
				Thickness = 0.1,
				StrokeSizingMode = 1
			})
		})
	})
end

return RewardLine