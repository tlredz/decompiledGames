local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")
local localPlayer = Players.LocalPlayer
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local modules = ReplicatedStorage:WaitForChild("Modules")
local sound_Effect = ReplicatedStorage:WaitForChild("Sound_Effect")
local tradeEvents = otherEvent:WaitForChild("TradeEvents")
local custom_Channels = TextChatService:WaitForChild("Custom_Channels")
local trade = tradeEvents:WaitForChild("Trade")
local trade_Event = tradeEvents:WaitForChild("Trade_Event")
tradeEvents:WaitForChild("Trade_Chat")
local guiEvent = otherEvent.GuiEvents:WaitForChild("GuiEvent")
require(modules:WaitForChild("FrameTrigger"))
local ItemInfo = require(moduleScript:WaitForChild("ItemInfo"))
local Translate = require(moduleScript:WaitForChild("Translate"))
local ColorTable = require(moduleScript:WaitForChild("ColorTable"))
local SetText = require(moduleScript:WaitForChild("SetText"))
local Abbreviate = require(moduleScript:WaitForChild("Abbreviate"))
local Untradeable_Items = require(moduleScript:WaitForChild("Untradeable_Items"))
local rarity = ItemInfo.Rarity
local icon = ItemInfo.Icon
local item = ColorTable.Item
local _ = ColorTable.Boarder
local _ = ColorTable.EquipBoarder
local weapon = rarity.Weapon
local accessory = rarity.Accessory
local power = rarity.Power
local item2 = rarity.Item
local parent = script.Parent
local item_Template = script:WaitForChild("Item_Template")
local myMessage = script:WaitForChild("MyMessage")
local theirMessage = script:WaitForChild("TheirMessage")
local frame = parent:WaitForChild("Frame")
local container_Frame = frame:WaitForChild("Container_Frame")
local countdown_Frame = frame:WaitForChild("Countdown_Frame")
local myItem_Frame = frame:WaitForChild("MyItem_Frame")
local currency_Frame = frame:WaitForChild("Currency_Frame")
local theirCurrency_Frame = frame:WaitForChild("TheirCurrency_Frame")
local myOffer_Frame = frame:WaitForChild("MyOffer_Frame")
local myName = frame:WaitForChild("MyName")
local theirOffer_Frame = frame:WaitForChild("TheirOffer_Frame")
local theirName = frame:WaitForChild("TheirName")
local myStatus = frame:WaitForChild("MyStatus")
local theirStatus = frame:WaitForChild("TheirStatus")
local amount_Frame = frame:WaitForChild("Amount_Frame")
local chat_Frame = frame:WaitForChild("Chat_Frame")
local chatToggle = frame:WaitForChild("ChatToggle")
local ready = frame:WaitForChild("Ready")
local decline = frame:WaitForChild("Decline")
local countdown = frame:WaitForChild("Countdown")
local countdownTitle = frame:WaitForChild("CountdownTitle")
local icon2 = frame:WaitForChild("Icon")
local addFrame = amount_Frame:WaitForChild("AddFrame")
local removeFrame = amount_Frame:WaitForChild("RemoveFrame")
local add = addFrame:WaitForChild("Add")
local remove = removeFrame:WaitForChild("Remove")
local item3 = amount_Frame:WaitForChild("Item")
local min = amount_Frame:WaitForChild("Min")
local max = amount_Frame:WaitForChild("Max")
local slideFrame = amount_Frame:WaitForChild("SlideFrame")
local outofStock = amount_Frame:WaitForChild("OutofStock")
local amountText = amount_Frame:WaitForChild("AmountText")
local chat_Input = chat_Frame:WaitForChild("Chat_Input")
local container = chat_Frame:WaitForChild("Container")
local weapon2 = myItem_Frame:WaitForChild("Weapon")
local accessory2 = myItem_Frame:WaitForChild("Accessory")
local power2 = myItem_Frame:WaitForChild("Power")
local item4 = myItem_Frame:WaitForChild("Item")
local gem_Input = currency_Frame.Display.Gem_Input
local money_Input = currency_Frame.Display.Money_Input
local gem_Input2 = theirCurrency_Frame.Display.Gem_Input
local money_Input2 = theirCurrency_Frame.Display.Money_Input
local input = amount_Frame.InputFrame.Input
local chat = chat_Input.Chat
local send_Button = chat_Input.Send_Button
local unreadMessages = chatToggle.UnreadMessages
local messageAmount = unreadMessages.MessageAmount
local playerData = localPlayer:WaitForChild("PlayerData", 60)
local items = localPlayer:WaitForChild("Items", 60)
local swordEquip = playerData:WaitForChild("SwordEquip")
local accessoryEquip = playerData:WaitForChild("AccessoryEquip")
local gem = playerData:WaitForChild("Gem")
local money = playerData:WaitForChild("Money")
local weapon3 = items:WaitForChild("Weapon")
local accessory3 = items:WaitForChild("Accessory")
local power3 = items:WaitForChild("Power")
local itemStorage = items:WaitForChild("ItemStorage")
local flag = false
local renderSteppedConnection = nil
local child = nil
local messageReceivedConnection = nil
local headShot = Enum.ThumbnailType.HeadShot
local size420x420 = Enum.ThumbnailSize.Size420x420
local notification2 = sound_Effect:WaitForChild("Notification2")
local v = {
	Exclusive = 1,
	Legendary = 2,
	Rare = 3,
	Uncommon = 4,
	Common = 5
}
local connections = {}
local renderSteppedConnection2 = nil
local lastTime = tick()
local _ = UserInputService.TouchEnabled == true

local function getLayoutOrder(p)
	return v[p]
end

local function canPlayersChat(_, p)
	return (trade:InvokeServer({
		Action = "CheckCan_Chat",
		Trader = p.UserId
	}))
end

local function SetColor_State(ready2, p: string)
	if p == "Ready" then
		ready2.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(63, 240, 148)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 126, 93))
		})
		ready2.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(63, 240, 148)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 126, 93))
		})
		ready2.Textlabel.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(63, 240, 148)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 126, 93))
		})
		ready2.Colours.Pattern.ImageColor3 = Color3.fromRGB(25, 74, 36)
	elseif p == "Cancel" then
		ready2.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(229, 92, 92)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(163, 38, 38))
		})
		ready2.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(229, 92, 92)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(163, 38, 38))
		})
		ready2.Textlabel.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(229, 92, 92)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(163, 38, 38))
		})
		ready2.Colours.Pattern.ImageColor3 = Color3.fromRGB(66, 26, 26)
	elseif p == "Unready" then
		ready2.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 138, 43)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 63, 20))
		})
		ready2.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 138, 43)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 63, 20))
		})
		ready2.Textlabel.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 138, 43)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 63, 20))
		})
		ready2.Colours.Pattern.ImageColor3 = Color3.fromRGB(74, 38, 12)
	end
end

local function TextColor(p, p2)
	if p and p2 then
		return (`<font color="rgb({p2})">{p}</font>`)
	end
end

local function CleanUp()
	for _, button in ipairs(myOffer_Frame.MyOffer:GetChildren()) do
		if button:IsA("GuiButton") then
			button:Destroy()
		end
	end

	for _, button in ipairs(theirOffer_Frame.TheirOffer:GetChildren()) do
		if button:IsA("GuiButton") then
			button:Destroy()
		end
	end

	for _, button in ipairs(weapon2:GetChildren()) do
		if button:IsA("GuiButton") then
			button:Destroy()
		end
	end

	for _, button in ipairs(accessory2:GetChildren()) do
		if button:IsA("GuiButton") then
			button:Destroy()
		end
	end

	for _, button in ipairs(power2:GetChildren()) do
		if button:IsA("GuiButton") then
			button:Destroy()
		end
	end

	for _, button in ipairs(item4:GetChildren()) do
		if button:IsA("GuiButton") then
			button:Destroy()
		end
	end

	for _, frame2 in ipairs(container:GetChildren()) do
		if frame2:IsA("Frame") then
			frame2:Destroy()
		end
	end

	for _, scrollingFrame in ipairs(myItem_Frame:GetChildren()) do
		if not scrollingFrame:IsA("ScrollingFrame") then
			continue
		end

		scrollingFrame.Visible = false
		scrollingFrame.CanvasPosition = Vector2.new(0, 0)
	end

	for _, connection in ipairs(connections) do
		if connection then
			connection:Disconnect()
		end
	end

	table.clear(connections)

	if renderSteppedConnection2 then
		renderSteppedConnection2:Disconnect()
		renderSteppedConnection2 = nil
	end

	weapon2.Visible = true

	if localPlayer:GetAttribute("TH") then
		ready.Textlabel.Text = "พร้อม!"
	else
		ready.Textlabel.Text = "Ready!"
	end

	SetColor_State(ready, "Ready")
	chat.Text = ""
	messageAmount:SetAttribute("Amount", 0)
	unreadMessages.Visible = false
	chat_Frame.Visible = false
	container_Frame.Visible = true
	icon2.Visible = true
	myItem_Frame.Visible = true
	countdown.Visible = false
	countdownTitle.Visible = false
	myOffer_Frame.Visible = false
	amount_Frame.Visible = false
	countdown_Frame.Visible = false
	item3.Value = nil

	if localPlayer:GetAttribute("TH") then
		myStatus.Text = "สถานะ : ยังไม่พร้อม."
		theirStatus.Text = "สถานะ : ยังไม่พร้อม."
	else
		myStatus.Text = "Status: Not ready."
		theirStatus.Text = "Status: Not ready."
	end

	myStatus.TextColor3 = Color3.fromRGB(236, 83, 83)
	theirStatus.TextColor3 = Color3.fromRGB(236, 83, 83)
	myOffer_Frame.MyOffer.CanvasPosition = Vector2.new(0, 0)
	theirOffer_Frame.TheirOffer.CanvasPosition = Vector2.new(0, 0)
	myItem_Frame.Weapon.CanvasPosition = Vector2.new(0, 0)
	myItem_Frame.Accessory.CanvasPosition = Vector2.new(0, 0)
	myItem_Frame.Power.CanvasPosition = Vector2.new(0, 0)
	myItem_Frame.Item.CanvasPosition = Vector2.new(0, 0)
	container.CanvasSize = UDim2.new(0, 0, 0, 0)
	container.CanvasPosition = Vector2.new(0, 0)
	container.UIGridLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	gem_Input:SetAttribute("RealInput", 0)
	money_Input:SetAttribute("RealInput", 0)
	input.Text = "1"
	gem_Input.PlaceholderText = "0"
	gem_Input.Text = "0"
	money_Input.PlaceholderText = "0"
	money_Input.Text = "0"
	gem_Input2.Text = "0"
	money_Input2.Text = "0"
end

local function ActiveAmount_Frame(itemType, p, _: number)
	if itemType == "Weapon" then
		if amount_Frame.Visible == true and item3.Value == p then
			amount_Frame.Visible = false
			return
		end

		item3.Value = p
		local v2 = UserInputService:GetMouseLocation() - frame.AbsolutePosition
		amount_Frame.Position = UDim2.new(0, v2.X + amount_Frame.AbsoluteSize.X / 2.25, 0, v2.Y)
		amount_Frame.Visible = true
		local child2

		if item3.Value then
			child2 = weapon3:FindFirstChild(item3.Value.Name)
		end

		if item3.Value and child2 then
			max.Text = child2.Value - item3.Value:GetAttribute("OfferAmount")
		end

		if tonumber(max.Text) > 0 then
			input.Parent.Visible = true
			add.Visible = true
			remove.Visible = true
			removeFrame.Position = UDim2.new(0.725, 0, 0.775, 0)
			slideFrame.Visible = true
			min.Visible = true
			max.Visible = true
			amountText.Visible = true
			outofStock.Visible = false
			local number = Abbreviate.GetNumber(input.Text)

			if number and tonumber(max.Text) < number then
				input.Text = max.Text
			end

			local v3

			if number then
				v3 = math.clamp(math.clamp(number - 1, 0, 999) / (math.clamp(tonumber(max.Text), 2, 999) - 1), 0, 1)
			else
				v3 = math.clamp(0 / (math.clamp(tonumber(max.Text), 2, 999) - 1), 0, 1)
			end

			TweenService:Create(slideFrame.Slide, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
				Position = UDim2.new(
					math.clamp(v3, 0, 1),
					0,
					slideFrame.Slide.Position.Y.Scale,
					slideFrame.Slide.Position.Y.Offset
				)
			}):Play()
			TweenService:Create(slideFrame.Bar, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
				Size = UDim2.new(math.clamp(v3, 0, 1), 0, 1, 0)
			}):Play()
		else
			input.Parent.Visible = false
			add.Visible = false
			slideFrame.Visible = false
			min.Visible = false
			max.Visible = false
			amountText.Visible = false
			removeFrame.Position = UDim2.new(0.5, 0, 0.775, 0)
			remove.Visible = true
			outofStock.Visible = true
		end
	elseif itemType == "Accessory" then
		if amount_Frame.Visible == true and item3.Value == p then
			amount_Frame.Visible = false
			return
		end

		item3.Value = p
		local v2 = UserInputService:GetMouseLocation() - frame.AbsolutePosition
		amount_Frame.Position = UDim2.new(0, v2.X + amount_Frame.AbsoluteSize.X / 2.25, 0, v2.Y)
		amount_Frame.Visible = true
		local child2

		if item3.Value then
			child2 = accessory3:FindFirstChild(item3.Value.Name)
		end

		if item3.Value and child2 then
			max.Text = child2.Value - item3.Value:GetAttribute("OfferAmount")
		end

		if tonumber(max.Text) > 0 then
			input.Parent.Visible = true
			add.Visible = true
			remove.Visible = true
			removeFrame.Position = UDim2.new(0.725, 0, 0.775, 0)
			slideFrame.Visible = true
			min.Visible = true
			max.Visible = true
			amountText.Visible = true
			outofStock.Visible = false
			local number = Abbreviate.GetNumber(input.Text)

			if number and tonumber(max.Text) < number then
				input.Text = max.Text
			end

			local v3

			if number then
				v3 = math.clamp(math.clamp(number - 1, 0, 999) / (math.clamp(tonumber(max.Text), 2, 999) - 1), 0, 1)
			else
				v3 = math.clamp(0 / (math.clamp(tonumber(max.Text), 2, 999) - 1), 0, 1)
			end

			TweenService:Create(slideFrame.Slide, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
				Position = UDim2.new(
					math.clamp(v3, 0, 1),
					0,
					slideFrame.Slide.Position.Y.Scale,
					slideFrame.Slide.Position.Y.Offset
				)
			}):Play()
			TweenService:Create(slideFrame.Bar, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
				Size = UDim2.new(math.clamp(v3, 0, 1), 0, 1, 0)
			}):Play()
		else
			input.Parent.Visible = false
			add.Visible = false
			slideFrame.Visible = false
			min.Visible = false
			max.Visible = false
			amountText.Visible = false
			removeFrame.Position = UDim2.new(0.5, 0, 0.775, 0)
			remove.Visible = true
			outofStock.Visible = true
		end
	elseif itemType == "Power" then
		if amount_Frame.Visible == true and item3.Value == p then
			amount_Frame.Visible = false
			return
		end

		item3.Value = p
		local v2 = UserInputService:GetMouseLocation() - frame.AbsolutePosition
		amount_Frame.Position = UDim2.new(0, v2.X + amount_Frame.AbsoluteSize.X / 2.25, 0, v2.Y)
		amount_Frame.Visible = true
		local child2

		if item3.Value then
			child2 = power3:FindFirstChild(item3.Value.Name)
		end

		if item3.Value and child2 then
			max.Text = child2.Value - item3.Value:GetAttribute("OfferAmount")
		end

		if tonumber(max.Text) > 0 then
			input.Parent.Visible = true
			add.Visible = true
			remove.Visible = true
			removeFrame.Position = UDim2.new(0.725, 0, 0.775, 0)
			slideFrame.Visible = true
			min.Visible = true
			max.Visible = true
			amountText.Visible = true
			outofStock.Visible = false
			local number = Abbreviate.GetNumber(input.Text)

			if number and tonumber(max.Text) < number then
				input.Text = max.Text
			end

			local v3

			if number then
				v3 = math.clamp(math.clamp(number - 1, 0, 999) / (math.clamp(tonumber(max.Text), 2, 999) - 1), 0, 1)
			else
				v3 = math.clamp(0 / (math.clamp(tonumber(max.Text), 2, 999) - 1), 0, 1)
			end

			TweenService:Create(slideFrame.Slide, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
				Position = UDim2.new(
					math.clamp(v3, 0, 1),
					0,
					slideFrame.Slide.Position.Y.Scale,
					slideFrame.Slide.Position.Y.Offset
				)
			}):Play()
			TweenService:Create(slideFrame.Bar, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
				Size = UDim2.new(math.clamp(v3, 0, 1), 0, 1, 0)
			}):Play()
		else
			input.Parent.Visible = false
			add.Visible = false
			slideFrame.Visible = false
			min.Visible = false
			max.Visible = false
			amountText.Visible = false
			removeFrame.Position = UDim2.new(0.5, 0, 0.775, 0)
			remove.Visible = true
			outofStock.Visible = true
		end
	elseif itemType == "Item" then
		if amount_Frame.Visible == true and item3.Value == p then
			amount_Frame.Visible = false
			return
		end

		item3.Value = p
		local v2 = UserInputService:GetMouseLocation() - frame.AbsolutePosition
		amount_Frame.Position = UDim2.new(0, v2.X + amount_Frame.AbsoluteSize.X / 2.25, 0, v2.Y)
		amount_Frame.Visible = true
		local child2

		if item3.Value then
			child2 = itemStorage:FindFirstChild(item3.Value.Name)
		end

		if item3.Value and child2 then
			max.Text = child2.Value - item3.Value:GetAttribute("OfferAmount")
		end

		if tonumber(max.Text) > 0 then
			input.Parent.Visible = true
			add.Visible = true
			remove.Visible = true
			removeFrame.Position = UDim2.new(0.725, 0, 0.775, 0)
			slideFrame.Visible = true
			min.Visible = true
			max.Visible = true
			amountText.Visible = true
			outofStock.Visible = false
			local number = Abbreviate.GetNumber(input.Text)

			if number and tonumber(max.Text) < number then
				input.Text = max.Text
			end

			local v3

			if number then
				v3 = math.clamp(math.clamp(number - 1, 0, 999) / (math.clamp(tonumber(max.Text), 2, 999) - 1), 0, 1)
			else
				v3 = math.clamp(0 / (math.clamp(tonumber(max.Text), 2, 999) - 1), 0, 1)
			end

			TweenService:Create(slideFrame.Slide, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
				Position = UDim2.new(
					math.clamp(v3, 0, 1),
					0,
					slideFrame.Slide.Position.Y.Scale,
					slideFrame.Slide.Position.Y.Offset
				)
			}):Play()
			TweenService:Create(slideFrame.Bar, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
				Size = UDim2.new(math.clamp(v3, 0, 1), 0, 1, 0)
			}):Play()
		else
			input.Parent.Visible = false
			add.Visible = false
			slideFrame.Visible = false
			min.Visible = false
			max.Visible = false
			amountText.Visible = false
			removeFrame.Position = UDim2.new(0.5, 0, 0.775, 0)
			remove.Visible = true
			outofStock.Visible = true
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Item_Tradeable(p: string)
	return not (p and table.find(Untradeable_Items, p))
end

local function GenerateOffer(data, parent2)
	local itemType = data.ItemType
	local itemName = data.ItemName

	if itemType == "Weapon" then
		local child2 = parent2:FindFirstChild(itemName)

		if child2 then
			local v2 = string.gsub(child2.Amount.Text, "%D+", "")

			if v2 then
				local v3 = v2 + data.ItemAmount

				if v3 > 0 then
					child2.Amount.Text = `x{v3}`

					if parent2.Name == "MyOffer" and item3.Value then
						item3.Value:SetAttribute("OfferAmount", v3)
					end
				end
			end
		else
			local clone = item_Template:Clone()
			clone.Name = itemName
			clone.ItemName.Text = itemName
			clone.Amount.Text = `x{data.ItemAmount}`

			if localPlayer:GetAttribute("TH") then
				clone.ItemType.Text = Translate.Weapon
			else
				clone.ItemType.Text = "Weapon"
			end

			clone.BackgroundColor3 = item[weapon[itemName]]
			clone.Icon.Image = icon[itemName]
			clone.Board.ImageColor3 = item[weapon[itemName]]
			clone.Name_Board.ImageColor3 = item[weapon[itemName]]
			clone.LayoutOrder = #parent2:GetChildren()
			clone.Amount.Visible = true
			clone.Visible = true
			clone.Parent = parent2

			if parent2.Name == "MyOffer" and item3.Value then
				item3.Value:SetAttribute("OfferAmount", data.ItemAmount)
			end
		end
	elseif itemType == "Accessory" then
		local child2 = parent2:FindFirstChild(itemName)

		if child2 then
			local v2 = string.gsub(child2.Amount.Text, "%D+", "")

			if v2 then
				local v3 = v2 + data.ItemAmount

				if v3 > 0 then
					child2.Amount.Text = `x{v3}`

					if parent2.Name == "MyOffer" and item3.Value then
						item3.Value:SetAttribute("OfferAmount", v3)
					end
				end
			end
		else
			local clone = item_Template:Clone()
			clone.Name = itemName
			clone.ItemName.Text = itemName
			clone.Amount.Text = `x{data.ItemAmount}`

			if localPlayer:GetAttribute("TH") then
				clone.ItemType.Text = Translate.Accessory
			else
				clone.ItemType.Text = "Accessory"
			end

			clone.BackgroundColor3 = item[accessory[itemName]]
			clone.Icon.Image = icon[itemName]
			clone.Board.ImageColor3 = item[accessory[itemName]]
			clone.Name_Board.ImageColor3 = item[accessory[itemName]]
			clone.LayoutOrder = #parent2:GetChildren()
			clone.Amount.Visible = true
			clone.Visible = true
			clone.Parent = parent2

			if parent2.Name == "MyOffer" and item3.Value then
				item3.Value:SetAttribute("OfferAmount", data.ItemAmount)
			end
		end
	elseif itemType == "Power" then
		local child2 = parent2:FindFirstChild(itemName)

		if child2 then
			local v2 = string.gsub(child2.Amount.Text, "%D+", "")

			if v2 then
				local v3 = v2 + data.ItemAmount

				if v3 > 0 then
					child2.Amount.Text = `x{v3}`

					if parent2.Name == "MyOffer" and item3.Value then
						item3.Value:SetAttribute("OfferAmount", v3)
					end
				end
			end
		else
			local clone = item_Template:Clone()
			clone.Name = itemName
			clone.ItemName.Text = itemName
			clone.Amount.Text = `x{data.ItemAmount}`

			if localPlayer:GetAttribute("TH") then
				clone.ItemType.Text = Translate.Power
			else
				clone.ItemType.Text = "Power"
			end

			clone.BackgroundColor3 = item[power[itemName]]
			clone.Icon.Image = icon[itemName]
			clone.Icon.ImageColor3 = Color3.fromRGB(235, 233, 227)
			clone.Board.ImageColor3 = item[power[itemName]]
			clone.Name_Board.ImageColor3 = item[power[itemName]]
			clone.LayoutOrder = #parent2:GetChildren()
			clone.Amount.Visible = true
			clone.Visible = true
			clone.Parent = parent2

			if parent2.Name == "MyOffer" and item3.Value then
				item3.Value:SetAttribute("OfferAmount", data.ItemAmount)
			end
		end
	elseif itemType == "Item" then
		local child2 = parent2:FindFirstChild(itemName)

		if child2 then
			local v2 = string.gsub(child2.Amount.Text, "%D+", "")

			if v2 then
				local v3 = v2 + data.ItemAmount

				if v3 > 0 then
					child2.Amount.Text = `x{v3}`

					if parent2.Name == "MyOffer" and item3.Value then
						item3.Value:SetAttribute("OfferAmount", v3)
					end
				end
			end
		else
			local clone = item_Template:Clone()
			clone.Name = itemName
			clone.ItemName.Text = itemName
			clone.Amount.Text = `x{data.ItemAmount}`

			if localPlayer:GetAttribute("TH") then
				clone.ItemType.Text = Translate.Item
			else
				clone.ItemType.Text = "Item"
			end

			clone.BackgroundColor3 = item[item2[itemName]]
			clone.Icon.Image = icon[itemName]
			clone.Board.ImageColor3 = item[item2[itemName]]
			clone.Name_Board.ImageColor3 = item[item2[itemName]]
			clone.LayoutOrder = #parent2:GetChildren()
			clone.Amount.Visible = true
			clone.Visible = true
			clone.Parent = parent2

			if parent2.Name == "MyOffer" and item3.Value then
				item3.Value:SetAttribute("OfferAmount", data.ItemAmount)
			end
		end
	elseif itemType == "Gem" then
		if tonumber(itemName) and tonumber(itemName) < 1000000000 then
			gem_Input2.Text = `{Abbreviate.Comma(itemName)}`
		else
			gem_Input2.Text = `{Abbreviate.ShowNum(itemName)}`
		end
	elseif itemType == "Money" then
		if tonumber(itemName) and tonumber(itemName) < 1000000000 then
			money_Input2.Text = `{Abbreviate.Comma(itemName)}`
		else
			money_Input2.Text = `{Abbreviate.ShowNum(itemName)}`
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StartSliding(p)
	if flag == false then
		if renderSteppedConnection then
			renderSteppedConnection:Disconnect()
			renderSteppedConnection = nil
		end

		flag = true
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			if flag then
				local X = UserInputService:GetMouseLocation().X
				local X2 = p.AbsoluteSize.X
				local v2 = math.clamp((X - p.AbsolutePosition.X) / X2, 0, 1)
				local v3 = math.floor(tonumber(max.Text) * v2 + 1)

				if input.Text ~= math.clamp(v3, 1, (tonumber(max.Text))) then
					input.Text = math.clamp(v3, 1, (tonumber(max.Text)))
				end
			elseif renderSteppedConnection then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			end
		end)
	end
end

local function ForceSlide(p)
	local X = UserInputService:GetMouseLocation().X
	local X2 = p.AbsoluteSize.X
	local v2 = math.clamp((X - p.AbsolutePosition.X) / X2, 0, 1)
	local text = math.floor((tonumber(max.Text) - 1) * v2 + 1)

	if input.Text ~= text then
		input.Text = text
	end
end

local function RemoveItem(instance, p)
	local child2 = myOffer_Frame.MyOffer:FindFirstChild(instance.Name)

	-- [DEDUP] synthesized from 3 duplicated terminal regions
	local function deduplicatedTail()
		if localPlayer:GetAttribute("TH") then
			local setText = SetText.SetText
			local formatted = `&lt;{instance.Name}&gt;`
			local v6

			if formatted then
				v6 = `<font color="rgb(255,100,100)">{formatted}</font>`
			end

			setText(localPlayer, "CustomMessage", {
				Message = `ลบ {v6} ออกจากข้อเสนอของคุณแล้ว.`
			})
		else
			local setText = SetText.SetText
			local formatted = `&lt;{instance.Name}&gt;`
			local v6

			if formatted then
				v6 = `<font color="rgb(255,100,100)">{formatted}</font>`
			end

			setText(localPlayer, "CustomMessage", {
				Message = `Removed {v6} from your offer.`
			})
		end

		instance:SetAttribute("OfferAmount", 0)
		child2:Destroy()
	end

	if p.Name == "Weapon" and child2 then
		trade_Event:FireServer({
			Action = "Remove_Item",
			Removing_Item = instance.Name
		})
		local child3 = weapon3:FindFirstChild(instance.Name)

		if not child3 then
			return deduplicatedTail()
		end

		instance.Amount.Text = `x{child3.Value}`

		if child3.Value > 0 then
			if instance.Check.Visible then
				instance.Check.Visible = false
			end

			if child3.Value > 1 then
				if instance.Amount.Visible == false then
					instance.Amount.Visible = true
				end
			elseif instance.Amount.Visible == true then
				instance.Amount.Visible = false
			end
		else
			if instance.Check.Visible == false then
				instance.Check.Visible = true
			end

			if instance.Amount.Visible then
				instance.Amount.Visible = false
			end
		end

		return deduplicatedTail()
	elseif p.Name == "Accessory" and child2 then
		trade_Event:FireServer({
			Action = "Remove_Item",
			Removing_Item = instance.Name
		})
		local child3 = accessory3:FindFirstChild(instance.Name)

		if not child3 then
			return deduplicatedTail()
		end

		instance.Amount.Text = `x{child3.Value}`

		if child3.Value > 0 then
			if instance.Check.Visible then
				instance.Check.Visible = false
			end

			if child3.Value > 1 then
				if instance.Amount.Visible == false then
					instance.Amount.Visible = true
				end
			elseif instance.Amount.Visible == true then
				instance.Amount.Visible = false
			end
		else
			if instance.Check.Visible == false then
				instance.Check.Visible = true
			end

			if instance.Amount.Visible then
				instance.Amount.Visible = false
			end
		end

		return deduplicatedTail()
	elseif p.Name == "Power" and child2 then
		trade_Event:FireServer({
			Action = "Remove_Item",
			Removing_Item = instance.Name
		})
		local child3 = power3:FindFirstChild(instance.Name)

		if not child3 then
			return deduplicatedTail()
		end

		instance.Amount.Text = `x{child3.Value}`

		if child3.Value > 0 then
			if instance.Check.Visible then
				instance.Check.Visible = false
			end

			if instance.Amount.Visible == false then
				instance.Amount.Visible = true
			end
		else
			if instance.Check.Visible == false then
				instance.Check.Visible = true
			end

			if instance.Amount.Visible then
				instance.Amount.Visible = false
			end
		end

		return deduplicatedTail()
	elseif p.Name == "Item" and child2 then
		trade_Event:FireServer({
			Action = "Remove_Item",
			Removing_Item = instance.Name
		})
		local child3 = itemStorage:FindFirstChild(instance.Name)

		if child3 then
			instance.Amount.Text = `x{child3.Value}`

			if child3.Value > 0 then
				if instance.Check.Visible then
					instance.Check.Visible = false
				end

				if instance.Amount.Visible == false then
					instance.Amount.Visible = true
				end
			else
				if instance.Check.Visible == false then
					instance.Check.Visible = true
				end

				if instance.Amount.Visible then
					instance.Amount.Visible = false
				end
			end
		end

		if localPlayer:GetAttribute("TH") then
			local setText = SetText.SetText
			local formatted = `&lt;{instance.Name}&gt;`
			local v6

			if formatted then
				v6 = `<font color="rgb(255,100,100)">{formatted}</font>`
			end

			setText(localPlayer, "CustomMessage", {
				Message = `ลบ {v6} ออกจากข้อเสนอของคุณแล้ว.`
			})
		else
			local setText = SetText.SetText
			local formatted = `&lt;{instance.Name}&gt;`
			local v6

			if formatted then
				v6 = `<font color="rgb(255,100,100)">{formatted}</font>`
			end

			setText(localPlayer, "CustomMessage", {
				Message = `Removed {v6} from your offer.`
			})
		end

		instance:SetAttribute("OfferAmount", 0)
		child2:Destroy()
	end
end

local function RemoveButton_Function(button)
	if button and button:IsA("GuiButton") then
		if button:GetAttribute("ItemType") == "Weapon" then
			RemoveItem(button, weapon2)
		elseif button:GetAttribute("ItemType") == "Accessory" then
			RemoveItem(button, accessory2)
		elseif button:GetAttribute("ItemType") == "Power" then
			RemoveItem(button, power2)
		elseif button:GetAttribute("ItemType") == "Item" then
			RemoveItem(button, item4)
		end
	else
		if item3.Value then
			if item3.Value:GetAttribute("ItemType") == "Weapon" then
				RemoveItem(item3.Value, weapon2)
			elseif item3.Value:GetAttribute("ItemType") == "Accessory" then
				RemoveItem(item3.Value, accessory2)
			elseif item3.Value:GetAttribute("ItemType") == "Power" then
				RemoveItem(item3.Value, power2)
			elseif item3.Value:GetAttribute("ItemType") == "Item" then
				RemoveItem(item3.Value, item4)
			end
		end

		amount_Frame.Visible = false
	end
end

local function GenerateItems(trader)
	if trader:FindFirstChild("Items") then
		for _, child2 in ipairs(weapon3:GetChildren()) do
			if not (child2.Value > 0 and weapon[child2.Name]) then
				continue
			end

			local clone = item_Template:Clone()
			clone.Name = child2.Name
			clone.ItemName.Text = child2.Name

			if localPlayer:GetAttribute("TH") then
				clone.ItemType.Text = Translate.Weapon
			else
				clone.ItemType.Text = "Weapon"
			end

			if child2.Value > 1 then
				clone.Amount.Visible = true
				clone.Amount.Text = `x{child2.Value}`
			else
				clone.Amount.Visible = false
			end

			clone.BackgroundColor3 = item[weapon[child2.Name]]
			clone.Icon.Image = icon[child2.Name]
			clone.Board.ImageColor3 = item[weapon[child2.Name]]
			clone.Name_Board.ImageColor3 = item[weapon[child2.Name]]
			clone.LayoutOrder = v[weapon[child2.Name]]
			clone:SetAttribute("Rarity", weapon[child2.Name])
			clone:SetAttribute("OfferAmount", 0)
			clone:SetAttribute("ItemType", "Weapon")
			clone.Parent = weapon2
			clone.Visible = true
			local v4 = child2
			connections[#connections + 1] = clone.Activated:Connect(function()
				if Item_Tradeable(clone.Name) or localPlayer:GetAttribute("TradeBypass") then
					if swordEquip.Value == clone.Name then
						if localPlayer:GetAttribute("TH") then
							SetText.SetText(localPlayer, "CustomMessage", {
								Message = "คุณไม่สามารถแลกเปลี่ยนอาวุธที่ใช้งานอยู่ได้!",
								MessageColor = "Red"
							})
						else
							SetText.SetText(localPlayer, "CustomMessage", {
								Message = "You can't trade your equipped weapon!",
								MessageColor = "Red"
							})
						end
					else
						if v4.Value ~= 1 then
							ActiveAmount_Frame(clone:GetAttribute("ItemType"), clone, v4.Value)
							return
						end

						if myOffer_Frame.MyOffer:FindFirstChild(clone.Name) then
							RemoveButton_Function(clone)
							return
						end

						local v5 = v4.Value >= 1 + clone:GetAttribute("OfferAmount")

						if v4.Value >= 1 and v5 then
							GenerateOffer({
								ItemType = clone:GetAttribute("ItemType"),
								ItemName = clone.Name,
								ItemAmount = 1
							}, myOffer_Frame.MyOffer)
							trade_Event:FireServer({
								Action = "Add_Item",
								Item_Table = {
									ItemType = clone:GetAttribute("ItemType"),
									ItemName = clone.Name,
									ItemAmount = 1
								}
							})

							if localPlayer:GetAttribute("TH") then
								local setText = SetText.SetText
								local formatted = `&lt;{clone.Name}&gt;`
								local v10

								if formatted then
									v10 = `<font color="rgb(100,255,100)">{formatted}</font>`
								end

								setText(localPlayer, "CustomMessage", {
									Message = `เพิ่ม {v10} (x1) ลงในข้อเสนอของคุณแล้ว.`
								})
							else
								local setText = SetText.SetText
								local formatted = `&lt;{clone.Name}&gt;`
								local v10

								if formatted then
									v10 = `<font color="rgb(100,255,100)">{formatted}</font>`
								end

								setText(localPlayer, "CustomMessage", {
									Message = `Added {v10} (1x) to your offer.`
								})
							end

							local v6 = string.gsub(clone.Amount.Text, "%D+", "")

							if v6 then
								local v7 = v6 - 1
								clone.Amount.Text = `x{v7}`

								if v7 > 0 then
									if clone.Check.Visible then
										clone.Check.Visible = false
									end

									if clone.Amount.Visible == false then
										clone.Amount.Visible = true
									end
								else
									if clone.Check.Visible == false then
										clone.Check.Visible = true
									end

									if clone.Amount.Visible then
										clone.Amount.Visible = false
									end
								end
							end
						elseif localPlayer:GetAttribute("TH") then
							SetText.SetText(localPlayer, "CustomMessage", {
								Message = "คุณมีไอเทมไม่เพียงพอที่จะเพิ่มลงไปได้!",
								MessageColor = "Red"
							})
						else
							SetText.SetText(localPlayer, "CustomMessage", {
								Message = "You don't have enough items to add to your offer!",
								MessageColor = "Red"
							})
						end
					end
				elseif localPlayer:GetAttribute("TH") then
					SetText.SetText(localPlayer, "CustomMessage", {
						Message = "ไอเทมชิ้นนี้ไม่สามารถแลกเปลี่ยนได้!",
						MessageColor = "Red"
					})
				else
					SetText.SetText(localPlayer, "CustomMessage", {
						Message = "This item is untradeable!",
						MessageColor = "Red"
					})
				end
			end)
		end

		for _, child2 in ipairs(accessory3:GetChildren()) do
			if not (child2.Value > 0 and accessory[child2.Name]) then
				continue
			end

			local clone = item_Template:Clone()
			clone.Name = child2.Name
			clone.ItemName.Text = child2.Name

			if localPlayer:GetAttribute("TH") then
				clone.ItemType.Text = Translate.Accessory
			else
				clone.ItemType.Text = "Accessory"
			end

			if child2.Value > 1 then
				clone.Amount.Visible = true
				clone.Amount.Text = `x{child2.Value}`
			else
				clone.Amount.Visible = false
			end

			clone.BackgroundColor3 = item[accessory[child2.Name]]
			clone.Icon.Image = icon[child2.Name]
			clone.Name_Board.ImageColor3 = item[accessory[child2.Name]]
			clone.Board.ImageColor3 = item[accessory[child2.Name]]
			clone.LayoutOrder = v[accessory[child2.Name]]
			clone:SetAttribute("Rarity", accessory[child2.Name])
			clone:SetAttribute("OfferAmount", 0)
			clone:SetAttribute("ItemType", "Accessory")
			clone.Parent = accessory2
			clone.Visible = true
			local v4 = child2
			connections[#connections + 1] = clone.Activated:Connect(function()
				if Item_Tradeable(clone.Name) or localPlayer:GetAttribute("TradeBypass") then
					if accessoryEquip.Value == clone.Name then
						if localPlayer:GetAttribute("TH") then
							SetText.SetText(localPlayer, "CustomMessage", {
								Message = "คุณไม่สามารถแลกเปลี่ยนอุปกรณ์เสริมที่ใช้งานอยู่ได้!",
								MessageColor = "Red"
							})
						else
							SetText.SetText(localPlayer, "CustomMessage", {
								Message = "You can't trade your equipped accessory!",
								MessageColor = "Red"
							})
						end
					else
						if v4.Value ~= 1 then
							ActiveAmount_Frame(clone:GetAttribute("ItemType"), clone, v4.Value)
							return
						end

						if myOffer_Frame.MyOffer:FindFirstChild(clone.Name) then
							RemoveButton_Function(clone)
							return
						end

						local v5 = v4.Value >= 1 + clone:GetAttribute("OfferAmount")

						if v4.Value >= 1 and v5 then
							GenerateOffer({
								ItemType = clone:GetAttribute("ItemType"),
								ItemName = clone.Name,
								ItemAmount = 1
							}, myOffer_Frame.MyOffer)
							trade_Event:FireServer({
								Action = "Add_Item",
								Item_Table = {
									ItemType = clone:GetAttribute("ItemType"),
									ItemName = clone.Name,
									ItemAmount = 1
								}
							})

							if localPlayer:GetAttribute("TH") then
								local setText = SetText.SetText
								local formatted = `&lt;{clone.Name}&gt;`
								local v10

								if formatted then
									v10 = `<font color="rgb(100,255,100)">{formatted}</font>`
								end

								setText(localPlayer, "CustomMessage", {
									Message = `เพิ่ม {v10} (x1) ลงในข้อเสนอของคุณแล้ว.`
								})
							else
								local setText = SetText.SetText
								local formatted = `&lt;{clone.Name}&gt;`
								local v10

								if formatted then
									v10 = `<font color="rgb(100,255,100)">{formatted}</font>`
								end

								setText(localPlayer, "CustomMessage", {
									Message = `Added {v10} (1x) to your offer.`
								})
							end

							local v6 = string.gsub(clone.Amount.Text, "%D+", "")

							if v6 then
								local v7 = v6 - 1
								clone.Amount.Text = `x{v7}`

								if v7 > 0 then
									if clone.Check.Visible then
										clone.Check.Visible = false
									end

									if clone.Amount.Visible == false then
										clone.Amount.Visible = true
									end
								else
									if clone.Check.Visible == false then
										clone.Check.Visible = true
									end

									if clone.Amount.Visible then
										clone.Amount.Visible = false
									end
								end
							end
						elseif localPlayer:GetAttribute("TH") then
							SetText.SetText(localPlayer, "CustomMessage", {
								Message = "คุณมีไอเทมไม่เพียงพอที่จะเพิ่มลงไปได้!",
								MessageColor = "Red"
							})
						else
							SetText.SetText(localPlayer, "CustomMessage", {
								Message = "You don't have enough items to add to your offer!",
								MessageColor = "Red"
							})
						end
					end
				elseif localPlayer:GetAttribute("TH") then
					SetText.SetText(localPlayer, "CustomMessage", {
						Message = "ไอเทมชิ้นนี้ไม่สามารถแลกเปลี่ยนได้!",
						MessageColor = "Red"
					})
				else
					SetText.SetText(localPlayer, "CustomMessage", {
						Message = "This item is untradeable!",
						MessageColor = "Red"
					})
				end
			end)
		end

		for _, child2 in ipairs(power3:GetChildren()) do
			if not (child2.Value > 0 and power[child2.Name]) then
				continue
			end

			local clone = item_Template:Clone()
			clone.Name = child2.Name
			clone.ItemName.Text = child2.Name
			clone.Amount.Text = `x{child2.Value}`

			if localPlayer:GetAttribute("TH") then
				clone.ItemType.Text = Translate.Power
			else
				clone.ItemType.Text = "Power"
			end

			clone.BackgroundColor3 = item[power[child2.Name]]
			clone.Icon.Image = icon[child2.Name]
			clone.Icon.ImageColor3 = Color3.fromRGB(235, 233, 227)
			clone.Name_Board.ImageColor3 = item[power[child2.Name]]
			clone.Board.ImageColor3 = item[power[child2.Name]]
			clone.LayoutOrder = v[power[child2.Name]]
			clone:SetAttribute("Rarity", power[child2.Name])
			clone:SetAttribute("OfferAmount", 0)
			clone:SetAttribute("ItemType", "Power")
			clone.Amount.Visible = true
			clone.Parent = power2
			clone.Visible = true
			local v4 = child2
			connections[#connections + 1] = clone.Activated:Connect(function()
				if Item_Tradeable(clone.Name) or localPlayer:GetAttribute("TradeBypass") then
					if v4.Value ~= 1 then
						ActiveAmount_Frame(clone:GetAttribute("ItemType"), clone, v4.Value)
						return
					end

					if myOffer_Frame.MyOffer:FindFirstChild(clone.Name) then
						RemoveButton_Function(clone)
						return
					end

					local v5 = v4.Value >= 1 + clone:GetAttribute("OfferAmount")

					if v4.Value >= 1 and v5 then
						GenerateOffer({
							ItemType = clone:GetAttribute("ItemType"),
							ItemName = clone.Name,
							ItemAmount = 1
						}, myOffer_Frame.MyOffer)
						trade_Event:FireServer({
							Action = "Add_Item",
							Item_Table = {
								ItemType = clone:GetAttribute("ItemType"),
								ItemName = clone.Name,
								ItemAmount = 1
							}
						})

						if localPlayer:GetAttribute("TH") then
							local setText = SetText.SetText
							local formatted = `&lt;{clone.Name}&gt;`
							local v10

							if formatted then
								v10 = `<font color="rgb(100,255,100)">{formatted}</font>`
							end

							setText(localPlayer, "CustomMessage", {
								Message = `เพิ่ม {v10} (x1) ลงในข้อเสนอของคุณแล้ว.`
							})
						else
							local setText = SetText.SetText
							local formatted = `&lt;{clone.Name}&gt;`
							local v10

							if formatted then
								v10 = `<font color="rgb(100,255,100)">{formatted}</font>`
							end

							setText(localPlayer, "CustomMessage", {
								Message = `Added {v10} (1x) to your offer.`
							})
						end

						local v6 = string.gsub(clone.Amount.Text, "%D+", "")

						if v6 then
							local v7 = v6 - 1
							clone.Amount.Text = `x{v7}`

							if v7 > 0 then
								if clone.Check.Visible then
									clone.Check.Visible = false
								end

								if clone.Amount.Visible == false then
									clone.Amount.Visible = true
								end
							else
								if clone.Check.Visible == false then
									clone.Check.Visible = true
								end

								if clone.Amount.Visible then
									clone.Amount.Visible = false
								end
							end
						end
					elseif localPlayer:GetAttribute("TH") then
						SetText.SetText(localPlayer, "CustomMessage", {
							Message = "คุณมีไอเทมไม่เพียงพอที่จะเพิ่มลงไปได้!",
							MessageColor = "Red"
						})
					else
						SetText.SetText(localPlayer, "CustomMessage", {
							Message = "You don't have enough items to add to your offer!",
							MessageColor = "Red"
						})
					end
				elseif localPlayer:GetAttribute("TH") then
					SetText.SetText(localPlayer, "CustomMessage", {
						Message = "ไอเทมชิ้นนี้ไม่สามารถแลกเปลี่ยนได้!",
						MessageColor = "Red"
					})
				else
					SetText.SetText(localPlayer, "CustomMessage", {
						Message = "This item is untradeable!",
						MessageColor = "Red"
					})
				end
			end)
		end

		for _, child2 in ipairs(itemStorage:GetChildren()) do
			if not (child2.Value > 0 and item2[child2.Name]) then
				continue
			end

			local clone = item_Template:Clone()
			clone.Name = child2.Name
			clone.ItemName.Text = child2.Name
			clone.Amount.Text = `x{child2.Value}`

			if localPlayer:GetAttribute("TH") then
				clone.ItemType.Text = Translate.Item
			else
				clone.ItemType.Text = "Item"
			end

			clone.BackgroundColor3 = item[item2[child2.Name]]
			clone.Icon.Image = icon[child2.Name]
			clone.Name_Board.ImageColor3 = item[item2[child2.Name]]
			clone.Board.ImageColor3 = item[item2[child2.Name]]
			clone.LayoutOrder = v[item2[child2.Name]]
			clone:SetAttribute("Rarity", item2[child2.Name])
			clone:SetAttribute("OfferAmount", 0)
			clone:SetAttribute("ItemType", "Item")
			clone.Amount.Visible = true
			clone.Parent = item4
			clone.Visible = true
			local v4 = child2
			connections[#connections + 1] = clone.Activated:Connect(function()
				if Item_Tradeable(clone.Name) or localPlayer:GetAttribute("TradeBypass") then
					if v4.Value ~= 1 then
						ActiveAmount_Frame(clone:GetAttribute("ItemType"), clone, v4.Value)
						return
					end

					if myOffer_Frame.MyOffer:FindFirstChild(clone.Name) then
						RemoveButton_Function(clone)
						return
					end

					local v5 = v4.Value >= 1 + clone:GetAttribute("OfferAmount")

					if v4.Value >= 1 and v5 then
						GenerateOffer({
							ItemType = clone:GetAttribute("ItemType"),
							ItemName = clone.Name,
							ItemAmount = 1
						}, myOffer_Frame.MyOffer)
						trade_Event:FireServer({
							Action = "Add_Item",
							Item_Table = {
								ItemType = clone:GetAttribute("ItemType"),
								ItemName = clone.Name,
								ItemAmount = 1
							}
						})

						if localPlayer:GetAttribute("TH") then
							local setText = SetText.SetText
							local formatted = `&lt;{clone.Name}&gt;`
							local v10

							if formatted then
								v10 = `<font color="rgb(100,255,100)">{formatted}</font>`
							end

							setText(localPlayer, "CustomMessage", {
								Message = `เพิ่ม {v10} (x1) ลงในข้อเสนอของคุณแล้ว.`
							})
						else
							local setText = SetText.SetText
							local formatted = `&lt;{clone.Name}&gt;`
							local v10

							if formatted then
								v10 = `<font color="rgb(100,255,100)">{formatted}</font>`
							end

							setText(localPlayer, "CustomMessage", {
								Message = `Added {v10} (1x) to your offer.`
							})
						end

						local v6 = string.gsub(clone.Amount.Text, "%D+", "")

						if v6 then
							local v7 = v6 - 1
							clone.Amount.Text = `x{v7}`

							if v7 > 0 then
								if clone.Check.Visible then
									clone.Check.Visible = false
								end

								if clone.Amount.Visible == false then
									clone.Amount.Visible = true
								end
							else
								if clone.Check.Visible == false then
									clone.Check.Visible = true
								end

								if clone.Amount.Visible then
									clone.Amount.Visible = false
								end
							end
						end
					elseif localPlayer:GetAttribute("TH") then
						SetText.SetText(localPlayer, "CustomMessage", {
							Message = "คุณมีไอเทมไม่เพียงพอที่จะเพิ่มลงไปได้!",
							MessageColor = "Red"
						})
					else
						SetText.SetText(localPlayer, "CustomMessage", {
							Message = "You don't have enough items to add to your offer!",
							MessageColor = "Red"
						})
					end
				elseif localPlayer:GetAttribute("TH") then
					SetText.SetText(localPlayer, "CustomMessage", {
						Message = "ไอเทมชิ้นนี้ไม่สามารถแลกเปลี่ยนได้!",
						MessageColor = "Red"
					})
				else
					SetText.SetText(localPlayer, "CustomMessage", {
						Message = "This item is untradeable!",
						MessageColor = "Red"
					})
				end
			end)
		end
	end
end

local function GemInput()
	local number = Abbreviate.GetNumber(gem_Input.Text)

	if number and gem.Value < number then
		gem_Input.Text = gem.Value
	end

	local text = gem_Input.Text
	local number2 = Abbreviate.GetNumber(text)

	if number2 then
		gem_Input:SetAttribute("RealInput", number2)

		if number2 < 1000000000 then
			gem_Input.PlaceholderText = Abbreviate.Comma(gem_Input:GetAttribute("RealInput"))
		else
			gem_Input.PlaceholderText = Abbreviate.ShowNum(gem_Input:GetAttribute("RealInput"))
		end

		gem_Input.Text = ""
		trade_Event:FireServer({
			Action = "Add_Item",
			Item_Table = {
				ItemType = "Gem",
				ItemName = gem_Input:GetAttribute("RealInput")
			}
		})
	end
end

local function MoneyInput()
	local number = Abbreviate.GetNumber(money_Input.Text)

	if number and money.Value < number then
		money_Input.Text = money.Value
	end

	local text = money_Input.Text
	local number2 = Abbreviate.GetNumber(text)

	if number2 then
		money_Input:SetAttribute("RealInput", number2)

		if number2 < 1000000000 then
			money_Input.PlaceholderText = Abbreviate.Comma(money_Input:GetAttribute("RealInput"))
		else
			money_Input.PlaceholderText = Abbreviate.ShowNum(money_Input:GetAttribute("RealInput"))
		end

		money_Input.Text = ""
		trade_Event:FireServer({
			Action = "Add_Item",
			Item_Table = {
				ItemType = "Money",
				ItemName = money_Input:GetAttribute("RealInput")
			}
		})
	end
end

local function MessageAmount_Changed()
	if messageAmount:GetAttribute("Amount") <= 0 then
		if unreadMessages.Visible then
			unreadMessages.Visible = false
		end
	else
		if not unreadMessages.Visible then
			unreadMessages.Visible = true
		end

		if messageAmount:GetAttribute("Amount") <= 99 then
			messageAmount.Text = messageAmount:GetAttribute("Amount")
		else
			messageAmount.Text = "99+"
		end
	end
end

local function Generate_Message(p: string, text: string, p2)
	if p == "My" then
		local userId = p2.UserId or 1587871301
		local clone = myMessage:Clone()
		local userThumbnailAsync = nil
		local v2 = nil
		local success, _ = pcall(function()
			userThumbnailAsync, v2 = Players:GetUserThumbnailAsync(userId, headShot, size420x420)
		end)

		if success and userThumbnailAsync then
			clone.Profile.Image = userThumbnailAsync
		else
			clone.Profile.Image = "rbxassetid://5861062308"
		end

		clone.LayoutOrder = #container:GetChildren()
		clone.MessageFrame.Message.Text = text
		clone.Visible = true
		clone.Parent = container
		container.CanvasSize = UDim2.new(
			0,
			container.UIGridLayout.AbsoluteContentSize.X,
			0,
			container.UIGridLayout.AbsoluteContentSize.Y
		)
		container.CanvasPosition = Vector2.new(0, container.AbsoluteCanvasSize.Y)

		if #container:GetChildren() >= 8 and container.UIGridLayout.VerticalAlignment == Enum.VerticalAlignment.Bottom then
			container.UIGridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
		end
	elseif p == "Their" then
		local userId = p2.UserId or 1587871301
		local clone = theirMessage:Clone()
		local userThumbnailAsync = nil
		local v2 = nil
		local success, _ = pcall(function()
			userThumbnailAsync, v2 = Players:GetUserThumbnailAsync(userId, headShot, size420x420)
		end)

		if success and userThumbnailAsync then
			clone.Profile.Image = userThumbnailAsync
		else
			clone.Profile.Image = "rbxassetid://5861062308"
		end

		clone.LayoutOrder = #container:GetChildren()
		clone.MessageFrame.Message.Text = text
		clone.Visible = true
		clone.Parent = container
		container.CanvasSize = UDim2.new(
			0,
			container.UIGridLayout.AbsoluteContentSize.X,
			0,
			container.UIGridLayout.AbsoluteContentSize.Y
		)
		container.CanvasPosition = Vector2.new(0, container.AbsoluteCanvasSize.Y)

		if #container:GetChildren() >= 8 and container.UIGridLayout.VerticalAlignment == Enum.VerticalAlignment.Bottom then
			container.UIGridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
		end
	end
end

local function Send_Chat()
	if chat:GetAttribute("CanChat") and child then
		local text = chat.Text

		if text ~= "" and not text:match("^%s*$") then
			chat.Text = ""
			child:SendAsync(text)
		end
	end
end

local function AddButton_Function()
	local v2 = input.Text == "" and 1 or input.Text
	local number = Abbreviate.GetNumber(v2)

	if number and item3.Value then
		if item3.Value:GetAttribute("ItemType") == "Weapon" then
			if weapon3:FindFirstChild(item3.Value.Name) then
				if number < 1 then
					input.Text = 1
					number = 1
				end

				local child2 = weapon3:FindFirstChild(item3.Value.Name)

				if child2 then
					local v3 = child2.Value >= number + item3.Value:GetAttribute("OfferAmount")

					if number <= child2.Value and v3 then
						GenerateOffer({
							ItemType = "Weapon",
							ItemName = item3.Value.Name,
							ItemAmount = number
						}, myOffer_Frame.MyOffer)
						trade_Event:FireServer({
							Action = "Add_Item",
							Item_Table = {
								ItemType = "Weapon",
								ItemName = item3.Value.Name,
								ItemAmount = number
							}
						})

						if localPlayer:GetAttribute("TH") then
							local setText = SetText.SetText
							local formatted = `&lt;{item3.Value.Name}&gt;`
							local v8

							if formatted then
								v8 = `<font color="rgb(100,255,100)">{formatted}</font>`
							end

							setText(localPlayer, "CustomMessage", {
								Message = `เพิ่ม {v8} (x{number}) ลงในข้อเสนอของคุณแล้ว.`
							})
						else
							local setText = SetText.SetText
							local formatted = `&lt;{item3.Value.Name}&gt;`
							local v8

							if formatted then
								v8 = `<font color="rgb(100,255,100)">{formatted}</font>`
							end

							setText(localPlayer, "CustomMessage", {
								Message = `Added {v8} (x{number}) to your offer.`
							})
						end

						local v4 = string.gsub(item3.Value.Amount.Text, "%D+", "")

						if v4 then
							local v5 = v4 - number
							item3.Value.Amount.Text = `x{v5}`

							if v5 > 0 then
								if item3.Value.Check.Visible then
									item3.Value.Check.Visible = false
								end

								if item3.Value.Amount.Visible == false then
									item3.Value.Amount.Visible = true
								end
							else
								if item3.Value.Check.Visible == false then
									item3.Value.Check.Visible = true
								end

								if item3.Value.Amount.Visible then
									item3.Value.Amount.Visible = false
								end
							end
						end
					elseif localPlayer:GetAttribute("TH") then
						SetText.SetText(localPlayer, "CustomMessage", {
							Message = "คุณมีไอเทมไม่เพียงพอที่จะเพิ่มลงไปได้!",
							MessageColor = "Red"
						})
					else
						SetText.SetText(localPlayer, "CustomMessage", {
							Message = "You don't have enough items to add to your offer!",
							MessageColor = "Red"
						})
					end
				end
			end
		elseif item3.Value:GetAttribute("ItemType") == "Accessory" then
			if accessory3:FindFirstChild(item3.Value.Name) then
				if number < 1 then
					input.Text = 1
					number = 1
				end

				local child2 = accessory3:FindFirstChild(item3.Value.Name)

				if child2 then
					local v3 = child2.Value >= number + item3.Value:GetAttribute("OfferAmount")

					if number <= child2.Value and v3 then
						GenerateOffer({
							ItemType = "Accessory",
							ItemName = item3.Value.Name,
							ItemAmount = number
						}, myOffer_Frame.MyOffer)
						trade_Event:FireServer({
							Action = "Add_Item",
							Item_Table = {
								ItemType = "Accessory",
								ItemName = item3.Value.Name,
								ItemAmount = number
							}
						})

						if localPlayer:GetAttribute("TH") then
							local setText = SetText.SetText
							local formatted = `&lt;{item3.Value.Name}&gt;`
							local v8

							if formatted then
								v8 = `<font color="rgb(100,255,100)">{formatted}</font>`
							end

							setText(localPlayer, "CustomMessage", {
								Message = `เพิ่ม {v8} (x{number}) ลงในข้อเสนอของคุณแล้ว.`
							})
						else
							local setText = SetText.SetText
							local formatted = `&lt;{item3.Value.Name}&gt;`
							local v8

							if formatted then
								v8 = `<font color="rgb(100,255,100)">{formatted}</font>`
							end

							setText(localPlayer, "CustomMessage", {
								Message = `Added {v8} (x{number}) to your offer.`
							})
						end

						local v4 = string.gsub(item3.Value.Amount.Text, "%D+", "")

						if v4 then
							local v5 = v4 - number
							item3.Value.Amount.Text = `x{v5}`

							if v5 > 0 then
								if item3.Value.Check.Visible then
									item3.Value.Check.Visible = false
								end

								if item3.Value.Amount.Visible == false then
									item3.Value.Amount.Visible = true
								end
							else
								if item3.Value.Check.Visible == false then
									item3.Value.Check.Visible = true
								end

								if item3.Value.Amount.Visible then
									item3.Value.Amount.Visible = false
								end
							end
						end
					elseif localPlayer:GetAttribute("TH") then
						SetText.SetText(localPlayer, "CustomMessage", {
							Message = "คุณมีไอเทมไม่เพียงพอที่จะเพิ่มลงไปได้!",
							MessageColor = "Red"
						})
					else
						SetText.SetText(localPlayer, "CustomMessage", {
							Message = "You don't have enough items to add to your offer!",
							MessageColor = "Red"
						})
					end
				end
			end
		elseif item3.Value:GetAttribute("ItemType") == "Power" then
			if power3:FindFirstChild(item3.Value.Name) then
				if number < 1 then
					input.Text = 1
					number = 1
				end

				local child2 = power3:FindFirstChild(item3.Value.Name)

				if child2 then
					local v3 = child2.Value >= number + item3.Value:GetAttribute("OfferAmount")

					if number <= child2.Value and v3 then
						GenerateOffer({
							ItemType = "Power",
							ItemName = item3.Value.Name,
							ItemAmount = number
						}, myOffer_Frame.MyOffer)
						trade_Event:FireServer({
							Action = "Add_Item",
							Item_Table = {
								ItemType = "Power",
								ItemName = item3.Value.Name,
								ItemAmount = number
							}
						})

						if localPlayer:GetAttribute("TH") then
							local setText = SetText.SetText
							local formatted = `&lt;{item3.Value.Name}&gt;`
							local v8

							if formatted then
								v8 = `<font color="rgb(100,255,100)">{formatted}</font>`
							end

							setText(localPlayer, "CustomMessage", {
								Message = `เพิ่ม {v8} (x{number}) ลงในข้อเสนอของคุณแล้ว.`
							})
						else
							local setText = SetText.SetText
							local formatted = `&lt;{item3.Value.Name}&gt;`
							local v8

							if formatted then
								v8 = `<font color="rgb(100,255,100)">{formatted}</font>`
							end

							setText(localPlayer, "CustomMessage", {
								Message = `Added {v8} (x{number}) to your offer.`
							})
						end

						local v4 = string.gsub(item3.Value.Amount.Text, "%D+", "")

						if v4 then
							local v5 = v4 - number
							item3.Value.Amount.Text = `x{v5}`

							if v5 > 0 then
								if item3.Value.Check.Visible then
									item3.Value.Check.Visible = false
								end

								if item3.Value.Amount.Visible == false then
									item3.Value.Amount.Visible = true
								end
							else
								if item3.Value.Check.Visible == false then
									item3.Value.Check.Visible = true
								end

								if item3.Value.Amount.Visible then
									item3.Value.Amount.Visible = false
								end
							end
						end
					elseif localPlayer:GetAttribute("TH") then
						SetText.SetText(localPlayer, "CustomMessage", {
							Message = "คุณมีไอเทมไม่เพียงพอที่จะเพิ่มลงไปได้!",
							MessageColor = "Red"
						})
					else
						SetText.SetText(localPlayer, "CustomMessage", {
							Message = "You don't have enough items to add to your offer!",
							MessageColor = "Red"
						})
					end
				end
			end
		elseif item3.Value:GetAttribute("ItemType") == "Item" and itemStorage:FindFirstChild(item3.Value.Name) then
			if number < 1 then
				input.Text = 1
				number = 1
			end

			local child2 = itemStorage:FindFirstChild(item3.Value.Name)

			if child2 then
				local v3 = child2.Value >= number + item3.Value:GetAttribute("OfferAmount")

				if number <= child2.Value and v3 then
					GenerateOffer({
						ItemType = "Item",
						ItemName = item3.Value.Name,
						ItemAmount = number
					}, myOffer_Frame.MyOffer)
					trade_Event:FireServer({
						Action = "Add_Item",
						Item_Table = {
							ItemType = "Item",
							ItemName = item3.Value.Name,
							ItemAmount = number
						}
					})

					if localPlayer:GetAttribute("TH") then
						local setText = SetText.SetText
						local formatted = `&lt;{item3.Value.Name}&gt;`
						local v8

						if formatted then
							v8 = `<font color="rgb(100,255,100)">{formatted}</font>`
						end

						setText(localPlayer, "CustomMessage", {
							Message = `เพิ่ม {v8} (x{number}) ลงในข้อเสนอของคุณแล้ว.`
						})
					else
						local setText = SetText.SetText
						local formatted = `&lt;{item3.Value.Name}&gt;`
						local v8

						if formatted then
							v8 = `<font color="rgb(100,255,100)">{formatted}</font>`
						end

						setText(localPlayer, "CustomMessage", {
							Message = `Added {v8} (x{number}) to your offer.`
						})
					end

					local v4 = string.gsub(item3.Value.Amount.Text, "%D+", "")

					if v4 then
						local v5 = v4 - number
						item3.Value.Amount.Text = `x{v5}`

						if v5 > 0 then
							if item3.Value.Check.Visible then
								item3.Value.Check.Visible = false
							end

							if item3.Value.Amount.Visible == false then
								item3.Value.Amount.Visible = true
							end
						else
							if item3.Value.Check.Visible == false then
								item3.Value.Check.Visible = true
							end

							if item3.Value.Amount.Visible then
								item3.Value.Amount.Visible = false
							end
						end
					end
				elseif localPlayer:GetAttribute("TH") then
					SetText.SetText(localPlayer, "CustomMessage", {
						Message = "คุณมีไอเทมไม่เพียงพอที่จะเพิ่มลงไปได้!",
						MessageColor = "Red"
					})
				else
					SetText.SetText(localPlayer, "CustomMessage", {
						Message = "You don't have enough items to add to your offer!",
						MessageColor = "Red"
					})
				end
			end
		end
	elseif localPlayer:GetAttribute("TH") then
		SetText.SetText(localPlayer, "CustomMessage", {
			Message = "โปรดใส่จำนวนให้ถูกต้อง!",
			MessageColor = "Red"
		})
	else
		SetText.SetText(localPlayer, "CustomMessage", {
			Message = "Please enter the correct amount!",
			MessageColor = "Red"
		})
	end

	amount_Frame.Visible = false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DeclineTrade()
	CleanUp()
	parent.Enabled = false

	if messageReceivedConnection then
		messageReceivedConnection:Disconnect()
		messageReceivedConnection = nil
	end

	if child then
		child = nil
	end
end

local function UnreadyTrade()
	if tick() - lastTime >= 0.1 then
		lastTime = tick()
		trade_Event:FireServer({
			Action = "Unready_Trade"
		})
		SetColor_State(ready, "Ready")
		myOffer_Frame.Visible = false
		container_Frame.Visible = true
		myItem_Frame.Visible = true

		if localPlayer:GetAttribute("TH") then
			myStatus.Text = "สถานะ : ยังไม่พร้อม."
		else
			myStatus.Text = "Status: Not ready."
		end

		myStatus.TextColor3 = Color3.fromRGB(236, 83, 83)
		currency_Frame.BackgroundColor3 = myItem_Frame.BackgroundColor3
		currency_Frame.BackgroundTransparency = myItem_Frame.BackgroundTransparency
		local text = not localPlayer:GetAttribute("TH") and "Ready!" or Translate["Ready!"]
		ready.Textlabel.Text = text
	end
end

local function Forced_UnreadyTrade()
	SetColor_State(ready, "Ready")
	myOffer_Frame.Visible = false
	container_Frame.Visible = true
	myItem_Frame.Visible = true

	if localPlayer:GetAttribute("TH") then
		myStatus.Text = "สถานะ : ยังไม่พร้อม."
	else
		myStatus.Text = "Status: Not ready."
	end

	myStatus.TextColor3 = Color3.fromRGB(236, 83, 83)
	currency_Frame.BackgroundColor3 = myItem_Frame.BackgroundColor3
	currency_Frame.BackgroundTransparency = myItem_Frame.BackgroundTransparency
	local text = not localPlayer:GetAttribute("TH") and "Ready!" or Translate["Ready!"]
	ready.Textlabel.Text = text
end

local function ReadyTrade()
	if ready.Textlabel.Text ~= "Ready!" and (ready.Textlabel.Text ~= "พร้อม!" or not (tick() - lastTime >= 0.1)) then
		UnreadyTrade()
		return
	end

	lastTime = tick()
	trade_Event:FireServer({
		Action = "Ready_Trade"
	})
	SetColor_State(ready, "Unready")
	amount_Frame.Visible = false
	container_Frame.Visible = false
	myItem_Frame.Visible = false
	myOffer_Frame.Visible = true

	if localPlayer:GetAttribute("TH") then
		myStatus.Text = "สถานะ : พร้อมแล้ว!"
	else
		myStatus.Text = "Status: Ready!"
	end

	myStatus.TextColor3 = Color3.fromRGB(102, 239, 75)
	currency_Frame.BackgroundColor3 = myOffer_Frame.BackgroundColor3
	currency_Frame.BackgroundTransparency = myOffer_Frame.BackgroundTransparency
	local text = not localPlayer:GetAttribute("TH") and "Unready" or Translate.Unready
	ready.Textlabel.Text = text
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Trader_ReadyTrade()
	if localPlayer:GetAttribute("TH") then
		theirStatus.Text = "สถานะ : พร้อมแล้ว!"
	else
		theirStatus.Text = "Status: Ready!"
	end

	theirStatus.TextColor3 = Color3.fromRGB(102, 239, 75)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Trader_UnreadyTrade()
	if localPlayer:GetAttribute("TH") then
		theirStatus.Text = "สถานะ : ยังไม่พร้อม."
	else
		theirStatus.Text = "Status: Not ready."
	end

	theirStatus.TextColor3 = Color3.fromRGB(236, 83, 83)
end

local function UpdateLabel(trader)
	if trade:InvokeServer({
		Action = "CheckCan_Chat",
		Trader = trader.UserId
	}) then
		local text = not (trader and trader.Name) and "Anonymous" or trader.Name
		local v3 = not (trader and trader.DisplayName) and "Anonymous" or trader.DisplayName
		myName.Text = localPlayer.Name
		theirName.Text = text
		local chat2 = chat
		local placeholderText

		if localPlayer:GetAttribute("TH") then
			placeholderText = `ส่งข้อความถึง @{v3}`
		else
			placeholderText = `Message @{v3}`
		end

		chat2.PlaceholderText = placeholderText
		chat.TextEditable = true
		chat:SetAttribute("CanChat", true)
	else
		local text = not (trader and trader.Name) and "Anonymous" or trader.Name
		myName.Text = localPlayer.Name
		theirName.Text = text
		chat.PlaceholderText = localPlayer:GetAttribute("TH") and "การตั้งค่าแชทของคุณหรืออีกฝ่ายถูกปิดไว้อยู่" or "Chat is disabled by either your or the other player's chat settings."
		chat.TextEditable = false
		chat:SetAttribute("CanChat", false)
	end
end

local function ChangeAmount(data)
	local item_Table = data.Item_Table

	if item_Table then
		local itemType = item_Table.ItemType
		local itemName = item_Table.ItemName or 0

		if itemType == "Money" then
			money_Input:SetAttribute("RealInput", itemName)
			money_Input.PlaceholderText = Abbreviate.Comma(itemName)
			money_Input.Text = Abbreviate.Comma(itemName)
		elseif itemType == "Gem" then
			gem_Input:SetAttribute("RealInput", itemName)
			gem_Input.PlaceholderText = Abbreviate.Comma(itemName)
			gem_Input.Text = Abbreviate.Comma(itemName)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function AddOffer(data)
	local item_Table = data.Item_Table

	if item_Table then
		GenerateOffer(item_Table, theirOffer_Frame.TheirOffer)
	end
end

local function RemoveOffer(childName)
	local child2 = theirOffer_Frame.TheirOffer:FindFirstChild(childName)

	if child2 then
		child2:Destroy()
	end
end

local function TradeCountdown(start_Countdown)
	if renderSteppedConnection2 then
		renderSteppedConnection2:Disconnect()
		renderSteppedConnection2 = nil
	end

	countdown_Frame:SetAttribute("Counting", true)
	icon2.Visible = false
	countdown.Visible = true
	countdownTitle.Visible = true
	countdown_Frame.Visible = true
	renderSteppedConnection2 = RunService.RenderStepped:Connect(function()
		if workspace:GetServerTimeNow() - start_Countdown <= 10 and countdown_Frame.Visible and countdown_Frame:GetAttribute("Counting") == true then
			countdown.Text = `{Abbreviate.Format(10 - (workspace:GetServerTimeNow() - start_Countdown), 1)}`
			return
		end

		countdown.Text = "     🕒     "

		if renderSteppedConnection2 then
			renderSteppedConnection2:Disconnect()
			renderSteppedConnection2 = nil
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Cancel_TradeCountdown()
	countdown_Frame.Visible = false
	countdown.Visible = false
	countdownTitle.Visible = false
	icon2.Visible = true
	countdown_Frame:SetAttribute("Counting", false)
end

local function TradeGui_Function(data)
	local action = data.Action

	if action == "Trade_Begin" then
		local trader = data.Trader

		if trader then
			CleanUp()
			UpdateLabel(trader)
			GenerateItems(trader)
			guiEvent:Fire({
				MenuName = "Menu",
				Action = "Close"
			})
			parent.Enabled = true
		end

		local trade_Channel = data.Trade_Channel

		if trade_Channel then
			child = custom_Channels:WaitForChild(trade_Channel, 10)

			if child then
				if messageReceivedConnection then
					messageReceivedConnection:Disconnect()
					messageReceivedConnection = nil
				end

				messageReceivedConnection = child.MessageReceived:Connect(function(p)
					local userId = p.TextSource.UserId
					local text = p.Text
					local playerByUserId = Players:GetPlayerByUserId(userId)

					if userId == localPlayer.UserId then
						if text ~= "" and not text:match("^%s*$") then
							Generate_Message("My", text, localPlayer)
						end
					else
						if text ~= "" and not text:match("^%s*$") then
							Generate_Message("Their", text, playerByUserId)
						end

						if not chat_Frame.Visible then
							notification2:Play()
							messageAmount:SetAttribute("Amount", messageAmount:GetAttribute("Amount") + 1)
						end
					end
				end)
			end
		end
	elseif action == "Add_Offer" then
		AddOffer(data) -- equivalent call inferred; original call site unknown
	elseif action == "Change_Amount" then
		ChangeAmount(data)
	elseif action == "Remove_Offer" then
		local removed_Offer = data.Removed_Offer
		local child2 = removed_Offer and theirOffer_Frame.TheirOffer:FindFirstChild(removed_Offer)

		if child2 then
			child2:Destroy()
		end
	elseif action == "Trade_Declined" then
		local decliner = data.Decliner
		DeclineTrade() -- equivalent call inferred; original call site unknown

		if decliner then
			if localPlayer:GetAttribute("TH") then
				local setText = SetText.SetText
				local v6

				if decliner then
					v6 = `<font color="rgb(255,100,100)">{decliner}</font>`
				end

				setText(localPlayer, "CustomMessage", {
					Message = `การเทรดของคุณกับ {v6} ถูกยกเลิกแล้ว.`,
					MessageColor = "White"
				})
			else
				local setText = SetText.SetText
				local v6

				if decliner then
					v6 = `<font color="rgb(255,100,100)">{decliner}</font>`
				end

				setText(localPlayer, "CustomMessage", {
					Message = `Your trade with {v6} has been cancelled.`,
					MessageColor = "White"
				})
			end
		end
	elseif action == "Trade_Ready" then
		Trader_ReadyTrade() -- equivalent call inferred; original call site unknown
	elseif action == "Trade_Unready" then
		Trader_UnreadyTrade() -- equivalent call inferred; original call site unknown
	elseif action == "Trade_Countdown" then
		TradeCountdown(data.Start_Countdown or tick())
	elseif action == "Trade_Cancel" then
		Cancel_TradeCountdown() -- equivalent call inferred; original call site unknown
	elseif action == "Force_Unready" then
		Forced_UnreadyTrade()
	elseif action == "Trade_Completed" then
		local trader = data.Trader
		DeclineTrade() -- equivalent call inferred; original call site unknown

		if trader then
			if localPlayer:GetAttribute("TH") then
				local setText = SetText.SetText
				local v6

				if trader then
					v6 = `<font color="rgb(100,255,100)">{trader}</font>`
				end

				setText(localPlayer, "CustomMessage", {
					Message = `การเทรดของคุณกับ {v6} เสร็จสมบูรณ์แล้ว!`,
					MessageColor = "White"
				})
			else
				local setText = SetText.SetText
				local v6

				if trader then
					v6 = `<font color="rgb(100,255,100)">{trader}</font>`
				end

				setText(localPlayer, "CustomMessage", {
					Message = `Your trade with {v6} has been completed!`,
					MessageColor = "White"
				})
			end
		end
	end
end

trade_Event.OnClientEvent:Connect(TradeGui_Function)
gem_Input.FocusLost:Connect(GemInput)
money_Input.FocusLost:Connect(MoneyInput)
add.Activated:Connect(AddButton_Function)
remove.Activated:Connect(RemoveButton_Function)
ready.Activated:Connect(ReadyTrade)
send_Button.Activated:Connect(Send_Chat)
messageAmount:GetAttributeChangedSignal("Amount"):Connect(MessageAmount_Changed)
chat.FocusLost:Connect(function(flag2: boolean)
	if flag2 and chat:GetAttribute("CanChat") and child then
		local text = chat.Text

		if text ~= "" and not text:match("^%s*$") then
			chat.Text = ""
			child:SendAsync(text)
		end
	end
end)
decline.Activated:Connect(function()
	if localPlayer:GetAttribute("Trading") then
		if localPlayer:GetAttribute("TH") then
			local setText = SetText.SetText
			local playerByUserId = Players:GetPlayerByUserId(localPlayer:GetAttribute("Trading"))
			local v6

			if playerByUserId then
				v6 = `<font color="rgb(255,100,100)">{playerByUserId}</font>`
			end

			setText(localPlayer, "CustomMessage", {
				Message = `การเทรดของคุณกับ {v6} ถูกยกเลิกแล้ว.`,
				MessageColor = "White"
			})
		else
			local setText = SetText.SetText
			local playerByUserId = Players:GetPlayerByUserId(localPlayer:GetAttribute("Trading"))
			local v6

			if playerByUserId then
				v6 = `<font color="rgb(255,100,100)">{playerByUserId}</font>`
			end

			setText(localPlayer, "CustomMessage", {
				Message = `Your trade with {v6} has been cancelled.`,
				MessageColor = "White"
			})
		end

		trade_Event:FireServer({
			Action = "Decline_Trade"
		})
	end

	DeclineTrade() -- equivalent call inferred; original call site unknown
end)
chat:GetPropertyChangedSignal("Text"):Connect(function()
	if chat.Text == "" or chat.Text == " " or chat.Text:match("^%s*$") then
		if send_Button.ImageTransparency == 0 then
			TweenService:Create(send_Button, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
				ImageTransparency = 0.75,
				ImageColor3 = Color3.fromRGB(214, 217, 220)
			}):Play()
		end
	elseif send_Button.ImageTransparency == 0.75 then
		TweenService:Create(send_Button, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
			ImageTransparency = 0,
			ImageColor3 = Color3.fromRGB(148, 156, 247)
		}):Play()
	end
end)
gem_Input:GetPropertyChangedSignal("Text"):Connect(function()
	gem_Input.Text = gem_Input.Text:gsub("%D+", "")
end)
money_Input:GetPropertyChangedSignal("Text"):Connect(function()
	money_Input.Text = money_Input.Text:gsub("%D+", "")
end)
input:GetPropertyChangedSignal("Text"):Connect(function()
	input.Text = input.Text:gsub("%D+", "")

	if item3.Value then
		local number = Abbreviate.GetNumber(input.Text)

		if item3.Value and number then
			local v2

			if number then
				v2 = math.clamp(math.clamp(number - 1, 0, 999) / (math.clamp(tonumber(max.Text), 2, 999) - 1), 0, 1)
			else
				v2 = math.clamp(0 / (math.clamp(tonumber(max.Text), 2, 999) - 1), 0, 1)
			end

			TweenService:Create(slideFrame.Slide, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
				Position = UDim2.new(
					math.clamp(v2, 0, 1),
					0,
					slideFrame.Slide.Position.Y.Scale,
					slideFrame.Slide.Position.Y.Offset
				)
			}):Play()
			TweenService:Create(slideFrame.Bar, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
				Size = UDim2.new(math.clamp(v2, 0, 1), 0, 1, 0)
			}):Play()
		end
	end
end)
input.FocusLost:Connect(function()
	if item3.Value then
		if item3.Value:GetAttribute("ItemType") == "Weapon" then
			local child2

			if item3.Value then
				child2 = weapon3:FindFirstChild(item3.Value.Name)
			end

			local number = Abbreviate.GetNumber(input.Text)

			if item3.Value and child2 and number then
				if child2.Value < number then
					input.Text = child2.Value - item3.Value:GetAttribute("OfferAmount")
				elseif tonumber(max.Text) < number then
					input.Text = tonumber(max.Text)
				elseif number < 1 then
					input.Text = 1
				end
			end
		elseif item3.Value:GetAttribute("ItemType") == "Accessory" then
			local child2

			if item3.Value then
				child2 = accessory3:FindFirstChild(item3.Value.Name)
			end

			local number = Abbreviate.GetNumber(input.Text)

			if item3.Value and child2 and number then
				if child2.Value < number then
					input.Text = child2.Value - item3.Value:GetAttribute("OfferAmount")
				elseif tonumber(max.Text) < number then
					input.Text = tonumber(max.Text)
				elseif number < 1 then
					input.Text = 1
				end
			end
		elseif item3.Value:GetAttribute("ItemType") == "Power" then
			local child2

			if item3.Value then
				child2 = power3:FindFirstChild(item3.Value.Name)
			end

			local number = Abbreviate.GetNumber(input.Text)

			if item3.Value and child2 and number then
				if child2.Value < number then
					input.Text = child2.Value - item3.Value:GetAttribute("OfferAmount")
				elseif tonumber(max.Text) < number then
					input.Text = tonumber(max.Text)
				elseif number < 1 then
					input.Text = 1
				end
			end
		elseif item3.Value:GetAttribute("ItemType") == "Item" then
			local child2

			if item3.Value then
				child2 = itemStorage:FindFirstChild(item3.Value.Name)
			end

			local number = Abbreviate.GetNumber(input.Text)

			if item3.Value and child2 and number then
				if child2.Value < number then
					input.Text = child2.Value - item3.Value:GetAttribute("OfferAmount")
				elseif tonumber(max.Text) < number then
					input.Text = tonumber(max.Text)
				elseif number < 1 then
					input.Text = 1
				end
			end
		end
	end
end)
slideFrame.Slide.MouseButton1Down:Connect(function()
	StartSliding(slideFrame) -- equivalent call inferred; original call site unknown
end)
slideFrame.MouseButton1Down:Connect(function()
	StartSliding(slideFrame) -- equivalent call inferred; original call site unknown
end)
chatToggle.Activated:Connect(function()
	messageAmount:SetAttribute("Amount", 0)

	if chat_Frame.Visible then
		chat_Frame.Visible = false
	else
		chat_Frame.Visible = true
	end
end)

for _, button in ipairs(container_Frame:GetChildren()) do
	if not button:IsA("GuiButton") then
		continue
	end

	local v2 = button
	button.Activated:Connect(function()
		for i, scrollingFrame in ipairs(myItem_Frame:GetChildren()) do
			if scrollingFrame:IsA("ScrollingFrame") then
				scrollingFrame.Visible = false
			end
		end

		if myItem_Frame:FindFirstChild(v2.Name) then
			local findFirstChild = myItem_Frame:FindFirstChild(v2.Name)
			findFirstChild.Visible = true
		end
	end)
end

UserInputService.InputEnded:Connect(function(input2)
	if input2.UserInputType == Enum.UserInputType.MouseButton1 then
		if flag == true then
			flag = false

			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			end
		end
	elseif input2.UserInputType == Enum.UserInputType.Touch and flag == true then
		flag = false

		if renderSteppedConnection then
			renderSteppedConnection:Disconnect()
			renderSteppedConnection = nil
		end
	end
end)