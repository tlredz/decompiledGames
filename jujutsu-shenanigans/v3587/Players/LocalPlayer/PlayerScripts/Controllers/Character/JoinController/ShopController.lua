local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local v = nil
local v2 = nil
local MarketplaceService = game:GetService("MarketplaceService")
local controller = Knit.CreateController({
	Name = "ShopController"
})
local sendRobux = script.SendRobux
local v3 = {
	[718947270] = "GamePass",
	[718699461] = "GamePass",
	[742180133] = "GamePass",
	[857428668] = "GamePass",
	[984868818] = "GamePass",
	[1151174294] = "GamePass"
}
local v4 = {
	15691934088,
	15692322754,
	16379484942,
	16380012541,
	16938511900
}
local v5 = {
	"Looking to buy something?",
	"Welcome to the shop!",
	"Hope you'll buy something this time.",
	"Check out the selection!",
	"What's up?",
	"Got something you're looking for?",
	"I've got some stuff for you!",
	"It's time to spend!",
	"How's the portable shop service?",
	"Welcome!",
	"Hope you have fun shopping!",
	"Get me out of here.",
	"Buying something for someone? We have gifting options!",
	"hiiiii!!!!!!",
	"How are you?",
	"How's your day?",
	"feed me cash",
	"omg hiiiiii!!!",
	"Thinking about buying some emotes?",
	"Thinking about gifting gamepasses?"
}
local v6 = {
	"ow",
	"yeow",
	"yeowch",
	"stop",
	"stop it",
	"that hurts"
}

function controller._initDonateMenu()
	sendRobux.Frame.Buttons.Cancel.MouseButton1Click:Connect(function()
		sendRobux.Parent = script
	end)
	sendRobux.Frame.Buttons.Send.MouseButton1Click:Connect(function()
		local text = tonumber(sendRobux.Frame.TextBox.Text)

		if text then
			sendRobux.Parent = script
			v.SendRobux:Fire(sendRobux:GetAttribute("ReceiverId"), text)
		end
	end)
end

function controller.PromptDonateMenu(_, receiverId: number, p: string?)
	if sendRobux.Parent ~= script then
		return
	end

	local v7 = p or game.Players:GetNameFromUserIdAsync(receiverId)
	sendRobux.Frame.Title.Text = `Sending to {v7}`
	sendRobux.Frame.TextBox.Text = ""
	sendRobux:SetAttribute("ReceiverId", receiverId)
	sendRobux.Parent = localPlayer.PlayerGui
end

local userId = nil

function controller.GetGiftSelect(_)
	return userId
end

function controller.KnitStart(_)
	local menus = localPlayer.PlayerGui:WaitForChild("Menus")
	local shop = menus.Group.Shop
	shop:SetAttribute("Loaded", true)
	local keeper = menus.Keeper
	local keeper2 = keeper.Keeper
	controller._initDonateMenu()
	v.Notification:Connect(function(p, p2, p3)
		if p2 == 1 then
			v2:PlaySound(sounds.Misc.UI.Purchase, workspace, game.SoundService.Effect)
			v2:Notification(p, Color3.fromRGB(255, 255, 0), p3)
		elseif p2 == 2 then
			v2:Notification(p, Color3.fromRGB(255, 255, 255), p3)
		elseif p2 == 3 then
			v2:PlaySound(sounds.Misc.UI.Announcement, workspace, game.SoundService.Effect)
			v2:Notification(p, Color3.fromRGB(255, 78, 119), p3)
		end
	end)
	v.Chat:Connect(function(p)
		TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage(p)
	end)

	local function Talk(value)
		if keeper:FindFirstChild("Chat") then
			keeper:FindFirstChild("Chat"):Destroy()
		end

		local clone = menus.Preset.Chat:Clone()
		clone.Parent = keeper
		task.spawn(function()
			for i = 1, #value do
				if not clone.Parent then
					break
				end

				shop.Talk:Play()
				keeper.Chat.Text = string.sub(value, 0, i)
				keeper2.Head.Mouth.Transparency = i % 2
				task.wait(0.035)
			end

			if not clone.Parent then
				return
			end

			keeper2.Head.Mouth.Transparency = 1
		end)
		return clone
	end

	local function SelectCategory(instance)
		for _, button in shop.Categories:GetChildren() do
			if button:IsA("TextButton") then
				button.Select.Visible = button == instance
			end
		end

		v2:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)

		for _, child in shop.Items:GetChildren() do
			child.Visible = child.Name == instance.Name
		end

		shop.Gift.Visible = instance:GetAttribute("Gift") and true or false
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function ChangeWarningType(p)
		menus.Warning.TextLabel.Text = ([[
You are <font color= "rgb(240, 40, 10)">buying a %s for another player</font> 
If you would like to buy a %s for yourself, close the gifting menu and try again 
If you would like to continue to purchase, press the purchase button below 
 Otherwise, press the cancel button below]]):format(p, p)
	end

	for _, button in shop.Categories:GetChildren() do
		if not button:IsA("TextButton") then
			continue
		end

		local v7 = button
		button.MouseButton1Down:Connect(function()
			SelectCategory(v7)
		end)
	end

	userId = localPlayer.UserId
	local text = nil

	for k, _ in v3 do
		local clone = menus.Preset.Gamepass:Clone()
		clone.Parent = shop.Items.Gamepass.Gamepasses
		local v7 = k
		task.spawn(function()
			local productInfo = MarketplaceService:GetProductInfo(v7, Enum.InfoType.GamePass)
			local name = productInfo.Name
			clone.Gamepass.Text = name
			clone.Purchase.Robux.Text = "" .. (productInfo.PriceInRobux or "NIL")
			clone.Description.Text = productInfo.Description or ""
			clone.Name = name
			clone.Icon.Image = "rbxassetid://" .. productInfo.IconImageAssetId
		end)
		local v9 = clone
		clone.Purchase.Robux.MouseButton1Down:Connect(function()
			v2:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)

			if userId == nil then
				return
			end

			if userId == localPlayer.UserId then
				v.Purchase:Fire(v9.Gamepass.Text, "Gamepass", userId)
				return
			end

			menus.Warning.Buttons.Robux.Text = v9.Purchase.Robux.Text
			ChangeWarningType("gamepass") -- equivalent call inferred; original call site unknown
			menus.Warning.Visible = true
			text = v9.Gamepass.Text
		end)
	end

	menus.Warning.Buttons.Robux.MouseButton1Down:Connect(function()
		v2:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
		menus.Warning.Visible = false
		v.Purchase:Fire(text, "Gamepass", userId)
	end)
	menus.Warning.Buttons.Cancel.MouseButton1Down:Connect(function()
		v2:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
		menus.Warning.Visible = false
	end)
	local players = shop.Gift.Players
	local v7 = shop.Gift.For
	local gift = shop.Gift.Gift

	local function createGiftPlayer(name, p, displayName)
		local clone = menus.Preset.Player:Clone()
		clone.Name = name
		clone.Display.Text = displayName or p
		clone.Main.Text = "(@" .. p .. ")"
		clone.Parent = players
		clone.Select.MouseButton1Down:Connect(function()
			userId = name
			v2:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)

			for _, frame in players:GetChildren() do
				if not frame:IsA("Frame") then
					continue
				end

				if frame == clone then
					frame.BackgroundTransparency = 0.5
				else
					frame.BackgroundTransparency = 1
				end
			end
		end)
		task.spawn(function()
			local userThumbnailAsync = game.Players:GetUserThumbnailAsync(
				name,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size48x48
			)
			clone.Icon.Image = userThumbnailAsync
		end)
		return clone
	end

	local now = tick()

	local function updateGiftList()
		local text2 = v7.Text
		userId = nil

		for _, frame in players:GetChildren() do
			if not frame:IsA("Frame") then
				continue
			end

			if game.Players:GetPlayerByUserId(frame.Name) then
				frame.BackgroundTransparency = 1
			else
				frame:Destroy()
			end
		end

		local v8 = #game.Players:GetChildren() - 1

		for _, child in game.Players:GetChildren() do
			if child == localPlayer then
				continue
			end

			local v9 = players:FindFirstChild(child.UserId) or createGiftPlayer(
				child.UserId,
				child.Name,
				child.DisplayName
			)

			if text2 == "" then
				continue
			end

			v9.Visible = string.sub(child.Name, 0, #text2) == text2

			if v9.Visible == false then
				v8 -= 1
			end
		end

		if v8 == 0 and text2 ~= "" then
			pcall(function()
				now = tick()
				local v9 = now
				local userIdFromNameAsync = game.Players:GetUserIdFromNameAsync(text2)

				if userIdFromNameAsync == localPlayer.UserId then
					return
				end

				local UserService = game:GetService("UserService")
				local userInfosByUserIdsAsync = UserService:GetUserInfosByUserIdsAsync({ userIdFromNameAsync })

				if now ~= v9 or not userInfosByUserIdsAsync then
					return
				end

				createGiftPlayer(
					userInfosByUserIdsAsync[1].Id,
					userInfosByUserIdsAsync[1].Username,
					userInfosByUserIdsAsync[1].DisplayName
				)
			end)
		end
	end

	v7:GetPropertyChangedSignal("Text"):Connect(updateGiftList)
	local v8 = false
	shop.Items.Merch:GetPropertyChangedSignal("Visible"):Connect(function()
		if v8 == true then
			return
		end

		v8 = true
		local v9 = game.ReplicatedStorage.Remotes.ShopUGC:InvokeServer()
		shop.Items.Merch.Loading.Visible = false

		for k, v10 in v9 do
			local v11 = v10
			local v12 = k
			task.delay(0.1 * k, function()
				local productInfo = MarketplaceService:GetProductInfo(v11, Enum.InfoType.Asset)
				local clone = menus.Preset.MerchItem:Clone()
				local universalTime = DateTime.fromIsoDate(productInfo.Created):ToUniversalTime()
				clone.LayoutOrder = -tonumber((`{tostring(universalTime.Year):sub(3)}{(universalTime.Month < 10 and "0" or "") .. universalTime.Month}{(universalTime.Day < 10 and "0" or "") .. universalTime.Day}`))
				clone.Price.Text = "" .. productInfo.PriceInRobux

				if v12 <= 2 then
					clone.BackgroundColor3 = Color3.fromRGB(170, 255, 255)
				end

				clone.Image = "rbxthumb://type=Asset&id=" .. v11 .. "&w=150&h=150"
				clone.Parent = shop.Items.Merch.Merch
				clone.MouseButton1Down:Connect(function()
					v2:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
					MarketplaceService:PromptPurchase(localPlayer, v11)
				end)
			end)
		end
	end)
	shop.Items.Rewards.TextBox.Redeem.MouseButton1Down:Connect(function()
		v2:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
		v.Code:Fire(shop.Items.Rewards.TextBox.Text)
		shop.Items.Rewards.TextBox.Text = ""
	end)
	gift.MouseButton1Down:Connect(function()
		v2:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)

		if players.Visible == false then
			players.Visible = true
			v7.Visible = true
			players.Position = UDim2.new(0, -20, -0.5, 0)
			v7.Position = UDim2.new(0, -20, -0.5, -10)
			TweenService:Create(players, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Position = UDim2.new(0, -20, 0, 0)
			}):Play()
			TweenService:Create(v7, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Position = UDim2.new(0, -20, 0, -10)
			}):Play()
			v2:PlaySound(sounds.Misc.UI.Wrap, workspace, game.SoundService.Effect)
			v7.Text = ""
			updateGiftList()
		else
			players.Visible = false
			v7.Visible = false
			userId = localPlayer.UserId
		end
	end)
	local right = shop.Items.Shop.Shop.Emote.Right
	local MVP = shop.Items.Shop.Shop.MVP
	local soda = shop.Items.Shop.Shop.Soda
	local item = shop.Items.Shop.Shop.Item
	local v9 = 1
	local v10 = {
		1,
		2,
		5,
		10
	}
	local v11 = 1
	right.Multiplier.Alt.Multiplier.MouseButton1Down:Connect(function()
		v9 += 1

		if v9 > 4 then
			v9 = 1
		end

		v11 = v10[v9]
		right.Multiplier.Alt.Multiplier.Text = ("%dx"):format(v11)
		right.Purchase.Buttons.Robux.Text = ("%d"):format(v11 * 25)
		right.Purchase.Buttons.Cash.Text = ("$%d"):format(v11 * 250)
	end)
	local _ = {
		[1758079520] = 1,
		[3415518126] = 2,
		[3415518509] = 5,
		[3415518615] = 10
	}
	right.Purchase.Buttons.Robux.MouseButton1Down:Connect(function()
		v2:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
		v.Purchase:Fire(`Emote{v11}`, "Robux", userId)
	end)
	right.Purchase.Buttons.Cash.MouseButton1Down:Connect(function()
		v2:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
		v.Purchase:Fire(`Emote{v11}`, "Cash", userId)
	end)
	right.Purchase.Odds.MouseButton1Down:Connect(function()
		v2:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
		v.UpdateOdds:Fire("Emotes")
	end)
	MVP.Purchase.Buttons.Robux.MouseButton1Down:Connect(function()
		v2:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
		v.Purchase:Fire("MVP", "Robux", userId)
	end)
	MVP.Purchase.Buttons.Cash.MouseButton1Down:Connect(function()
		v2:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
		v.Purchase:Fire("MVP", "Cash", userId)
	end)
	MVP.Odds.MouseButton1Click:Connect(function()
		v2:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
		v.UpdateOdds:Fire("MVPs")
	end)
	soda.Purchase.Cash.MouseButton1Down:Connect(function()
		v2:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
		v.Purchase:Fire("Soda", "Cash")
	end)
	item.Purchase.Cash.MouseButton1Down:Connect(function()
		v2:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
		v.Purchase:Fire("Item", "Cash")
	end)
	local shopOpen = replicatedStorage.Animations.Misc.ShopOpen
	local tracks = {}

	for _, v12 in v4 do
		shopOpen.AnimationId = "rbxassetid://" .. v12
		table.insert(tracks, (keeper2.Humanoid:LoadAnimation(shopOpen)))
	end

	local connection = nil
	local v12 = nil
	shop:GetPropertyChangedSignal("Visible"):Connect(function()
		if shop.Visible == true then
			local v13 = tracks[math.random(1, #tracks)]
			v13:Play(0, nil, 1)
			connection = v13:GetMarkerReachedSignal("Chat"):Connect(function()
				v13:AdjustSpeed(0)
				keeper.Button.Visible = true
				v12 = Talk(v5[math.random(1, #v5)])
			end)
			keeper2.Head.Mouth.Transparency = 1
			keeper.Button.Visible = false
			keeper.ImageTransparency = 1
			keeper.Position = UDim2.new(0.75, 0, 0.675, 0)
			TweenService:Create(keeper, TweenInfo.new(2, Enum.EasingStyle.Elastic), {
				Position = UDim2.new(0.75, 0, 0.875, 0)
			}):Play()
			TweenService:Create(keeper, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
				ImageTransparency = 0
			}):Play()
		else
			if connection then
				connection:Disconnect()
				connection = nil
			end

			if v12 then
				v12:Destroy()
				v12 = nil
			end

			for _, v13 in tracks do
				v13:Stop(0)
			end

			TweenService:Create(keeper, TweenInfo.new(0), {
				ImageTransparency = 1
			}):Play()
			players.Visible = false
			v7.Visible = false
			keeper.Button.Visible = false
			userId = localPlayer.UserId
		end
	end)
	keeper.Button.MouseButton1Down:Connect(function()
		keeper.Size = UDim2.new(0.275, 0, 0.55, 0)
		keeper.AnchorPoint = Vector2.new(0.5, 0.9)
		TweenService:Create(keeper, TweenInfo.new(1, Enum.EasingStyle.Elastic), {
			Size = UDim2.new(0.25, 0, 0.6, 0),
			AnchorPoint = Vector2.new(0.5, 1)
		}):Play()
		v2:PlaySound(sounds.Misc.UI.Squeak, workspace, game.SoundService.Effect)
		v12 = Talk(v6[math.random(1, #v6)])
	end)
	local emoteSelect = localPlayer.PlayerGui.Emotes.EmoteSelect

	replicatedStorage.Remotes.PickEmotePrompt.OnClientInvoke = function(items)
		emoteSelect.Visible = true
		local search = emoteSelect.Search
		local textBox = emoteSelect.TextBox
		local v13 = nil

		local function clearSearch()
			for _, frame in search:GetChildren() do
				if frame:IsA("Frame") then
					frame:Destroy()
				end
			end
		end

		local function updateSearch()
			clearSearch()
			local text2 = textBox.Text:lower()

			for _, item2 in items do
				if not (textBox == "" or item2:lower():find(text2)) then
					continue
				end

				local clone = menus.Preset.Emote:Clone()
				clone.EmoteName.Text = item2
				clone.Visible = true
				clone.Parent = search
				clone.MouseEnter:Connect(function()
					v2:PlaySound(sounds.Misc.UI.Hover, workspace, game.SoundService.Effect)
				end)
				local v14 = item2
				clone.EmoteName.MouseButton1Down:Connect(function()
					v2:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
					v13 = v14
					emoteSelect.Visible = false
				end)
			end
		end

		updateSearch()
		local textChangedConnection = textBox:GetPropertyChangedSignal("Text"):Connect(updateSearch)
		emoteSelect.Cancel.MouseButton1Click:Once(function()
			emoteSelect.Visible = false
			return nil
		end)
		emoteSelect:GetPropertyChangedSignal("Visible"):Wait()
		clearSearch()
		textChangedConnection:Disconnect()
		return v13
	end

	local oddsList = shop.OddsList
	local item2 = oddsList.Configuration.Item

	local function updateOdds(list)
		keeper.Visible = false
		oddsList.Visible = true
		table.sort(list, function(a, b)
			return a:lower() < b:lower()
		end)

		for _, frame in oddsList:GetChildren() do
			if frame:IsA("Frame") then
				frame:Destroy()
			end
		end

		local v13 = 100 / #list
		local v14 = string.format("%.3f", v13):gsub("%.?0+$", "")

		for k, text2 in list do
			local clone = item2:Clone()
			clone.ItemName.Text = text2
			clone.Odds.Text = `{v14}%`
			clone.LayoutOrder = k
			clone.Parent = oddsList
		end
	end

	v.UpdateOdds:Connect(updateOdds)
	local success, result = pcall(function()
		local PolicyService = game:GetService("PolicyService")
		return PolicyService:GetPolicyInfoForPlayerAsync(localPlayer)
	end)

	if success and result.ArePaidRandomItemsRestricted then
		right.Purchase.Buttons.Robux.Visible = false
		right.Gift.Visible = false
		MVP.Purchase.Buttons.Robux.Visible = false
	end
end

function controller.KnitInit(_)
	v = Knit.GetService("ShopService")
	v2 = Knit.GetController("FXController")
end

return controller