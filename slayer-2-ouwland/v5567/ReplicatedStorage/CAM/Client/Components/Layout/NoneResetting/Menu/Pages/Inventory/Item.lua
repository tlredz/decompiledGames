local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local faye = require(ReplicatedStorage.Packages.faye)
local data = Utility.GetData(localPlayer, true)
local Rarities = require(ReplicatedStorage.CAM.Global.Rarities)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local ItemIcon = require(ReplicatedStorage.CAM.Global.Collectibles.ItemIcon)
local FightingStyles = require(ReplicatedStorage.CAM.Global.Collectibles.FightingStyles)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
require(ReplicatedStorage.CAM.Client.Components.Layout.NoneResetting.Menu.Pages.Inventory.SelectModeHandler)
local Adders = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.Adders)
local MenuConfig = require(ReplicatedStorage.CAM.Client.Components.Layout.NoneResetting.Menu.MenuConfig)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local RarityShine = require(ReplicatedStorage.CAM.Client.Components.Misc.RarityShine)

-- equivalent calls inferred from this helper; original call sites unknown
local function cellSize()
	local v = Platform_Handler.Platform.Value == "Mobile" and 0.12366199999999998 or 0.08832999999999999
	return UDim2.fromScale(v, v)
end

local info = faye.Info(0.2)
local uDim = UDim2.fromScale(0.27999999999999997, 1.4)
local uDim2 = UDim2.fromScale(0.63, 1.4)
local v = {
	Vanity = "rbxassetid://81079881410330",
	Stats = "rbxassetid://130994003654653"
}
return function(object, data2, object2, state, p, data3, object3)
	local item = Items[data2.Name]
	local value = object:Value(1)
	local backgroundTransparency = object:Value(0.5)
	local transparency = object:Value(0.3)
	local value4 = object:Value(Color3.new(1, 1, 1))
	local imageTransparency = object:Value(0)
	local backgroundTransparency2 = object:Value(0)
	local value7 = object:Value(false)
	local text = object:Value()
	local visible = object:Value(false)
	local item2 = data3.Selected:GetItem(data2.Name)
	local value10 = object:Value((math.clamp(
		item2 == nil and 1 or item2[data2.Id or data2.ItemId] or 1,
		1,
		data2.Amount
	)))
	local color

	if item ~= nil then
		color = Rarities.Gradients[item.Rarity or 1]
	end

	local v3 = {
		In = nil,
		LastState = nil,
		RarityColor = 0
	}
	local rarityColor

	if color == nil then
		rarityColor = item ~= nil and Rarities.Colors[item.Rarity or 1] or Color3.new()
	else
		rarityColor = Color3.new(1, 1, 1)
	end

	v3.RarityColor = rarityColor
	local v5 = object3:Add({
		v3,
		data2,
		visible,
		backgroundTransparency,
		transparency,
		value,
		value4,
		imageTransparency,
		backgroundTransparency2,
		value7,
		text,
		value10
	}, object):Call()
	local image = object:Value(ItemIcon.For(localPlayer, data2.Name))

	if data2.Name == FightingStyles.TOOL_NAME then
		object:Connect(data.Powers.FightingStyle.Changed, function()
			image:Set(ItemIcon.For(localPlayer, data2.Name))
		end)
		object:Connect(data.Race.Changed, function()
			image:Set(ItemIcon.For(localPlayer, data2.Name))
		end)
	end

	local inventoryRepsExceeds = MenuConfig.inventoryRepsExceeds(
		Utility.ItemBag(data, data2.Name) or data.Inventory.Inventory,
		data2.Name
	)
	local v6

	if data2.Id ~= nil or data2.DestinctAmount <= 1 then
		v6 = Character_info_provider.GetItemFromId(localPlayer, data2.Id or data2.ItemId) or nil
	end

	local v7

	if v6 == nil then
		v7 = false
	else
		v7 = v6:FindFirstChild("NoSave") ~= nil
	end

	local v8 = object:Create("Frame")
	local v9 = {
		object:Create("TextButton")({
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Name = "Clickbox",
			MouseEnter = function()
				v3.In = true
				v5:Call()
			end,
			MouseLeave = function()
				v3.In = false
				v5:Call()
			end,
			MouseButton1Click = function()
				ScreenEffects.CircleClick()

				if data3.Enabled:Compare(true) and (data2.Id ~= nil or not inventoryRepsExceeds) then
					if item ~= nil and (item.NoDelete == true or item.NoDiscard == true) then
						return
					end

					local item3 = data3.Selected:GetItem(data2.Name)
					local id = data2.Id or data2.ItemId

					if item3 == nil then
						data3.Selected:Add(data2.Name, {
							[id] = 1,
							Count = 1
						})
					elseif item3[id] == nil then
						item3.Count += 1
						item3[id] = 1
						v5:Call()
					elseif item3.Count <= 1 then
						data3.Selected -= data2.Name
					else
						item3[id] = nil
						item3.Count -= 1
						v5:Call()
					end
				elseif object2:Compare(true) then
					if data2.Id ~= nil then
						if state.Value == data2.Id then
							state.Value = 0
							state.ItemName.Value = ""
						else
							state.ItemName.Value = data2.Name
							state.Value = data2.Id
						end
					end
				else
					if data2.Name ~= state.ItemName.Value then
						state.ItemName.Value = ""
						state.Value = 0
					end

					if p.Value == data2.Name then
						p.Value = ""
					else
						p.Value = data2.Name
					end
				end
			end
		}),
		Name = data2.Name or data2.Id,
		LayoutOrder = data2.Order or 0,
		Size = cellSize(),
		object:Create("UIAspectRatioConstraint")({
			AspectRatio = 1
		}),
		object:Create("UICorner")({
			CornerRadius = UDim.new(0.1)
		}),
		BackgroundColor3 = Color3.new(0.15, 0.15, 0.15),
		BackgroundTransparency = backgroundTransparency2
	}
	local v10 = object:Create("Frame")({
		Name = "Fg",
		Size = UDim2.fromScale(1, 1),
		object:Create("UICorner")({
			CornerRadius = UDim.new(0.1)
		}),
		BackgroundTransparency = backgroundTransparency,
		BackgroundColor3 = value4,
		object:Create("UIGradient")({
			Color = color,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.2),
				NumberSequenceKeypoint.new(0.6, 0.9),
				NumberSequenceKeypoint.new(0.8, 1),
				NumberSequenceKeypoint.new(1, 1)
			}),
			Rotation = -90
		})
	})
	local v11 = object:Create("ImageLabel")({
		Name = "Img",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Image = image,
		ImageTransparency = imageTransparency
	})
	local v12 = object:Create("Frame")({
		ZIndex = 2,
		Name = "EqFg",
		Size = UDim2.new(1, -5, 1, -5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		object:Create("UIStroke")({
			Thickness = 1,
			Color = Color3.new(1, 1, 1),
			Transparency = object:Animation(value, info)
		}),
		object:Create("UICorner")({
			CornerRadius = UDim.new(0.1)
		}),
		BackgroundTransparency = 1
	})
	local v13 = object:Create("UIStroke")
	local v16

	if item ~= nil then
		v16 = item.Rarity or nil
	end

	v9[4], v9[5], v9[6], v9[7], v9[8], v9[9], v9[10], v9[11], v9[12] = v10, v11, v12, v13({
	Thickness = 1,
	Color = value4,
	Transparency = transparency,
	RarityShine(v16, "Spin")
}), object:State(function(callback, object4)
	if not callback(value7) then
		return
	end

	local v17 = 1

	local function add(p2)
		v17 = p2
		local item3 = data3.Selected:GetItem(data2.Name)

		if item3 ~= nil and item3[data2.Id or data2.ItemId] ~= nil then
			local v18 = math.clamp(value10.Value + p2, 1, data2.Amount)
			value10:Set(v18)
			item3[data2.Id or data2.ItemId] = v18

			if data3.Update ~= nil then
				data3.Update:Fire()
			end
		end
	end

	local v18 = nil
	return object4:Create("Frame")({
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -5),
		Size = UDim2.fromScale(0.9, 0.25),
		BackgroundTransparency = object4:Animation(0.2, info, {
			From = 1
		}),
		BackgroundColor3 = Color3.new(0.25, 0.25, 0.25),
		object4:Create("UIGradient")({
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.25, 0),
				NumberSequenceKeypoint.new(0.75, 0),
				NumberSequenceKeypoint.new(1, 1)
			})
		}),
		object4:Create("Frame")({
			Name = "TxtHolder",
			Size = uDim2,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			object4:Create("UICorner")({
				CornerRadius = UDim.new(1)
			}),
			ClipsDescendants = true,
			BackgroundColor3 = Color3.new(0.15, 0.15, 0.15),
			BackgroundTransparency = 0.5,
			object4:State(function(callback2, object5)
				local text2 = callback2(value10)

				if v18 ~= nil and text2 == v18 then
					return
				end

				if v18 == nil then
					v18 = text2
					return object5:Create("TextLabel")({
						Size = UDim2.fromScale(1, 0.95),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						BackgroundTransparency = 1,
						OnClean = function(object6, p2)
							object6:Configure(p2)({
								Position = object6:Animation(UDim2.fromScale(0.5, v17 * 1 * -1), info)
							})
						end,
						TextScaled = true,
						Font = Enum.Font.SourceSansBold,
						Text = text2,
						TextColor3 = Color3.new(1, 1, 1)
					})
				end

				v18 = text2
				return object5:Create("TextLabel")({
					Size = UDim2.fromScale(1, 0.95),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = object5:Animation(UDim2.fromScale(0.5, 0.5), info, {
						From = UDim2.fromScale(0.5, v17 * 1)
					}),
					BackgroundTransparency = 1,
					CleanDelay = 0.2,
					TextScaled = true,
					Font = Enum.Font.SourceSansBold,
					Text = text2,
					TextColor3 = Color3.new(1, 1, 1),
					OnClean = function(object6, p2)
						object6:Configure(p2)({
							Position = object6:Animation(UDim2.fromScale(0.5, v17 * 1 * -1), info)
						})
					end
				})
			end)
		}),
		Adders(object4, {
			Size = uDim
		}, nil, function()
			add(1)
		end),
		Adders(object4, {
			Size = uDim,
			Position = UDim2.fromScale(1, 0.5),
			AnchorPoint = Vector2.new(1, 0.5)
		}, 90, function()
			add(-1)
		end)
	})
end), object:State(function(callback, object4)
	local v17 = callback(text)

	if v17 == nil then
		return
	else
		return object4:Create("Frame")({
			Size = UDim2.fromScale(0.295, 0.325),
			Position = UDim2.new(0, 2, 1, -2),
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, 1),
			Name = "SelectFrame",
			ZIndex = 99,
			object4:Create("ImageLabel")({
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.8, 0.8),
				Image = "rbxassetid://116594504938394",
				ImageTransparency = 0.5,
				Name = "Square"
			}),
			object4:Create("ImageLabel")({
				ZIndex = 2,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Image = "rbxassetid://115228880374136",
				Name = "Checkmark"
			}),
			object4:Create("Frame")({
				ZIndex = -1,
				Name = "TxtGradient",
				BackgroundColor3 = Color3.new(0.15, 0.15, 0.15),
				BackgroundTransparency = 0.1,
				Position = UDim2.fromScale(0.835, 0.5),
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.fromScale(2, 0.6),
				object4:Create("UIGradient")({
					Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })
				}),
				function()
					if typeof(v17) == "string" then
						return object4:Create("TextLabel")({
							Name = "Text",
							Size = UDim2.fromScale(2, 1.2),
							Position = UDim2.fromScale(0.115, 0.5),
							BackgroundTransparency = 1,
							Text = text,
							AnchorPoint = Vector2.new(0, 0.5),
							TextColor3 = Color3.new(1, 1, 1),
							TextXAlignment = Enum.TextXAlignment.Left,
							Font = Enum.Font.SourceSansSemibold,
							TextScaled = true
						})
					end

					return { object4:Create("UIListLayout")({
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalAlignment = Enum.HorizontalAlignment.Left,
							VerticalAlignment = Enum.VerticalAlignment.Center,
							Padding = UDim.new(-0.085, 0)
						}), object4:Iterate(v17, function(p2, p3, object5)
							if p3 then
								return object5:Create("ImageLabel")({
									Size = UDim2.fromScale(1.5, 1.5),
									BackgroundTransparency = 1,
									Image = v[p2],
									Instance.new("UIAspectRatioConstraint")
								})
							end
						end) }
				end
			})
		})
	end
end), function()
	if v7 then
		return object:Create("ImageLabel")({
			Name = "NoSave",
			ZIndex = 3,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = BunchaIcons.NoSave,
			ImageTransparency = gameSettings.noSaveOverlayTransparency,
			object:Create("UIShadow")({
				Color = gameSettings.noSaveOverlayShadowColor,
				Transparency = gameSettings.noSaveOverlayShadowTransparency,
				BlurRadius = gameSettings.noSaveOverlayShadowBlur
			})
		})
	end
end, function(_)
	if not ((data2.RefineLevel or 0) > 0) or data2.Id == nil and not (data2.DestinctAmount <= 1) then
		return
	end

	local preferedFont = gameSettings.preferedFont
	return object:Create("TextLabel")({
		ZIndex = 3,
		Visible = visible,
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.new(0, 4, 0, 1),
		Size = UDim2.fromScale(0.42, 0.34),
		BackgroundTransparency = 1,
		Text = `+{data2.RefineLevel}`,
		TextXAlignment = Enum.TextXAlignment.Left,
		FontFace = Font.new(preferedFont.Family, Enum.FontWeight.Bold, Enum.FontStyle.Normal),
		TextScaled = true,
		TextColor3 = Color3.new(1, 1, 1),
		object:Create("UIStroke")({
			Thickness = 1,
			Color = Color3.fromRGB(85, 170, 255),
			object:Create("UIGradient")({
				Rotation = 90,
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(155, 220, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 95, 200))
				}),
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.5, 0.3),
					NumberSequenceKeypoint.new(1, 0.85)
				})
			})
		})
	})
end, function(_)
	if data2.Amount > 1 then
		return object:Create("Frame")({
			ZIndex = 2,
			Visible = visible,
			Size = UDim2.fromScale(0.5175, 0.2875),
			Position = UDim2.new(1, -5, 0, 5),
			AnchorPoint = Vector2.new(1, 0),
			object:Create("UICorner")({
				CornerRadius = UDim.new(1)
			}),
			object:Create("TextLabel")({
				Size = UDim2.fromScale(1, 0.85),
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Text = `x{data2.Amount}`,
				Font = Enum.Font.SourceSansBold,
				TextScaled = true
			})
		})
	end
end
	return v8(v9)
end