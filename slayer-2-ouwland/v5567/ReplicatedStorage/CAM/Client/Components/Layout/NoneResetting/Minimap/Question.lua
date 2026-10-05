local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local GradientButton = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.GradientButton)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local numberSequence = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.7),
	NumberSequenceKeypoint.new(0.5, 0.9),
	NumberSequenceKeypoint.new(1, 1)
})
local uDim = UDim.new(0.1)
local color = Color3.new()
local uDim2 = UDim.new(1, 0)
local sourceSansSemibold = Enum.Font.SourceSansSemibold
local color2 = Color3.new(0.15, 1, 0.15)
local color3 = Color3.new(1, 0.15, 0.15)
local numberSequence2 = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 1) })
local v = {
	Yes = BunchaIcons.Checkmark2,
	No = BunchaIcons.DeniedMark2
}
local v2 = {
	{
		Text = "Yes",
		Color = color2
	},
	{
		Text = "No",
		Color = color3
	}
}
local info = faye.Info(0.15)
return function(object, p)
	local flag = false
	return object:Create("CanvasGroup")({
		Name = "Question",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		GroupTransparency = object:Animation(0, info, {
			From = 1
		}),
		object:Create("Frame")({
			Name = "Card",
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 0.96),
			Size = UDim2.fromScale(1, 0.32),
			BackgroundTransparency = 1,
			object:Create("UIAspectRatioConstraint")({
				AspectRatio = 2.2
			}),
			object:Create("Frame")({
				Name = "Bg",
				ZIndex = 0,
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = Color3.new(),
				object:Create("UIGradient")({
					Rotation = -90,
					Transparency = numberSequence
				}),
				object:Create("UICorner")({
					CornerRadius = uDim
				}),
				object:Create("UIShadow")({
					Color = color,
					Transparency = 0.5,
					BlurRadius = uDim2
				})
			}),
			object:Create("Frame")({
				Name = "Rows",
				ZIndex = 1,
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				object:Create("UIListLayout")({
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					FillDirection = Enum.FillDirection.Vertical,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 5)
				}),
				object:Create("TextLabel")({
					Name = "TextContent",
					LayoutOrder = 1,
					Size = UDim2.fromScale(0.9, 0.6),
					BackgroundTransparency = 1,
					Text = p.Text,
					RichText = true,
					Font = sourceSansSemibold,
					TextColor3 = Color3.new(1, 1, 1),
					TextWrapped = true,
					TextScaled = true,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextYAlignment = Enum.TextYAlignment.Bottom,
					object:Create("UITextSizeConstraint")({
						MaxTextSize = 30
					})
				}),
				object:Create("Frame")({
					Name = "ZButtonsHolder",
					LayoutOrder = 2,
					Size = UDim2.fromScale(0.22, 0.2),
					BackgroundTransparency = 1,
					object:Create("UIListLayout")({
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						FillDirection = Enum.FillDirection.Horizontal,
						Padding = UDim.new(0.15, 0)
					}),
					object:Iterate(v2, function(_, p2, object2)
						return object2:Create("Frame")({
							Name = p2.Text,
							Size = UDim2.fromScale(1, 1),
							BackgroundTransparency = 1,
							GradientButton(object2, {
								GradientRotation = -90,
								BgColor = p2.Color,
								Text = p2.Text,
								Image = v[p2.Text],
								StrokeClick = true,
								Properties = {
									AnchorPoint = Vector2.new(0.5, 0.5),
									Position = UDim2.fromScale(0.5, 0.5)
								},
								GradientTransparency = numberSequence2,
								Clicked = function()
									if flag then
										return
									end

									flag = true
									p.Answer(p2.Text)
								end
							})
						})
					end)
				})
			})
		})
	})
end