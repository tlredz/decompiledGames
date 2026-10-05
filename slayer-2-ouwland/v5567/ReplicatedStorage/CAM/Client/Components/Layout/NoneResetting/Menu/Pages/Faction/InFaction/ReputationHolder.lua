local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
require(ReplicatedStorage.CAM.Client.Modules.FactionState)
require(ReplicatedStorage.Packages.faye)
local color = Color3.fromRGB(110, 245, 140)
local color2 = Color3.fromRGB(255, 95, 110)
local color3 = Color3.fromRGB(190, 190, 195)
return function(object, p)
	local total = 0

	for _, member in p.Members do
		total += member.Reputation
	end

	local backgroundColor

	if total > 0 then
		backgroundColor = color
	elseif total < 0 then
		backgroundColor = color2
	else
		backgroundColor = color3
	end

	local v2

	if total > 0 then
		v2 = `+{total}`
	else
		v2 = tostring(total)
	end

	return object:Create("Frame")({
		Name = "ReputationHolder",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		object:Create("Frame")({
			Name = "ActualHolder",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 4, 0.5, 0),
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ZIndex = 2,
			object:Create("UIListLayout")({
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 6)
			}),
			object:Create("Frame")({
				Name = "Icon",
				LayoutOrder = 1,
				Size = UDim2.fromScale(0.5, 1),
				Instance.new("UIAspectRatioConstraint"),
				BackgroundTransparency = 1,
				object:Create("ImageLabel")({
					Name = "Image",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					Image = BunchaIcons.Reputation
				})
			}),
			object:Create("TextLabel")({
				Name = "Title",
				LayoutOrder = 2,
				Size = UDim2.fromScale(0.5, 0.8),
				BackgroundTransparency = 1,
				Text = `Faction Reputation <b><font color="#{backgroundColor:ToHex()}">{v2}</font></b>`,
				RichText = true,
				TextColor3 = Color3.new(1, 1, 1),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextScaled = true,
				Font = Enum.Font.SourceSans
			})
		}),
		object:Create("Frame")({
			Name = "Bg",
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = backgroundColor,
			BackgroundTransparency = 0.5,
			object:Create("UIGradient")({
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.35),
					NumberSequenceKeypoint.new(0.7, 1),
					NumberSequenceKeypoint.new(1, 1)
				})
			}),
			object:Create("UICorner")({
				CornerRadius = UDim.new(1)
			})
		})
	})
end