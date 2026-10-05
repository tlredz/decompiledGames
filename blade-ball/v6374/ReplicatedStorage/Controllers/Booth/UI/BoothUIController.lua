local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Packages.Trove)
local v3 = require3(ReplicatedStorage2.Packages.Freeze)
local client = require3(ReplicatedStorage2.Packages.Replion).Client
local v4 = require3(ReplicatedStorage2.Common.Utils)
local v5 = require3(ReplicatedStorage2.Shared.ItemInfo)
local v6 = require3(ReplicatedStorage2.Shared.Statable)
local v7 = require3(ReplicatedStorage2.Packages.Observers)
local client2 = require3(ReplicatedStorage2.Shared.Inventory).Client
local v8 = require3(ReplicatedStorage2.Shared.Trading.TradeInfo)
local v9 = require3(ReplicatedStorage2.ServerInfo)
local v10 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v11 = require3(ReplicatedStorage2.Shared.ReplionUtils)
local v12 = require3(ReplicatedStorage2.Controllers.Booth.BoothController)
local v13 = require3(ReplicatedStorage2.ClientGameModules.CreatePriceLabel)
local v14 = require3(ReplicatedStorage2.Controllers.UI.ShopControllerAPI)
local v15 = require3(ReplicatedStorage2.Common.MarketplaceService)
local v16 = require3(ReplicatedStorage2.Controllers.Trading.IndexController)
local v17 = require3(ReplicatedStorage2.Controllers.Trading.TradeTokensController)
local v18 = require3(ReplicatedStorage2.Controllers.NotificationController)
local v19 = require3(ReplicatedStorage2.Controllers.Booth.UI.BoothInventoryUIController)
local v20 = require3(ReplicatedStorage2.Controllers.HoverInfoController)
local v21 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.SwordAccessories)
local v22 = require3(ReplicatedStorage2.Controllers.Trading.RAPController)
local v23 = require3(ReplicatedStorage2.Controllers.PromptController)
local v24 = require3(ReplicatedStorage2.Controllers.Trading.ExistCounterController)
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
local v25 = require3(ReplicatedStorage2.Shared.Inventory.Shared)
local v26 = {
	Common = {
		Image = "rbxassetid://18836303352",
		HoverImage = "rbxassetid://18836337450"
	},
	Rare = {
		Image = "rbxassetid://18836316451",
		HoverImage = "rbxassetid://18836346702"
	},
	Legendary = {
		Image = "rbxassetid://18836298229",
		HoverImage = "rbxassetid://18836339835"
	},
	Unique = {
		Image = "rbxassetid://18836308899",
		HoverImage = "rbxassetid://18836334772"
	},
	Limited = {
		Image = "rbxassetid://18836240662",
		HoverImage = "rbxassetid://18836349534"
	},
	LimitedU = {
		Image = "rbxassetid://18836240662",
		HoverImage = "rbxassetid://18836349534"
	}
}
local v27 = {
	Most = -1,
	Least = 1
}
local _ = {
	Explosion = 0,
	Sword = 1,
	Emote = 2
}
local v28 = {
	"Default",
	"Alphabetical",
	"RAP",
	"Creation Date",
	"Exists"
}
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local booth = playerGui:WaitForChild("Booth")
local playersBooth = booth.PlayersBooth
local myBooth = booth.MyBooth
local createListing = booth.CreateListing
local editBooth = booth.EditBooth
local history = booth.History
local v29 = v2.new()
local v30 = nil
local BoothUIController = {
	OpenView = function(self, p: string)
		if p ~= v30 then
			v29:Clean()
		end

		for _, image in booth:GetChildren() do
			if image:IsA("ImageLabel") then
				image.Visible = image.Name == p
			end
		end

		v30 = p
	end
}
local v31 = nil

function BoothUIController:DisplayError(text: string)
	local now = os.clock()
	v31 = now
	booth.Error.Text = text
	booth.Error.Visible = true
	task.delay(3, function()
		if v31 == now then
			booth.Error.Visible = false
		end
	end)
end

local maid = v2.new()
local v32 = nil

function BoothUIController:OpenPlayerBooth(player)
	v10:Open("Booth")
	self:OpenView("PlayersBooth")
	local playerName = playersBooth.Top.PlayerName
	playerName:SetAttribute("TextPreview", player.DisplayName)
	playerName:SetAttribute("TextReveal", player.Name)
	playerName:SetAttribute("RevealFormat", "%s's Booth")
	playerName:AddTag("TextHoverReveal")
	playersBooth.Top.PlayerProfile.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={player.UserId}&w=150&h=150`
	maid:Clean()
	v32 = player
	maid:Add(v11.observeTableContent(v12.BoothListings, { (tostring(player.UserId)) }, function(name: string, data)
		local maid2 = v2.new()
		local clone = playersBooth.ScrollingList.UIGridLayout.Frame:Clone()
		clone.LayoutOrder = -data.Price
		maid2:Add(clone)
		local itemInfo = v14:GetItemInfo(data.Type, data.ItemName)
		clone.Name = name
		clone.Frame.ItemName.Text = itemInfo.DisplayName or itemInfo.Name
		clone.Frame.Vector.Image = itemInfo.Icon or v4.Icons:GetIcon("DEFAULT_MISSING")
		local v33 = v8.SlotColors[itemInfo.Rarity] or v8.SlotColors.Default
		clone.Frame.Image = v33.Image
		clone.Frame.HoverImage = v33.HoverImage
		clone.Frame.ItemName.UIStroke.Color = v33.StrokeColor

		if data.Item and data.Item.Finisher and clone.Frame:FindFirstChild("Finisher") then
			clone.Frame.Finisher.Visible = true
			local child = ReplicatedStorage2.Misc.DataFinishers:FindFirstChild(data.ItemName)
			clone.Frame.Finisher.Icon.Image = child and child:GetAttribute("Icon") or v4.Icons:GetIcon("DEFAULT_MISSING")
		end

		if data.Item and data.Item.Accessory == true and clone.Frame:FindFirstChild("SwordAccessory") then
			clone.Frame.SwordAccessory.Visible = true
			local v34 = v21:GetCollection()[data.ItemName]
			clone.Frame.SwordAccessory.Icon.Image = v34 and v34.Icon or v4.Icons:GetIcon("DEFAULT_MISSING")
		end

		clone.BuyButton.List.Amount.Text = v4.ValueConvertor:AddCommas(data.Price)
		clone.Parent = playersBooth.ScrollingList
		local itemKey

		if data.Item then
			itemKey = client2:ItemToKey(data.Type, data.Item, { "TradeLock" })
		else
			itemKey = nil
		end

		if data.Item then
			local item = data.Item

			if item.TradeLock then
				item = table.clone(item)
				item.TradeLock = nil
			end

			v20:Add(clone.Frame, data.Type, item, itemKey)
		end

		maid2:Add(clone.BuyButton.Activated:Connect(function()
			v17:PromptConfirmation({
				Icon = itemInfo.Icon or v4.Icons:GetIcon("DEFAULT_MISSING"),
				Price = data.Price,
				Name = itemInfo.DisplayName,
				Type = data.Type or "",
				ItemKey = itemKey
			}, function(p, p2)
				if p then
					local purchaseListing, v35 = v12:PurchaseListing(player, name)

					if not purchaseListing then
						ReplicatedStorage2.Misc.error:Play()

						if v35 then
							self:DisplayError(v35)
						end
					end
				elseif p2 then
					v18:SendNotification(p2)
				end
			end)
		end))
		maid:Add(maid2)
		return function()
			maid2:Destroy()
		end
	end))
	v29:Add(maid)
end

function BoothUIController:OpenMyBooth()
	v10:Open("Booth")
	self:OpenView("MyBooth")
end

local v33 = nil

function BoothUIController:PromptCreateListing()
	v33 = nil
	local promptSync, v34 = v19:PromptSync()

	if not (promptSync and v34) then
		return
	end

	local inventoryType = v12:FindInventoryTypeFromKey(promptSync)

	if not inventoryType then
		return
	end

	local replion = client:GetReplion("Inventory")

	if not replion then
		return
	end

	local v35 = replion:Get({ "Listings" })

	if v35 and not (v3.Dictionary.count(v35) >= v8.MaxListingInBooth) then
		local keyToItem = client2:KeyToItem(promptSync)
		local itemInfo = v14:GetItemInfo(inventoryType, keyToItem.Name)
		local replion2 = client:GetReplion("Data")

		if replion2 and replion2:Get("TradeSettings.LowPriceWarning") == true then
			local fastGetRAP = v22:FastGetRAP(
				inventoryType,
				keyToItem,
				(v22:GetFilteredItemKey(inventoryType, keyToItem))
			)

			if fastGetRAP and v34 < fastGetRAP // 2 then
				local thread = coroutine.running()
				v23:CreatePrompt({
					PromptType = "Accept",
					Description = `⚠️ Warning: You are selling for {v34} Tokens, which is less than 50% of the RAP ({fastGetRAP}).\nAre you sure you want to continue?`,
					Title = "Low Price Alert",
					AcceptButtonText = "Confirm",
					DeclineButtonText = "Cancel"
				}, function(p)
					task.spawn(thread, p)
				end)

				if not coroutine.yield() then
					return
				end
			end
		end

		createListing.Label.Text = `<stroke color="rgb(8, 23, 73)" joins="round" thickness="2">Sell "<font color="rgb(120, 255, 98)">{itemInfo and itemInfo.DisplayName or keyToItem.Name}</font>" for</stroke>`
		createListing.List.Amount.Text = v4.ValueConvertor:AddCommas(v34)
		createListing.Template:ClearAllChildren()
		local v36 = v19.LastSelectedFrames[inventoryType]:Get()

		if v36 then
			local clone = v36:Clone()

			if clone:FindFirstChild("Stack") then
				clone.Stack:Destroy()
			end

			clone.AnchorPoint = Vector2.new(0.5, 0.5)
			clone.Position = UDim2.fromScale(0.5, 0.5)
			clone.Size = UDim2.fromScale(1, 1)
			clone.Parent = createListing.Template
		end

		if not v10:IsOpen("Booth") then
			v10:Open("Booth")
		end

		self:OpenView("CreateListing")
		v33 = {
			inventoryType,
			promptSync,
			1,
			v34
		}
	else
		v18:SendNotification("Max listing reached! Please delete a listing before creating a new one!")
		ReplicatedStorage2.Misc.error:Play()
	end
end

function BoothUIController:Start()
	if not v9.isTradingPlazaServer() then
		return
	end

	client:WaitReplion("Data")
	client:WaitReplion("Inventory")
	local v34 = client:WaitReplion("BoothListings")
	v7.observeTag("TradeBoothStand", function(instance)
		local proximityPrompt = instance.PrimaryPart:FindFirstChildWhichIsA("ProximityPrompt", true)

		if proximityPrompt then
			proximityPrompt.Triggered:Connect(function()
				local owner = instance:GetAttribute("Owner")

				if owner then
					if owner == localPlayer.UserId then
						self:OpenMyBooth()
						return
					end

					local playerByUserId = Players:GetPlayerByUserId(owner)

					if playerByUserId then
						self:OpenPlayerBooth(playerByUserId)
					end
				end
			end)
		end

		local v35 = v7.observeAttribute(instance, "Owner", function(p)
			local v36 = Players.LocalPlayer.UserId == p
			local v37 = tostring(p)

			if proximityPrompt then
				if v36 then
					proximityPrompt.ActionText = "Edit Booth"
				else
					proximityPrompt.ActionText = "Open Booth"
				end
			end

			local playerByUserId = Players:GetPlayerByUserId(p)
			local v38 = v7.observeChildren(instance, function(instance2)
				if not instance2:HasTag("TradeBooth") then
					return function() end
				end

				local topGui = instance2:WaitForChild("TopGui")
				topGui.Parent = playerGui
				topGui:AddTag("SurfaceGuiFocus")
				local scrollingFrame = topGui:WaitForChild("ScrollingFrame")
				local bottomGui = instance2:WaitForChild("BottomGui")
				bottomGui:AddTag("SurfaceGuiFocus")
				local username = bottomGui:WaitForChild("Frame"):WaitForChild("Username")
				username:SetAttribute("TextPreview", playerByUserId.DisplayName)
				username:SetAttribute("TextReveal", playerByUserId.Name)
				username:SetAttribute("RevealFormat", "%s's Booth")
				username:AddTag("TextHoverReveal")

				if v36 then
					local createListing2 = scrollingFrame.UIListLayout["~CreateListing"]
					createListing2.Activated:Connect(function()
						self:OpenMyBooth()
					end)
					createListing2.Parent = scrollingFrame
				end

				local v39 = v7.observeTag(`ListingsUI_{p}`, function(parent)
					local maxListingItems = parent:GetAttribute("MaxListingItems")
					local frame = parent:WaitForChild("UIListLayout"):WaitForChild("Frame")

					local function getMostExpensiveListings(maxListingItems2: number)
						local expect = v34:GetExpect(v37)
						local v40 = {}

						for k, v41 in expect do
							table.insert(v40, {
								ListingId = k,
								Price = v41.Price
							})
						end

						table.sort(v40, function(a, b)
							return a.Price > b.Price
						end)
						local listingIds = {}

						for i = 1, maxListingItems2 do
							local v41 = v40[i]

							if not v41 then
								break
							end

							table.insert(listingIds, v41.ListingId)
						end

						return listingIds
					end

					local v40 = v11.observeTableContent(v34, v37, function(name, data)
						if maxListingItems and not table.find(getMostExpensiveListings(maxListingItems), name) then
							return function() end
						end

						local itemInfo = v14:GetItemInfo(data.Type, data.ItemName)

						if not itemInfo then
							return function() end
						end

						local clone = frame:Clone()
						clone.LayoutOrder = -data.Price
						clone.Name = name
						clone.Template.ItemName.Text = itemInfo.DisplayName or itemInfo.Name
						clone.Template.Vector.Image = itemInfo.Icon or v4.Icons:GetIcon("DEFAULT_MISSING")
						local v41 = v8.SlotColors[itemInfo.Rarity] or v8.SlotColors.Default
						clone.Template.Image = v41.Image
						clone.Template.HoverImage = v41.HoverImage
						clone.Template.ItemName.UIStroke.Color = v41.StrokeColor

						if data.Item and data.Item.Finisher and clone.Template:FindFirstChild("Finisher") then
							clone.Template.Finisher.Visible = true
							local child = ReplicatedStorage2.Misc.DataFinishers:FindFirstChild(data.ItemName)
							clone.Template.Finisher.Icon.Image = child and child:GetAttribute("Icon") or v4.Icons:GetIcon("DEFAULT_MISSING")
						end

						if data.Item and data.Item.Accessory == true and clone.Template:FindFirstChild("SwordAccessory") then
							clone.Template.SwordAccessory.Visible = true
							local v42 = v21:GetCollection()[data.ItemName]
							clone.Template.SwordAccessory.Icon.Image = v42 and v42.Icon or v4.Icons:GetIcon("DEFAULT_MISSING")
						end

						clone.BuyButton.List.Amount.Text = v4.ValueConvertor:AddCommas(data.Price)
						clone.Parent = parent

						if data.Item then
							local item = data.Item

							if item.TradeLock then
								item = table.clone(item)
								item.TradeLock = nil
							end

							v20:Add(
								clone.Template,
								data.Type,
								item,
								client2:ItemToKey(data.Type, data.Item, { "TradeLock" })
							)
						end

						local activatedConnection = clone.Template.Activated:Connect(function()
							if v36 then
								self:OpenMyBooth()
							else
								self:OpenPlayerBooth(playerByUserId)
							end
						end)
						local activatedConnection2 = clone.BuyButton.Activated:Connect(function()
							if v36 then
								self:OpenMyBooth()
							else
								self:OpenPlayerBooth(playerByUserId)
							end
						end)
						return function()
							activatedConnection:Disconnect()
							activatedConnection2:Disconnect()
							clone:Destroy()
						end
					end)
					return function()
						v40()
					end
				end)
				scrollingFrame:AddTag((`ListingsUI_{p}`))
				return function()
					v39()
				end
			end)
			return function()
				if proximityPrompt then
					proximityPrompt.ActionText = "Claim Booth!"
				end

				if v32 == playerByUserId then
					v10:Close("Booth")
				end

				v38()
			end
		end)
		return function()
			v35()
		end
	end)
	playersBooth.Close.Activated:Connect(function()
		v10:Close("Booth")
	end)
	v10:OnGuiClose("Booth", function()
		v32 = nil
	end)
	myBooth.Close.Activated:Connect(function()
		v10:Close("Booth")
	end)
	myBooth.Buttons.EditBooth.Activated:Connect(function()
		self:OpenView("EditBooth")
	end)
	myBooth.Buttons.History.Activated:Connect(function()
		self:OpenView("History")
	end)
	local state = v6.State("")
	local state2 = v6.State("Default")
	local state3 = v6.State("Most")
	v11.observeTableContent(v34, tostring(localPlayer.UserId), function(p: string, data)
		local maid2 = v2.new()
		local clone = myBooth.ScrollingList.UIGridLayout.Frame:Clone()
		maid2:Add(clone)
		local itemInfo = v14:GetItemInfo(data.Type, data.ItemName)
		local name = itemInfo.Name
		clone.Name = itemInfo.DisplayName or name
		clone.ItemName.Text = itemInfo.DisplayName or itemInfo.Name
		clone.Vector.Image = itemInfo.Icon or v4.Icons:GetIcon("DEFAULT_MISSING")
		local v35 = v8.SlotColors[itemInfo.Rarity] or v8.SlotColors.Default
		clone.Image = v35.Image
		clone.HoverImage = v35.HoverImage
		clone.ItemName.UIStroke.Color = v35.StrokeColor

		if data.Item and data.Item.Finisher and clone:FindFirstChild("Finisher") then
			clone.Finisher.Visible = true
			local child = ReplicatedStorage2.Misc.DataFinishers:FindFirstChild(data.ItemName)
			clone.Finisher.Icon.Image = child and child:GetAttribute("Icon") or v4.Icons:GetIcon("DEFAULT_MISSING")
		end

		if data.Item and data.Item.Accessory == true and clone:FindFirstChild("SwordAccessory") then
			clone.SwordAccessory.Visible = true
			local v36 = v21:GetCollection()[data.ItemName]
			clone.SwordAccessory.Icon.Image = v36 and v36.Icon or v4.Icons:GetIcon("DEFAULT_MISSING")
		end

		clone.List.Amount.Text = v4.ValueConvertor:AddCommas(data.Price)
		clone.Parent = myBooth.ScrollingList

		if data.Item then
			local item = data.Item

			if item.TradeLock then
				item = table.clone(item)
				item.TradeLock = nil
			end

			v20:Add(clone, data.Type, item, client2:ItemToKey(data.Type, data.Item, { "TradeLock" }))
		end

		maid2:Add(clone.Delete.Activated:Connect(function()
			v12:DeleteListing(p)
		end))
		debug.profilebegin("getFilteredItemKey")
		local filteredItemKey = v22:GetFilteredItemKey(data.Type, data.Item)
		debug.profileend()
		local createdAt = itemInfo.CreatedAt
		local state4 = v6.State(0)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateRAP()
			state4:Set(v22:IsEnabled() and v22:FastGetRAP(data.Type, data.Item, filteredItemKey) or v22:ShouldShowRAP(
				data.Type,
				name
			) and 0 or -1)
		end

		local itemToKey = v25:ItemToKey(data.Type, data.Item, { "Id" })
		maid2:Add(task.spawn(function()
			client:WaitReplion("ItemRAP")
			maid2:Add(v22:OnRAPUpdated(data.Type, filteredItemKey, updateRAP))
		end))
		updateRAP() -- equivalent call inferred; original call site unknown
		local state5 = v6.State(-1)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateExistCounter()
			state5:Set(v24:IsEnabled("ClientExistCount") and v24:Get(data.Type, itemToKey, true, "ClientExistCount") or -1)
		end

		maid2:Add(task.spawn(function()
			client:WaitReplion("ClientExistCount")
			maid2:Add(v24:OnUpdated(data.Type, itemToKey, updateExistCounter, "ClientExistCount"))
			updateExistCounter() -- equivalent call inferred; original call site unknown
		end))
		local displayName = string.lower(itemInfo.DisplayName or itemInfo.Nam)
		maid2:Add(v6.setPropertyComputed(clone, "Visible", function(callback)
			local v36 = string.lower(callback(state))
			return #v36 <= 0 or displayName == v36 or string.sub(displayName, 1, #v36) == v36 or string.find(
				displayName,
				v36,
				1,
				true
			) ~= nil
		end))
		local v36 = itemInfo.Rarity and v14.RarityOrder[itemInfo.Rarity] or 0

		if data.ItemName ~= "Base Sword" and data.ItemName ~= "Explosion Normal" then
			v36 += 1
		end

		maid2:Add(v6.setPropertyComputed(clone, "LayoutOrder", function(callback)
			local v37 = not state2 and "Default" or callback(state2)

			if v37 == "RAP" then
				return callback(state4) * v27[callback(state3)]
			elseif v37 == "Exists" then
				return callback(state5) * v27[callback(state3)]
			elseif v37 == "Creation Date" then
				return (createdAt or 0) * v27[callback(state3)]
			elseif v37 == "Default" then
				return data.Price * v27[callback(state3)]
			end

			return 0
		end))
		return function()
			maid2:Destroy()
		end
	end)

	local function updateSearch()
		state:Set(string.lower(myBooth.ItemSearch.SearchBox.Text))
	end

	v6.setPropertyComputed(myBooth.ScrollingList.UIGridLayout, "SortOrder", function(callback)
		return callback(state2) == "Alphabetical" and Enum.SortOrder.Name or Enum.SortOrder.LayoutOrder
	end)
	myBooth.ItemSearch.SearchBox:GetPropertyChangedSignal("Text"):Connect(updateSearch)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function toggleSort()
		debug.profilebegin("toggleSort")
		state3:Set(state3:Get() == "Most" and "Least" or "Most")
		debug.profileend()
	end

	for _, v35 in v28 do
		local clone = myBooth.ItemSearch.Sort.FilterPopUp.UIListLayout.Template:Clone()
		clone.Name = v35
		clone.Label.Text = v35
		local v36 = v35
		v6.Computed(function(callback)
			local v38 = callback(state2) == v36
			clone.Image = v38 and "rbxassetid://18123223527" or "rbxassetid://18123248161"
			clone.HoverImage = v38 and "rbxassetid://18123872657" or "rbxassetid://18123874724"
			local uIStroke = clone.Label.UIStroke
			local color

			if v38 then
				color = Color3.fromRGB(149, 67, 0)
			else
				color = Color3.fromRGB(21, 56, 169)
			end

			uIStroke.Color = color
			return nil
		end)
		clone.Parent = myBooth.ItemSearch.Sort.FilterPopUp
		local v38 = v35
		clone.Activated:Connect(function()
			if state2:Get() == v38 then
				toggleSort() -- equivalent call inferred; original call site unknown
			else
				state3:Set("Most")
				state2:Set(v38)
			end

			myBooth.ItemSearch.Sort.FilterPopUp.Visible = false
		end)

		if v35 ~= "RAP" then
			continue
		end

		local v39 = clone
		task.spawn(function()
			local v40 = client:WaitReplion("ItemRAP")
			v6.setPropertyComputed(v39, "Visible", function(callback)
				return callback((v6.getReplionPathState(v40, "AllItemsLoaded")))
			end)
		end)
	end

	v6.setPropertyComputed(myBooth.ItemSearch.Sort.Arrow, "Rotation", function(callback)
		if callback(state3) == "Most" then
			return 0
		end

		return 180
	end)
	local v35 = 0
	myBooth.ItemSearch.Sort.Activated:Connect(function()
		local now = os.clock()
		local visible = not myBooth.ItemSearch.Sort.FilterPopUp.Visible

		if visible then
			v35 = now
		elseif now - v35 < 0.3 then
			toggleSort() -- equivalent call inferred; original call site unknown
		end

		myBooth.ItemSearch.Sort.FilterPopUp.Visible = visible
	end)
	myBooth.ScrollingList["~CreateListing"].Activated:Connect(function()
		self:PromptCreateListing()
	end)
	myBooth.Buttons.Unclaim.Activated:Connect(function()
		v12:UnclaimBooth()
		v10:Close("Booth")
	end)
	createListing.Buttons.Sell.Activated:Connect(function()
		if not v33 then
			return
		end

		local listing, v36 = v12:CreateListing(table.unpack(v33))
		v33 = nil

		if listing then
			self:OpenView("MyBooth")
			return
		end

		ReplicatedStorage2.Misc.error:Play()
		v18:SendNotification(v36 or "Internal server error")

		if v9.isTestGame() then
			warn("Failed to create booth listing:", listing, v36)
		end
	end)
	createListing.Buttons.Cancel.Activated:Connect(function()
		v33 = nil
		self:OpenView("MyBooth")
	end)
	createListing.Back.Activated:Connect(function()
		self:PromptCreateListing()
	end)
	local HUD = playerGui.HUD
	HUD.LeftFrame.Middle.MiddleStack.ToBooth.Visible = v9.isTradingPlazaServer()

	if v9.isTradingPlazaServer() then
		HUD.LeftFrame.Middle.MiddleStack.ToBooth.Activated:Connect(function()
			v:Invoke("TeleportToBooth")
		end)
	end

	history.Close.Activated:Connect(function()
		self:OpenView("MyBooth")
	end)
	editBooth.Close.Activated:Connect(function()
		self:OpenView("MyBooth")
	end)

	for k, v36 in v5.Booth do
		local clone = editBooth.List.ScrollingFrame.UIGridLayout.Template:Clone()
		local rarity = v36.Rarity or "Common"
		local v37 = v26[rarity]
		clone.Image = v37.Image
		clone.HoverImage = v37.HoverImage
		clone.Name = (k == "Normal" and "!" or "") .. k
		clone.ItemName.Text = v36.DisplayName
		clone.Icon.Image = v36.Icon or v4.Icons:GetIcon("DEFAULT_MISSING")
		local itemKey = v14:ParseItemKey("Booth", {
			Name = k
		})
		v20:Add(clone, "Booth", {
			Name = k
		}, itemKey)
		local boothData = v14:GetBoothData(itemKey)

		if v36.CoinsPrice then
			clone.Coins.List.Label.Text = v4.ValueConvertor:AddCommas(v36.CoinsPrice)
		elseif v36.DevProductId then
			v13(clone.Robux.Label, v36.DevProductId, "DevProduct", ":robux: %s")
		elseif v36.GamePassId then
			v13(clone.Robux.Label, v36.GamePassId, "GamePass", ":robux: %s")
		end

		local v39 = k
		local v40 = v36
		clone.Activated:Connect(function()
			if boothData.OwnedCopies:Get() > 0 then
				v:Invoke("RequestEquipBooth", client2:FindItems("Booth", v39)[1])
			elseif v40.CoinsPrice then
				v:Invoke("RequestBuyBooth", v39)
			elseif v40.DevProductId then
				v17:PromptPurchase(v40.DevProductId, Enum.InfoType.Product)
			elseif v40.GamePassId then
				v15:TradeTokensController(v40.GamePassId, Enum.InfoType.GamePass)
			end
		end)
		local v41 = boothData
		local alwaysShow = boothData.ItemInfo.AlwaysShow
		local v44 = v36
		v6.Computed(function(callback)
			local v46 = callback(v41.OwnedCopies) > 0
			local visible = v46 or alwaysShow
			clone.Visible = visible

			if not visible then
				return nil
			end

			clone.Coins.Visible = not v46 and v44.CoinsPrice
			clone.Robux.Visible = not v46 and (v44.DevProductId or v44.GamePassId)
			local visible2 = callback(v41.IsEquipped)
			clone.Equipped.Visible = visible2
			clone.Glow.Visible = visible2
			clone.Black.Visible = not v46 and (rarity == "Unique" or not (v44.CoinsPrice or v44.DevProductId or v44.GamePassId))
			clone.LayoutOrder = visible2 and -10000 or (v44.Order or 0) + (v46 and -1000 or 0)
			return nil
		end)
		clone.Parent = editBooth.List.ScrollingFrame
	end

	v:Connect("OpenPlayerBooth", function(instance)
		if not (instance and instance:IsDescendantOf(game)) then
			return
		end

		local tagged = CollectionService:GetTagged("TradeBoothStand")

		for _, v36 in tagged do
			local owner = v36:GetAttribute("Owner")
			local playerByUserId = owner and Players:GetPlayerByUserId(owner)

			if not (playerByUserId and playerByUserId == instance) then
				continue
			end

			if v10:IsOpen("Index") then
				v16:Close()
			end

			self:OpenPlayerBooth(playerByUserId)
			break
		end
	end)
end

return BoothUIController