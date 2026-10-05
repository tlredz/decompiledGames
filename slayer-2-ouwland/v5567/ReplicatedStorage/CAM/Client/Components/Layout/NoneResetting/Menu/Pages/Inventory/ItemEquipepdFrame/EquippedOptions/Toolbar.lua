local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local GradientButton = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.GradientButton)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local data = Utility.GetData(localPlayer, true)
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local FightingStyles = require(ReplicatedStorage.CAM.Global.Collectibles.FightingStyles)
local ItemIcon = require(ReplicatedStorage.CAM.Global.Collectibles.ItemIcon)
local Slot = require(script.Slot)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local v = {
	data.Inventory.Toolbar.One,
	data.Inventory.Toolbar.Two,
	data.Inventory.Toolbar.Three,
	data.Inventory.Toolbar.Four,
	data.Inventory.Toolbar.Five
}
require(ReplicatedStorage.Packages.faye)
local SlotDragger = require(ReplicatedStorage.CAM.Client.Components.Misc.Utilities.SlotDragger)
local v2 = {
	One = 1,
	Two = 2,
	Three = 3,
	Four = 4,
	Five = 5
}
local v3 = "One"
return function(object, target, object2)
	local value = object:Value(Color3.new(0.666667, 1, 0.498039))
	local info = object.Info(0.2)
	local text = object:Value("Equip")
	local value3 = object:Value(v3)
	local v4 = false

	local function updItems()
		local v5 = object2:Get()

		if v5 ~= nil then
			local value4 = v5.Id.Value

			for _, child in ipairs(data.Inventory.Toolbar:GetChildren()) do
				if child.Value ~= value4 then
					continue
				end

				value3:Set(child.Name)
				return
			end
		end

		if v4 or v5 == nil then
			return
		end

		for i = 1, 5 do
			if v[i].Value ~= 0 then
				continue
			end

			value3:Set(v[i].Name)
			return
		end

		value3:Set(v[5].Name)
	end

	updItems()
	local flag = true
	local value4 = object:Value(false)

	local function updSlot()
		local v5 = value3:Get()

		if object2:Get() == nil then
			local child = data.Inventory.Toolbar:FindFirstChild(v5)

			if not v4 or child == nil or child.Value == 0 then
				value4:Set(false)
				return
			end

			flag = false
			value:Set(Color3.new(1, 0, 0))
			text:Set("UnEquip")
			value4:Set(true)
		else
			if object2:Compare(Character_info_provider.getEquippedItems(localPlayer, v5)) then
				flag = false
				value:Set(Color3.new(1, 0, 0))
				text:Set("UnEquip")
			else
				text:Reset()
				value:Reset()
				flag = true
			end

			value4:Set(true)
		end
	end

	updSlot()

	for _, v5 in pairs(v) do
		object:Connect(v5.Changed, updSlot)
	end

	value3.Changed:Connect(updSlot)
	object:Connect(object2.Changed, updSlot)
	object:Connect(value3.Changed, function()
		v3 = value3:Get()
	end)

	local function tryToolbarEquip(childName: string)
		local items_Config = localPlayer:FindFirstChild("Items_Config")

		if items_Config == nil or items_Config:FindFirstChild("Equipped") == nil or items_Config.Equipped.Value ~= 0 then
			return
		end

		local child = data.Inventory.Toolbar:FindFirstChild(childName)

		if child == nil or child.Value == 0 then
			return
		end

		local v5 = v2[childName]

		if v5 ~= nil then
			items_Config.Equipped.Value = v5
		end
	end

	local function onSlotClicked(p2: string)
		v4 = true
		updSlot()
		tryToolbarEquip(p2)
	end

	local slotDragger = SlotDragger(object, {
		Target = target,
		Backdrop = function(object3)
			return object3:Create("Frame")({
				Name = "Bg",
				ZIndex = -1,
				object3:Create("UICorner")({
					CornerRadius = UDim.new(0.2)
				}),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 0,
				BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
			})
		end,
		IconScaleType = Enum.ScaleType.Crop,
		OnDrop = function(p2: string, p3: string)
			if Checker.DenyLoadoutChange(localPlayer) then
				return
			end

			local value5 = data.Inventory.Toolbar[p2].Value
			local value6 = data.Inventory.Toolbar[p3].Value
			data.Inventory.Toolbar[p3].Value = value5
			data.Inventory.Toolbar[p2].Value = value6
			SignalEvent.ToServer("Toolbar_Equip", p3, value5, p2)
		end
	})
	local space = object:Space(function(state, p2, object3, object4, object5, object6, object7, object8, object9)
		local v6 = slotDragger.Dragging:Get()
		local v7 = slotDragger.Hover:Get()
		local lastState

		if v6 ~= state.Key and v7 == state.Key and v6 ~= nil then
			lastState = 4
		elseif v6 == state.Key then
			lastState = 5
		elseif v6 ~= nil then
			lastState = 3
		elseif value3:Compare(p2.Name) == true then
			lastState = 1
		elseif slotDragger.Hover:Compare(p2.Name) then
			lastState = 2
		else
			lastState = 3
		end

		if lastState ~= state.LastState then
			state.LastState = lastState

			if lastState == 1 then
				object5:Set(0.25)
				object6:Set(0)
				object7:Set(0)
				object8:Reset()
				object9:Reset()
			elseif lastState == 2 then
				object7:Set(0.45)
				object6:Set(0.3)
				object5:Set(0.75)
				object8:Reset()
				object9:Reset()
			elseif lastState == 4 then
				object8:Set(Color3.new(0.35, 0.35, 0.35))
				object7:Set(1)
				object6:Set(0)
				object5:Set(0)
				object9:Reset()
			elseif lastState == 5 then
				object8:Reset()
				object9:Set(0.65)
				object7:Set(1)
				object6:Set(1)
				object5:Set(1)
			else
				object9:Reset()
				object8:Reset()
				object7:Reset()
				object6:Reset()
				object5:Reset()
			end
		end

		local lastNew = p2.Value

		if lastNew ~= state.LastNew or state.LastNewIsStyle == true then
			local v9 = false
			local v10 = ""
			state.LastNewIsStyle = false

			if lastNew ~= nil then
				local item = Character_info_provider.GetItemFromId(localPlayer, lastNew)

				if item ~= nil then
					v9 = object2:Compare(item)
					v10 = ItemIcon.For(localPlayer, item.Name)
					state.LastNewIsStyle = item.Name == FightingStyles.TOOL_NAME
				end
			end

			object3:Set(v9)
			object4:Set(v10)
			state.LastNew = lastNew
		end
	end)

	for _, v6 in pairs(v) do
		space:Connect(v6.Changed, v6.Name)
	end

	space:Connect(value3.Changed)
	space:Connect(object2.Changed)
	object:Connect(object2.Changed, updItems)
	space:Connect(slotDragger.Dragging.Changed)
	space:Connect(slotDragger.Hover.Changed)
	space:Connect(data.Powers.FightingStyle.Changed)
	space:Connect(data.Race.Changed)
	local v6 = Platform_Handler.Platform.Value == "Mobile" and 1.4 or 1
	return object:Create("Frame")({
		Size = UDim2.fromScale(0.6, 1),
		BackgroundTransparency = 1,
		object:Create("Frame")({
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromScale(v6, v6 * 0.4),
			object:Create("UIListLayout")({
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.Name,
				Padding = UDim.new(0.05, 0)
			}),
			object:Iterate(v, function(_, p2, p3)
				return Slot(p3, p2, value3, object2, space, slotDragger, onSlotClicked)
			end)
		}),
		object:State(function(callback, object3)
			if callback(value4) then
				return object3:Create("CanvasGroup")({
					Name = "ButtonGroup",
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.fromScale(0.5, (v6 - 1) * 0.4 + 0.7),
					Size = UDim2.fromScale(0.28, 0.4),
					BackgroundTransparency = 1,
					GroupTransparency = object3:Animation(0, info),
					OnClean = function()
						return {
							GroupTransparency = object3:Animation(1, info)
						}
					end,
					GradientButton(object3, {
						Properties = {
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(0.9, 1)
						},
						GradientTransparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0),
							NumberSequenceKeypoint.new(0.75, 0.5),
							NumberSequenceKeypoint.new(1, 0.5)
						}),
						TextXAlignment = Enum.TextXAlignment.Center,
						Clicked = function()
							local v7 = object2:Get()

							if v7 == nil and flag then
								return
							end

							local v8 = value3:Get()
							local v9 = v7 == nil and 0 or v7.Id.Value or 0

							if v8 ~= "" then
								if flag then
									SignalEvent.ToServer("Toolbar_Equip", v8, v9)
								else
									SignalEvent.ToServer("Toolbar_Equip", v8, 0)
								end
							end
						end,
						BgColor = object3:Animation(value, info),
						GradientRotation = -90,
						Text = text,
						ContentColor = Color3.new(1, 1, 1)
					})
				})
			end
		end)
	})
end