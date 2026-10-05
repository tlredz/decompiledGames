local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("StarterGui")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("packages")
local Trove = require(packages.Trove)
local Net = require(packages.Net)
local legacyControllers = ReplicatedStorage:WaitForChild("client").legacyControllers
local DataController = require(legacyControllers.DataController)
local RAPController = require(legacyControllers.RAPController)
local modules = ReplicatedStorage.client.modules
local legacyLocalPlayerData = require(modules.legacyLocalPlayerData)
local modules2 = ReplicatedStorage:WaitForChild("shared").modules
local RodSkins = require(modules2.RodSkins)
local vessels = require(modules2.vessels)
local library = vessels.library
local bobbers = require(modules2.fishing.bobbers)
local bobbers2 = bobbers.Bobbers
local NumberUtils = require(ReplicatedStorage.shared.utils.NumberUtils)
local halos = require(ReplicatedStorage.shared.modules.library.halos)
local lanterns = require(ReplicatedStorage.shared.modules.library.lanterns)
local SalesBooth = require(ReplicatedStorage.shared.modules.SalesBooth)
require(ReplicatedStorage.shared.modules.library.items.gliderdata)
local items = require(ReplicatedStorage.shared.modules.library.items)
local skins = require(ReplicatedStorage.shared.modules.library.companions.skins)
local remoteEvent = Net:RemoteEvent("SalesBoothService/AddItem")
local remoteEvent2 = Net:RemoteEvent("SalesBoothService/UpdateInfo")
local itemList = nil
local SellItem = {}
SellItem.__index = SellItem

local function parsePriceInput(text: string)
	if text == "" then
		return -1
	end

	local lower = text:gsub(",", ""):gsub("%s+", ""):lower()

	if text:find("e%+") then
		return (tonumber(text))
	end

	local v = string.match(lower, "^([%d%.]+)")

	if not v then
		return nil
	end

	local v2 = tonumber(v)

	if not v2 then
		return nil
	end

	local v3 = string.sub(lower, #v + 1, #v + 1)
	local v4 = {
		k = 1000,
		m = 1000000,
		b = 1000000000,
		t = 1000000000000
	}

	if v4[v3] then
		v2 *= v4[v3]
	end

	return (math.floor(v2))
end

local function updateTaxPreview(sellAmount, itemInfo)
	local amount = sellAmount:FindFirstChild("Amount")
	local item = itemInfo and itemInfo:FindFirstChild("Item")
	local taxPreview = item and item:FindFirstChild("TaxPreview")

	if not taxPreview then
		return
	end

	if amount.Text == "" then
		taxPreview.Text = "Leave price blank to list the item for <b>Trading only</b>."
		taxPreview.Size = UDim2.fromScale(1.5, 0.3)
		itemInfo.Sell.Label.Text = "List for Trading"
	else
		itemInfo.Sell.Label.Text = "Sell"
		taxPreview.Size = UDim2.fromScale(1.5, 0.2)
		local v = parsePriceInput(amount.Text)

		if v and v > 0 then
			taxPreview.Text = `You'll receive: <b>S$ {v - math.floor(v * 0.1)}</b> <font transparency="0.4">(10% tax)</font>`
		else
			taxPreview.Text = ""
		end
	end
end

function SellItem:ToggleSelected(flag: boolean, lastType: string, lastIndex: string)
	local uDim = UDim2.fromScale(0.567, 0.725)
	local uDim2 = UDim2.fromScale(0.567, 0.09)
	local uDim3 = UDim2.fromScale(0.208, 0.268)
	local uDim4 = UDim2.fromScale(0.981, 0.725)
	local uDim5 = UDim2.fromScale(0.981, 0.09)
	local uDim6 = UDim2.fromScale(0.12, 0.268)

	if flag == true then
		self.LastType = lastType
		self.LastIndex = lastIndex
		self.Instance.ItemList.Size = uDim
		self.Instance.Sort.Size = uDim2
		self.Instance.ItemList.List.ScrollingFrame.UIGridLayout.CellSize = uDim3
		local displayText = ""
		local targetRod = ""
		local icon = ""

		if lastType == "RodSkins" then
			local skin = RodSkins.Skins[lastIndex]
			displayText = skin.DisplayText or lastIndex
			targetRod = skin.TargetRod
			icon = skin.Icon or ""
		elseif lastType == "Boat" then
			local v = library[lastIndex]
			displayText = v.DisplayText or lastIndex
			icon = v.Icon or ""
		elseif lastType == "Bobber" then
			local bobber = bobbers2[lastIndex]
			displayText = bobber.Name or lastIndex
			icon = bobber.Icon or ""
		elseif lastType == "Halo" then
			local halo = halos[lastIndex]
			displayText = halo.DisplayText or lastIndex
			icon = halo.Icon or ""
		elseif lastType == "Lantern" then
			local lantern = lanterns[lastIndex]
			displayText = lantern.DisplayText or lastIndex
			icon = lantern.Icon or ""
		elseif lastType == "BoothSkin" then
			local SalesBooth2 = require(ReplicatedStorage.shared.modules.SalesBooth)
			local item = SalesBooth2.Items[lastIndex]
			displayText = item.DisplayName or lastIndex
			icon = item.Icon or ""
		elseif lastType == "Glider" then
			DataController.InventoryReplicator:WaitForLoaded()
			local v = DataController.InventoryReplicator:TryIndex({ "Inventory", lastIndex })

			if v then
				local item = items.Items[v.name]
				displayText = v.name
				icon = item and item.Icon or ""
			end
		elseif lastType == "CompanionSkin" then
			local skin = skins.Skins[lastIndex]

			if skin then
				displayText = skin.DisplayText or lastIndex
			else
				displayText = lastIndex
			end

			icon = skin and skin.Icon or ""
		end

		self.Instance.ItemInfo.Item.Icon.Image = icon
		self.Instance.ItemInfo.Item.Label.Text = displayText
		self.Instance.ItemInfo.AdditionalInfo.Text = targetRod
		self.Instance.ItemInfo.RAP.Text = "Sales Average: ..."
		self.Instance.ItemInfo.RAP.Visible = true
		task.spawn(function()
			local rAPAsync = RAPController:GetRAPAsync(lastType, displayText or lastIndex)

			if rAPAsync then
				self.Instance.ItemInfo.RAP.Text = `Sales Average: S$ {NumberUtils:ToString(rAPAsync, 2)}`
			else
				self.Instance.ItemInfo.RAP.Text = "Sales Average: N/A"
			end
		end)
		self.Instance.ItemInfo.SellAmount.Amount.Text = ""
		self.Instance.ItemInfo.SellAmount.Amount.PlaceholderText = "0"
		updateTaxPreview(self.Instance.ItemInfo.SellAmount, self.Instance.ItemInfo)
		self.Instance.ItemInfo.Visible = true
	else
		self.Instance.ItemList.Size = uDim4
		self.Instance.Sort.Size = uDim5
		self.Instance.ItemList.List.ScrollingFrame.UIGridLayout.CellSize = uDim6
		self.Instance.ItemInfo.Visible = false
		self.Instance.ItemInfo.RAP.Text = ""
	end
end

function SellItem:Update()
	self.Collector:Clean()
	self.Collector:Add(coroutine.running())
	DataController.PlayerDataReplicator:WaitForLoaded()

	if not itemList then
		itemList = DataController.PlayerDataReplicator:Index({ "SalesBooth", "ItemList" })

		if not itemList then
			warn("no sales booth data found?? how?? help??")
			return
		end
	end

	local v = itemList
	local fetched = legacyLocalPlayerData.fetch()
	local _ = fetched.Cache
	local index = DataController.PlayerDataReplicator:Index({ "RodSkins" })
	local boats = fetched.Boats
	local bobber = fetched.Stats.bobber
	self.LastAmountOfItems = #v

	if self.FilterType == "RodSkins" then
		local v2 = {}

		for _, v3 in v do
			if v3.Type == "RodSkins" then
				v2[v3.Index] = (v2[v3.Index] or 0) + 1
			end
		end

		local v3 = {}
		local v4 = {}

		for k, v5 in index do
			if typeof(v5) ~= "table" or k == "" or (v5.stack or 0) <= 0 then
				continue
			end

			local skin = RodSkins.Skins[k]

			if not skin or skin.Untradeable or not (v5.stack > (v2[k] or 0)) then
				continue
			end

			if self.SearchString == "" then
				table.insert(v3, k)
			else
				local displayText = SalesBooth.Types.RodSkins.Data[k].DisplayText or k

				if string.find(string.lower(displayText), string.lower(self.SearchString)) ~= nil then
					table.insert(v3, k)
				end
			end

			v4[k] = v5.stack - (v2[k] or 0)
		end

		table.sort(v3, function(a, b)
			return string.lower(a) < string.lower(b)
		end)

		for i = 1, #v3 do
			local v5 = v3[i]
			local skin = RodSkins.Skins[v5]

			if not skin then
				continue
			end

			local clone = self.Instance.ItemList.List.ScrollingFrame.Template:Clone()
			clone.Parent = self.Instance.ItemList.List.ScrollingFrame
			clone.Label.Text = skin.DisplayText or v5
			clone.count.Text = `×{NumberUtils:Comma(index[v5].stack - (v2[v5] or 0))}`
			clone.Icon.Image = skin.Icon or ""
			clone.Visible = true
			self.Collector:Add(clone)
			local v6 = v5
			self.Collector:Add(clone.Activated:Connect(function()
				self:ToggleSelected(true, self.FilterType, v6)
			end))
		end
	elseif self.FilterType == "Boat" then
		local v2 = {}

		for _, v3 in v do
			if v3.Type == "Boat" then
				v2[v3.Index] = (v2[v3.Index] or 0) + 1
			end
		end

		local names = {}
		local v3 = {}

		for _, child in boats:GetChildren() do
			local name = child.Name

			if name == "" or (tonumber(child.Value) or 0) <= 0 then
				continue
			end

			local v4 = library[name]

			if not v4 or v4.Untradeable then
				continue
			end

			local value = tonumber(child.Value)

			if not ((v2[name] or 0) < value) then
				continue
			end

			if self.SearchString == "" then
				table.insert(names, name)
			elseif string.find(string.lower(name), string.lower(self.SearchString)) ~= nil then
				table.insert(names, name)
			end

			v3[name] = value - (v2[name] or 0)
		end

		table.sort(names, function(a, b)
			return string.lower(a) < string.lower(b)
		end)

		for i = 1, #names do
			local v4 = names[i]
			local v5 = library[v4]

			if not v5 then
				continue
			end

			local clone = self.Instance.ItemList.List.ScrollingFrame.Template:Clone()
			clone.Parent = self.Instance.ItemList.List.ScrollingFrame
			clone.Label.Text = v5.DisplayText or v4
			clone.count.Text = `×{NumberUtils:Comma(v3[v4])}`
			clone.Icon.Image = v5.Icon or ""
			clone.Visible = true
			self.Collector:Add(clone)
			local v6 = v4
			self.Collector:Add(clone.Activated:Connect(function()
				self:ToggleSelected(true, self.FilterType, v6)
			end))
		end
	elseif self.FilterType == "Bobber" then
		local v2 = {}

		for _, v3 in v do
			if v3.Type == "Bobber" then
				v2[v3.Index] = (v2[v3.Index] or 0) + 1
			end
		end

		local names = {}
		local v3 = {}

		for _, child in bobber:GetChildren() do
			local name = child.Name

			if name == "" or (tonumber(child.Value) or 0) <= 0 then
				continue
			end

			local bobber2 = bobbers2[name]

			if not bobber2 or bobber2.Untradeable then
				continue
			end

			local value = tonumber(child.Value)

			if not ((v2[name] or 0) < value) then
				continue
			end

			if self.SearchString == "" then
				table.insert(names, name)
			elseif string.find(string.lower(name), string.lower(self.SearchString)) ~= nil then
				table.insert(names, name)
			end

			v3[name] = value - (v2[name] or 0)
		end

		table.sort(names, function(a, b)
			return string.lower(a) < string.lower(b)
		end)

		for i = 1, #names do
			local v4 = names[i]
			local bobber2 = bobbers2[v4]

			if not bobber2 then
				continue
			end

			local clone = self.Instance.ItemList.List.ScrollingFrame.Template:Clone()
			clone.Parent = self.Instance.ItemList.List.ScrollingFrame
			clone.Label.Text = bobber2.Name or v4
			clone.count.Text = `×{NumberUtils:Comma(v3[v4])}`
			clone.Icon.Image = bobber2.Icon or ""
			clone.Visible = true
			self.Collector:Add(clone)
			local v5 = v4
			self.Collector:Add(clone.Activated:Connect(function()
				self:ToggleSelected(true, self.FilterType, v5)
			end))
		end
	elseif self.FilterType == "Halo" then
		local v2 = {}

		for _, v3 in v do
			if v3.Type == "Halo" then
				v2[v3.Index] = (v2[v3.Index] or 0) + 1
			end
		end

		DataController.PlayerDataReplicator:WaitForLoaded()
		local v3 = {}
		local v4 = {}

		for k, v5 in DataController.PlayerDataReplicator:Index({ "Halos", "Owned" }) do
			if not v5 or not v5.stack or v5.stack <= 0 then
				continue
			end

			local halo = halos[k]

			if not halo or halo.Untradeable or not (v5.stack > (v2[k] or 0)) then
				continue
			end

			if self.SearchString == "" then
				table.insert(v3, k)
			elseif string.find(string.lower(k), string.lower(self.SearchString)) ~= nil then
				table.insert(v3, k)
			end

			v4[k] = v5.stack - (v2[k] or 0)
		end

		table.sort(v3, function(a, b)
			return string.lower(a) < string.lower(b)
		end)

		for i = 1, #v3 do
			local v5 = v3[i]
			local halo = halos[v5]

			if not halo then
				continue
			end

			local clone = self.Instance.ItemList.List.ScrollingFrame.Template:Clone()
			clone.Parent = self.Instance.ItemList.List.ScrollingFrame
			clone.Label.Text = halo.DisplayText or v5
			clone.count.Text = `×{NumberUtils:Comma(v4[v5])}`
			clone.Icon.Image = halo.Icon or ""
			clone.Visible = true
			self.Collector:Add(clone)
			local v6 = v5
			self.Collector:Add(clone.Activated:Connect(function()
				self:ToggleSelected(true, self.FilterType, v6)
			end))
		end
	elseif self.FilterType == "Lantern" then
		local lanterns2 = legacyLocalPlayerData.fetch().Lanterns
		local v2 = {}

		for _, v3 in v do
			if v3.Type == "Lantern" then
				v2[v3.Index] = (v2[v3.Index] or 0) + 1
			end
		end

		local names = {}
		local v3 = {}

		for _, child in lanterns2:GetChildren() do
			local name = child.Name

			if name == "" or (tonumber(child.Value) or 0) <= 0 then
				continue
			end

			local lantern = lanterns[name]

			if not lantern or lantern.Untradeable then
				continue
			end

			local value = tonumber(child.Value) or 1

			if not ((v2[name] or 0) < value) then
				continue
			end

			if self.SearchString == "" then
				table.insert(names, name)
			elseif string.find(string.lower(name), string.lower(self.SearchString)) ~= nil then
				table.insert(names, name)
			end

			v3[name] = value - (v2[name] or 0)
		end

		table.sort(names, function(a, b)
			return string.lower(a) < string.lower(b)
		end)

		for i = 1, #names do
			local v4 = names[i]
			local lantern = lanterns[v4]

			if not lantern then
				continue
			end

			local clone = self.Instance.ItemList.List.ScrollingFrame.Template:Clone()
			clone.Parent = self.Instance.ItemList.List.ScrollingFrame
			clone.Label.Text = lantern.DisplayText or v4
			clone.count.Text = `×{NumberUtils:Comma(v3[v4])}`
			clone.Icon.Image = lantern.Icon or ""
			clone.Visible = true
			self.Collector:Add(clone)
			local v5 = v4
			self.Collector:Add(clone.Activated:Connect(function()
				self:ToggleSelected(true, self.FilterType, v5)
			end))
		end
	elseif self.FilterType == "BoothSkin" then
		local v2 = {}

		for _, v3 in v do
			if v3.Type == "BoothSkin" then
				v2[v3.Index] = (v2[v3.Index] or 0) + 1
			end
		end

		DataController.PlayerDataReplicator:WaitForLoaded()
		local v3 = {}
		local v4 = {}

		for k, v5 in DataController.PlayerDataReplicator:Index({ "SalesBooth", "Skins" }) do
			local v6 = 0
			local stack

			if typeof(v5) == "table" then
				stack = v5.stack or 0
			else
				stack = v5 == true and 1 or v6
			end

			if stack <= 0 then
				continue
			end

			local item = SalesBooth.Items[k]

			if not item or item.Untradeable or k == "Default" or not ((v2[k] or 0) < stack) then
				continue
			end

			if self.SearchString == "" then
				table.insert(v3, k)
			elseif string.find(string.lower(k), string.lower(self.SearchString)) ~= nil then
				table.insert(v3, k)
			end

			v4[k] = stack - (v2[k] or 0)
		end

		table.sort(v3, function(a, b)
			return string.lower(a) < string.lower(b)
		end)

		for i = 1, #v3 do
			local v5 = v3[i]
			local item = SalesBooth.Items[v5]

			if not item then
				continue
			end

			local clone = self.Instance.ItemList.List.ScrollingFrame.Template:Clone()
			clone.Parent = self.Instance.ItemList.List.ScrollingFrame
			clone.Label.Text = item.DisplayName or v5
			clone.count.Text = `×{NumberUtils:Comma(v4[v5])}`
			clone.Icon.Image = item.Icon or ""
			clone.Visible = true
			self.Collector:Add(clone)
			local v6 = v5
			self.Collector:Add(clone.Activated:Connect(function()
				self:ToggleSelected(true, self.FilterType, v6)
			end))
		end
	elseif self.FilterType == "Glider" then
		local gliderdata = require(ReplicatedStorage.shared.modules.library.items.gliderdata)
		local items2 = require(ReplicatedStorage.shared.modules.library.items)
		DataController.InventoryReplicator:WaitForLoaded()
		local index2 = DataController.InventoryReplicator:Index({ "Inventory" })
		local v2 = {}

		for _, v3 in v do
			if v3.Type == "Glider" then
				v2[v3.Index] = true
			end
		end

		local v3 = {}

		for k, v4 in index2 do
			if not gliderdata[v4.name] or items2.Items[v4.name] and items2.Items[v4.name].Untradeable then
				continue
			end

			if not (not v4.sub.CanTradeIn or not (v4.sub.CanTradeIn > workspace:GetServerTimeNow()) and v4.sub.CanTradeIn ~= -1) then
				continue
			end

			if not (v4.name ~= "Forbidden Plesiosaur" or v4.sub.Serial and not (v4.sub.Serial >= 1185 and v4.sub.Serial <= 1276)) or v2[k] then
				continue
			end

			if not (self.SearchString == "" or string.find(string.lower(v4.name), string.lower(self.SearchString)) ~= nil) then
				continue
			end

			table.insert(v3, {
				id = k,
				name = v4.name
			})
		end

		table.sort(v3, function(a, b)
			return string.lower(a.name) < string.lower(b.name)
		end)

		for _, v4 in v3 do
			local item = items2.Items[v4.name]
			local clone = self.Instance.ItemList.List.ScrollingFrame.Template:Clone()
			clone.Parent = self.Instance.ItemList.List.ScrollingFrame
			clone.Label.Text = v4.name
			clone.Icon.Image = item and item.Icon or ""
			clone.Visible = true
			self.Collector:Add(clone)
			local v5 = v4
			self.Collector:Add(clone.Activated:Connect(function()
				self:ToggleSelected(true, self.FilterType, v5.id)
			end))
		end
	elseif self.FilterType == "CompanionSkin" then
		local v2 = {}

		for _, v3 in v do
			if v3.Type == "CompanionSkin" then
				v2[v3.Index] = (v2[v3.Index] or 0) + 1
			end
		end

		DataController.PlayerDataReplicator:WaitForLoaded()
		local v3 = {}
		local v4 = {}

		for k, v5 in DataController.PlayerDataReplicator:Index({ "Companions", "Skins" }) do
			local v6 = typeof(v5) ~= "table" and 0 or v5.stack or 0

			if v6 <= 0 then
				continue
			end

			local skin = skins.Skins[k]

			if not skin or skin.Untradeable or not ((v2[k] or 0) < v6) then
				continue
			end

			if self.SearchString == "" then
				table.insert(v3, k)
			else
				local displayText = skin.DisplayText or k

				if string.find(string.lower(displayText), string.lower(self.SearchString)) ~= nil then
					table.insert(v3, k)
				end
			end

			v4[k] = v6 - (v2[k] or 0)
		end

		table.sort(v3, function(a, b)
			return string.lower(a) < string.lower(b)
		end)

		for i = 1, #v3 do
			local v5 = v3[i]
			local skin = skins.Skins[v5]

			if not skin then
				continue
			end

			local clone = self.Instance.ItemList.List.ScrollingFrame.Template:Clone()
			clone.Parent = self.Instance.ItemList.List.ScrollingFrame
			clone.Label.Text = skin.DisplayText or v5
			clone.count.Text = `×{NumberUtils:Comma(v4[v5])}`
			clone.Icon.Image = skin.Icon or ""
			clone.Visible = true
			self.Collector:Add(clone)
			local v6 = v5
			self.Collector:Add(clone.Activated:Connect(function()
				self:ToggleSelected(true, self.FilterType, v6)
			end))
		end
	end

	self:ToggleSelected(false)
end

function SellItem:Toggle(visible: boolean?)
	if visible == nil then
		visible = not self.Instance.Visible or nil
	end

	local visible2 = self.Instance.Visible
	self.Instance.Visible = visible

	if visible ~= visible2 then
		if visible == false then
			self.Collector:Clean()

			if self.CloseCallback then
				self.CloseCallback(self.Instance.Name)
			end
		else
			self:ToggleSelected(false)
			self:Update()
		end
	end
end

function SellItem:IsOpen()
	return self.Instance.Visible == true
end

function SellItem.new(instance)
	local object = setmetatable({}, SellItem)
	object.Instance = instance
	object.Collector = Trove.new()
	object.FilterType = "RodSkins"
	object.SearchString = ""
	object.Instance:FindFirstChild("Close").Activated:Connect(function()
		object.OpenUI("EditBooth")
	end)
	remoteEvent2.OnClientEvent:Connect(function(_, p)
		if p.Owner == Players.LocalPlayer then
			itemList = p.ItemList

			if object:IsOpen() then
				object:Update()
			end

			if object.LastAmountOfItems then
				if #p.ItemList > object.LastAmountOfItems then
					object.OpenUI("EditBooth")
				end

				object.LastAmountOfItems = #p.ItemList
			end
		end
	end)
	object.Instance.ItemInfo.Sell.Activated:Connect(function()
		if not (object.LastType and object.LastIndex) then
			return
		end

		local v = parsePriceInput(object.Instance.ItemInfo.SellAmount.Amount.Text)

		if v == nil then
			ReplicatedStorage.events.anno_localthought:Fire("Invalid price!")
		else
			remoteEvent:FireServer(object.LastType, object.LastIndex, v)
		end
	end)
	local amount = object.Instance.ItemInfo.SellAmount.Amount
	amount:GetPropertyChangedSignal("Text"):Connect(function()
		updateTaxPreview(object.Instance.ItemInfo.SellAmount, object.Instance.ItemInfo)
	end)
	amount.FocusLost:Connect(function()
		local v = parsePriceInput(amount.Text)

		if v and not (v <= 0) then
			amount.Text = NumberUtils:Comma(v)
		else
			amount.Text = ""
		end

		updateTaxPreview(object.Instance.ItemInfo.SellAmount, object.Instance.ItemInfo)
	end)
	updateTaxPreview(object.Instance.ItemInfo.SellAmount, object.Instance.ItemInfo)
	local textBox = object.Instance.Sort.Container.Search.TextBox
	textBox:GetPropertyChangedSignal("Text"):Connect(function()
		object.SearchString = textBox.Text

		if object:IsOpen() then
			object:Update()
		end
	end)

	for _, button in object.Instance.Sort.Container:GetChildren() do
		if not button:IsA("ImageButton") then
			continue
		end

		local v = button
		button.Activated:Connect(function()
			object.FilterType = v.Name

			if object:IsOpen() then
				object:Update()
			end
		end)
	end

	for _, button in object.Instance.NewTradables:GetChildren() do
		if not button:IsA("ImageButton") then
			continue
		end

		local v = button
		button.Activated:Connect(function()
			object.FilterType = v.Name

			if object:IsOpen() then
				object:Update()
			end
		end)
	end

	return object
end

return SellItem