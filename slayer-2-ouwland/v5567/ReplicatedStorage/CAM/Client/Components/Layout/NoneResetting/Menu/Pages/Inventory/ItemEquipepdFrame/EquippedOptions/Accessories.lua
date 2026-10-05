local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local faye = ReplicatedStorage.Packages.faye
local module = require(faye)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local data = Utility.GetData(localPlayer, true)
local GradientButton = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.GradientButton)
local order = {
	data.Inventory.Accessories.Stats.One,
	data.Inventory.Accessories.Stats.Two,
	data.Inventory.Accessories.Stats.Three,
	data.Inventory.Accessories.Stats.Four,
	data.Inventory.Accessories.Stats.Five
}
local order2 = {
	data.Inventory.Accessories.Vanity.One,
	data.Inventory.Accessories.Vanity.Two,
	data.Inventory.Accessories.Vanity.Three,
	data.Inventory.Accessories.Vanity.Four,
	data.Inventory.Accessories.Vanity.Five
}
local _ = {
	Vanity = "rbxassetid://81079881410330",
	Stats = "rbxassetid://130994003654653"
}
local info = module.Info(0.1)
local ItemIcon = require(ReplicatedStorage.CAM.Global.Collectibles.ItemIcon)
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local Slot = require(script.Slot)
return function(object, _, object2)
	local value = object:Value("One")
	local value2 = object:Value("One")
	local v3 = {
		Vanity = {
			BgColor = object:Value(Color3.new(0.936187, 0.90518, 0.404486)),
			Info = object.Info(0.2),
			Text = object:Value("Equip Vanity"),
			Value = value2,
			Order = order2,
			Type = 2
		},
		Stats = {
			BgColor = object:Value(Color3.new(0.834806, 0.703838, 0.976837)),
			Info = object.Info(0.2),
			Text = object:Value("Equip Stats"),
			Enabled = false,
			Value = value,
			Order = order,
			Type = 1
		}
	}

	local function updItems()
		local v4 = object2:Get()
		local value3 = v4 ~= nil and v4.Id.Value or nil

		local function pickSlot(list, value4)
			if value3 ~= nil then
				for _, v5 in list do
					if v5.Value ~= value3 then
						continue
					end

					value4.Value = v5.Name
					return
				end
			end

			for i = 1, 5 do
				if list[i].Value ~= 0 then
					continue
				end

				value4.Value = list[i].Name
				return
			end

			value4.Value = list[5].Name
		end

		pickSlot(order, value)
		pickSlot(order2, value2)
	end

	updItems()
	local space = object:Space(function(state, object3, p, object4, object5, object6, object7, object8, _, object9)
		local v4 = 0
		local lastNew = p.Value
		local v5

		if lastNew == state.LastNew then
			v5 = false
		else
			v5 = true
			local v6 = ""

			if lastNew ~= nil then
				local item = Character_info_provider.GetItemFromId(localPlayer, lastNew)

				if item ~= nil then
					object2:Compare(item)
					v6 = ItemIcon.For(localPlayer, item.Name)
				end
			end

			object3:Set(v6)
			state.LastNew = lastNew
		end

		local v6

		if state.Type == 1 then
			v6 = value:Compare(state.Index) and 1 or v4
		else
			v6 = value2:Compare(state.Index) and 1 or v4
		end

		local state2 = v6 == 0 and state.In and 2 or v6

		if state2 ~= state.State or v5 then
			state.State = state2

			if state2 == 1 then
				object4:Set(0)
				object7:Set(UDim2.fromScale(0.8, 0.8))
				object8:Set(UDim2.fromScale(0.85, 0.85))
				object6:Set(0.75)
				object5:Set(0.25)
				object9:Set(2)
			else
				if lastNew == 0 then
					object4:Reset()
				else
					object4:Set(0)
				end

				object7:Reset()
				object8:Reset()
				object6:Reset()

				if state2 == 2 then
					object9:Set(1)
					object5:Set(0.4)
				else
					object9:Reset()
					object5:Reset()
				end
			end
		end
	end)
	space:Connect(object2.Changed)
	object:Connect(object2.Changed, updItems)
	space:Connect(value2.Changed)
	space:Connect(value.Changed)

	for k, v4 in v3 do
		local v5 = k
		local v6 = v4

		local function updSlot()
			if object2:Compare(Character_info_provider[`getEquippedAccessory{v5}`](localPlayer, v6.Value:Get())) then
				v6.Enabled = false
				v6.BgColor:Set(Color3.new(1, 0, 0))
				v6.Text:Set("UnEquip")
			else
				v6.Text:Reset()
				v6.BgColor:Reset()
				v6.Enabled = true
			end
		end

		updSlot()

		for _, v7 in pairs(v4.Order) do
			object:Connect(v7.Changed, updSlot)
			space:Connect(v7.Changed, (`{v4.Type}-{v7.Name}`))
		end

		v4.Value.Changed:Connect(updSlot)
	end

	return object:Create("Frame")({
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Name = "AccessoriesEquipped",
		object:Create("Frame")({
			Name = "Stats",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			object:Create("Frame")({
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				Name = "Holder",
				object:Create("UIListLayout")({
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0.0075, 0)
				}),
				object:Iterate(order, function(p, p2, p3)
					return Slot(p3, p, p2, value, space, 1)
				end)
			}),
			object:Create("Frame")({
				Name = "Title",
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.fromScale(0, 1.5),
				Size = UDim2.fromScale(0.2, 0.4),
				object:Create("UICorner")({
					CornerRadius = UDim.new(1)
				}),
				object:Create("UIGradient")({
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.9),
						NumberSequenceKeypoint.new(1, 1)
					})
				}),
				object:Create("TextLabel")({
					Size = UDim2.fromScale(1, 1),
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(0.12, 3, 0.5, 0),
					BackgroundTransparency = 1,
					Font = Enum.Font.SourceSansSemibold,
					Text = "Stats",
					TextTransparency = 0.15,
					TextScaled = true,
					TextColor3 = Color3.new(1, 1, 1),
					TextXAlignment = Enum.TextXAlignment.Left,
					object:Create("UIStroke")({
						Thickness = 1,
						Transparency = 0.5
					})
				}),
				object:Create("ImageLabel")({
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.fromScale(-0.015, 0.6),
					Size = UDim2.fromScale(0.2, 1),
					BackgroundTransparency = 1,
					ScaleType = Enum.ScaleType.Fit,
					Image = "rbxassetid://130994003654653",
					ImageTransparency = 0.15
				})
			}),
			GradientButton(object, {
				Properties = {
					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.fromScale(0.4375, 1.15),
					Size = UDim2.fromScale(0.2, 0.4)
				},
				GradientTransparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.75, 0.5),
					NumberSequenceKeypoint.new(1, 0.5)
				}),
				TextXAlignment = Enum.TextXAlignment.Center,
				Clicked = function()
					local value3 = object2:Get().Id.Value
					local v4 = value:Get()

					if v4 ~= "" and value3 ~= nil then
						if v3.Stats.Enabled then
							SignalEvent.ToServer("AccessoryEquip", v4, value3, "Stats")
						else
							SignalEvent.ToServer("AccessoryEquip", v4, 0, "Stats")
						end
					end
				end,
				BgColor = object:Animation(v3.Stats.BgColor, info),
				GradientRotation = -90,
				Text = v3.Stats.Text,
				ContentColor = Color3.new(1, 1, 1)
			})
		}),
		object:Create("Frame")({
			Name = "Vanity",
			Size = UDim2.fromScale(1, 1),
			Position = UDim2.fromScale(1, 0),
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			object:Create("Frame")({
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				Name = "Holder",
				object:Create("UIListLayout")({
					HorizontalAlignment = Enum.HorizontalAlignment.Right,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0.0075, 0)
				}),
				object:Iterate(order2, function(p, p2, p3)
					return Slot(p3, p + 10, p2, value2, space, 2)
				end)
			}),
			object:Create("Frame")({
				Name = "Title",
				AnchorPoint = Vector2.new(1, 1),
				Position = UDim2.fromScale(1, 1.4),
				Size = UDim2.fromScale(0.2, 0.4),
				object:Create("UICorner")({
					CornerRadius = UDim.new(1)
				}),
				object:Create("UIGradient")({
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.9),
						NumberSequenceKeypoint.new(1, 1)
					}),
					Rotation = 180
				}),
				object:Create("TextLabel")({
					Size = UDim2.fromScale(1, 1),
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(-0.155, -3, 0.5, 0),
					BackgroundTransparency = 1,
					Font = Enum.Font.SourceSansSemibold,
					Text = "Vanity",
					TextScaled = true,
					TextTransparency = 0.15,
					TextColor3 = Color3.new(1, 1, 1),
					TextXAlignment = Enum.TextXAlignment.Right,
					object:Create("UIStroke")({
						Thickness = 1,
						Transparency = 0.5
					})
				}),
				object:Create("ImageLabel")({
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.fromScale(1.015, 0.6),
					Size = UDim2.fromScale(0.2, 1),
					BackgroundTransparency = 1,
					ScaleType = Enum.ScaleType.Fit,
					ImageTransparency = 0.15,
					Image = "rbxassetid://81079881410330"
				})
			}),
			GradientButton(object, {
				Properties = {
					AnchorPoint = Vector2.new(0, 0),
					Position = UDim2.fromScale(0.5625, 1.15),
					Size = UDim2.fromScale(0.2, 0.4)
				},
				GradientTransparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.75, 0.5),
					NumberSequenceKeypoint.new(1, 0.5)
				}),
				TextXAlignment = Enum.TextXAlignment.Center,
				Clicked = function()
					local value3 = object2:Get().Id.Value
					local v4 = value2:Get()

					if v4 ~= "" and value3 ~= nil then
						if v3.Vanity.Enabled then
							SignalEvent.ToServer("AccessoryEquip", v4, value3, "Vanity")
						else
							SignalEvent.ToServer("AccessoryEquip", v4, 0, "Vanity")
						end
					end
				end,
				BgColor = object:Animation(v3.Vanity.BgColor, info),
				GradientRotation = -90,
				Text = v3.Vanity.Text,
				ContentColor = Color3.new(1, 1, 1)
			})
		})
	})
end