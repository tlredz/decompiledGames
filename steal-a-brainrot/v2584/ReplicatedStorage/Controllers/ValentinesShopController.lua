local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Gradients = require(ReplicatedStorage.Packages.Gradients)
local FFlags = require(ReplicatedStorage.Packages.FFlags)
local Timer = require(ReplicatedStorage.Packages.Timer)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local Spr = require(ReplicatedStorage.Packages.Spr)
local AnimatedButton = require(ReplicatedStorage.Classes.AnimatedButton)
local Animals = require(ReplicatedStorage.Shared.Animals)
local Mutations = require(ReplicatedStorage.Shared.Mutations)
local MutationText = require(ReplicatedStorage.Shared.MutationText)
local Marketplace = require(ReplicatedStorage.Shared.Marketplace)
local UsersAPI = require(ReplicatedStorage.Shared.UsersAPI)
local Friends = require(ReplicatedStorage.Shared.Friends)
local Updates = require(ReplicatedStorage.Shared.Updates)
local Policy = require(ReplicatedStorage.Shared.Policy)
local CreateTween = require(ReplicatedStorage.Packages.CreateTween)
local ValentinesShop = require(ReplicatedStorage.Datas.ValentinesShop)
local LuckyBlocks = require(ReplicatedStorage.Datas.LuckyBlocks)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local LuckyBlockFlags = require(ReplicatedStorage.Shared.Flags.LuckyBlockFlags)
local Rarities = require(ReplicatedStorage.Datas.Rarities)
local Animals2 = require(ReplicatedStorage.Datas.Animals)
local Mutations2 = require(ReplicatedStorage.Datas.Mutations)
local Shop = require(ReplicatedStorage.Datas.Shop)
local TimeUtils = require(ReplicatedStorage.Utils.TimeUtils)
local CornerNotificationController = require(ReplicatedStorage.Controllers.CornerNotificationController)
local NotificationController = require(ReplicatedStorage.Controllers.NotificationController)
local InterfaceController = require(ReplicatedStorage.Controllers.InterfaceController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local ShopController = require(ReplicatedStorage.Controllers.ShopController)
local VFX = require(ReplicatedStorage.Shared.VFX)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local remoteFunction = Net:RemoteFunction("ValentinesShopService/SearchUser")
local remoteFunction2 = Net:RemoteFunction("ValentinesShopService/OpenGift")
local remoteFunction3 = Net:RemoteFunction("ValentinesShopService/Gift")
local remoteEvent = Net:RemoteEvent("ValentinesShopService/GiftNotify")
local valentinesShop = playerGui:WaitForChild("ValentinesShop").ValentinesShop
local list = valentinesShop.Sections.Send.List
local valentinesSendGift = playerGui:WaitForChild("ValentinesSendGift").ValentinesSendGift
local valentinesCard = playerGui:WaitForChild("ValentinesCard"):WaitForChild("ValentinesCard")
local v = nil
local v2 = nil
local ValentinesShopController = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function getFailedGiftKeyFromDiscounted(p: number)
	for _, product in ValentinesShop.Products do
		if product.discountedProductId == p then
			return product.failedGiftKey or tostring(p)
		end
	end

	return (tostring(p))
end

local v3 = nil
local v4 = nil
local v5 = nil

local function updateSelectedProductUI()
	local right

	if FFlags:GetInstant("ValentinesShop/MessagesDisabled", true) then
		right = valentinesSendGift.Right
	else
		right = valentinesSendGift.RightMessage
	end

	if FFlags:GetInstant("ValentinesShop/MessagesDisabled", true) then
		valentinesSendGift.RightMessage.Visible = false
		valentinesSendGift.Right.Visible = true
	else
		valentinesSendGift.RightMessage.Visible = true
		valentinesSendGift.Right.Visible = false
	end

	if v5 then
		v5:Destroy()
		v5 = nil
	end

	local brainrotViewport = right.Box.Item:FindFirstChild("BrainrotViewport")

	if brainrotViewport then
		brainrotViewport:Destroy()
	end

	right.Cost.Text = "???"

	if v4 then
		local v6 = Shop[v4.rawId]
		ValentinesShopController:BindLabelToProductPrice(right.Cost, v4.remappedId, "Product")
		right.Title.Text = not v6 and "???" or v6.Display or "???"

		if v6 and v6.Type == "LuckyBlock" and v6.Value then
			right.Box.Item.Image = ""
			local value

			if typeof(v6.Value) == "table" then
				value = v6.Value[1]
			else
				value = v6.Value
			end

			local viewportFrame = Instance.new("ViewportFrame")
			viewportFrame.Name = "BrainrotViewport"
			viewportFrame.Size = UDim2.fromScale(1, 1)
			viewportFrame.Position = UDim2.fromScale(0.5, 0.5)
			viewportFrame.AnchorPoint = Vector2.new(0.5, 0.5)
			viewportFrame.BackgroundTransparency = 1
			viewportFrame.Parent = right.Box.Item
			local v8 = Animals:AttachOnViewport(value, viewportFrame, true, (Mutations.get()))

			if v8 then
				v5 = v8
			end
		elseif v6 and v6.Icon then
			right.Box.Item.Image = v6.Icon
		else
			task.spawn(function()
				local v7 = v4
				local productInfo = Marketplace:GetProductInfo(v4.rawId, "Product")

				if not (productInfo and v4 == v7) then
					return
				end

				right.Box.Item.Image = productInfo.Icon or ""
			end)
		end
	else
		ShopController:UnbindLabelProductPrice(right.Cost)
		right.Title.Text = "NONE"
		right.Box.Item.Image = ""
	end
end

local function setSelectedProduct(rawId: number?)
	if rawId == nil then
		v4 = nil
	else
		if not ValentinesShop.Products[rawId] then
			return false
		end

		v4 = {
			remappedId = ValentinesShopController:GetProductId(rawId),
			rawId = rawId
		}
	end

	updateSelectedProductUI()
	return true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setSelectedUser(p)
	local v6 = v3
	v3 = p
	local fill = v6 and v6.card and v6.card.Parent and v6.card:FindFirstChild("Fill")

	if fill then
		fill.BackgroundColor3 = Color3.fromRGB(255, 189, 240)
	end
end

local function renderBrainrotAtFrame(boxBrainrot, rewardName)
	local animal = Animals2[rewardName]

	if not animal then
		return nil
	end

	local maid = Trove.new()
	local rarity = Rarities[animal.Rarity]
	boxBrainrot.Title.Text = Animals:GetDisplayName(rewardName)
	boxBrainrot.UIStroke.Color = Color3.new(0, 0, 0)

	if rarity.GradientPreset then
		boxBrainrot.Title.TextColor3 = Color3.new(1, 1, 1)
		maid:Add(Gradients.apply(boxBrainrot.Title, rarity.GradientPreset))
	else
		boxBrainrot.Title.TextColor3 = rarity.Color
	end

	boxBrainrot.Visible = true
	local v6 = Animals:AttachOnViewportWithOptimizations(rewardName, boxBrainrot.ViewportFrame, true)

	if v6 then
		maid:Add(v6)
	end

	return maid
end

local flag = false

function ValentinesShopController:OpenAnimation(data)
	while flag do
		task.wait()
	end

	flag = true
	local v6 = true
	CreateTween(valentinesCard.Parent.Frame, TweenInfo.new(0.25), {
		BackgroundTransparency = 0.5
	})
	valentinesCard.bgbtmback.ImageTransparency = 0
	valentinesCard.bgbtmfront.ImageTransparency = 0
	valentinesCard.CardInside.ZIndex = 1
	valentinesCard.bgtopseal.Visible = true
	valentinesCard.bgtopseal.Position = UDim2.fromScale(0.5, 0.486)
	valentinesCard.bgtopseal.HeartSeal.Position = UDim2.fromScale(0.5, 0.5)
	valentinesCard.bgtopseal.HeartSeal.ImageTransparency = 0
	valentinesCard.Visible = false
	valentinesCard.Position = UDim2.fromScale(0.5, 2)
	local message = valentinesCard.CardInside:FindFirstChild("Message")

	if message then
		message.Text = ""
		message.Visible = false
	end

	valentinesCard.bgtopseal.Title.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={data.Sender}&w=100&h=100`

	if data.SenderUsername then
		valentinesCard.bgtopseal.Title.User.Text = `@{data.SenderUsername}`
	else
		valentinesCard.bgtopseal.Title.User.Text = "???"
		task.spawn(function()
			local user = UsersAPI:GetUser(data.Sender)

			if user and v6 then
				valentinesCard.bgtopseal.Title.User.Text = `@{user.Username}`
			end
		end)
	end

	local giftType = data.GiftType or "purchased"
	local display = "Gift"
	local icon = nil
	local value = nil
	local maid = Trove.new()

	if giftType == "purchased" then
		local v7 = nil

		for k, product in ValentinesShop.Products do
			if data.ProductId ~= product.discountedProductId then
				continue
			end

			v7 = Shop[k]
			break
		end

		if v7 then
			display = v7.Display

			if v7.Type == "LuckyBlock" and v7.Value then
				if typeof(v7.Value) == "table" then
					value = v7.Value[1]
				else
					value = v7.Value
				end
			else
				icon = v7.Icon
			end
		end
	elseif giftType == "pool" then
		display = data.RewardName or "Mystery Gift"
	elseif giftType == "brainrot" then
		display = data.RewardName or data.BrainrotName or "Special Gift"
		valentinesCard.CardInside.Box.Visible = false
		valentinesCard.CardInside.BoxBrainrot.Visible = true
		maid:Add(function()
			valentinesCard.CardInside.BoxBrainrot.Visible = false
			valentinesCard.CardInside.Box.Visible = true
		end)
		local v7 = renderBrainrotAtFrame(valentinesCard.CardInside.BoxBrainrot, data.RewardName or data.BrainrotName)

		if v7 then
			maid:Add(v7)
		end
	end

	valentinesCard.CardInside.Box.Title.Text = display
	local item = valentinesCard.CardInside.Box.Item
	local brainrotViewport = item:FindFirstChild("BrainrotViewport")

	if brainrotViewport then
		brainrotViewport:Destroy()
	end

	item.Image = ""

	if value then
		local v7 = maid:Add(Instance.new("ViewportFrame"))
		v7.Name = "BrainrotViewport"
		v7.Size = UDim2.fromScale(1, 1)
		v7.Position = UDim2.fromScale(0.5, 0.5)
		v7.AnchorPoint = Vector2.new(0.5, 0.5)
		v7.BackgroundTransparency = 1
		v7.Parent = item
		local v8 = Animals:AttachOnViewport(value, v7, true, data.Mutation)

		if v8 then
			maid:Add(v8)
		end
	elseif icon then
		item.Image = icon
	elseif giftType == "purchased" and data.ProductId then
		local v7 = nil

		for k, product in ValentinesShop.Products do
			if data.ProductId ~= product.discountedProductId then
				continue
			end

			v7 = k
			break
		end

		task.spawn(function()
			local v9 = v4
			local productInfo = Marketplace:GetProductInfo(v7 or data.ProductId, "Product")

			if not (productInfo and v4 == v9) then
				return
			end

			item.Image = productInfo.Icon or ""
		end)
	elseif (giftType == "pool" or giftType == "brainrot") and (data.RewardName or data.BrainrotName) then
		local rewardName = data.RewardName or data.BrainrotName
		local v7 = maid:Add(Instance.new("ViewportFrame"))
		v7.Name = "BrainrotViewport"
		v7.Size = UDim2.fromScale(1, 1)
		v7.Position = UDim2.fromScale(0.5, 0.5)
		v7.AnchorPoint = Vector2.new(0.5, 0.5)
		v7.BackgroundTransparency = 1
		v7.Parent = item
		local v8 = Animals:AttachOnViewport(rewardName, v7, true, data.Mutation)

		if v8 then
			maid:Add(v8)
		end
	end

	local message2 = data.Message and typeof(data.Message) == "string" and #data.Message > 0 and valentinesCard.CardInside:FindFirstChild("Message")

	if message2 then
		message2.Text = data.Message
		message2.Visible = true
	end

	task.wait(0.5)
	valentinesCard.Visible = true
	CreateTween(valentinesCard, TweenInfo.new(0.75), {
		Position = UDim2.fromScale(0.5, 0.5)
	})
	task.wait(0.75)
	SoundController:PlaySound(ReplicatedStorage.Sounds.Sfx.ValentinesLetter, nil, false)
	CreateTween(valentinesCard.bgtopseal.HeartSeal, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
		Position = UDim2.fromScale(0.5, 2)
	})
	task.wait(0.8)
	valentinesCard.bgtopseal.HeartSeal.ImageTransparency = 1
	CreateTween(valentinesCard.bgtopseal, TweenInfo.new(1, Enum.EasingStyle.Quad), {
		Position = UDim2.fromScale(0.5, -1)
	})
	task.wait(0.6)
	CreateTween(valentinesCard.CardInside, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Position = UDim2.fromScale(0.5, -0.4)
	})
	task.wait(0.3)
	valentinesCard.bgtopseal.Visible = false
	valentinesCard.CardInside.ZIndex = 20
	CreateTween(valentinesCard.CardInside, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Position = UDim2.fromScale(0.5, 0.5)
	})
	valentinesCard.CardInside.Close.Activated:Once(function()
		CreateTween(valentinesCard.Parent.Frame, TweenInfo.new(0.25), {
			BackgroundTransparency = 1
		})
		CreateTween(valentinesCard, TweenInfo.new(0.5), {
			Position = UDim2.fromScale(0.5, 2)
		})
		task.wait(1)
		maid:Destroy()
		flag = false
		v6 = false
	end)
	task.delay(1, function()
		CreateTween(valentinesCard.bgbtmback, TweenInfo.new(0.5), {
			ImageTransparency = 1
		})
		CreateTween(valentinesCard.bgbtmfront, TweenInfo.new(0.5), {
			ImageTransparency = 1
		})
	end)
end

function ValentinesShopController._createRightFrame(_)
	local v6 = nil
	FFlags:OnUpdate(function()
		local v7 = not FFlags:GetInstant("ValentinesShop/MessagesDisabled", true)

		if v6 ~= v7 then
			v6 = v7
			updateSelectedProductUI()
		end
	end)
	local textBox = valentinesSendGift.RightMessage.Frame.ScrollingFrame.TextBox

	if textBox then
		textBox.TextSize = 22
	end

	local flag2 = false

	local function buy()
		if flag2 then
			return
		end

		if not v3 then
			NotificationController:Error("You need to select a user to send a gift to!")
			return
		end

		if not v4 then
			return
		end

		local v7 = nil

		if textBox then
			local v8 = string.gsub(textBox.Text, "^%s+", "")
			local v9 = string.gsub(v8, "%s+$", "")

			if #v9 > 0 then
				v7 = v9
			end
		end

		local rightMessage

		if FFlags:GetInstant("ValentinesShop/MessagesDisabled", true) then
			rightMessage = valentinesSendGift.RightMessage
		else
			rightMessage = valentinesSendGift.Right
		end

		if FFlags:GetInstant("ValentinesShop/MessagesDisabled", true) then
			v7 = nil
		end

		flag2 = true
		rightMessage.Buy.BackgroundColor3 = Color3.fromRGB(115, 152, 172)
		rightMessage.Buy.Price.Text = "..."
		pcall(function()
			if remoteFunction3:InvokeServer(v4.rawId, v3.user.userId, v7) then
				if textBox then
					textBox.Text = ""
				end

				InterfaceController:SetState("ValentinesSendGift", false)
				InterfaceController:SetState("ValentinesShop", true)
			end
		end)
		rightMessage.Buy.BackgroundColor3 = Color3.fromRGB(81, 158, 86)
		rightMessage.Buy.Price.Text = "GIFT"
		flag2 = false
	end

	valentinesSendGift.RightMessage.Buy.Activated:Connect(buy)
	valentinesSendGift.Right.Buy.Activated:Connect(buy)

	if not textBox then
		return nil
	end

	local parent = textBox.Parent
	local getTextBoundsParams = Instance.new("GetTextBoundsParams")
	getTextBoundsParams.Size = textBox.TextSize
	getTextBoundsParams.Font = textBox.FontFace
	getTextBoundsParams.Width = textBox.AbsoluteSize.X

	local function updateTextBoxSize()
		local text = textBox.Text

		if utf8.len(text) and utf8.len(text) > 60 then
			local count = 0
			local v7 = 0

			for k, _ in utf8.codes(text) do
				count += 1

				if count > 60 then
					break
				else
					v7 = k
				end
			end

			if v7 > 0 then
				local v8 = utf8.offset(text, 2, v7)
				textBox.Text = string.sub(text, 1, (v8 or #text + 1) - 1)
			end
		else
			getTextBoundsParams.Text = textBox.Text

			if #textBox.Text == 0 then
				getTextBoundsParams.Text = textBox.PlaceholderText or " "
			end

			getTextBoundsParams.Width = textBox.AbsoluteSize.X
			local success, result = pcall(function()
				return TextService:GetTextBoundsAsync(getTextBoundsParams)
			end)

			if success and result then
				local v7 = math.max(result.Y + 10, textBox.TextSize + 10)
				textBox.Size = UDim2.new(0.975, 0, 0, v7)

				if parent then
					parent.CanvasSize = UDim2.new(0, 0, 0, v7)

					if textBox.CursorPosition > 0 then
						parent.CanvasPosition = Vector2.new(0, parent.AbsoluteCanvasSize.Y)
					end
				end
			end
		end
	end

	textBox:GetPropertyChangedSignal("Text"):Connect(updateTextBoxSize)
	textBox:GetPropertyChangedSignal("CursorPosition"):Connect(function()
		if textBox.CursorPosition > 0 and parent then
			parent.CanvasPosition = Vector2.new(0, parent.AbsoluteCanvasSize.Y)
		end
	end)
	task.spawn(updateTextBoxSize)
	return nil
end

function ValentinesShopController._createGiftsTab(_)
	local v6 = Synchronizer:Wait(localPlayer)

	if not v6 then
		return
	end

	local list2 = valentinesShop.Sections.Gifts.List
	local v7 = {}

	local function reconcileGiftInventory()
		local v8 = v6:Get({ "ValentinesEvent", "GiftInventory" })
		list2.Parent.NoGifts.Visible = #v8 == 0
		local v9 = {}

		for k, v10 in v8 do
			v9[v10.Id] = true
			local v11 = v7[v10.Id]

			if not v11 then
				v11 = {}
				local clone = list2.Template:Clone()
				clone.Name = v10.Id
				clone.Visible = true
				clone.Frame.PlayerIcon.Image = `rbxthumb://type=AvatarHeadShot&id={v10.Sender}&w=100&h=100`

				if v10.SenderUsername then
					clone.Frame.Username.Text = `@{v10.SenderUsername}`
				else
					clone.Frame.Username.Text = "???"
					local v12 = v10
					local frame = clone
					v11.thread = task.spawn(function()
						local user = UsersAPI:GetUser(v12.Sender)

						if user then
							frame.Frame.Username.Text = `@{user.Username}`
						end
					end)
				end

				local v12 = AnimatedButton.new(clone.Frame.Send)
				v12:Animate()
				local v13 = v10
				v12.OnActivated:Connect(function()
					local v14, v15 = remoteFunction2:InvokeServer(v13.Id)

					if v14 then
						ValentinesShopController:OpenAnimation(v15)
					end
				end)
				clone.Parent = list2
				v11.frame = clone
				v7[v10.Id] = v11
			end

			v11.frame.LayoutOrder = k
		end

		for k, v10 in v7 do
			if v9[k] then
				continue
			end

			pcall(task.cancel, v10.thread)
			v10.frame:Destroy()
			v7[k] = nil
		end
	end

	v6:OnArrayInserted({ "ValentinesEvent", "GiftInventory" }, reconcileGiftInventory)
	v6:OnArrayRemoved({ "ValentinesEvent", "GiftInventory" }, reconcileGiftInventory)
	task.spawn(reconcileGiftInventory)
end

local v6 = nil

function ValentinesShopController:Open(p: string?, p2: string?)
	InterfaceController:SetState("ValentinesShop", true)
	v6 = p2

	if p ~= nil then
		ValentinesShopController:SetTab(p)
	end
end

function ValentinesShopController:SetTab(p: string)
	for _, child in valentinesShop.Sections:GetChildren() do
		child.Visible = child.Name == p
	end

	local text = p == "Gifts" and "GIFT INVENTORY" or "GIFT SHOP"
	valentinesShop.Header.Txts.Txt1.Text = text

	for _, button in valentinesShop.SideBtns:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		local backgroundColor

		if button.Name == p then
			backgroundColor = Color3.fromRGB(244, 102, 190)
		else
			backgroundColor = Color3.fromRGB(244, 181, 241)
		end

		button.BackgroundColor3 = backgroundColor
	end
end

function ValentinesShopController._createShopTabs(_)
	for _, button in valentinesShop.SideBtns:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		local v7 = AnimatedButton.new(button)
		v7:Animate()
		local v8 = button
		v7.OnActivated:Connect(function()
			ValentinesShopController:SetTab(v8.Name)
		end)
	end

	if ValentinesShopController:IsEnabled() then
		ValentinesShopController:SetTab("Send")
	else
		ValentinesShopController:SetTab("Gifts")
	end
end

function ValentinesShopController._createPlayerList(_)
	v2 = InterfaceController:Register("ValentinesSendGift", valentinesSendGift, "TopQuint")
	v2:Close()
	v2.OnClose:Connect(function()
		setSelectedUser(nil) -- equivalent call inferred; original call site unknown
		v4 = nil
		updateSelectedProductUI()
		local textBox = valentinesSendGift.RightMessage.Frame.ScrollingFrame.TextBox

		if textBox then
			textBox.Text = ""
		end
	end)
	local v7 = AnimatedButton.new(valentinesSendGift.Header.Close)
	v7:Animate()
	v7.OnActivated:Connect(function()
		InterfaceController:SetState("ValentinesSendGift", false)
		InterfaceController:SetState("ValentinesShop", true)
	end)
	local searchBox = valentinesSendGift.Left.SearchFrame.SearchBox
	local v8 = nil
	local v9 = nil

	local function updateUserCard(parent, data, layoutOrder: number, p)
		local formatted = `{data.username}_{data.userId}`
		local v10 = p or parent:FindFirstChild(formatted)

		if not v10 then
			return
		end

		v10.Fill.Status2.Text = data.inGame and "Online" or data.isFriend and "Away" or "Offline"
		local status2 = v10.Fill.Status2
		local color

		if data.inGame then
			color = Color3.fromRGB(86, 211, 74)
		elseif data.isFriend then
			color = Color3.fromRGB(239, 225, 69)
		else
			color = Color3.fromRGB(211, 38, 38)
		end

		status2.TextColor3 = color
		local status = v10.Fill.PlayerImage.Status
		local color2

		if data.inGame then
			color2 = Color3.fromRGB(86, 211, 74)
		elseif data.isFriend then
			color2 = Color3.fromRGB(239, 225, 69)
		else
			color2 = Color3.fromRGB(211, 38, 38)
		end

		status.BackgroundColor3 = color2

		if not data.inGame then
			layoutOrder += 300
		end

		v10.LayoutOrder = layoutOrder
		local fill = v10.Fill
		local backgroundColor

		if v3 and v3.user and v3.user.userId == data.userId then
			backgroundColor = Color3.fromRGB(244, 102, 190)
		else
			backgroundColor = Color3.fromRGB(255, 189, 240)
		end

		fill.BackgroundColor3 = backgroundColor
	end

	local function createUserCard(parent, user, p2: number)
		local formatted = `{user.username}_{user.userId}`
		local clone = valentinesSendGift.Left.LocalList.UIListLayout.Template:Clone()
		clone.Name = formatted
		clone.Fill.PlayerImage.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={user.userId}&w=100&h=100`
		clone.Fill.Username.Text = `@{user.username}`
		updateUserCard(parent, user, p2, clone)
		clone.Visible = true
		clone.Parent = parent
		clone.Destroying:Once(function()
			if v3 and v3.card == clone then
				setSelectedUser(nil) -- equivalent call inferred; original call site unknown
			end
		end)
		clone.Fill.Activated:Connect(function()
			local v10 = v3
			local v11 = v3
			v3 = {
				parent = parent,
				card = clone,
				user = user,
				index = p2
			}
			local fill = v11 and v11.card and v11.card.Parent and v11.card:FindFirstChild("Fill")

			if fill then
				fill.BackgroundColor3 = Color3.fromRGB(255, 189, 240)
			end

			if v10 then
				updateUserCard(v10.parent, v10.user, v10.index, v10.card)
			end

			updateUserCard(parent, user, p2, clone)
		end)
		return clone
	end

	local v10 = Trove.new()

	local function updateLists()
		local thread = coroutine.running()
		v9 = thread
		v10:Clean()
		local inGameFriends = Friends:GetInGameFriends(localPlayer)
		local v11 = {}

		if v8 == "Server" then
			for _, v12 in Players:GetPlayers() do
				if v12 ~= localPlayer then
					table.insert(v11, {
						username = v12.Name,
						userId = v12.UserId,
						inGame = true,
						isFriend = table.find(inGameFriends, v12) ~= nil
					})
				end
			end
		elseif v8 == "Global" then
			local onlineFriends, v12 = Friends:GetOnlineFriends()

			if onlineFriends and typeof(v12) == "table" then
				for _, v13 in v12 do
					local v14 = {
						username = v13.UserName,
						userId = v13.VisitorId,
						inGame = v13.PlaceId ~= nil and table.find(ServerData.AllPlaces, v13.PlaceId) ~= nil,
						isFriend = true
					}
					table.insert(v11, v14)
				end
			end
		end

		if thread ~= v9 then
			return
		end

		for k, v12 in v11 do
			local maid = v10
			local v14

			if v8 == "Global" then
				v14 = valentinesSendGift.Left.GlobalList
			else
				v14 = valentinesSendGift.Left.LocalList
			end

			maid:Add((createUserCard(v14, v12, k)))
		end
	end

	local function setTab(p: string)
		if v8 == p then
			return
		end

		v8 = p
		searchBox.Text = ""
		valentinesSendGift.Left.LocalList.Visible = v8 ~= "Global"
		valentinesSendGift.Left.GlobalList.Visible = v8 == "Global"
		valentinesSendGift.Left.SearchFrame.Visible = v8 == "Global"

		for _, button in valentinesSendGift.Left.Btns:GetChildren() do
			if not button:IsA("GuiButton") then
				continue
			end

			local name = button.Name
			local backgroundColor

			if v8 == name then
				backgroundColor = Color3.fromRGB(244, 102, 190)
			else
				backgroundColor = Color3.fromRGB(225, 162, 220)
			end

			button.BackgroundColor3 = backgroundColor
		end

		updateLists()
	end

	Players.PlayerAdded:Connect(function()
		if v8 == "Server" then
			updateLists()
		end
	end)
	Players.PlayerRemoving:Connect(function()
		if v8 == "Server" then
			updateLists()
		end
	end)
	valentinesSendGift.Left.SearchFrame.SearchBox.FocusLost:Connect(function(flag2: boolean)
		local WAIT_INTERVAL = 5
		assert(v4)

		if not flag2 then
			return
		end

		local text = searchBox.Text
		searchBox.TextEditable = false
		searchBox.Active = false
		searchBox.Text = "..."
		v10:Clean()
		local success, result = pcall(function()
			return Players:GetUserIdFromNameAsync(text)
		end)

		if success and typeof(result) == "number" then
			local success2, result2, inGame = pcall(function()
				return remoteFunction:InvokeServer(v4.rawId, result)
			end)

			if success2 and result2 then
				local success3, result3 = pcall(function()
					return UsersAPI:GetUser(result)
				end)
				local maid = v10
				local globalList = valentinesSendGift.Left.GlobalList
				local user = {
					userId = result,
					username = 0,
					inGame = 0
				}
				local username

				if success3 and typeof(result3) == "table" and result3.IsLoaded then
					username = result3.Username
				else
					username = string.upper(text)
				end

				user.username = username
				user.inGame = inGame
				maid:Add((createUserCard(globalList, user, 1)))
				searchBox.Text = ""
				task.wait(WAIT_INTERVAL)
				searchBox.TextEditable = true
				searchBox.ClearTextOnFocus = true
				searchBox.Active = true
			else
				local searchBox2 = searchBox

				if typeof(result2) ~= "string" then
					result2 = typeof(inGame) ~= "string" and "Failed to search for user, try again later" or inGame
				end

				searchBox2.Text = result2
				task.wait(WAIT_INTERVAL)
				searchBox.Text = ""
				searchBox.TextEditable = true
				searchBox.Active = true
				updateLists()
				return false
			end
		else
			searchBox.Text = string.find(result, "Unknown user") and "User not found!" or "Failed to search for user, try again later"
			task.wait(WAIT_INTERVAL)
			searchBox.Text = ""
			searchBox.TextEditable = true
			searchBox.Active = true
			updateLists()
			return false
		end
	end)

	for _, button in valentinesSendGift.Left.Btns:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		local name = button.Name
		local v11 = AnimatedButton.new(button)
		v11:Animate()
		v11.OnActivated:Connect(function()
			setTab(name)
		end)
	end

	setTab("Server")
end

function ValentinesShopController:_createShopObjects()
	v = InterfaceController:Register("ValentinesShop", valentinesShop, "TopQuint")
	local v7 = AnimatedButton.new(valentinesShop.Header.Close)
	v7:Animate(nil, nil, 5)
	v7.OnActivated:Connect(function()
		InterfaceController:SetState("ValentinesShop", false)

		if v6 then
			InterfaceController:SetState(v6, true)
			v6 = nil
		end
	end)
	v:Close()
	task.spawn(function()
		list["Heart Lucky Block"].Visible = false
		list.LuckyBlocksList.Secret.Visible = false
		local policy = Policy.getPolicy(localPlayer)

		if policy and not policy.ArePaidRandomItemsRestricted then
			list["Heart Lucky Block"].Visible = true
			list.LuckyBlocksList.Secret.Visible = true
		end
	end)

	local function setupOdds(parent, p, p2: string)
		local maid = Trove.new()
		local v8 = nil

		local function setOddsVisibility(visible: boolean)
			parent.Visible = visible

			if visible == v8 then
				return
			end

			v8 = visible

			if not visible then
				maid:Clean()
				return
			end

			local v9 = Mutations.get()
			local v10 = {}
			local v11 = LuckyBlockFlags.OddsOverride:Get()[p2]

			if v11 and next(v11) then
				for k, chance in v11 do
					table.insert(v10, {
						animal = k,
						chance = chance
					})
				end
			else
				for _, animal in p.Animals do
					if (not animal.IsEnabled or animal.IsEnabled()) and animal.Chance then
						table.insert(v10, {
							animal = animal.Name,
							chance = animal.Chance
						})
					end
				end
			end

			table.sort(v10, function(a, b)
				return b.chance < a.chance
			end)
			local xScalar = parent:GetAttribute("XScalar") or 1
			local v12 = parent.Template.Size.X.Scale * xScalar
			local v13 = math.ceil(1 / v12) + 1
			local v14 = math.ceil(v13 / #v10) * #v10
			local clones = table.create(v14)
			local total = 0

			for i = 1, v14 do
				local v15 = v10[(i - 1) % #v10 + 1]
				local clone = maid:Clone(parent.Template)
				clone.Name = tostring(i)
				clone.LayoutOrder = i
				clone.Chance.Text = `{v15.chance}%`
				clone.Visible = true
				clone.Position = UDim2.fromScale(total, 0.5)
				clone.Parent = parent
				total += v12
				clones[i] = clone
				local v16 = Animals:AttachOnViewport(v15.animal, clone, true, v9)

				if v16 then
					maid:Add(v16)
				end
			end

			if v13 <= #clones then
				local v15 = 0.5

				if xScalar > 1 then
					v15 *= xScalar
				end

				maid:Add(RunService.PreRender:Connect(function(dt: number)
					local v16 = v12 * dt * v15

					for _, v17 in clones do
						v17.Position -= UDim2.fromScale(v16, 0)

						if v17.Position.X.Scale <= -v12 then
							v17.Position += UDim2.fromScale(v12 * #clones, 0)
						end
					end
				end))
			end
		end

		Updates.OnUpdateEnabled:Connect(function()
			if parent.Visible and v:IsOpened() then
				parent.Visible = false

				if v8 ~= false then
					v8 = false
					maid:Clean()
				end

				setOddsVisibility(true)
			end
		end)
		Updates.OnUpdateDisabled:Connect(function()
			if parent.Visible and v:IsOpened() then
				parent.Visible = false

				if v8 ~= false then
					v8 = false
					maid:Clean()
				end

				setOddsVisibility(true)
			end
		end)
		v.OnClose:Connect(function()
			parent.Visible = false

			if v8 == false then
				return
			end

			v8 = false
			maid:Clean()
		end)
		v.OnOpen:Connect(function()
			setOddsVisibility(true)
		end)
		Mutations.watch(function()
			if parent.Visible and v:IsOpened() then
				parent.Visible = false

				if v8 ~= false then
					v8 = false
					maid:Clean()
				end

				setOddsVisibility(true)
			end
		end)
		LuckyBlockFlags.OddsOverride.Changed:Connect(function()
			if parent.Visible and v:IsOpened() then
				parent.Visible = false

				if v8 ~= false then
					v8 = false
					maid:Clean()
				end

				setOddsVisibility(true)
			end
		end)
	end

	for _, child in list:GetChildren() do
		local name = child.Name

		if name == "Heart Lucky Block" then
			local v8 = child
			task.spawn(function()
				local policy = Policy.getPolicy(localPlayer)

				if not policy or policy.ArePaidRandomItemsRestricted then
					return
				end

				-- equivalent calls inferred from this helper; original call sites unknown
				local function isLuckyBlockActive()
					return workspace:GetServerTimeNow() < FFlags:GetInstant("HeartLuckyBlockPackEndTime", 1771704000)
				end

				for i, child2 in v8:GetChildren() do
					if child2.Name == "Odds" then
						setupOdds(child2, LuckyBlocks["Premium Heart Lucky Block"], "Premium Heart Lucky Block")
					end
				end

				local v9 = Trove.new()

				local function updateInfo()
					v9:Destroy()

					if not v:IsOpened() then
						return
					end

					local v10 = Mutations.get()

					if v10 and Mutations2[v10] then
						MutationText.apply(v8.Mutation, v10, "Rich")
						v8.Mutation.Visible = true
					else
						v8.Mutation.Visible = nil
					end

					for i, viewportFrame in v8:GetChildren() do
						if not (viewportFrame:IsA("ViewportFrame") and viewportFrame.Name == "IconViewport") then
							continue
						end

						local v11 = Animals:AttachOnViewport("Premium Heart Lucky Block", viewportFrame, true, v10)

						if v11 then
							v9:Add(v11)
						end
					end
				end

				task.spawn(updateInfo)
				v.OnClose:Connect(updateInfo)
				v.OnOpen:Connect(updateInfo)
				Mutations.watch(updateInfo)
				local v10 = AnimatedButton.new(v8.Buttons.Buy)
				v10:Animate()
				v10.OnActivated:Connect(function()
					self:Purchase(3531057541)
				end)
				local v11 = AnimatedButton.new(v8.Buttons.Buy3)
				v11:Animate()
				v11.OnActivated:Connect(function()
					self:Purchase(3531057803)
				end)
				local v12 = AnimatedButton.new(v8.Buttons.Buy10)
				v12:Animate()
				v12.OnActivated:Connect(function()
					self:Purchase(3531057804)
				end)

				local function updateBuyVisibility()
					local v13 = Synchronizer:Get(localPlayer)

					if not v13 then
						return
					end

					local v14 = v13:Get({ "LuckyBlocks", (tostring(3531057803)) }) or 0
					v12.Instance.Visible = v14 >= 5
					v11.Instance.Visible = v14 < 5
				end

				task.spawn(function()
					ValentinesShopController:BindLabelToProductPrice(
						v8.Buttons.Buy.Price,
						ValentinesShopController:GetProductId(3531057541),
						"Product"
					)
					ValentinesShopController:BindLabelToProductPrice(
						v8.Buttons.Buy3.Price,
						ValentinesShopController:GetProductId(3531057803),
						"Product"
					)
					ValentinesShopController:BindLabelToProductPrice(
						v8.Buttons.Buy10.Price,
						ValentinesShopController:GetProductId(3531057804),
						"Product"
					)
				end)
				task.spawn(function()
					local v13 = Synchronizer:Wait(localPlayer)

					if not v13 then
						return
					end

					v13:OnChanged({ "LuckyBlocks", (tostring(3531057803)) }, updateBuyVisibility)
					updateBuyVisibility()
				end)
				task.spawn(updateBuyVisibility)
				local timer = v8:WaitForChild("Timer")
				Timer.Simple(1, function()
					v8.Visible = isLuckyBlockActive()
					local instant = FFlags:GetInstant("HeartLuckyBlockPackEndTime", 1771704000)
					local serverTimeNow = workspace:GetServerTimeNow()

					if timer then
						timer.Text = `{TimeUtils:E(instant - serverTimeNow)} left`
					end
				end)
			end)
		elseif name == "LuckyBlocksList" then
			local v8 = child
			task.spawn(function()
				local secret = v8.Secret
				local secretLuckyBlock = LuckyBlocks["Secret Lucky Block"]

				if not secretLuckyBlock then
					return
				end

				local productId = secretLuckyBlock.ProductId

				if not productId then
					return
				end

				for i, child2 in ipairs(secret:GetChildren()) do
					if child2.Name ~= "Odds" then
						continue
					end

					local luckyBlock = child2:GetAttribute("LuckyBlock") or "Secret Lucky Block"
					setupOdds(child2, LuckyBlocks[luckyBlock], luckyBlock)
				end

				local v9 = Trove.new()

				local function updateInfo()
					v9:Destroy()

					if not v:IsOpened() then
						return
					end

					local v10 = Mutations.get()

					if v10 and Mutations2[v10] then
						MutationText.apply(secret.Mutation, v10, "Rich")
						secret.Mutation.Visible = true
					else
						secret.Mutation.Visible = nil
					end

					for i, viewportFrame in ipairs(secret:GetChildren()) do
						if not (viewportFrame:IsA("ViewportFrame") and viewportFrame.Name == "IconViewport") then
							continue
						end

						local luckyBlock = viewportFrame:GetAttribute("LuckyBlock") or "Secret Lucky Block"
						local v11 = Animals:AttachOnViewport(luckyBlock, viewportFrame, true, v10)

						if v11 then
							v9:Add(v11)
						end
					end
				end

				task.spawn(updateInfo)
				v.OnClose:Connect(function()
					updateInfo()
				end)
				v.OnOpen:Connect(function()
					updateInfo()
				end)
				Mutations.watch(function()
					task.spawn(updateInfo)
				end)
				local v10 = AnimatedButton.new(secret.Buy)
				v10:Animate()
				v10.OnActivated:Connect(function()
					self:Purchase(productId)
				end)
				ValentinesShopController:BindLabelToProductPrice(
					secret.Buy.Price,
					ValentinesShopController:GetProductId(productId),
					"Product",
					100
				)
			end)
			local v9 = child
			task.spawn(function()
				local wings = v9.Wings
				local policy = Policy.getPolicy(localPlayer)
				local visible = not policy or policy.ArePaidRandomItemsRestricted
				local v11 = visible and 3536298171 or 3536298173
				wings.LuckyBlock.Visible = not visible
				wings.NonLuckyBlock.Visible = visible
				local v12 = AnimatedButton.new(wings.Buy)
				v12:Animate()
				v12.OnActivated:Connect(function()
					self:Purchase(v11)
				end)
				ValentinesShopController:BindLabelToProductPrice(
					wings.Buy.Price,
					ValentinesShopController:GetProductId(v11),
					"Product",
					100
				)
			end)
		elseif name == "Rose Base" then
			local v8 = child
			task.spawn(function()
				-- equivalent calls inferred from this helper; original call sites unknown
				local function isRoseBaseActive()
					return workspace:GetServerTimeNow() < FFlags:GetInstant("RoseBasePackEndTime", 1771704000)
				end

				local policy = Policy.getPolicy(localPlayer)
				local buy = v8:WaitForChild("Buy", 5)
				local price = buy and buy:WaitForChild("Price", 5)
				local flag2 = false

				local function getProductId()
					if policy and not policy.ArePaidRandomItemsRestricted then
						return 3531055926
					end

					return 3531055923
				end

				v8.LuckyBlock.Visible = (policy and not policy.ArePaidRandomItemsRestricted and 3531055926 or 3531055923) == 3531055926
				v8.Visible = true
				v8:SetAttribute(
					"ProductId",
					policy and not policy.ArePaidRandomItemsRestricted and 3531055926 or 3531055923
				)

				-- equivalent calls inferred from this helper; original call sites unknown
				local function updateInfo()
					local v9 = policy and not policy.ArePaidRandomItemsRestricted and 3531055926 or 3531055923
					v8:SetAttribute("ProductId", v9)
					v8.LuckyBlock.Visible = v9 == 3531055926

					if price then
						ValentinesShopController:BindLabelToProductPrice(
							price,
							ValentinesShopController:GetProductId(v9)
						)
					end
				end

				-- equivalent calls inferred from this helper; original call sites unknown
				local function ToggleVisibility()
					v8.Visible = isRoseBaseActive()
				end

				FFlags:OnUpdate(function()
					ToggleVisibility() -- equivalent call inferred; original call site unknown
				end)
				local timer = v8:WaitForChild("Timer", 5)
				Timer.Simple(1, function()
					local instant = FFlags:GetInstant("RoseBasePackEndTime", 1771704000)
					local serverTimeNow = workspace:GetServerTimeNow()

					if timer then
						timer.Text = `{TimeUtils:E(instant - serverTimeNow)} left`
					end

					if instant <= serverTimeNow then
						if not flag2 then
							flag2 = true
							ToggleVisibility() -- equivalent call inferred; original call site unknown
						end
					elseif flag2 then
						flag2 = false
						ToggleVisibility() -- equivalent call inferred; original call site unknown
					end
				end)
				updateInfo() -- equivalent call inferred; original call site unknown
				local v9 = AnimatedButton.new(buy)
				v9:Animate()
				v9.OnActivated:Connect(function()
					self:Purchase(policy and not policy.ArePaidRandomItemsRestricted and 3531055926 or 3531055923)
				end)
			end)
		elseif name == "ItemsList" or name == "GamepassList" then
			local v8

			if name == "GamepassList" then
				v8 = { child["3296367604"], child.Main["3296367825"], child.Main["3296367737"] }
			else
				v8 = child.Fill:GetChildren()
			end

			for _, guiObject in v8 do
				if not guiObject:IsA("GuiObject") then
					continue
				end

				local v9 = guiObject
				task.spawn(function()
					local name2 = tonumber(v9.Name)

					if not name2 then
						return
					end

					assert(name2)
					local v10 = Shop[name2]

					if not v10 then
						return
					end

					local buy = v9:WaitForChild("Buy", 5)
					local price = buy and buy:WaitForChild("Price", 5)
					local icon = v9:FindFirstChild("Icon", true)

					if v10.Icon and icon then
						icon.ScaleType = Enum.ScaleType.Fit
						icon.Image = v10.Icon
					end

					local function updateInfo()
						local productInfo = Marketplace:GetProductInfo(name2, "Product")

						if price then
							ValentinesShopController:BindLabelToProductPrice(
								price,
								ValentinesShopController:GetProductId(name2)
							)
						end

						if productInfo.Icon and icon then
							icon.ScaleType = Enum.ScaleType.Fit

							if not v10.Icon then
								icon.Image = productInfo.Icon
							end
						end
					end

					updateInfo()
					local v11 = AnimatedButton.new(buy)
					v11:Animate()
					v11.OnActivated:Connect(function()
						self:Purchase(name2)
					end)
				end)
			end
		end
	end
end

function ValentinesShopController:GetProductId(p: number)
	return ValentinesShop.Products[p].discountedProductId
end

function ValentinesShopController:Purchase(rawId: number)
	if not ValentinesShop.Products[rawId] then
		return
	end

	setSelectedProduct(rawId)
	InterfaceController:SetState("ValentinesSendGift", true)
end

function ValentinesShopController:BindLabelToProductPrice(p, p2: number, p3: string?, p4: number?)
	local v7 = Synchronizer:Wait(localPlayer)

	if not v7 then
		return
	end

	local failedGiftKeyFromDiscounted = getFailedGiftKeyFromDiscounted(p2) -- equivalent call inferred; original call site unknown

	local function updatePrice()
		local v8 = v7:Get({ "ValentinesEvent", "FailedGifts", failedGiftKeyFromDiscounted })

		if typeof(v8) ~= "table" or not (#v8 > 0) then
			ShopController:BindLabelToProductPrice(p, p2, p3, p4)
			return
		end

		ShopController:UnbindLabelProductPrice(p)
		p.Text = `FREE ({#v8})`
	end

	v7:OnChanged({ "ValentinesEvent", "FailedGifts", failedGiftKeyFromDiscounted }, updatePrice)
	v7:OnArrayInserted({ "ValentinesEvent", "FailedGifts", failedGiftKeyFromDiscounted }, updatePrice)
	v7:OnArrayRemoved({ "ValentinesEvent", "FailedGifts", failedGiftKeyFromDiscounted }, updatePrice)
	updatePrice()
end

local function listenForGiftInventoryChanges(object, fn)
	local connection = object:OnChanged({ "ValentinesEvent", "GiftInventory" }, fn)
	local connection2 = object:OnArrayInserted({ "ValentinesEvent", "GiftInventory" }, fn)
	local connection3 = object:OnArrayRemoved({ "ValentinesEvent", "GiftInventory" }, fn)
	local thread = task.spawn(fn)
	return function()
		pcall(task.cancel, thread)

		if connection2 then
			connection2:Disconnect()
		end

		if connection3 then
			connection3:Disconnect()
		end

		if connection then
			connection:Disconnect()
		end
	end
end

function ValentinesShopController._createGiftSubtitleLabel(_)
	local v7 = Synchronizer:Wait(localPlayer)

	if not v7 then
		return
	end

	local function getSubtitleText()
		local v8 = v7:Get({ "ValentinesEvent", "GiftInventory" })

		if typeof(v8) ~= "table" or not (#v8 > 0) then
			return "Send Gifts"
		end

		if #v8 == 1 then
			return "1 Gift Available"
		end

		return (`{#v8} Gifts Available`)
	end

	Observers.observeTag("ValentinesGiftSubtitle", function(p)
		return (listenForGiftInventoryChanges(v7, function()
			p.Text = getSubtitleText()
		end))
	end)
	Observers.observeTag("ValentinesMailboxRotate", function(instance)
		local pivot = instance:GetPivot()
		local v8 = listenForGiftInventoryChanges(v7, function()
			local v9 = v7:Get({ "ValentinesEvent", "GiftInventory" })
			local v10

			if typeof(v9) == "table" then
				v10 = #v9 > 0
			else
				v10 = false
			end

			local target = Spr.target
			local pivot2

			if v10 then
				pivot2 = pivot * CFrame.Angles(0, 0, 1.5707963267948966)
			else
				pivot2 = pivot
			end

			target(instance, 0.75, 3, {
				Pivot = pivot2
			})
		end)
		return function()
			v8()
			Spr.stop(instance)
			instance:PivotTo(pivot)
		end
	end)
end

function ValentinesShopController._createMailboxVFX(_)
	local v7 = Synchronizer:Wait(localPlayer)

	if not v7 then
		return
	end

	Observers.observeTag("ValentinesShopModel", function(instance)
		local VFX2 = instance:WaitForChild("VFX", 5)

		if not VFX2 then
			return nil
		end

		local minorGlow = VFX2:FindFirstChild("MinorGlow")
		local glowAndHearts = VFX2:FindFirstChild("GlowAndHearts")
		local burst = VFX2:FindFirstChild("Burst")

		local function updateMailboxVFX()
			local v8 = v7:Get({ "ValentinesEvent", "GiftInventory" })
			local v9

			if typeof(v8) == "table" then
				v9 = #v8 > 0
			else
				v9 = false
			end

			if v9 then
				if minorGlow then
					VFX.disable(minorGlow)
				end

				if glowAndHearts then
					VFX.enable(glowAndHearts)
				end
			else
				if minorGlow then
					VFX.enable(minorGlow)
				end

				if glowAndHearts then
					VFX.disable(glowAndHearts)
				end
			end
		end

		local connection = v7:OnArrayInserted({ "ValentinesEvent", "GiftInventory" }, function()
			if burst and ValentinesShopController:IsEnabled() then
				VFX.emit(burst)
				SoundController:PlaySound(
					ReplicatedStorage.Sounds.Sfx.ValentinesMailboxBurst,
					instance:GetPivot().Position,
					false
				)
			end

			updateMailboxVFX()
		end)
		local connection2 = v7:OnArrayRemoved({ "ValentinesEvent", "GiftInventory" }, function()
			updateMailboxVFX()
		end)
		local connection3 = v7:OnChanged({ "ValentinesEvent", "GiftInventory" }, function()
			updateMailboxVFX()
		end)
		updateMailboxVFX()
		return function()
			if connection then
				connection:Disconnect()
			end

			if connection2 then
				connection2:Disconnect()
			end

			if connection3 then
				connection3:Disconnect()
			end
		end
	end)
end

function ValentinesShopController._createGiftNotifications(_)
	local valentinesGifts = playerGui:WaitForChild("ValentinesGifts").ValentinesGifts
	remoteEvent.OnClientEvent:Connect(function(data)
		local clone = valentinesGifts.Template:Clone()
		clone.Visible = true
		local icon = clone:FindFirstChild("Icon") or clone:FindFirstChild("PlayerIcon")

		if icon then
			icon.Image = `rbxthumb://type=AvatarHeadShot&id={data.Sender}&w=100&h=100`
		end

		local username = clone:FindFirstChild("Username")

		if username then
			if data.SenderUsername then
				username.Text = `@{data.SenderUsername} sent you a gift!`
			else
				username.Text = "Someone sent you a gift!"
				task.spawn(function()
					local user = UsersAPI:GetUser(data.Sender)

					if user and clone.Parent then
						username.Text = `@{user.Username} sent you a gift!`
					end
				end)
			end
		end

		local v7 = CornerNotificationController:Add(clone)
		local yes = clone:FindFirstChild("Yes")

		if yes then
			local v8 = AnimatedButton.new(yes)
			v8:Animate()
			v8.OnActivated:Connect(function()
				SoundController:PlaySound("Sounds.Sfx.Activated")
				v7()

				if data.Id then
					local v9, v10 = remoteFunction2:InvokeServer(data.Id)

					if v9 then
						ValentinesShopController:OpenAnimation(v10)
					end
				end
			end)
		end

		local no = clone:FindFirstChild("No")

		if no then
			local v8 = AnimatedButton.new(no)
			v8:Animate()
			v8.OnActivated:Connect(function()
				v7()
			end)
		end

		CreateTween(clone.Fill, TweenInfo.new(15), {
			Size = UDim2.fromScale(0, clone.Fill.Size.Y.Scale)
		})
		task.delay(15, v7)
	end)
end

function ValentinesShopController.IsEnabled(_)
	return false
end

function ValentinesShopController.Start(_)
	local v7 = Synchronizer:Wait(localPlayer)

	if not v7 then
		return
	end

	task.spawn(ValentinesShopController._createGiftsTab, ValentinesShopController)
	task.spawn(ValentinesShopController._createShopTabs, ValentinesShopController)
	task.spawn(ValentinesShopController._createRightFrame, ValentinesShopController)
	task.spawn(ValentinesShopController._createPlayerList, ValentinesShopController)
	task.spawn(ValentinesShopController._createShopObjects, ValentinesShopController)
	task.spawn(ValentinesShopController._createGiftNotifications, ValentinesShopController)
	task.spawn(ValentinesShopController._createGiftSubtitleLabel, ValentinesShopController)
	task.spawn(ValentinesShopController._createMailboxVFX, ValentinesShopController)
	local notification = valentinesShop.SideBtns.Gifts.Notification
	listenForGiftInventoryChanges(v7, function()
		local count = #v7:Get({ "ValentinesEvent", "GiftInventory" })
		notification.Visible = count > 0
		notification.Txt.Text = tostring(count)
	end)

	local function updateView()
		local isEnabled = ValentinesShopController:IsEnabled()
		valentinesShop.SideBtns.Visible = isEnabled
		valentinesShop.Header.DiscountText1.Visible = isEnabled
		valentinesShop.Header.DiscountText2.Visible = isEnabled

		if not (isEnabled or valentinesShop.Sections.Gifts.Visible) then
			ValentinesShopController:SetTab("Gifts")
		end
	end

	Updates.OnUpdateEnabled:Connect(updateView)
	Updates.OnUpdateDisabled:Connect(updateView)
	task.spawn(updateView)
	Observers.observeTag("ValentinesGiftsPrompt", function(p)
		local triggeredConnection = p.Triggered:Connect(function()
			if not Synchronizer:Get(localPlayer) then
				return
			end

			ValentinesShopController:Open()
		end)
		return function()
			triggeredConnection:Disconnect()
		end
	end)
end

return ValentinesShopController