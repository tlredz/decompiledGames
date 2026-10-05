local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Trove)
local client = require3(ReplicatedStorage2.Packages.Replion).Client
local v2 = require3(ReplicatedStorage2.Common.Utils)
local v3 = require3(ReplicatedStorage2.Shared.Statable)
local client2 = require3(ReplicatedStorage2.Shared.Inventory).Client
local v4 = require3(ReplicatedStorage2.Shared.Trading.TradeInfo)
local v5 = require3(ReplicatedStorage2.ServerInfo)
local v6 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
require3(ReplicatedStorage2.Shared.ReplionUtils)
local v7 = require3(ReplicatedStorage2.Controllers.Trading.RAPController)
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
require3(ReplicatedStorage2.Controllers.Booth.BoothController)
local v8 = require3(ReplicatedStorage2.Controllers.UI.ShopControllerAPI)
local v9 = require3(ReplicatedStorage2.Controllers.Trading.RAPChartController)
local v10 = require3(ReplicatedStorage2.Controllers.NotificationController)
local v11 = require3(ReplicatedStorage2.Controllers.HoverInfoController)
local v12 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.SwordAccessories)
local mainFrame = Players.LocalPlayer.PlayerGui:WaitForChild("BoothInventory").MainFrame
local pages = mainFrame.Pages
local topButtons = mainFrame.TopButtons
local BoothInventoryUIController = {
	CurrentPage = v3.State("Sword"),
	SelectedSlots = {},
	PagesSearchs = {},
	LastSelectedFrames = {}
}
local v13 = {}

function BoothInventoryUIController:UpdateSlotStatus(p: string, _: string, p2: string)
	local v14 = v13[p][p2]

	if not v14 then
		return
	end

	client2:KeyToItem(p2)

	if #client2:FindItemsWithKey(p, p2) <= 0 then
		print("deleting", p2)
		v14:Destroy()
		v13[p][p2] = nil
	end
end

function BoothInventoryUIController:CreateSlot(p: string, data)
	local maid = v.new()
	local list = pages[p].List
	local itemInfo = v8:GetItemInfo(p, data.Name)

	if not itemInfo then
		warn((`INVALID ITEM COULD NOT BE FOUND: {p} called "{data.Name}"`))
		return
	end

	local clone = list.UIGridLayout.Template:Clone()
	local itemToKey = client2:ItemToKey(p, data, { "Id" })

	if not itemToKey or v13[p][itemToKey] or data.TradeLock then
		return
	end

	local itemData = v8:GetItemData(p, v8:ParseItemKey(p, data))
	clone.ItemName.Text = itemInfo.DisplayName or itemInfo.Name
	clone.Rarity.Text = itemInfo.Rarity or ""
	clone.Vector.Image = itemInfo.Icon or v2.Icons:GetIcon("DEFAULT_MISSING")
	local v14 = v4.SlotColors[itemInfo.Rarity] or v4.SlotColors.Default
	clone.Image = v14.Image
	clone.HoverImage = v14.HoverImage
	clone.ItemName.UIStroke.Color = v14.StrokeColor
	clone.Rarity.UIStroke.Color = v14.StrokeColor
	maid:Add(v3.Computed(function(callback)
		local v15 = callback(itemData.OwnedCopies)
		clone.Stack.Visible = v15 > 1
		clone.Stack.Label.Text = `x{v15}`
		return nil
	end))
	v11:Add(clone, p, data, itemToKey)
	maid:Add(clone.Activated:Connect(function()
		self.SelectedSlots[p]:Set(itemToKey)
		self.LastSelectedFrames[p]:Set(clone)
	end))

	if p == "Sword" or p == "Explosion" then
		local v15 = v8.RarityOrder[itemInfo.Rarity] or 0

		if itemInfo.Name ~= "Base Sword" and itemInfo.Name ~= "Explosion Normal" then
			v15 += 1
		end

		local formatted = `{v15}|{itemInfo.Name}`
		maid:Add(v3.setPropertyComputed(clone, "Name", function(callback)
			return callback(itemData.IsFavorited) and `!{formatted}` or formatted
		end))
	else
		clone.Name = itemInfo.Name
	end

	if p == "Sword" then
		clone.Finisher.Visible = data and data.Finisher ~= nil

		if clone.Finisher.Visible then
			local child = ReplicatedStorage2.Misc.DataFinishers:FindFirstChild(data.Name)
			clone.Finisher.Icon.Image = child and child:GetAttribute("Icon") or v2.Icons:GetIcon("DEFAULT_MISSING")
		end

		clone.SwordAccessory.Visible = data and data.Accessory == true

		if clone.SwordAccessory then
			local v15 = v12:GetCollection()[data.Name]
			clone.SwordAccessory.Icon.Image = v15 and v15.Icon or v2.Icons:GetIcon("DEFAULT_MISSING")
		end
	end

	local displayName = (itemInfo.DisplayName or itemInfo.Name):lower()
	local pagesSearch = self.PagesSearchs[p]
	maid:Add(v3.setPropertyComputed(clone, "Visible", function(callback)
		local v15 = callback(pagesSearch)

		if v15 then
			return displayName == v15 or displayName:sub(1, #v15) == v15 or displayName:find(v15, 1, true) ~= nil
		end

		return true
	end))
	clone.Parent = list
	v13[p][itemToKey] = clone
	clone.Destroying:Once(function()
		maid:Destroy()
	end)
	local v15 = {
		clone:FindFirstChild("Stack"),
		clone:FindFirstChild("Finisher"),
		clone:FindFirstChild("SwordAccessory")
	}

	for i = #v15, 1, -1 do
		if v15[i] == nil then
			table.remove(v15, i)
		end
	end

	local positions = {}

	for k, v16 in v15 do
		local position = v16:GetAttribute("Position")

		if not position then
			position = v16.Position
			v16:SetAttribute("Position", position)
		end

		positions[k] = position
	end

	local v16 = 1

	for _, v17 in v15 do
		if not v17.Visible then
			continue
		end

		v17.Position = positions[v16] or v17.Position
		v16 += 1
	end

	self:UpdateSlotStatus(p, data.Name, itemToKey)
end

function BoothInventoryUIController:CreateInventory(p: string)
	local v14 = client2:Get(p)

	if v14 then
		for _, v15 in v14 do
			self:CreateSlot(p, v15)
		end
	end

	client2:OnChange(p, function(p2, p3: string, p4)
		if p3 == "Insert" then
			self:CreateSlot(p, p2)
		elseif p3 == "Remove" then
			local itemToKey = client2:ItemToKey(p, p2, { "Id" })

			if not itemToKey then
				return
			end

			if v13[p][itemToKey] and #client2:FindItemsWithKey(p, itemToKey) <= 0 then
				v13[p][itemToKey]:Destroy()
				v13[p][itemToKey] = nil
			else
				self:UpdateSlotStatus(p, p2.Name, itemToKey)
			end

			self:UpdateSlotStatus(p, p2.Name, itemToKey)
		elseif p3 == "Change" then
			local itemToKey = client2:ItemToKey(p, p2, { "Id" })

			if not itemToKey then
				return
			end

			local v15 = p4 and client2:ItemToKey(p, p4, { "Id" })

			if p4 and v15 then
				if v13[p][v15] and #client2:FindItemsWithKey(p, v15) <= 0 then
					v13[p][v15]:Destroy()
					v13[p][v15] = nil
				else
					self:UpdateSlotStatus(p, p4.Name, v15)
				end

				self:UpdateSlotStatus(p, p4.Name, v15)
			end

			self:CreateSlot(p, p2)
			self:UpdateSlotStatus(p, p2.Name, itemToKey)
		end
	end)
end

local thread = nil

function BoothInventoryUIController.PromptSync(p)
	v6:Open("BoothInventory")

	for k, selectedSlot in p.SelectedSlots do
		local v14 = selectedSlot:Get()

		if v14 and #client2:FindItemsWithKey(k, v14) <= 0 then
			selectedSlot:Set(nil)
		end
	end

	thread = coroutine.running()
	local connection = nil
	connection = v6:OnGuiClose("BoothInventory", function()
		if thread then
			if connection then
				connection:Disconnect()
				connection = nil
			end

			task.spawn(thread, nil, nil)
			thread = nil
		end
	end)
	local v14, v15 = coroutine.yield()
	thread = nil

	if connection then
		connection:Disconnect()
		connection = nil
	end

	v6:Close("BoothInventory")
	return v14, v15
end

function BoothInventoryUIController:Start()
	if not v5.isTradingPlazaServer() then
		return
	end

	mainFrame.Close.Activated:Connect(function()
		v6:Close("BoothInventory")

		if thread then
			task.spawn(thread, nil, nil)
			thread = nil
		end
	end)

	for _, guiObject in pages:GetChildren() do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		local name = guiObject.Name
		local rightPart = guiObject.RightPart
		local frame = rightPart.Frame
		local v15 = guiObject
		local v17 = topButtons[name]
		v3.Computed(function(callback)
			local visible = callback(self.CurrentPage) == name
			v15.Visible = visible

			if visible then
				frame.Price.TextBox.Text = ""
				frame.YouReceive.Visible = false
			end

			v17.Image = visible and "rbxassetid://18205032430" or "rbxassetid://18205023711"
			v17.HoverImage = visible and "rbxassetid://18208226931" or "rbxassetid://18208231836"
			v17.Label.UIStroke.Color = visible and Color3.fromRGB(149, 67, 0) or Color3.fromRGB(21, 56, 169)
			return nil
		end)
		local state = v3.State()
		self.SelectedSlots[name] = state
		self.PagesSearchs[name] = v3.State()
		self.LastSelectedFrames[name] = v3.State()
		v13[name] = {}
		local name2 = name
		local frame2 = frame
		v3.Computed(function(callback)
			local v22 = callback(state)

			if not v22 then
				rightPart.Visible = false
				return nil
			end

			local keyToItem = client2:KeyToItem(v22)
			rightPart.Visible = true
			local itemInfo = v8:GetItemInfo(name2, keyToItem.Name)
			frame2.Vector.Label.Text = itemInfo.DisplayName or itemInfo.Name
			frame2.Vector.Description.Text = itemInfo.Description or ""
			frame2.Vector.Image = itemInfo.Icon
			frame2.Price.TextBox.Text = ""
			frame2.YouReceive.Visible = false
			frame2.Rap.Visible = v7:IsEnabled()
			frame2.Rap.Coins.Amount.Text = "---"
			frame2.Rap.Coins.Amount.Text = v2.ValueConvertor:AddCommas(v7:GetRAPAsync(name2, v22) or 0)
			return nil
		end)
		local searchFrame = guiObject:FindFirstChild("SearchFrame")

		if searchFrame then
			local v22 = searchFrame
			local name3 = name

			local function update()
				local text = v22.Input.Box.Text

				if text and #text > 0 then
					self.PagesSearchs[name3]:Set(text:lower())
				else
					self.PagesSearchs[name3]:Set()
				end
			end

			searchFrame.Input.Box.Changed:Connect(update)
			searchFrame.Search.Activated:Connect(update)
		end

		local textBox = frame.Price.TextBox
		local frame3 = frame
		local amount = frame.YouReceive.Coins.Amount

		local function update()
			local text = textBox.Text
			local v25 = math.min(tonumber((text:gsub("%D", ""):sub(1, 9))) or 0, 100000000)
			frame3.YouReceive.Visible = true
			amount.Text = v2.ValueConvertor:AddCommas((math.floor(v25 * (1 - v4.TradeBoothTax))))
			textBox:SetAttribute("Value", v25)
			frame3.SellButton.Active = v25 > 0
			local v26 = v2.ValueConvertor:AddCommas(v25)
			local text2 = v26 == "0" and "" or v26

			if text == text2 then
				return
			end

			local count = 0

			for k in text:gmatch(",") do
				count += 1
			end

			local count2 = 0

			for k in text2:gmatch(",") do
				count2 += 1
			end

			if text ~= text2 then
				textBox.Text = text2
			end

			textBox.CursorPosition += math.max(0, count2 - count)
		end

		textBox:GetPropertyChangedSignal("Text"):Connect(update)
		local v25 = state
		local textBox2 = textBox
		frame.SellButton.Activated:Connect(function()
			local v27 = v25:Get()

			if thread and v27 and textBox2:GetAttribute("Value") then
				task.spawn(thread, v27, textBox2:GetAttribute("Value"))
			end
		end)
		local v27 = state
		local name4 = name
		rightPart.Frame.Rap.Coins.RapButton.Activated:Connect(function()
			local v29 = v27:Get()

			if not v29 or v9:Render("Booth", name4, v29) then
				return
			end

			warn("Failed to render RAP chart")
			v10:SendNotification("Failed to load RAP history. Try again later")
			v9:Close("Booth")
		end)
	end

	for _, button in topButtons:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		local v14 = button
		button.Activated:Connect(function()
			v9:Close("Booth")
			self.CurrentPage:Set(v14.Name)
		end)
	end

	v6:OnGuiOpen("BoothInventory", function()
		local v14 = self.CurrentPage:Get()

		if not v14 then
			return
		end

		local child = pages:FindFirstChild(v14)

		if not child then
			return
		end

		v9:Close("Booth")
		child.RightPart.Frame.Price.TextBox.Text = ""
		child.RightPart.Frame.YouReceive.Visible = false
	end)
	client:WaitReplion("Data")
	self:CreateInventory("Sword")
	self:CreateInventory("Emote")
	self:CreateInventory("Explosion")
end

return BoothInventoryUIController