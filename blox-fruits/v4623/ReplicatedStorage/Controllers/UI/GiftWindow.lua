local GiftWindow = {}
local color = Color3.fromRGB(0, 255, 38)
local color2 = Color3.fromRGB(61, 61, 61)
local color3 = Color3.fromRGB(0, 99, 23)
local color4 = Color3.fromRGB(132, 132, 132)
local color5 = Color3.fromRGB(167, 140, 32)
local color6 = Color3.fromRGB(63, 63, 63)
local ImageUtil = require(game.ReplicatedStorage.Modules.Asset.ImageUtil)
local UIUtil = require(game.ReplicatedStorage.Modules.Util.UIUtil)
local TextUtil = require(game.ReplicatedStorage.Modules.Util.TextUtil)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local WrapPurchase = require(game.ReplicatedStorage.Modules.Asset.WrapPurchase)
local HUD = require(game.ReplicatedStorage.Controllers.UI.HUD)
local GetUserInfo = require(game.ReplicatedStorage.Modules.Player.GetUserInfo)
local ViewportOverlay = require(game.ReplicatedStorage.Controllers.UI.ViewportOverlay)
local Notification = require(game.ReplicatedStorage.Notification)
local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
require(game.ReplicatedStorage.Modules.Util.Signal)
local Flags = require(game.ReplicatedStorage.Modules.Flags)
local LastInput = require(game.ReplicatedStorage.Modules.LastInput)
local PriceService = require(game.ReplicatedStorage.PriceService)
local localPlayer = game.Players.LocalPlayer
local GuiService = game:GetService("GuiService")
game:GetService("UserInputService")
local v = nil
local v2 = nil
local context = nil
local playerList = nil
local v3 = nil
local cancel = nil
local serverButton = nil
local globalButton = nil
local textBox = nil
local overlay = nil
local template = nil
local v4 = "Server"
local shopData = nil
local purchaseLocation = nil
local receiverName = nil
local receiverUserId = nil
local text = nil
local v7 = false
local v8 = nil
local v9 = nil
local v10 = nil
local v11 = nil
local clones = {}
local v12 = {}
local v13 = {}
local v14 = {}
local now = 1

local function process(value: string?)
	if v11 then
		v11:Destroy()
	end

	overlay.Visible = true

	if not v10 then
		return
	end

	local fn

	fn = function()
		fn = function() end

		if v11 then
			v11:Destroy()
		end
	end

	local maid = v10:Extend()
	v11 = maid
	maid:Add(function()
		v11 = nil
		overlay.Visible = false
		overlay.Loading.ImageLabel.Rotation = 0
		overlay.Loading.TextLabel.Text = ""
	end)
	local v15 = 0
	local total = 1
	ImageUtil.applySpriteFromItemId(shopData and shopData.storageName or "_na", "Redeemable", {
		Icon = overlay.Loading.ImageLabel
	})
	local RunService = game:GetService("RunService")
	maid:Add(RunService.Heartbeat:Connect(function(dt: number)
		if total >= 0.33 then
			total = 0
			overlay.Loading.TextLabel.Text = (value or "") .. string.rep(".", v15)
			v15 = v15 + 1 > 3 and 1 or v15 + 1
		end

		total += dt
	end))
	return maid, fn
end

local function recycle(instance)
	v13[instance.Name] = nil

	if not (instance.Parent and v8) then
		return
	end

	instance.TextButton.Selectable = false
	instance.Name = ""
	instance.Visible = false
	table.insert(v12, instance)
end

local function get(value)
	local count = #v12
	local clone = v12[count]

	if clone then
		table.remove(v12, count)
	else
		clone = template:Clone()
		table.insert(clones, clone)
	end

	local textButton = clone.TextButton
	local lower = value:lower()
	clone.Note.Visible = false
	clone.Name = lower
	textButton.Active = true
	textButton.Selectable = true
	textButton.AutoButtonColor = true
	textButton.Store.Visible = false
	textButton.Gift.Visible = false
	textButton.Global.Visible = false
	textButton.Global.Line1.Text = "Global:"
	textButton.Global.Line2.Text = "Press enter to search"
	textButton.Store.DisplayName.TextColor3 = color4
	textButton.Gift.DisplayName.TextColor3 = color4
	textButton.LayoutOrder = 0
	textButton.BackgroundColor3 = color2
	textButton.BorderSizePixel = 0
	v13[lower] = clone
	clone.Visible = true
	return clone
end

function changeSelection(p: string?, p2: number?)
	if v9 then
		v9:Destroy()
	end

	receiverName = p
	receiverUserId = p2

	if not shopData then
		context.Text = "???"
		return
	end

	local v15 = shopData.subtype ~= "AuraSkin" and shopData.subtype ~= "FruitSkin" and shopData.bundletype ~= "FruitSkin" and "" or (shopData.subtype == "FruitSkin" or shopData.bundletype == "FruitSkin") and "Fruit Skin" or "Aura Skin"
	local unwrapped = ItemConfig.match(shopData.storageName, "Redeemable"):unwrap()

	if receiverUserId then
		if receiverUserId == localPlayer.UserId then
			context.Text = `Storing <{unwrapped.Display.Name or unwrapped.Index.StorageKey}> {v15}`
		else
			context.Text = `Gifting [{receiverName}] <{unwrapped.Display.Name or unwrapped.Index.StorageKey}}> {v15}`
		end
	else
		context.Text = `Gifting <{unwrapped.Display.Name or unwrapped.Index.StorageKey}}> {v15}`
	end

	v3:UpdateProperties({
		Appearance = receiverUserId and "Active" or "Inactive",
		ImageLabel = {
			ImageColor3 = receiverUserId and color5 or color6,
			ImageId = "Gift"
		},
		TextLabel = {
			Text = `<font color="#000000"></font>{PriceService.getPrice(shopData.storageName) or "???"}`
		}
	})
end

function changeCategory(p: string, p2)
	v4 = p
	textBox.Text = ""
	changeSelection()

	if v10 then
		v10:Destroy()
	end

	local maid = assert(v8, "bad screenMaid"):Extend()
	v10 = maid
	maid:Add(function()
		v10 = nil
	end)

	if tick() - now > 300 then
		now = tick()
		table.clear(v14)
	end

	local count = 0
	local total = -199
	local v15 = {}
	local v16 = {}

	local function addEntry(player)
		if v16[player.UserId] then
			return
		end

		local v17 = player.UserId == localPlayer.UserId

		if v17 and shopData.nostore == true then
			return
		end

		v16[player.UserId] = true
		local v18 = get(`{player.Name}:{player.DisplayName}`)
		local textButton = v18.TextButton
		local isFriend = player.IsFriend

		if not isFriend then
			isFriend = v14[player.UserId] or nil
		end

		if isFriend ~= nil then
			v14[player.UserId] = isFriend
		end

		if v14[player.UserId] == nil and not v17 then
			local playerByUserId = game.Players:GetPlayerByUserId(player.UserId)

			if playerByUserId then
				pcall(function()
					isFriend = playerByUserId.UserId <= 0 or playerByUserId:IsFriendsWith(localPlayer.UserId)
					v14[player.UserId] = isFriend == true
				end)
			else
				isFriend = false
			end
		end

		maid:Add(function()
			local v19 = v18
			v13[v19.Name] = nil

			if v19.Parent then
				if not v8 then
					return
				end

				v19.TextButton.Selectable = false
				v19.Name = ""
				v19.Visible = false
				table.insert(v12, v19)
			end
		end)
		local store

		if v17 then
			store = textButton.Store
		else
			store = textButton.Gift
			store.Friends.Visible = isFriend == true
			store.Friends.ImageColor3 = Color3.fromRGB(89, 89, 89)
			store.Thumbnail.Image = `rbxthumb://type=AvatarHeadShot&id={player.UserId}&w=150&h=150`
			store.Username.Text = player.Name
			store.DisplayName.Text = not player.DisplayName and "" or "@" .. player.DisplayName or ""
		end

		total += isFriend and 1 or 0
		count += 1

		if v4 == "Server" then
			v18.LayoutOrder = v17 and -999 or isFriend and total or count
		elseif v4 == "Global" then
			v18.LayoutOrder = v17 and -999 or count
		end

		maid:Add(textButton.Activated:Connect(function()
			if receiverUserId == player.UserId then
				changeSelection()
				return
			end

			local maid2 = maid:Extend()
			maid2:Add(function()
				v9 = nil
				text = nil
				changeSelection()

				if not (v8 and v18.Parent) then
					return
				end

				v18.TextButton.BorderSizePixel = 0
				v18.TextButton.BackgroundColor3 = color2
				v18.Note.Visible = false
				v18.Note.BorderSizePixel = 0

				for _, childName in pairs({ "Gift", "Store" }) do
					local child = v18.TextButton:FindFirstChild(childName)
					child.BorderSizePixel = 0
					local displayName = child:FindFirstChild("DisplayName")
					displayName.TextColor3 = color4
				end
			end)
			textButton.BackgroundColor3 = color
			store.DisplayName.TextColor3 = color3

			if localPlayer.UserId == player.UserId then
				changeSelection(player.Name, player.UserId)
			else
				changeSelection(player.Name, player.UserId)
				local note = v18.Note
				local textBox2 = note.TextBox
				local characterLimit = note.CharacterLimit
				textBox2.Text = ""
				textBox2.PlaceholderText = `Leave a gift note for [{receiverName}]..`
				characterLimit.Text = `Characters 0/{50}`
				characterLimit.TextColor3 = Color3.fromRGB(135, 135, 135)
				v18.Note.BorderSizePixel = 2
				textButton.BorderSizePixel = 2
				note.Visible = true
				local snapLocation = UIUtil.getSnapLocation(v18, playerList)

				if snapLocation then
					playerList.CanvasPosition = Vector2.zero
					playerList.CanvasPosition = snapLocation.Snap
				end

				local text2 = nil
				maid2:Add(textBox2:GetPropertyChangedSignal("Text"):Connect(function()
					text2 = textBox2.Text:sub(1, (math.min(textBox2.Text:len(), 50)))
					textBox2.Text = text2
					local v20 = textBox2.Text:len()
					local v21 = math.clamp(v20 / 50, 0, 1)
					characterLimit.TextColor3 = Color3.fromRGB(135, 135, 135):Lerp(Color3.fromRGB(255, 0, 4), v21)
					characterLimit.Text = `Characters {v20}/{50}`

					if textBox2.Text:gsub(" ", "") == 0 then
						text = nil
					else
						text = textBox2.Text
					end
				end))
			end

			v9 = maid2
		end))
		store.Visible = true
		textButton.Visible = true
		textButton.Selectable = true
		v18.Parent = playerList
	end

	local now2 = 1
	local uIListLayout = playerList:FindFirstChildOfClass("UIListLayout")
	local flag = false

	local function fn(flag2: boolean?)
		if not flag2 and tick() - now2 < 0.06 or flag then
			return
		end

		now2 = tick()
		playerList.CanvasSize = UDim2.new(
			0,
			0,
			0,
			uIListLayout.AbsoluteContentSize.Y + uIListLayout.Padding.Offset + (LastInput:Get() ~= "Gamepad" and 4 or template.AbsoluteSize.Y * 1.1 or 4)
		)
	end

	local function fn2()
		if next(v15) then
			flag = true
			local v17 = playerList.CanvasSize.Y.Offset - playerList.AbsoluteSize.Y

			if playerList.CanvasPosition.Y >= v17 - template.AbsoluteSize.Y * 2 then
				local count2 = 0

				for k, v18 in pairs(v15) do
					count2 += 1

					if count2 >= 25 then
						break
					end

					v15[k] = nil
					addEntry(v18)
				end
			end

			flag = false
			now2 = tick()
			playerList.CanvasSize = UDim2.new(
				0,
				0,
				0,
				uIListLayout.AbsoluteContentSize.Y + uIListLayout.Padding.Offset + (LastInput:Get() ~= "Gamepad" and 4 or template.AbsoluteSize.Y * 1.1 or 4)
			)
		end
	end

	task.spawn(fn)
	maid:Add(uIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(fn))
	maid:Add(playerList:GetPropertyChangedSignal("CanvasPosition"):Connect(fn2))
	maid:Add(textBox:GetPropertyChangedSignal("Text"):Connect(function()
		local v17 = textBox.Text:gsub(" ", "")

		if p2 and v17 == "" then
			changeCategory(v4)
			return
		end

		if next(v15) then
			for k, v18 in pairs(v15) do
				if not k:match(v17:lower()) then
					continue
				end

				v15[k] = nil
				addEntry(v18)
			end
		end

		for k, v18 in pairs(v13) do
			if not v10 then
				break
			end

			if k == "_global" then
				globalSearchChanged(textBox.Text)
			elseif k == `{localPlayer.Name:lower()}:{localPlayer.DisplayName:lower()}` then
				v18.Visible = v4 == "Server"
			elseif v17 == "" then
				v18.Visible = true
			else
				v18.Visible = k:match(v17:lower()) and true or false
			end
		end
	end))

	if p2 then
		textBox.Text = p2.Name
	else
		textBox.Text = ""
	end

	if v4 == "Server" then
		local function removeEntry(player)
			if player.UserId == receiverUserId then
				changeSelection()
			end

			local formatted = `{player.Name}:{player.DisplayName}`
			local child = playerList:FindFirstChild(formatted)

			if child then
				v13[child.Name] = nil

				if child.Parent then
					if not v8 then
						return
					end

					child.TextButton.Selectable = false
					child.Name = ""
					child.Visible = false
					table.insert(v12, child)
				end
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function addPlayer(player)
			if not v10 then
				return
			end

			v15[`{player.Name}:{player.DisplayName}`] = {
				UserId = player.UserId,
				Name = player.Name,
				DisplayName = player.DisplayName
			}
		end

		maid:Add(game.Players.PlayerRemoving:Connect(removeEntry))
		maid:Add(game.Players.PlayerAdded:Connect(addPlayer))

		for _, v17 in game.Players:GetPlayers() do
			addPlayer(v17) -- equivalent call inferred; original call site unknown
		end

		fn2()
	elseif v4 == "Global" then
		if Flags.OFFLINE_GIFTING_ENABLED == false then
			Notification.new("<Color=Red>Offline gifting is disabled.<Color=/>"):Display()
			return
		end

		local v17 = get("_global")
		v17.LayoutOrder = -998
		maid:Add(textBox.FocusLost:Connect(function(flag2: boolean, _)
			if flag2 and v17.Visible then
				globalSearchChanged(textBox.Text, true)
			end
		end))

		if p2 then
			addEntry(p2)
		else
			local _, v18 = process("Loading Friends")
			local FriendFinder = require(game.ReplicatedStorage:WaitForChild("FriendFinder"))
			maid:AddPromise(FriendFinder:GetFriends():andThen(function(list)
				if not list then
					return
				end

				table.insert(list, {
					UserId = localPlayer.UserId,
					Name = localPlayer.Name,
					DisplayName = localPlayer.DisplayName
				})

				for _, v19 in pairs(list) do
					if not v10 then
						break
					end

					v15[`{v19.Name}:{v19.DisplayName}`] = {
						IsFriend = true,
						UserId = v19.UserId,
						Name = v19.Name,
						DisplayName = v19.DisplayName
					}
				end

				fn2()

				if v18 then
					v18()
				end
			end))
		end

		v17.TextButton.Active = false
		v17.TextButton.AutoButtonColor = false
		v17.TextButton.Global.Visible = true
		maid:Add(function()
			local v18 = v17
			v13[v18.Name] = nil

			if v18.Parent then
				if not v8 then
					return
				end

				v18.TextButton.Selectable = false
				v18.Name = ""
				v18.Visible = false
				table.insert(v12, v18)
			end
		end)
		v17.Parent = playerList
	end
end

function globalSearchChanged(value: string?, flag: boolean?)
	if v13._global then
		local _global = v13._global

		if value and (v13[value] or v13[value:gsub(" ", "")]) then
			_global.Visible = false
		else
			_global.Visible = true
		end

		if flag and value then
			local _, v15 = process(`Searching for <{value}>`)
			_global.TextButton.Global.Line1.Text = "Searching.."
			_global.TextButton.Global.Line2.Text = textBox.Text
			local v16 = GetUserInfo:FromUsernameAsync(value)

			if v16 and v16.UserId ~= 0 then
				changeCategory("Global", {
					Name = v16.Name,
					UserId = v16.UserId,
					DisplayName = v16.DisplayName
				})
			else
				_global.TextButton.Global.Line1.Text = "User not found, try again."
				_global.TextButton.Global.Line2.Text = textBox.Text
			end

			if v15 then
				v15()
			end
		else
			_global.TextButton.Global.Line1.Text = `Global: "{textBox.Text}"`
			_global.TextButton.Global.Line2.Text = "Press enter to search"

			if v11 then
				v11:Destroy()
			end
		end
	end
end

function GiftWindow.IsOpen(_)
	return v8 ~= nil
end

function GiftWindow:Open(data)
	if data.shopData and data.shopData.gift then
		if v8 then
			v8:Destroy()
		end

		shopData = data.shopData
		purchaseLocation = data.purchaseLocation
		local maid = Trove.new()
		v8 = maid
		maid:Add(function()
			v8 = nil
		end)

		if v then
			if not v7 then
				v7 = true
				tick()
				local FriendFinder = require(game.ReplicatedStorage:WaitForChild("FriendFinder"))
				FriendFinder:GetFriends():andThen(function(p)
					if not p then
						v7 = false
					end
				end)
			end

			ViewportOverlay:SetDisplayOrder(v.DisplayOrder - 1):Lock("GiftWindow")
			local TextButtonComponent = require(game.ReplicatedStorage.Modules.Create.TextButtonComponent)
			v3 = TextButtonComponent(v2.Content.Buttons.Purchase)
			maid:Add(v3)
			maid:Add(function()
				ViewportOverlay:Unlock("GiftWindow")
				shopData = nil
				purchaseLocation = nil

				for _, v15 in pairs(clones) do
					v15:Destroy()
				end

				table.clear(clones)
				table.clear(v12)
				table.clear(v13)
			end)
			maid:Add(GuiService.MenuOpened:Connect(function()
				GiftWindow:Close()
			end))
			local remotes = game.ReplicatedStorage:WaitForChild("Remotes")
			maid:Add(v3.Instance.Activated:Connect(function()
				if not (receiverUserId and shopData) then
					Notification.new("<Color=Red>Select someone to gift to.<Color=/>"):Display()
					return
				end

				local maid2, v15 = process("Processing Purchase")

				if maid2 and v15 then
					local MarketplaceService = game:GetService("MarketplaceService")
					maid2:Add(MarketplaceService.PromptGamePassPurchaseFinished:Connect(v15))
					local MarketplaceService2 = game:GetService("MarketplaceService")
					maid2:Add(MarketplaceService2.PromptProductPurchaseFinished:Connect(function(_, _, p)
						v15()

						if p then
							GiftWindow:Close(data.onClose)
						end
					end))
					local v16 = {
						StorageName = shopData.storageName,
						ReceiverUserId = receiverUserId,
						ReceiverName = receiverName,
						Message = 0,
						PurchaseLocation = 0,
						PurchaseAction = 0,
						FunnelId = "Shop"
					}
					local message

					if receiverUserId ~= localPlayer.UserId then
						message = text or nil
					end

					v16.Message = message
					v16.PurchaseLocation = purchaseLocation
					v16.PurchaseAction = receiverUserId == localPlayer.UserId and "Store" or "Gift"

					if v16.Message then
						v16.Message = TextUtil.sanitizeStringForSave(v16.Message)
					end

					maid2:Add(WrapPurchase(v16, function(p)
						if p then
							if not remotes.CommF_:InvokeServer("buyRobuxShop", v16) then
								v15()
							end
						else
							v15()
						end

						ViewportOverlay:SetDisplayOrder(v.DisplayOrder - 1):Lock("GiftWindow")
					end))
				end
			end))
			maid:Add(cancel.Activated:Connect(function()
				GiftWindow:Close(data.onClose)
			end))
			maid:Add(serverButton.Activated:Connect(function()
				if v4 == "Server" then
					return
				end

				changeCategory("Server")
			end))
			maid:Add(globalButton.Activated:Connect(function()
				if v4 == "Global" then
					return
				end

				changeCategory("Global")
			end))
			maid:Add(game.ReplicatedStorage.Remotes.CommE.OnClientEvent:Connect(function(p)
				if p == "RobuxPurchaseSuccess" then
					GiftWindow:Close(data.onClose)
				end
			end))

			local function controllerAction(_: string, p, p2)
				if p ~= Enum.UserInputState.End or p2.UserInputType ~= Enum.UserInputType.Gamepad1 then
					return Enum.ContextActionResult.Pass
				end

				GuiService.SelectedObject = v3.Instance
				return Enum.ContextActionResult.Sink
			end

			game.ContextActionService:BindActionAtPriority(
				"GiftWindowAction",
				controllerAction,
				false,
				4,
				Enum.KeyCode.ButtonB
			)
			maid:Add(function()
				game.ContextActionService:UnbindAction("GiftWindowAction")
			end)
			changeCategory("Server")
			v.Enabled = true
			task.defer(function()
				if v.Enabled and LastInput:Get() == "Gamepad" then
					GuiService.SelectedObject = v4 == "Server" and serverButton or globalButton
				end
			end)
			return v8
		else
			if not localPlayer.PlayerGui:FindFirstChild("GiftWindow") then
				local clone = script.GiftWindow:Clone()
				clone.Parent = localPlayer.PlayerGui
			end

			local PlayerUtil = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("PlayerUtil"))
			maid:Add(PlayerUtil.ScreenReady({ "GiftWindow" }, function(p)
				local v15 = assert(p.GiftWindow, "bad package.GiftWindow")
				local window = v15:WaitForChild("Window", 5)

				if window then
					v = v15
					v2 = window
					context = v2.Footer.Context
					playerList = v2.Content.PlayerList
					cancel = v2.Content.Buttons.Cancel
					serverButton = v2.Content.Navigation.ServerButton
					globalButton = v2.Content.Navigation.GlobalButton
					textBox = v2.Content.Navigation.SearchFrame.TextBox
					overlay = v2.Overlay
					overlay.Visible = false
					template = playerList.Template
					template.Visible = false
				end

				if v8 and v then
					GiftWindow:Open(data)
				else
					GiftWindow:Close()
				end
			end, (`Init {script.Name}`)))
		end
	else
		print("Can't gift, how did we make it here??", debug.traceback())
		print(data.shopData)
	end
end

function GiftWindow:Close(callback)
	if v then
		v.Enabled = false
	end

	local v15 = v8 ~= nil

	if v8 then
		v8:Destroy()
	end

	if callback and typeof(callback) == "function" then
		task.spawn(callback)
	end

	return v15 == true
end

task.spawn(function()
	while not HUD.IsInitialized do
		task.wait()
	end

	assert(HUD.IsInitialized, "bad HUD")
	HUD:RegisterPage("GiftWindow", function(...)
		return GiftWindow:Open(...)
	end, function(...)
		return GiftWindow:Close(...)
	end, function()
		return v8 ~= nil
	end)
end)
return GiftWindow