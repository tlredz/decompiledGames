local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local Shop = require(ReplicatedStorage.CAM.Global.Shop)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
local SignalFunction = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalFunction)
local faye = require(ReplicatedStorage.Packages.faye)
local info = faye.Info(0.15, Enum.EasingStyle.Sine)
local color = Color3.new(0.15, 0.15, 0.15)
local robuxColor = gameSettings.robuxColor
local color2 = Color3.new(1, 1, 1)
local color3 = Color3.new(1, 0.35, 0.35)
local flag = false
return function(object, data, p, value: number?)
	local v = robuxColor
	local v2

	if data.Price == nil then
		v2 = ""
	else
		v2 = Utility.addCommasToNumber(data.Price)

		if data.ListedPrice ~= nil and data.ListedPrice ~= data.Price then
			v2 = `{v2} <font face="SourceSans" color="rgb(170,170,170)" transparency=".45"><s>{Utility.addCommasToNumber(data.ListedPrice)}</s></font>`
		end
	end

	local oreContent = Shop.GetOreContent(nil, data.Name)
	local v3 = oreContent == nil and "" or Utility.addCommasToNumber(oreContent.Price)

	local function perSpinOf(p2: number?, p3: string)
		if p2 == nil then
			return ""
		end

		return (`{p3}{math.floor(p2 / math.max(data.Spins, 1) * 10 + 0.5) / 10} / Spin`)
	end

	local text = object:Value(v2)
	local image = object:Value(BunchaIcons.Robux)
	local value4 = object:Value(robuxColor)
	local value5 = object:Value(robuxColor)
	local price = data.Price
	local text2 = object:Value(price == nil and "" or `R${math.floor(price / math.max(data.Spins, 1) * 10 + 0.5) / 10} / Spin`)

	local function inOre()
		return p ~= nil and p.Value == "Ore" and oreContent ~= nil
	end

	local value7 = object:Value(0)

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
				value7:Set(value7.Value + 1)
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
			object:Connect(inventory2.ChildRemoved, function(p2)
				if p2.Name == oreContent.Item then
					bump() -- equivalent call inferred; original call site unknown
				end
			end)
		end
	end

	local value8 = object:Value(0.92)
	local value9 = object:Value(0.8)
	local value10 = object:Value(false)
	local v4 = object:Create("Frame")
	local v5 = {
		Name = data.Name,
		LayoutOrder = -data.Spins,
		CleanDelay = value or 0.45,
		Size = UDim2.fromScale(1, 0.2),
		object:Create("UIAspectRatioConstraint")({
			AspectRatio = 5.5,
			AspectType = Enum.AspectType.ScaleWithParentSize,
			DominantAxis = Enum.DominantAxis.Width
		}),
		BackgroundTransparency = 1
	}
	local v6 = object:Create("Frame")
	local v7 = {
		Name = "ActualHolder",
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(1, -2, 1, -2),
		object:Create("UICorner")({
			CornerRadius = UDim.new(0.2)
		}),
		BackgroundColor3 = color
	}
	local v8 = object:Create("Frame")({
		Name = "Fg",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = v,
		BackgroundTransparency = object:Animation(value8, info),
		object:Create("UICorner")({
			CornerRadius = UDim.new(0.2)
		}),
		object:Create("UIGradient")({
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.2),
				NumberSequenceKeypoint.new(0.6, 0.9),
				NumberSequenceKeypoint.new(1, 1)
			})
		})
	})
	local v9 = object:Create("UIStroke")({
		Thickness = 1,
		Color = v,
		Transparency = object:Animation(value9, info)
	})
	local v10 = object:Create("Frame")({
		Name = "Left",
		Size = UDim2.new(0.6, 0, 1, -4),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 4, 0.5, 0),
		BackgroundTransparency = 1,
		object:Create("UIListLayout")({
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		object:Create("Frame")({
			Name = "NameRow",
			LayoutOrder = 1,
			Size = UDim2.fromScale(1, 0.7),
			BackgroundTransparency = 1,
			object:Create("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 6)
			}),
			object:Create("TextLabel")({
				Name = "Title",
				LayoutOrder = 1,
				AutomaticSize = Enum.AutomaticSize.X,
				Size = UDim2.fromScale(0, 1),
				BackgroundTransparency = 1,
				Text = data.Name,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextScaled = true,
				Font = Enum.Font.SourceSansBold,
				TextColor3 = color2,
				object:Create("UIStroke")({
					Thickness = 1,
					Transparency = 0.5
				})
			}),
			object:Create("TextLabel")({
				Name = "PerSpin",
				LayoutOrder = 2,
				AutomaticSize = Enum.AutomaticSize.X,
				Size = UDim2.fromScale(0, 0.5),
				BackgroundTransparency = 1,
				Text = text2,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextScaled = true,
				Font = Enum.Font.SourceSansSemibold,
				TextColor3 = color2,
				TextTransparency = 0.6
			})
		})
	})
	local v11 = object:Create("Frame")({
		Name = "Price",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -6, 0.5, 0),
		Size = UDim2.new(0.4, -6, 0.51, 0),
		BackgroundTransparency = 1,
		object:Create("UIListLayout")({
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
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
				ImageColor3 = object:Animation(value5, info)
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
			TextXAlignment = Enum.TextXAlignment.Right,
			TextScaled = true,
			Font = Enum.Font.SourceSansBold,
			TextColor3 = object:Animation(value4, info),
			object:Create("UIStroke")({
				Thickness = 1,
				Transparency = 0.5
			})
		})
	})
	local v12

	if p ~= nil then
		v12 = object:State(function(callback, object2)
			callback(value7)

			if callback(p) == "Ore" and oreContent ~= nil then
				local oreContent2 = Shop.GetOreContent(Players.LocalPlayer, data.Name)
				local v13

				if oreContent2 == nil then
					v13 = false
				else
					v13 = oreContent2.CanBuy == false
				end

				local v15

				if v13 then
					v15 = `<s>{v3}</s>`
				else
					v15 = v3
				end

				text:Set(v15)
				image:Set(oreContent.Icon)
				value5:Set(color2)
				local v17

				if v13 then
					v17 = color3
				else
					v17 = color2
				end

				value4:Set(v17)
				local price2 = oreContent.Price
				text2:Set(price2 == nil and "" or `{math.floor(price2 / math.max(data.Spins, 1) * 10 + 0.5) / 10} / Spin`)
			else
				text:Reset()
				image:Reset()
				value5:Reset()
				value4:Reset()
				text2:Reset()
			end

			return object2:Create("Frame")({
				Size = UDim2.fromScale(0, 0),
				BackgroundTransparency = 1
			})
		end) or nil
	end

	do local _values = table.pack(v8, v9, v10, v11, v12, object:State(function(callback, object2)
	if callback(value10) then
		value8:Set(0.45)
		value9:Set(0.25)
	else
		value8:Reset()
		value9:Reset()
	end

	return object2:Create("Frame")({
		Size = UDim2.fromScale(0, 0),
		BackgroundTransparency = 1
	})
end), object:Create("TextButton")({
	Name = "Hit",
	ZIndex = 3,
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	MouseButton1Click = function()
		if flag then
			return
		end

		ScreenEffects.CircleClick()
		flag = true
		local v13

		if p == nil or p.Value ~= "Ore" then
			v13 = false
		else
			v13 = oreContent ~= nil
		end

		if v13 then
			local oreContent2 = Shop.GetOreContent(Players.LocalPlayer, data.Name)
			local held = oreContent2 ~= nil and oreContent2.Held or nil

			if PopUpCreator.new({
				Type = "Question",
				Content = `You have {Utility.addCommasToNumber(held or 0)} {oreContent.Item} left, are you sure you want to buy this?`
			}).Result:Wait(5) ~= "Yes" then
				flag = false
				return
			end
		end

		local v14 = PopUpCreator.new({
			Type = "LoadingFull"
		})
		local v15

		if p == nil or p.Value ~= "Ore" then
			v15 = false
		else
			v15 = oreContent ~= nil
		end

		local success, result

		if v15 then
			success, result = pcall(SignalFunction.ToServer, "PurchaseFromShopWithOre", data.Name)
		else
			success, result = pcall(SignalFunction.ToServer, "PurchaseFromShop", data.Name, 1)
		end

		v14:Destroy()
		flag = false
		local v16 = success and result == true and "Money_Kaching" or "denied_old"
		local clone = ReplicatedStorage.Assets.Sounds.Misc[v16]:Clone()
		clone.Parent = script
		clone:Play()
		DebrisModule:AddItem(clone, clone.TimeLength)
	end,
	MouseEnter = function()
		if value10.Value == false then
			value10:Set(true)
		end
	end,
	MouseLeave = function()
		if value10.Value == true then
			value10:Set(false)
		end
	end
})); for _k = 1, _values.n do v7[1 + _k] = _values[_k] end end
	do local _values = table.pack(v6(v7)); for _k = 1, _values.n do v5[1 + _k] = _values[_k] end end
	return v4(v5)
end