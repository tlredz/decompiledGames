local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local Shop = require(ReplicatedStorage.CAM.Global.Shop)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
local SignalFunction = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalFunction)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local faye = require(ReplicatedStorage.Packages.faye)
local notification = ReplicatedStorage.Communication.CnC.Notifications.Notification
local robuxColor = gameSettings.robuxColor
local color = Color3.new(1, 1, 1)
local color2 = Color3.new(1, 0.35, 0.35)
local flag = false
local info = faye.Info(0.2)
local springInfo = faye.SpringInfo(0.4, 1, 0.6)
local v = {
	White = Color3.new(1, 1, 1),
	Green = Color3.fromRGB(130, 255, 160),
	Red = Color3.fromRGB(255, 120, 120),
	Purple = Color3.fromRGB(195, 140, 255),
	Blue = Color3.fromRGB(130, 185, 255),
	Yellow = Color3.fromRGB(255, 225, 130)
}

local function accentOf(p: string?)
	local v2

	if p ~= nil then
		v2 = v[p] or nil
	end

	if v2 == nil and p ~= nil then
		warn((`Shop GridContent: no accent colour "{p}", using White`))
	end

	return v2 or v.White
end

return function(object, object2, data, p, p2: string, p3, p4)
	local v2 = p2 == "Half" and 1.7 or 1
	local color3 = data.Color
	local v3

	if color3 ~= nil then
		v3 = v[color3] or nil
	end

	if v3 == nil and color3 ~= nil then
		warn((`Shop GridContent: no accent colour "{color3}", using White`))
	end

	local v4 = v3 or v.White
	local v5 = {
		Value = data,
		In = object:Value(false),
		BgColor = object:Value(Color3.new(0.25, 0.25, 0.25)),
		ShadowTransparency = object:Value(0.4),
		StrokeTransparency = object:Value(0.7),
		StrokeThickness = object:Value(1),
		GradientTransparency = object:Value(NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(0.35, 0.9),
			NumberSequenceKeypoint.new(1, 1)
		})),
		IconSize = object:Value(UDim2.fromScale(1.2, 1.2))
	}
	object2:Add(v5, object, true):Call():Connect(v5.In.Changed)
	local robuxPrice = Shop.cashiers.Product.GetRobuxPrice(data.ProductId)
	local v6

	if robuxPrice == nil then
		v6 = ""
	else
		v6 = Utility.addCommasToNumber(robuxPrice)

		if data.ListedPrice ~= nil and data.ListedPrice ~= robuxPrice then
			v6 = `{v6} <font face="SourceSans" color="rgb(190,190,190)" transparency=".2"><s>{Utility.addCommasToNumber(data.ListedPrice)}</s></font>`
		end
	end

	local oreContent = Shop.GetOreContent(nil, data.Name)
	local v7 = oreContent == nil and "" or Utility.addCommasToNumber(oreContent.Price)
	local text = object:Value(v6)
	local image = object:Value(BunchaIcons.Robux)
	local value3 = object:Value(robuxColor)
	local value4 = object:Value(robuxColor)
	local value5 = object:Value(0)

	if oreContent ~= nil then
		local data2 = Utility.GetData(Players.LocalPlayer)
		local inventory

		if data2 ~= nil then
			inventory = data2:FindFirstChild("Inventory") or nil
		end

		local inventory2

		if inventory ~= nil then
			inventory2 = inventory:FindFirstChild("Inventory") or nil
		end

		if inventory2 ~= nil then
			-- equivalent calls inferred from this helper; original call sites unknown
			local function bump()
				value5:Set(value5.Value + 1)
			end

			local function watchStack(instance)
				if instance.Name ~= oreContent.Item then
					return
				end

				bump() -- equivalent call inferred; original call site unknown
				local amount = instance:FindFirstChild("Amount")

				if amount ~= nil then
					object:Connect(amount.Changed, bump)
				end
			end

			local child = inventory2:FindFirstChild(oreContent.Item)

			if child ~= nil and child.Name == oreContent.Item then
				bump() -- equivalent call inferred; original call site unknown
				local amount = child:FindFirstChild("Amount")

				if amount ~= nil then
					object:Connect(amount.Changed, bump)
				end
			end

			object:Connect(inventory2.ChildAdded, watchStack)
			object:Connect(inventory2.ChildRemoved, function(p5)
				if p5.Name == oreContent.Item then
					bump() -- equivalent call inferred; original call site unknown
				end
			end)
		end
	end

	return object:Create("Frame")({
		Name = "Content",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		object:Create("Frame")({
			Size = UDim2.new(1, -4, 1, -4),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundColor3 = object:Animation(v5.BgColor, info),
			object:Create("UIShadow")({
				Color = Color3.new(0.25, 0.25, 0.25),
				BlurRadius = UDim.new(0.4),
				Transparency = object:Animation(v5.ShadowTransparency, info)
			}),
			object:Create("UICorner")({
				CornerRadius = UDim.new(0.2)
			}),
			object:Create("UIStroke")({
				Color = v4,
				BorderOffset = UDim.new(0, -3),
				Transparency = object:Animation(v5.StrokeTransparency, info),
				Thickness = object:Animation(v5.StrokeThickness, info)
			}),
			object:Create("TextButton")({
				Name = "Hitbox",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				ZIndex = 5,
				MouseButton1Click = function()
					if flag then
						return
					end

					local value6

					if p3.Value ~= "" then
						value6 = p3.Value
					end

					if value6 == nil and p4.Value ~= "" then
						notification:Fire("Notify", {
							Text = `No player named {p4.Value} is in this server`,
							Type = "Denied"
						})
						return
					end

					local v8

					if p.Value == "Ore" then
						v8 = oreContent ~= nil
					else
						v8 = false
					end

					if value6 ~= nil and v8 then
						notification:Fire("Notify", {
							Text = "Gifts can only be bought with Robux, switch to the Robux tab",
							Type = "Denied"
						})
						return
					end

					ScreenEffects.CircleClick()
					flag = true
					local content = nil

					if v8 then
						local oreContent2 = Shop.GetOreContent(Players.LocalPlayer, data.Name)
						content = `You have {Utility.addCommasToNumber(oreContent2 == nil and 0 or oreContent2.Held or 0)} {oreContent.Item} left, are you sure you want to buy this?`
					elseif value6 ~= nil then
						content = `Gift {data.Label or data.Name} to {value6}?`
					end

					if content ~= nil and PopUpCreator.new({
						Type = "Question",
						Content = content
					}).Result:Wait(5) ~= "Yes" then
						flag = false
						return
					end

					local v10 = PopUpCreator.new({
						Type = "LoadingFull"
					})
					local success, result, text2

					if v8 then
						success, result, text2 = pcall(
							SignalFunction.ToServer,
							"PurchaseFromShopWithOre",
							data.Name,
							1,
							value6
						)
					else
						success, result, text2 = pcall(
							SignalFunction.ToServer,
							"PurchaseFromShop",
							data.Name,
							1,
							value6
						)
					end

					v10:Destroy()
					flag = false

					if success and result ~= true and typeof(text2) == "string" then
						notification:Fire("Notify", {
							Text = text2,
							Type = "Denied"
						})
					end

					local v12 = success and result == true and "Money_Kaching" or "denied_old"
					local clone = ReplicatedStorage.Assets.Sounds.Misc[v12]:Clone()
					clone.Parent = script
					clone:Play()
					DebrisModule:AddItem(clone, clone.TimeLength)
				end,
				MouseEnter = function()
					v5.In:Set(true)
				end,
				MouseLeave = function()
					if not v5.In:Compare(true) then
						return
					end

					v5.In:Set(false)
				end
			}),
			object:Create("ImageLabel")({
				Name = "Icon",
				Size = object:Animation(v5.IconSize, springInfo),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				object:Create("UICorner")({
					CornerRadius = UDim.new(0.2)
				}),
				Image = data.Icon,
				ScaleType = Enum.ScaleType.Fit,
				BackgroundTransparency = 1
			}),
			object:Create("TextLabel")({
				Name = "Title",
				Size = UDim2.fromScale(0.9, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.4),
				BackgroundTransparency = 1,
				ZIndex = 33,
				Text = data.Label or data.Name,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				Font = Enum.Font.SourceSansSemibold,
				object:Create("UIShadow")({
					BlurRadius = UDim.new(0.5),
					Transparency = 0.7
				}),
				object:Create("UIStroke")({
					Thickness = 2,
					Color = Color3.new(),
					object:Create("UIGradient")({
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0.5),
							NumberSequenceKeypoint.new(1, 0.75)
						}),
						Rotation = -90
					})
				})
			}),
			object:Create("Frame")({
				Name = "Price",
				ZIndex = 3,
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.fromScale(0.5, 0.95),
				Size = UDim2.fromScale(0.9, v2 * 0.16),
				BackgroundTransparency = 1,
				object:Create("UIListLayout")({
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 1)
				}),
				object:Create("Frame")({
					Name = "IconHolder",
					LayoutOrder = 1,
					Size = UDim2.fromScale(0.8, 0.8),
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					BackgroundTransparency = 1,
					object:Create("ImageLabel")({
						Name = "Icon",
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.55),
						Size = UDim2.fromScale(0.8, 0.8),
						BackgroundTransparency = 1,
						Image = image,
						ImageColor3 = object:Animation(value4, info),
						object:Create("UIShadow")({
							BlurRadius = UDim.new(0.5),
							Transparency = 0.7
						})
					})
				}),
				object:Create("TextLabel")({
					Name = "Amount",
					LayoutOrder = 2,
					AutomaticSize = Enum.AutomaticSize.X,
					Size = UDim2.fromScale(0, 1),
					BackgroundTransparency = 1,
					RichText = true,
					Text = text,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextScaled = true,
					Font = Enum.Font.SourceSansBold,
					TextColor3 = object:Animation(value3, info),
					object:Create("UIShadow")({
						BlurRadius = UDim.new(0.5),
						Transparency = 0.7
					}),
					object:Create("UIStroke")({
						Thickness = 1,
						Transparency = 0.5
					})
				}),
				object:State(function(callback, object3)
					callback(value5)

					if callback(p) == "Ore" and oreContent ~= nil then
						local oreContent2 = Shop.GetOreContent(Players.LocalPlayer, data.Name)
						local v8

						if oreContent2 == nil then
							v8 = false
						else
							v8 = oreContent2.CanBuy == false
						end

						local v10

						if v8 then
							v10 = `<s>{v7}</s>`
						else
							v10 = v7
						end

						text:Set(v10)
						image:Set(oreContent.Icon)
						value4:Set(color)
						local v12

						if v8 then
							v12 = color2
						else
							v12 = color
						end

						value3:Set(v12)
					else
						text:Reset()
						image:Reset()
						value4:Reset()
						value3:Reset()
					end

					return object3:Create("Frame")({
						Size = UDim2.fromScale(0, 0),
						BackgroundTransparency = 1
					})
				end)
			}),
			object:Create("Frame")({
				Size = UDim2.fromScale(1, 1),
				ZIndex = 2,
				BackgroundColor3 = v4,
				object:Create("UICorner")({
					CornerRadius = UDim.new(0.2)
				}),
				object:Create("UIGradient")({
					Transparency = object:Animation(v5.GradientTransparency, info),
					Rotation = -90
				})
			})
		})
	})
end