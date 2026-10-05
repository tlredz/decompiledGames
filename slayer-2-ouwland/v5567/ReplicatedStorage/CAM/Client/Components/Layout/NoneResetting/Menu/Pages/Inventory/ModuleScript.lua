local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
Utility.GetData(localPlayer, true)
local Rarities = require(ReplicatedStorage.CAM.Global.Rarities)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
return function(object, data, object2, instance, instance2)
	local item = Items[data.Name]
	local info = object.Info(0.2)
	local value = object:Value(1)
	local value2 = object:Value(0.5)
	local value3 = object:Value(0.3)
	local v = false
	local v2 = nil

	local function Update()
		local v3

		if object2:Compare(true) and instance.Value == data.Id then
			v3 = 1
		elseif object2:Compare(false) and (instance2.Value == data.Name or data.Name == instance.ItemName.Value) then
			v3 = 1
		elseif v == true then
			v3 = 2
		else
			v3 = 3
		end

		if v3 ~= v2 then
			if v3 == 1 then
				value2:Set(0.25)
				value3:Set(0.1)
				value:Set(0.1)
			elseif v3 == 2 then
				value2:Set(0.25)
				value3:Set(0.185)
				value:Reset()
			else
				value:Reset()
				value2:Reset()
				value3:Reset()
			end

			v2 = v3
		end
	end

	Update()
	object:Connect(object2.Changed, Update)
	object:Connect(instance2:GetPropertyChangedSignal("Value"), Update)
	object:Connect(instance:GetPropertyChangedSignal("Value"), Update)
	local icon = item.Icon or ""
	local v3 = item ~= nil and Rarities.Colors[item.Rarity or 1] or Color3.new()
	return object:Create("Frame")({
		object:Create("TextButton")({
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Name = "Clickbox",
			MouseEnter = function()
				v = true
				Update()
			end,
			MouseLeave = function()
				v = false
				Update()
			end,
			MouseButton1Click = function()
				ScreenEffects.CircleClick()

				if object2:Compare(true) then
					if data.Id ~= nil then
						if instance.Value == data.Id then
							instance.Value = 0
							instance.ItemName.Value = ""
						else
							instance.ItemName.Value = data.Name
							instance.Value = data.Id
						end
					end
				else
					if data.Name ~= instance.ItemName.Value then
						instance.ItemName.Value = ""
						instance.Value = 0
					end

					if instance2.Value == data.Name then
						instance2.Value = ""
					else
						instance2.Value = data.Name
					end
				end
			end
		}),
		Name = data.Name or data.Id,
		Size = UDim2.fromScale(0.08832999999999999, 0.08832999999999999),
		object:Create("UICorner")({
			CornerRadius = UDim.new(0.1)
		}),
		BackgroundColor3 = Color3.new(0.15, 0.15, 0.15),
		object:Create("Frame")({
			Name = "Fg",
			Size = UDim2.fromScale(1, 1),
			object:Create("UICorner")({
				CornerRadius = UDim.new(0.1)
			}),
			BackgroundTransparency = object:Animation(value2, info),
			BackgroundColor3 = v3,
			object:Create("UIGradient")({
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.2),
					NumberSequenceKeypoint.new(0.6, 0.9),
					NumberSequenceKeypoint.new(0.8, 1),
					NumberSequenceKeypoint.new(1, 1)
				}),
				Rotation = -90
			})
		}),
		object:Create("ImageLabel")({
			Name = "Img",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Image = icon
		}),
		object:Create("Frame")({
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
		}),
		object:Create("UIStroke")({
			Thickness = 1,
			Color = v3,
			Transparency = object:Animation(value3, info)
		}),
		function(_)
			if data.Amount > 1 then
				return object:Create("Frame")({
					ZIndex = 2,
					Size = UDim2.fromScale(0.45, 0.25),
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
						Text = `x{data.Amount}`,
						Font = Enum.Font.SourceSansBold,
						TextScaled = true
					})
				})
			end
		end
	})
end