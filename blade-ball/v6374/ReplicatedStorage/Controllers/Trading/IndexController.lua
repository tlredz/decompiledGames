local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ProximityPromptService = game:GetService("ProximityPromptService")
game:GetService("ServerScriptService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage3:WaitForChild("UserInputService"))
game:GetService("StarterGui")
game:GetService("RunService")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Packages.Freeze)
local v3 = require3(ReplicatedStorage2.Packages.Trove)
local v4 = require3(ReplicatedStorage2.Packages.Net)
local v5 = require3(ReplicatedStorage2.ClientGameModules.DeviceListener)
local v6 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v7 = require3(ReplicatedStorage2.Common.Utils)
local v8 = require3(ReplicatedStorage2.Controllers.FinishersController)
local v9 = require3(ReplicatedStorage2.Controllers.Trading.InventoryController)
local v10 = require3(ReplicatedStorage2.Controllers.ShowRoomController)
local v11 = require3(ReplicatedStorage2.Controllers.Trading.RAPController)
local v12 = require3(ReplicatedStorage2.Controllers.PromptController)
local v13 = nil
local v14 = require3(ReplicatedStorage2.Shared.FastUtils)
local client = require3(ReplicatedStorage2.Shared.Inventory).Client
local v15 = require3(ReplicatedStorage2.Shared.Inventory.Internal.DefaultItems)
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
local v16 = require3(ReplicatedStorage2.Shared.Trading.TradeInfo)
local v17 = require3(ReplicatedStorage2.Shared.UntradableItems)
local v18 = require3(ReplicatedStorage2.Shared.IndexData)
local v19 = require3(ReplicatedStorage2.Shared.ItemInfo)
local v20 = require3(ReplicatedStorage2.Shared.Statable)
require3(ReplicatedStorage2.Common.RewardInfo)
local v22 = false
local v23 = require3(ReplicatedStorage2.Packages.Signal).new()
local v24 = require3(ReplicatedStorage2.ServerInfo)
local v25 = {
	[true] = {
		Image = "rbxassetid://15697987058",
		HoverImage = "rbxassetid://15697983062"
	},
	[false] = {
		Image = "rbxassetid://15697981750",
		HoverImage = "rbxassetid://15697987058"
	}
}
local v26 = {
	"Default",
	"Alphabetical",
	"RAP",
	"Creation Date",
	"Exists"
}
local v27 = { "Sword", "Explosion", "Emote" }
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local indexScreenBlackout = playerGui.IndexScreenBlackout
local index = playerGui.Index
local main = index.Main
local mainLabel = main.Left.MainLabel
local mainLabel2 = main.Right.MainLabel
local itemPreview = mainLabel.ItemPreview
local onlineSellers = mainLabel2.OnlineSellers
local searchBox = mainLabel.ItemSearch.SearchBox
local v28 = false
local _ = workspace.CurrentCamera
local state = v20.State("Teleport")
local maid = v3.new()
local v29 = false
local flag = false
local remoteFunction = v4:RemoteFunction("TradePlaza/TeleportToListing")
local remoteFunction2 = v4:RemoteFunction("TradePlaza/GetItemListings")
local remoteEvent = v4:RemoteEvent("Index/Favorite")
local state2 = v20.State("Sword")
local state3 = v20.State("")
local state4 = v20.State("Default")
local state5 = v20.State("Most")
local state6 = v20.State("All")
local state7 = v20.State(true)
local state8 = v20.State(false)
local v30 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function openRapChart(p, p2)
	v13:Render("Index", p, client:ItemToKey(p, p2))
	v13:Open("Index")
end

local function setSearch()
	if flag then
		return
	end

	flag = true
	indexScreenBlackout.Blackout.BackgroundTransparency = 1
	indexScreenBlackout.Spinner.ImageTransparency = 0
	indexScreenBlackout.Spinner.Rotation = 0
	indexScreenBlackout.Enabled = true
	v14.fastTween(indexScreenBlackout.Blackout, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.2
	})
	v14.fastTween(
		indexScreenBlackout.Spinner,
		TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
		{
			Rotation = 360
		}
	)
end

local function removeSearch()
	if not flag then
		return
	end

	flag = false
	v14.fastTween(indexScreenBlackout.Blackout, TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		BackgroundTransparency = 1
	})
	v14.fastTween(indexScreenBlackout.Spinner, TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		ImageTransparency = 1
	}).Completed:Once(function()
		indexScreenBlackout.Enabled = false
	end)
end

local IndexController = {
	GetCurrentPage = function(_)
		return state2:Get()
	end,
	SetPage = function(_, p: string)
		table.insert(v30, state2:Get())
		state2:Set(p)
	end,
	Back = function(self)
		local v31 = table.remove(v30)

		if v31 then
			state2:Set(v31)
		end
	end,
	Open = function(self)
		if v10.UI == "Index" then
			return
		end

		if not v22 then
			v22 = true
			v23:Fire()
		end

		local v31 = assert(v10:Get("Index"), "Index showroom not found")
		v10:Open("Index", "Index", true, not v24.isTradingPlazaServer())

		if not v28 then
			v28 = true
			v31.Info.Render("Sword", {
				Name = "Base Sword"
			})
		end

		self._lastUI = nil
		self._onCloseCallback = nil
	end,
	Close = function(self)
		if v10.UI == "Index" then
			v10:Close()
		end
	end,
	Preview = function(self, p, name, lastUI, onCloseCallback)
		if localPlayer.Character and localPlayer.Character:IsDescendantOf(workspace.Alive) then
			return
		end

		local v31 = type(name) == "string" and {
			Name = name
		} or name
		maid:Clean()

		if not p or type(v31) ~= "table" or not v19[p][v31.Name] then
			return
		end

		self:Open()
		local v32 = assert(v10:Get("Index"), "Index showroom not found")
		local itemToKey = client:ItemToKey(p, v31)
		table.insert(v30, state2:Get())
		state2:Set("ItemPreview")
		local v33 = v19[p] and v19[p][v31.Name]
		itemPreview.Item.Vector.Image = v33 and v33.Icon or v7.Icons:GetIcon("DEFAULT_MISSING")
		itemPreview.ItemName.Text = v33 and (v33.DisplayName or v33.Name) or v31.Name
		itemPreview.Description.Text = v33 and v33.Description or ""
		itemPreview.Owned.Visible = #client:FindItemsWithKey(p, itemToKey) > 0
		itemPreview.Unowned.Visible = not itemPreview.Owned.Visible
		local maid2 = maid:Extend()
		maid2:Add(function()
			return function()
				self._lastUI = nil
				self._onCloseCallback = nil
			end
		end)

		if v24.isTradingPlazaServer() then
			for k in v25[true] do
				local v34 = self:GetFavoriteState(p, v31.Name)
				local v35 = k
				maid:Add(v20.setPropertyComputed(itemPreview.Item.FavoritedTemplate, k, function(callback)
					return v25[callback(v34) or false][v35]
				end))
			end
		end

		itemPreview.Item.FavoritedTemplate.Visible = v24.isTradingPlazaServer()
		maid:Add(itemPreview.Item.FavoritedTemplate.Activated:Connect(function()
			remoteEvent:FireServer(p, v31.Name)
		end))

		if v24.isTradingPlazaServer() then
			itemPreview.Back.Visible = true
			maid:Add(itemPreview.Back.Activated:Connect(function()
				self:Back()
				maid2:Clean()
			end))
		else
			itemPreview.Back.Visible = false
		end

		local finisher = v31.Finisher == true
		itemPreview.Preview.Label.Text = finisher and "Preview Finisher" or "Preview"
		local v34 = 0
		maid:Add(itemPreview.Preview.Activated:Connect(function()
			local now = os.clock()

			if v34 - now > 0 then
				return
			end

			if p == "Sword" then
				v34 = now + 0.2
			else
				v34 = now + 1
			end

			if finisher then
				v8:Preview(v31.Name)

				if v6._currentGui or playerGui.Trade.Enabled then
					return
				end

				self:Open()
			else
				v32.Info.Render(p, v31)
				local previewClicked = v32.Info.PreviewClicked()

				if previewClicked then
					maid2:Add(previewClicked)
				end
			end
		end))
		maid:Add(itemPreview.Rap.RapButton.Activated:Connect(function()
			openRapChart(p, v31) -- equivalent call inferred; original call site unknown
		end))
		maid:Add(mainLabel2.Parent.ShowSellers.Activated:Connect(function()
			if flag or v29 then
				return
			end

			if state:Get() == "Teleport" then
				v29 = true
				setSearch()
				local lastTime = os.clock()
				local success, result, v35 = pcall(function()
					return remoteFunction2:InvokeServer("Teleport", p, itemToKey)
				end)
				task.wait(1 - (os.clock() - lastTime))
				removeSearch()
				task.delay(0.5, function()
					v29 = false
				end)

				if success then
					if result and type(v35) == "table" then
						if #v35 == 1 then
							v12:CreatePrompt({
								PromptType = "Accept",
								Description = "A seller has been found!\nWould you like to teleport to their server?",
								AcceptButtonText = "Yes",
								DeclineButtonText = "No"
							}, function(flag2: boolean)
								if flag2 then
									local v36, v37 = remoteFunction:InvokeServer("Teleport", p, itemToKey, v35[1].GUID)

									if not v36 then
										warn((`Failed to teleport to listing!\n{v37 or "No data"}`))
									end
								end
							end)
						else
							v12:CreatePrompt({
								PromptType = "Ok",
								Description = "No users selling this item are online :("
							})
						end
					else
						v12:CreatePrompt({
							PromptType = "Ok",
							Description = "Internal server error [2]"
						})
					end
				else
					warn(result)
					v12:CreatePrompt({
						PromptType = "Ok",
						Description = "Internal server error [1]"
					})
				end
			end
		end))
		local visible

		if p == "Sword" or p == "Explosion" or p == "Emote" then
			visible = v11:IsEnabled() and v11:ShouldShowRAP(p, v31.Name)
		else
			visible = false
		end

		if visible then
			local RAP = v11:GetRAP(p, itemToKey)
			itemPreview.Rap.Amount.Text = RAP and v7.ValueConvertor:ShrinkNumber(RAP) or "---"
			maid:Add(task.spawn(function()
				local rAPAsync = v11:GetRAPAsync(p, itemToKey)
				itemPreview.Rap.Amount.Text = rAPAsync and v7.ValueConvertor:ShrinkNumber(rAPAsync) or 0
			end))
		end

		itemPreview.Rap.Visible = visible
		v32.Info.Render(p, v31)

		if p ~= "Explosion" then
			v32.Info.Render(p, v31)
		end

		local extended = maid:Extend()
		local v36 = false
		local flag2 = true
		maid:Add(function()
			flag2 = false
		end)

		local function destroyOld()
			for _, child in onlineSellers:GetChildren() do
				if child.ClassName == onlineSellers.UIListLayout.Template.ClassName then
					child:Destroy()
				end
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function fullClearOnlineSellers()
			onlineSellers.NoResults.Visible = true
			onlineSellers.Loading.Visible = false
			destroyOld()
			extended:Clean()
		end

		local function updateOnlineSellers()
			if not v36 then
				onlineSellers.NoResults.Visible = false
				onlineSellers.Loading.Visible = true
				destroyOld()
				extended:Clean()
			end

			if state:Get() == "OnlineSellers" then
				local v37, v38 = remoteFunction2:InvokeServer("OnlineSellers", p, itemToKey)

				if not v37 then
					warn((`Failed to load online sellers for {p} {itemToKey}`))
				end

				if state:Get() == "OnlineSellers" then
					if not flag2 or v36 and not (v38 and v37) then
						return
					end

					if v38 then
						local v39 = {}

						for k, v40 in v38 do
							v39[v40.GUID] = true

							if onlineSellers:FindFirstChild(v40.GUID) then
								continue
							end

							local price = v40.Price or 0
							local clone = extended:Clone(onlineSellers.UIListLayout.Template)
							clone.LayoutOrder = k
							clone.Name = v40.GUID
							local amount = clone.Price.Amount
							local text

							if price >= 10000 then
								text = v7.ValueConvertor:ShrinkNumber(price)
							else
								text = v7.ValueConvertor:AddCommas(price)
							end

							amount.Text = text
							clone.ProfilePicture.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={v40.Seller.UserId}&w=100&h=100`
							clone.Parent = onlineSellers
							local v42 = v40
							clone.Join.Activated:Connect(function()
								if not remoteFunction:InvokeServer("OnlineSellers", p, itemToKey, v42.GUID) then
									warn("Failed to teleport to listing")
								end
							end)
						end

						for _, child in onlineSellers:GetChildren() do
							if not v39[child.Name] then
								extended:Remove(child)
							end
						end
					end

					onlineSellers.NoResults.Visible = v38 == nil or #v38 == 0
					onlineSellers.Loading.Visible = false
					v36 = true
				else
					fullClearOnlineSellers() -- equivalent call inferred; original call site unknown
				end
			else
				fullClearOnlineSellers() -- equivalent call inferred; original call site unknown
			end
		end

		maid:Add(task.spawn(updateOnlineSellers))
		maid:Add(task.delay(v7.FFlag.GetFFlag("IndexOnlineSellersRefreshTime", 10), function()
			while flag2 do
				if v7.FFlag.GetFFlag("IndexCanRefreshOnlineSellers") then
					local v37, v38 = xpcall(updateOnlineSellers, function(p2)
						return (`{p2}\n{debug.traceback()}`)
					end)

					if not v37 then
						warn(v38)
					end
				end

				task.wait(v7.FFlag.GetFFlag("IndexOnlineSellersRefreshTime", 10))
			end
		end))
		self._lastUI = lastUI
		self._onCloseCallback = onCloseCallback
	end,
	PreviewReward = function(self, p, p2, callback)
		if p.Type == "Finisher" then
			v8:Preview(p.Value)

			if p2 then
				v6:Open(p2)
			end

			if callback then
				task.spawn(callback)
			end
		else
			local v31 = {
				Name = p.Value
			}

			if p.Type == "SwordAccessory" then
				v31.Accessory = true
			end

			self:Preview(p.Type, v31, p2, callback)
		end
	end,
	CanPreview = function(_, p)
		return table.find({
			"Emote",
			"Explosion",
			"Sword",
			"Finisher",
			"SwordAccessory"
		}, p.Type) ~= nil
	end,
	Init = function(_)
		v13 = require3(ReplicatedStorage2.Controllers.Trading.RAPChartController)
	end
}
local v31 = {}

function IndexController:GetFavoriteState(p, p2: string)
	local states = v31[p]

	if not states then
		states = {}
		v31[p] = states
	end

	if states[p2] then
		return states[p2]
	end

	local state9 = v20.State(false)
	states[p2] = state9
	local v32 = v.Client:WaitReplion("Data")
	local v33 = { "IndexFavorites", p, p2 }

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateFavorited()
		state9:Set(v32:Get(v33) and true or false)
	end

	updateFavorited() -- equivalent call inferred; original call site unknown
	v32:OnChange(v33, updateFavorited)
	return state9
end

function IndexController:GetFakeCaller(p, p2)
	local inventory = {}
	local equipped = {}
	local values = {}

	for _, inventoryType in client.InventoryTypes do
		inventory[inventoryType] = {}
		local v34 = v15[inventoryType]
		local v35 = p2 and p2[inventoryType]

		if type(v34) == "table" then
			for _, name in v34 do
				if not v35 or table.find(v35, name) then
					inventory[inventoryType][name] = {
						Name = name
					}
				end
			end

			values[inventoryType] = v2.List.map(v34, function(p3, p4)
				return {
					Name = p3,
					Id = p3
				}, p4
			end)
		else
			if not v35 or table.find(v35, v34) then
				inventory[inventoryType][v34] = {
					Name = v34
				}
			end

			equipped[inventoryType] = {
				Name = v34,
				Id = v34
			}
		end
	end

	for _, v34 in pairs(p or v16.TradableItemTypes) do
		local v35 = v19[v34]
		local v36 = p2 and p2[v34]

		for _, v37 in v35 do
			if not (v37.Name and (not v36 or table.find(v36, v37.Name))) then
				continue
			end

			inventory[v34][v37.Name] = {
				Name = v37.Name
			}

			if v34 == "Sword" and v37.HasFinisher then
				inventory.Sword[v37.Name .. "_Finisher"] = {
					Name = v37.Name,
					Finisher = true
				}
			end

			if v34 == "Sword" and v37.AccessoryUnlockable then
				inventory.Sword[v37.Name .. "_Accessory"] = {
					Name = v37.Name,
					Accessory = true
				}
			end
		end
	end

	return {
		Type = "FakeCaller",
		CustomType = "Index",
		Replion = client:CreateFakeReplion({
			Tokens = 0,
			Inventory = inventory,
			Equipped = equipped,
			EquippedList = values
		})
	}
end

function IndexController:Start()
	if not (v24.isTradingPlazaServer() or v22) then
		v23:Wait()
	end

	local fakeCaller = self:GetFakeCaller()
	v6:OnGuiOpen("Index", function()
		ProximityPromptService.Enabled = false
		self._lastUI = nil
		self._onCloseCallback = nil
	end)
	v6:OnGuiClose("Index", function()
		ProximityPromptService.Enabled = true
	end)
	local v32 = assert(v10:Get("Index"), "Index showroom not found")
	index.Main.Close.Activated:Connect(function()
		self:Close()

		if self._lastUI then
			v6:Open(self._lastUI)
		end

		if self._onCloseCallback then
			task.spawn(self._onCloseCallback)
		end

		self._lastUI = nil
		self._onCloseCallback = nil
	end)

	for _, button in mainLabel.Top:GetChildren() do
		if not button:IsA("ImageButton") then
			continue
		end

		local v33 = button
		v20.Computed(function(callback)
			local v34

			if callback(state2) == v33.Name then
				v34 = callback(state3) == ""
			else
				v34 = false
			end

			v33.Image = v34 and "rbxassetid://18123223527" or "rbxassetid://18123248161"
			v33.HoverImage = v34 and "rbxassetid://18123872657" or "rbxassetid://18123874724"
			local uIStroke = v33.Label.UIStroke
			local color

			if v34 then
				color = Color3.fromRGB(149, 67, 0)
			else
				color = Color3.fromRGB(21, 56, 169)
			end

			uIStroke.Color = color
			v33.Visible = v24.isTradingPlazaServer()
			return nil
		end)
		local v34 = button
		button.Activated:Connect(function()
			if not v24.isTradingPlazaServer() then
				return
			end

			mainLabel.ItemsList.CanvasPosition = Vector2.zero
			state2:Set(v34.Name)
			searchBox.Text = ""
			state3:Set("")
		end)
	end

	v20.Computed(function(callback)
		local v33 = callback(state6)
		local v34 = v33 ~= "All"
		mainLabel.Owned.Image = v34 and "rbxassetid://18123223527" or "rbxassetid://18123248161"
		mainLabel.Owned.HoverImage = v34 and "rbxassetid://18123872657" or "rbxassetid://18123874724"
		local uIStroke = mainLabel.Owned.Label.UIStroke
		local color

		if v34 then
			color = Color3.fromRGB(149, 67, 0)
		else
			color = Color3.fromRGB(21, 56, 169)
		end

		uIStroke.Color = color
		mainLabel.Owned.Visible = v24.isTradingPlazaServer()
		mainLabel.Owned.Label.Text = not v34 and "Owned" or v33
		return nil
	end)
	mainLabel.Owned.Activated:Connect(function()
		local v33 = state6:Get()
		local v34 = v33 == "Owned"
		local v35 = v33 ~= "All"
		mainLabel.ItemsList.CanvasPosition = Vector2.zero
		state6:Set(v35 and (v34 and "Unowned" or "All") or "Owned")
	end)
	v20.Computed(function(callback)
		local v33 = callback(state8)
		mainLabel.Favorites.Image = v33 and "rbxassetid://18123223527" or "rbxassetid://18123248161"
		mainLabel.Favorites.HoverImage = v33 and "rbxassetid://18123872657" or "rbxassetid://18123874724"
		local uIStroke = mainLabel.Favorites.Label.UIStroke
		local color

		if v33 then
			color = Color3.fromRGB(149, 67, 0)
		else
			color = Color3.fromRGB(21, 56, 169)
		end

		uIStroke.Color = color
		mainLabel.Favorites.Visible = v24.isTradingPlazaServer()
		return nil
	end)
	mainLabel.Favorites.Activated:Connect(function()
		mainLabel.ItemsList.CanvasPosition = Vector2.zero
		state8:Set(not state8:Get())
	end)
	searchBox.FocusLost:Connect(function(flag2: boolean)
		if flag2 then
			mainLabel.ItemsList.CanvasPosition = Vector2.zero
			state3:Set(searchBox.Text)
		end
	end)
	mainLabel.ItemSearch.Search.Activated:Connect(function()
		mainLabel.ItemsList.CanvasPosition = Vector2.zero
		state3:Set(searchBox.Text)
	end)
	v9:CreateSortOptions(mainLabel.ItemSearch.Sort, state4, state5, v26)
	local computed = v20.Computed(function(callback)
		local v33 = callback(state2)
		return v33 == "Sword" or v33 == "Explosion" or v33 == "Emote"
	end)

	local function updateState()
		state:Set(localPlayer:GetAttribute("ViewOnlineSellers") and "OnlineSellers" or v7.FFlag.GetFFlag("SaleListingsMode"))
	end

	localPlayer:GetAttributeChangedSignal("ViewOnlineSellers"):Connect(updateState)
	v7.FFlag.OnChange(updateState)
	task.spawn(updateState)
	local computed2 = v20.Computed(function(callback)
		return v24.isTradingPlazaServer() and callback(state7) and not callback(computed) and callback(state) == "OnlineSellers"
	end)
	mainLabel2.Hide.Visible = v24.isTradingPlazaServer()
	mainLabel2.Parent.ShowSellers.Activated:Connect(function()
		if flag or v29 then
			return
		end

		if state:Get() ~= "Teleport" then
			state7:Set(true)
		end
	end)
	mainLabel2.Hide.Activated:Connect(function()
		state7:Set(false)
	end)
	v20.setPropertyComputed(mainLabel2, "Visible", function(callback)
		local v33 = callback(computed2)
		v32.Info.SetCamera(v33 and "Middle" or "Right")
		return v33
	end)
	v20.setPropertyComputed(mainLabel2.Parent.ShowSellers, "Visible", function(callback)
		return v24.isTradingPlazaServer() and (not callback(state7) or callback(state) == "Teleport")
	end)
	v20.setPropertyComputed(mainLabel2.Parent.ShowSellers.Label, "Text", function(callback)
		if callback(state) == "Teleport" then
			return "Find Seller"
		end

		return "< Show Sellers"
	end)
	v20.setPropertyComputed(mainLabel2.Parent, "Visible", function(callback)
		return not callback(computed)
	end)
	v20.setPropertyState(mainLabel.ItemSearch, "Visible", computed)
	v20.setPropertyState(mainLabel.ItemsList, "Visible", computed)
	v20.setPropertyComputed(mainLabel.RapChart, "Visible", function(callback)
		return callback(state2) == "RapChart"
	end)
	v20.setPropertyComputed(itemPreview, "Visible", function(callback)
		return callback(state2) == "ItemPreview"
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function previewItem(p, p2)
		maid:Clean()

		if p and p2 then
			self:Preview(p, p2)
		end
	end

	if not v24.isTradingPlazaServer() then
		return
	end

	v20.setPropertyComputed(mainLabel.ItemsList.UIGridLayout, "CellSize", function(callback)
		local v33 = callback(v5.State)

		if v33 == "Phone" or v33 == "Tablet" then
			return (UDim2.fromScale(0.31, 0.31))
		end

		return (UDim2.fromScale(0.23, 0.23))
	end)
	local state9 = v20.State(false)
	v20.State(true)
	local defaults = {
		ItemTemplate = mainLabel.ItemsList.UIGridLayout.Template,
		Container = mainLabel.ItemsList,
		Caller = fakeCaller,
		SearchFilter = state3,
		SortOption = state4,
		SortOrder = state5,
		GetVisibleState = function(p, p2)
			local favoriteState = self:GetFavoriteState(p, p2.Name)

			if v18.ShownItems[p] and not table.find(v18.ShownItems[p], p2.Name) and v17[p] and table.find(
				v17[p],
				p2.Name
			) then
				return state9
			end

			return (v20.Computed(function(callback)
				local v34 = callback(state6)
				local v35 = #client:FindItems(p, p2.Name) > 0 and "Owned" or "Unowned"
				local v36 = v34 == "All" or v34 == v35
				local v37 = not callback(state8) or callback(favoriteState)
				return v36 and v37
			end))
		end,
		OnSlotCreated = function(p, p2, _: string, p3, maid2)
			maid2:Add(v20.setPropertyState(p3.FavoritedTemplate, "Visible", state8))
			maid2:Add(p3.ActivationButton.Activated:Connect(function()
				previewItem(p, p2) -- equivalent call inferred; original call site unknown
			end))
		end
	}

	for _, inventoryType in v27 do
		local v35 = inventoryType
		v9:CreateInventory((v2.Dictionary.merge(defaults, {
			InventoryType = inventoryType,
			PageVisible = v20.Computed(function(callback)
				return callback(state2) == v35
			end)
		})))
	end
end

return IndexController