local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local VideUtil = require(script.Parent.Parent.Basics.VideUtil)
local create = Vide.create
local defaulted = VideUtil.defaulted
local rbxassetfontsfamiliesFredokaOnejson = Font.new(
	"rbxasset://fonts/families/FredokaOne.json",
	Enum.FontWeight.Regular
)
local rbxassetfontsfamiliesGothamSSmjson = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy)
local colorSequence = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(148, 160, 196))
local colorSequence2 = ColorSequence.new(Color3.fromRGB(226, 233, 248), Color3.fromRGB(255, 255, 255))
local colorSequence3 = ColorSequence.new(Color3.fromRGB(236, 102, 102), Color3.fromRGB(255, 255, 255))
local colorSequence4 = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(248, 172, 255)),
	ColorSequenceKeypoint.new(0.2, Color3.fromRGB(249, 178, 255)),
	ColorSequenceKeypoint.new(0.48, Color3.fromRGB(254, 239, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
})
local color = Color3.fromRGB(255, 255, 255)

local function hasText(p)
	return function()
		return (p == nil and "" or VideUtil.read(p)) ~= ""
	end
end

local function banner(instance)
	local v = create("Frame")
	local v2 = {
		Name = "PanelFrame",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0),
		Size = UDim2.fromScale(1, 0.5),
		BackgroundTransparency = 1
	}
	local bannerText = instance.BannerText

	function v2.Visible()
		return (bannerText == nil and "" or VideUtil.read(bannerText)) ~= ""
	end

	v2.ZIndex = 3
	do local _values = table.pack(create("Frame")({
	Name = "Banner",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(0.8, 0.2),
	Rotation = defaulted(instance.BannerRotation, -2),
	BackgroundColor3 = defaulted(instance.BannerColor, Color3.fromRGB(235, 190, 90)),
	create("UICorner")({
		CornerRadius = UDim.new(0.25, 0)
	}),
	create("UIStroke")({
		Color = defaulted(instance.BannerStrokeColor, Color3.fromRGB(255, 244, 200)),
		Thickness = 0.07,
		StrokeSizingMode = 1
	}),
	create("TextLabel")({
		Name = "BannerText",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.97, 1),
		BackgroundTransparency = 1,
		FontFace = rbxassetfontsfamiliesFredokaOnejson,
		Text = defaulted(instance.BannerText, ""),
		TextColor3 = defaulted(instance.BannerTextColor, Color3.fromRGB(96, 62, 0)),
		TextScaled = true,
		create("UIStroke")({
			Color = defaulted(instance.BannerStrokeColor, Color3.fromRGB(255, 244, 200)),
			Thickness = 0.08,
			StrokeSizingMode = 1
		})
	})
})); for _k = 1, _values.n do v2[_k] = _values[_k] end end
	return v(v2)
end

local function closeButton(instance)
	local backgroundColor = defaulted(instance.CloseColor, Color3.fromRGB(212, 0, 148))
	return create("ImageButton")({
		Name = "CloseButton",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.fromScale(0.12, 0.12),
		BackgroundColor3 = backgroundColor,
		Image = "",
		Visible = defaulted(instance.ShowClose, true),
		ZIndex = 4,
		MouseButton1Click = instance.OnClose,
		create("UIAspectRatioConstraint")({
			AspectRatio = 1
		}),
		create("UICorner")({
			CornerRadius = UDim.new(0.2, 0)
		}),
		create("UIGradient")({
			Color = defaulted(instance.CloseGradient, colorSequence3),
			Rotation = 90
		}),
		create("UIStroke")({
			Name = "OuterStroke",
			Color = defaulted(instance.CloseOuterStrokeColor, Color3.fromRGB(113, 4, 62)),
			Thickness = 0.06,
			StrokeSizingMode = 1,
			create("UIGradient")({
				Color = ColorSequence.new(Color3.fromRGB(132, 0, 144), Color3.fromRGB(255, 255, 255)),
				Rotation = 90
			})
		}),
		create("UIStroke")({
			Name = "InnerStroke",
			Color = defaulted(instance.CloseInnerStrokeColor, Color3.fromRGB(255, 111, 248)),
			Thickness = 0.06,
			StrokeSizingMode = 1,
			create("UIGradient")({
				Color = defaulted(instance.CloseGradient, colorSequence3),
				Rotation = -90
			})
		}),
		create("ImageLabel")({
			Name = "Icon",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.7, 0.7),
			BackgroundTransparency = 1,
			Image = "rbxassetid://8511577140",
			ZIndex = 5,
			create("UIGradient")({
				Color = defaulted(instance.CloseIconGradient, colorSequence4),
				Rotation = 90
			})
		})
	})
end

local function statusStrip(instance)
	local v = create("Frame")
	local v2 = {
		Name = "StatusFrame",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 0.25),
		Size = UDim2.fromScale(0.8, 0.115),
		BackgroundColor3 = defaulted(instance.StatusColor, Color3.fromRGB(70, 90, 120)),
		BackgroundTransparency = 0.5
	}
	local statusText = instance.StatusText

	function v2.Visible()
		return (statusText == nil and "" or VideUtil.read(statusText)) ~= ""
	end

	v2.ZIndex = 2
	do local _values = table.pack(create("UICorner")({
	CornerRadius = UDim.new(0.3, 0)
}), create("UIGradient")({
	Color = defaulted(instance.StatusGradient, ColorSequence.new(color, Color3.fromRGB(120, 150, 200))),
	Rotation = 90
}), create("TextLabel")({
	Name = "StatusText",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(0.95, 0.68),
	BackgroundTransparency = 1,
	FontFace = rbxassetfontsfamiliesGothamSSmjson,
	Text = defaulted(instance.StatusText, ""),
	TextColor3 = defaulted(instance.StatusTextColor, color),
	TextScaled = true,
	create("UIStroke")({
		Color = defaulted(instance.StatusStrokeColor, Color3.fromRGB(22, 34, 52)),
		Thickness = 0.08,
		StrokeSizingMode = 1
	})
})); for _k = 1, _values.n do v2[_k] = _values[_k] end end
	return v(v2)
end

local function PanelModal(instance, p)
	local headerHeight = instance.HeaderHeight or 0
	return create("ImageLabel")({
		Name = instance.Name or "PanelModal",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = defaulted(instance.Position, UDim2.fromScale(0.5, 0.55)),
		Size = defaulted(instance.Size, UDim2.fromScale(0.9, 0.7)),
		BackgroundColor3 = defaulted(instance.BackgroundColor, Color3.fromRGB(46, 52, 68)),
		Image = defaulted(instance.BackgroundImage, "rbxassetid://106467099323886"),
		ImageTransparency = defaulted(instance.BackgroundImageTransparency, 0.54),
		ScaleType = Enum.ScaleType.Tile,
		TileSize = defaulted(instance.TileSize, UDim2.fromScale(0.025, 0.035)),
		Visible = defaulted(instance.Visible, true),
		ZIndex = instance.ZIndex or 1,
		Parent = instance.Parent,
		create("UIAspectRatioConstraint")({
			AspectRatio = defaulted(instance.AspectRatio, 1.4)
		}),
		create("UICorner")({
			CornerRadius = defaulted(instance.CornerRadius, UDim.new(0.05, 0))
		}),
		create("UIGradient")({
			Color = defaulted(instance.GradientColor, colorSequence),
			Rotation = defaulted(instance.GradientRotation, -31)
		}),
		create("UIStroke")({
			Name = "OuterStroke",
			Color = defaulted(instance.OuterStrokeColor, Color3.fromRGB(24, 28, 40)),
			Thickness = defaulted(instance.StrokeThickness, 0.007),
			StrokeSizingMode = 1
		}),
		create("UIStroke")({
			Name = "InnerStroke",
			Color = defaulted(instance.InnerStrokeColor, Color3.fromRGB(196, 208, 235)),
			Thickness = defaulted(instance.StrokeThickness, 0.007),
			StrokeSizingMode = 1
		}),
		banner(instance),
		closeButton(instance),
		statusStrip(instance),
		create("Frame")({
			Name = "ItemsFrame",
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 0.97),
			Size = UDim2.fromScale(0.85, 0.72),
			BackgroundColor3 = defaulted(instance.PanelColor, Color3.fromRGB(38, 44, 58)),
			BackgroundTransparency = defaulted(instance.PanelTransparency, 0.3),
			create("UICorner")({
				CornerRadius = UDim.new(0.06, 0)
			}),
			create("UIGradient")({
				Color = defaulted(instance.PanelGradient, colorSequence2),
				Rotation = 129
			}),
			create("UIStroke")({
				Color = defaulted(instance.PanelStrokeColor, Color3.fromRGB(196, 208, 235)),
				Thickness = 0.007,
				StrokeSizingMode = 1
			}),
			create("Frame")({
				Name = "PanelHeader",
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.fromScale(0.5, 0.04),
				Size = UDim2.fromScale(0.975, headerHeight),
				BackgroundTransparency = 1,
				Visible = headerHeight > 0,
				instance.Header
			}),
			create("ScrollingFrame")({
				Name = "ItemsList",
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.fromScale(0.5, 0.04 + headerHeight),
				Size = UDim2.fromScale(0.975, 0.935 - headerHeight),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ClipsDescendants = true,
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				CanvasSize = UDim2.new(),
				ScrollingDirection = Enum.ScrollingDirection.Y,
				ScrollBarThickness = 12,
				create("UIPadding")({
					PaddingLeft = UDim.new(0.01, 0),
					PaddingRight = UDim.new(0.01, 0)
				}),
				create("UIListLayout")({
					Padding = defaulted(instance.ListPadding, UDim.new(0, 0)),
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder
				}),
				p
			})
		})
	})
end

return PanelModal