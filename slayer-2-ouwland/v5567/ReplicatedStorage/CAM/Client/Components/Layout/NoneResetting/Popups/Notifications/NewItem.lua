local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local Rarities = require(ReplicatedStorage.CAM.Global.Rarities)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local faye = require(ReplicatedStorage.Packages.faye)
local info = faye.Info(0.3)
local springInfo = faye.SpringInfo(0.5, 1, 0.35)
local color = Color3.new(0.45, 0.45, 0.45)
local color2 = Color3.new(0.6, 0.6, 0.6)
local color3 = Color3.new(0.28, 0.28, 0.28)
return function(object, data)
	local v = Items[data.Name] or {
		Icon = data.Icon,
		Rarity = data.Rarity
	}
	local v2

	if data.AlreadyOwned then
		v2 = nil
	else
		v2 = Rarities.Gradients[v.Rarity]
	end

	local color4

	if data.AlreadyOwned then
		color4 = color
	elseif v2 == nil then
		color4 = Rarities.Colors[v.Rarity] or Rarities.Colors[1]
	else
		color4 = Color3.new(1, 1, 1)
	end

	return object:SpecialThread(function(object2)
		local v3 = object2:Create("Frame")
		local v4 = {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Name = data.Name,
			CleanDelay = info.Time
		}
		local v5 = object2:Create("UIAspectRatioConstraint")({
			AspectRatio = 4.5
		})
		local v6 = object2:Create("Frame")
		local v7 = {
			Name = "InnerHolder",
			Position = object2:Animation(UDim2.fromScale(), springInfo, {
				From = UDim2.fromScale(-0.1)
			}),
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.new(0.15, 0.15, 0.15),
			Transparency = 0.25,
			BackgroundTransparency = object2:Animation(0, info, {
				From = 1
			}),
			OnClean = function()
				return {
					BackgroundTransparency = object2:Animation(1, info)
				}
			end
		}
		local v8 = object2:Create("UIGradient")({
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.6, 0.85),
				NumberSequenceKeypoint.new(0.9, 1),
				NumberSequenceKeypoint.new(1, 1)
			})
		})
		local v9 = object2:Create("UICorner")({
			CornerRadius = UDim.new(1)
		})
		local v10 = object2:Create("UIStroke")({
			Thickness = 1.5,
			Color = Color3.new(1, 1, 1),
			BorderOffset = UDim.new(0, -3),
			object2:Create("UIGradient")({
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.45),
					NumberSequenceKeypoint.new(1, 1)
				}),
				Color = v2 or ColorSequence.new(color4)
			}),
			Transparency = object2:Animation(0, info, {
				From = 1
			}),
			OnClean = function()
				return {
					Transparency = object2:Animation(1, info)
				}
			end
		})
		local v11 = object2:Create("Frame")({
			Name = "Bg",
			Size = UDim2.new(1, -10, 1, -10),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			object2:Create("UICorner")({
				CornerRadius = UDim.new(1)
			}),
			BackgroundColor3 = color4,
			object2:Create("UIGradient")({
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.5),
					NumberSequenceKeypoint.new(0.4, 1),
					NumberSequenceKeypoint.new(1, 1)
				}),
				Color = v2 or ColorSequence.new(color4)
			}),
			BackgroundTransparency = object2:Animation(0, info, {
				From = 1
			}),
			OnClean = function()
				return {
					BackgroundTransparency = object2:Animation(1, info)
				}
			end
		})
		local v12 = object2:Create("ImageLabel")
		local v13 = {
			Name = "Image",
			Size = UDim2.fromScale(1.4, 1.4),
			Instance.new("UIAspectRatioConstraint"),
			Image = data.Icon or v.Icon
		}
		local imageColor

		if data.AlreadyOwned then
			imageColor = color2
		else
			imageColor = Color3.new(1, 1, 1)
		end

		v13.ImageColor3 = imageColor
		v13.BackgroundTransparency = 1
		v13.AnchorPoint = Vector2.new(0.5, 0.5)
		v13.Position = UDim2.fromScale(0.05, 0.5)
		v13.ImageTransparency = object2:Animation(0, info, {
			From = 1
		})

		function v13.OnClean()
			return {
				ImageTransparency = object2:Animation(1, info)
			}
		end

		local v15

		if data.NoSave then
			v15 = object2:Create("ImageLabel")({
				Name = "NoSave",
				ZIndex = 2,
				Size = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = BunchaIcons.NoSave,
				ImageTransparency = object2:Animation(gameSettings.noSaveOverlayTransparency, info, {
					From = 1
				}),
				object2:Create("UIShadow")({
					Color = gameSettings.noSaveOverlayShadowColor,
					Transparency = gameSettings.noSaveOverlayShadowTransparency,
					BlurRadius = gameSettings.noSaveOverlayShadowBlur
				}),
				OnClean = function()
					return {
						ImageTransparency = object2:Animation(1, info)
					}
				end
			})
		end

		v13[2] = v15
		local v16 = v12(v13)
		local v17 = object2:Create("TextLabel")({
			Name = "Lbel",
			Size = UDim2.fromScale(5, 0.65),
			Position = UDim2.fromScale(0.15, 0.5),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Text = data.Name,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			Font = Enum.Font.SourceSansSemibold,
			TextColor3 = Color3.new(1, 1, 1),
			object2:Create("UIStroke")({
				Thickness = 2,
				Transparency = object2:Animation(0.82, info, {
					From = 1
				}),
				OnClean = function()
					return {
						Transparency = object2:Animation(1, info)
					}
				end
			}),
			TextTransparency = object2:Animation(0, info, {
				From = 1
			}),
			OnClean = function()
				return {
					TextTransparency = object2:Animation(1, info)
				}
			end
		})
		local v18

		if data.IsNew or data.AlreadyOwned then
			local v19 = object2:Create("CanvasGroup")
			local size

			if data.AlreadyOwned then
				size = UDim2.fromScale(0, 0.40249999999999997)
			else
				size = UDim2.fromScale(0.3, 0.35)
			end

			local v20 = {
				Name = "Amount",
				Size = size,
				Position = UDim2.fromScale(0.5, 1),
				AnchorPoint = Vector2.new(0.5, 0.5),
				GroupTransparency = object2:Animation(0, info, {
					From = 1
				}),
				OnClean = function()
					return {
						GroupTransparency = object2:Animation(1, info)
					}
				end
			}
			local backgroundColor

			if data.AlreadyOwned then
				backgroundColor = color3
			else
				backgroundColor = Color3.new(0.972549, 0.831373, 0.192157)
			end

			v20.BackgroundColor3 = backgroundColor
			v20.BackgroundTransparency = data.AlreadyOwned and 0.25 or 0
			local v23 = object2:Create("UICorner")({
				CornerRadius = UDim.new(1)
			})
			local v24 = object2:Create("TextLabel")
			local size2

			if data.AlreadyOwned then
				size2 = UDim2.fromScale(100, 1)
			else
				size2 = UDim2.fromScale(1, 1.2)
			end

			local v25 = {
				TextScaled = true,
				Size = size2,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundTransparency = 1,
				Text = data.AlreadyOwned and "Can only have one" or "NEW!",
				TextColor3 = 0,
				Font = 0,
				TextBoundsOnChangedInit = 0
			}
			local textColor

			if data.AlreadyOwned then
				textColor = Color3.new(1, 1, 1)
			else
				textColor = Color3.new()
			end

			v25.TextColor3 = textColor
			v25.Font = Enum.Font.SourceSansBold
			v25.TextBoundsOnChangedInit = data.AlreadyOwned and function(p)
				local parent = p.Parent

				if parent == nil or p.TextBounds.X <= 0 then
					return
				end

				parent.Size = UDim2.new(0, p.TextBounds.X + 16, 0.40249999999999997, 0)
			end or nil
			do local _values = table.pack(v23, v24(v25)); for _k = 1, _values.n do v20[_k] = _values[_k] end end
			v18 = v19(v20)
		end

		local v19

		if not (data.Amount == nil or not (data.Amount > (data.IsNew and 1 or 0))) then
			local v20 = object2:Create("TextLabel")
			local v21 = {
				TextScaled = true,
				TextColor3 = Color3.new(1, 1, 1),
				Size = UDim2.fromScale(0.3, 0.5),
				Position = 0,
				AnchorPoint = 0,
				Text = 0,
				BackgroundTransparency = 1,
				TextTransparency = 0,
				TextStrokeTransparency = 0,
				OnClean = 0,
				Font = 0
			}
			local position

			if data.IsNew then
				position = UDim2.fromScale(0.8, 1)
			else
				position = UDim2.fromScale(0.5, 0.925)
			end

			v21.Position = position
			v21.AnchorPoint = Vector2.new(0.5, 0.5)
			v21.Text = `x{data.Amount or 1}`
			v21.TextTransparency = object2:Animation(0, info, {
				From = 1
			})
			v21.TextStrokeTransparency = object2:Animation(0.75, info, {
				From = 1
			})

			function v21.OnClean()
				return {
					TextStrokeTransparency = object2:Animation(1, info),
					TextTransparency = object2:Animation(1, info)
				}
			end

			v21.Font = Enum.Font.SourceSansBold
			v19 = v20(v21)
		end

		v7[1], v7[2], v7[3], v7[4], v7[5], v7[6], v7[7], v7[8] = v8, v9, v10, v11, v16, v17, v18, v19
		do local _values = table.pack(v5, v6(v7)); for _k = 1, _values.n do v4[_k] = _values[_k] end end
		return v3(v4)
	end, {
		Lifetime = data.Time or 5
	})
end