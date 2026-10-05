local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
require(ReplicatedStorage.CAM.Global.Types.CraftingTypes)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local Rarities = require(ReplicatedStorage.CAM.Global.Rarities)
require(script.Parent.MaterialCard)
local info = faye.Info(0.2)
local color = Color3.fromRGB(255, 95, 95)
local color2 = Color3.new(1, 1, 1)
return function(object, p, callback)
	local item = Items[p.name]
	local backgroundColor = item ~= nil and Rarities.Colors[item.Rarity] or Color3.new(1, 1, 1)
	local text

	if #p.name > 10 then
		text = `{string.sub(p.name, 1, 8)}..`
	else
		text = p.name
	end

	return object:Create("Frame")({
		Name = p.name,
		Size = UDim2.fromScale(1, 1),
		object:Create("UIAspectRatioConstraint")({
			DominantAxis = Enum.DominantAxis.Height
		}),
		BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
		BackgroundTransparency = 0.5,
		object:Create("UICorner")({
			CornerRadius = UDim.new(0.15)
		}),
		object:Create("UIStroke")({
			Color = Color3.new(1, 1, 1),
			BorderOffset = UDim.new(0, -4),
			Transparency = 0.9
		}),
		object:Create("Frame")({
			Name = "Glow",
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 1),
			Size = UDim2.fromScale(1, 0.5),
			BackgroundColor3 = backgroundColor,
			ZIndex = 0,
			object:Create("UICorner")({
				CornerRadius = UDim.new(0.15)
			}),
			object:Create("UIGradient")({
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.7),
					NumberSequenceKeypoint.new(1, 1)
				}),
				Rotation = -90
			})
		}),
		object:Create("ImageLabel")({
			Name = "Icon",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0.06),
			Size = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = item == nil and "" or item.Icon or ""
		}),
		object:Create("TextLabel")({
			Name = "ItemName",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0.56),
			Size = UDim2.fromScale(0.9, 0.18),
			BackgroundTransparency = 1,
			Font = Enum.Font.SourceSansSemibold,
			Text = text,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true
		}),
		object:Create("TextLabel")({
			Name = "Count",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0.75),
			Size = UDim2.fromScale(0.9, 0.221),
			BackgroundTransparency = 1,
			Font = Enum.Font.SourceSansBold,
			Text = object:Do(function(p2)
				return (`{callback(p2, p.name)}/{p.amount}`)
			end),
			TextColor3 = object:Do(function(p2)
				local v4

				if callback(p2, p.name) >= p.amount then
					v4 = color2
				else
					v4 = color
				end

				return object:Animation(v4, info)
			end),
			TextScaled = true,
			TextStrokeTransparency = 0.8
		})
	})
end