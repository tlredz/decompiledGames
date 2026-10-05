local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local Shop = require(ReplicatedStorage.CAM.Global.Shop)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local GradientButton = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.GradientButton)
local info = faye.Info(0.2)
local color = Color3.fromRGB(255, 95, 95)
local color2 = Color3.new(1, 1, 1)
local color3 = Color3.fromRGB(85, 170, 255)
local color4 = Color3.new(0.35, 0.35, 0.35)
return function(object, data)
	local canPay = data.CanPay
	local priceLines = data.PriceLines
	local v = {
		BgColor = false,
		ContentTransparency = false
	}
	return object:Create("Frame")({
		Name = "Footer",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.fromScale(1, 0.1),
		BackgroundTransparency = 1,
		object:Create("Frame")({
			Name = "Cost",
			Size = UDim2.fromScale(0.6, 1),
			BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
			BackgroundTransparency = 0.5,
			object:Create("UICorner")({
				CornerRadius = UDim.new(0.3)
			}),
			object:Create("UIStroke")({
				Color = Color3.new(1, 1, 1),
				BorderOffset = UDim.new(0, -4),
				Transparency = 0.9
			}),
			object:Create("UIPadding")({
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10)
			}),
			object:Create("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 10)
			}),
			object:Create("TextLabel")({
				Name = "Label",
				LayoutOrder = 0,
				Size = UDim2.fromScale(0, 0.5),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				Font = Enum.Font.SourceSansSemibold,
				Text = data.Label or #priceLines > 0 and "Cost" or "Free",
				TextColor3 = Color3.new(1, 1, 1),
				TextTransparency = 0.25,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left
			}),
			object:Iterate(priceLines, function(layoutOrder, p2, object2, _)
				local cashier = Shop.cashiers[p2.Currency]
				local v2

				if cashier == nil then
					v2 = false
				else
					v2 = cashier.Deferred == true
				end

				local v3

				if not (cashier == nil or v2) then
					v3 = cashier.GetContent(p2.Amount)
				end

				local value = object2:Value(v3)

				if v2 then
					task.spawn(function()
						local content = cashier.GetContent(p2.Amount)

						if not object2.IsActive then
							return
						end

						value:Set(content)
					end)
				end

				return object2:Create("Frame")({
					Name = p2.Currency,
					LayoutOrder = layoutOrder,
					Size = UDim2.fromScale(0, 1),
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundTransparency = 1,
					object2:Create("UIListLayout")({
						FillDirection = Enum.FillDirection.Horizontal,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 3)
					}),
					object2:Create("ImageLabel")({
						Name = "Icon",
						LayoutOrder = 1,
						Size = UDim2.fromScale(0.55, 0.55),
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						BackgroundTransparency = 1,
						Image = object2:Do(function(callback)
							local v4 = callback(value)
							return v4 ~= nil and v4.Icon or ""
						end),
						ScaleType = Enum.ScaleType.Fit
					}),
					object2:Create("TextLabel")({
						Name = "Amount",
						LayoutOrder = 2,
						Size = UDim2.fromScale(0, 0.5),
						AutomaticSize = Enum.AutomaticSize.X,
						BackgroundTransparency = 1,
						Font = Enum.Font.SourceSansBold,
						RichText = true,
						Text = object2:Do(function(callback)
							local v4 = callback(value)

							if v4 == nil then
								return "..."
							end

							local v5 = Utility.addCommasToNumber(v4.Price)

							if canPay(callback, p2.Currency, p2.Amount) then
								return v5
							end

							return (`<s>{v5}</s>`)
						end),
						TextColor3 = object2:Do(function(callback)
							local v4 = callback(value)
							local color5 = v4 ~= nil and v4.Color or color2

							if not canPay(callback, p2.Currency, p2.Amount) then
								color5 = color
							end

							return object2:Animation(color5, info)
						end),
						TextScaled = true,
						TextXAlignment = Enum.TextXAlignment.Left
					})
				})
			end)
		}),
		object:Create("Frame")({
			Name = "ActionButton",
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.new(0.4, -6, 1, 0),
			BackgroundTransparency = 1,
			GradientButton(object, {
				Text = data.Text,
				Font = Enum.Font.SourceSansBold,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextBoxSize = UDim2.fromScale(0.8, 0.55),
				GradientRotation = -90,
				GradientTransparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.4),
					NumberSequenceKeypoint.new(1, 1)
				}),
				BgColor = object:Do(function(p)
					local selected

					if data.Ready(p) then
						selected = color3
					else
						selected = color4
					end

					if v.BgColor then
						return object:Animation(selected, info)
					end

					v.BgColor = true
					return selected
				end),
				ContentTransparency = object:Do(function(p)
					local selected = data.Ready(p) and 0 or 0.5

					if v.ContentTransparency then
						return object:Animation(selected, info)
					end

					v.ContentTransparency = true
					return selected
				end),
				CornerRadius = UDim.new(0.3),
				StrokeClick = true,
				Clicked = data.Clicked,
				Properties = {
					Size = UDim2.fromScale(0.9, 1),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5)
				}
			})
		})
	})
end