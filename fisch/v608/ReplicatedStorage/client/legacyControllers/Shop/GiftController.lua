local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
game:GetService("MarketplaceService")
local _ = ReplicatedStorage.events
local localPlayer = game.Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local packages = ReplicatedStorage.packages
local shared = ReplicatedStorage.shared
local modules = shared.modules
local Monetization = require(shared.Monetization)
local Net = require(packages.Net)
require(modules.fishing.bobbers)
local GeneralUtils = require(shared.utils.GeneralUtils)
local randomPaidItems = require(modules.library.randomPaidItems)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local remoteEvent = Net:RemoteEvent("Gift/FinishPrompt", -1)
local remoteEvent2 = Net:RemoteEvent("Gift/SetTarget")
local remoteEvent3 = Net:RemoteEvent("Gift/EndPromptState")
local remoteFunction = Net:RemoteFunction("Gift/GetPrompted")
local gifting = playerGui:WaitForChild("Gifting")
local close = gifting:WaitForChild("Main").Close
local main = gifting.Main:WaitForChild("Frame"):WaitForChild("PlayerList"):WaitForChild("Main")
local template = main:WaitForChild("Template")
local inputBox = gifting.Main.Frame:WaitForChild("Search"):WaitForChild("InputBox")
local imageLabel = gifting.Main.Frame:WaitForChild("Preview"):WaitForChild("ProductIcon"):WaitForChild("ImageLabel")
local buyButton = gifting.Main.Frame.Preview:WaitForChild("BuyButton")
local description = gifting.Main.Frame.Preview:WaitForChild("Description")
local itemName = gifting.Main.Frame.Preview:WaitForChild("ItemName")
local headshot = gifting.Main.Frame.Preview:WaitForChild("PlayerSelected"):WaitForChild("playerimage"):WaitForChild("Headshot")
local playerName = gifting.Main.Frame.Preview.PlayerSelected:WaitForChild("PlayerName")
local _ = {
	Bobbers = function(p, p2: string)
		if legacyLocalPlayerData.forPublicPlayer(p):FindFirstChild((`bobber_{p2}`)) then
			return true
		end

		return false
	end,
	Gamepass = function(p, p2: number)
		if legacyLocalPlayerData.forPublicPlayer(p):FindFirstChild((`gp_{p2}`)) then
			return true
		end

		return false
	end,
	Credits = function(_)
		return false
	end,
	Bundle = {
		["Fischers Bobbler Bundle"] = function(p)
			local v2 = legacyLocalPlayerData.forPublicPlayer(p)

			if v2 then
				for _, bobber in Monetization.products.LimitedBobbers.Bobbers do
					if not v2:FindFirstChild((`bobber_{bobber}`)) then
						return false
					end
				end
			end

			return true
		end
	}
}
local v = {}
local GiftController = {}
GiftController.Prompted = false
GiftController.isGifting = false
GiftController.giftingId = nil
GiftController.giftingPlayer = nil
GiftController.gamepassId = nil
GiftController.class = nil
GiftController.name = nil

function GiftController:_SelectTarget(giftingPlayer, p)
	self.giftingPlayer = giftingPlayer
	local note = gifting.Main.Frame.Preview:FindFirstChild("Note")
	local text = note and note.Text or ""
	remoteEvent2:FireServer(self.giftingPlayer, self.giftingId, text)
	headshot.Image = p.IconFrame.Icon.Image
	playerName.Text = p.Name
end

function GiftController:Start()
	local function PlayerAdded(player)
		if player.Name == localPlayer.Name then
			return
		end

		if player:GetAttribute("PolicyPaidRandomItemsRestricted") == nil then
			player:GetAttributeChangedSignal("PolicyPaidRandomItemsRestricted"):Wait()
		end

		local clone = template:Clone()
		clone:SetAttribute("PolicyPaidRandomItemsRestricted", player:GetAttribute("PolicyPaidRandomItemsRestricted"))
		task.spawn(function()
			local userThumbnailAsync, v2 = Players:GetUserThumbnailAsync(
				player.UserId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size420x420
			)
			clone.IconFrame.Icon.Image = v2 and userThumbnailAsync or "rbxassetid://0"
		end)
		clone.PlayerName.Text = player.Name
		clone.Name = player.DisplayName
		clone.Activated:Connect(function()
			if self.giftingId then
				if self.gamepassId then
					local gamepassId = self.gamepassId

					if legacyLocalPlayerData.forPublicPlayer(player):FindFirstChild((`gp_{gamepassId}`)) then
						Net:RemoteEvent("Gift/AlertMessage"):FireServer()
						return
					end
				end

				print(self.class, self.name)

				if randomPaidItems[self.giftingId] then
					if clone:GetAttribute("PolicyPaidRandomItemsRestricted") or localPlayer:GetAttribute("PolicyPaidRandomItemsRestricted") then
						return
					end
				end

				self:_SelectTarget(player, clone)
			end
		end)
		clone.Parent = main
		clone.Visible = true
		v[player] = clone
	end

	local function PlayerRemoved(p)
		if v[p] then
			v[p]:Destroy()
			v[p] = nil
		end
	end

	for _, v2 in Players:GetPlayers() do
		task.spawn(PlayerAdded, v2)
	end

	Players.PlayerRemoving:Connect(PlayerRemoved)
	Players.PlayerAdded:Connect(function(player)
		task.spawn(PlayerAdded, player)
	end)
	remoteEvent.OnClientEvent:Connect(function()
		self:EndPrompt()
	end)
	buyButton.Activated:Connect(function()
		local priceLevel = Players.LocalPlayer:GetAttribute("PriceLevel") or 1000
		local priceLevel2 = self.giftingPlayer and self.giftingPlayer:GetAttribute("PriceLevel") or 1000

		if not (priceLevel and priceLevel2) then
			warn("One or both price levels were not found.")
		end

		if priceLevel < priceLevel2 then
			ReplicatedStorage.events.anno_localthought:Fire("You may not gift this player due to regional pricing.")
		elseif self.isGifting and self.giftingId and self.giftingPlayer then
			local note = gifting.Main.Frame.Preview:FindFirstChild("Note")
			local text = note and note.Text or ""

			if #text > 0 then
				local success, result = pcall(function()
					return TextService:FilterStringAsync(text, localPlayer.UserId)
				end)

				if success then
					local success2, result2 = pcall(function()
						return result:GetNonChatStringForBroadcastAsync()
					end)

					if success2 and result2 ~= text then
						ReplicatedStorage.events.anno_localthought:Fire("Some words in your note aren’t allowed, Please revise and try again.")
						return
					end
				end
			end

			self.Prompted = true
			remoteEvent2:FireServer(self.giftingPlayer, self.giftingId, text)
			Monetization.BuyProduct:FireServer(self.giftingId)
		end
	end)
	close.Activated:Connect(function()
		if not self.Prompted then
			self:EndPrompt()
		end
	end)
	gifting:GetPropertyChangedSignal("Enabled"):Connect(function()
		if not gifting.Enabled then
			self:EndPrompt()
		end
	end)
	remoteEvent3.OnClientEvent:Connect(function()
		self.Prompted = false
	end)
	inputBox:GetPropertyChangedSignal("Text"):Connect(function()
		local text = string.lower(inputBox.Text)

		for _, v2 in pairs(v) do
			v2.Visible = string.find(string.lower(v2.Name), text, 1, true) and true or false
		end
	end)

	remoteFunction.OnClientInvoke = function()
		return self.Prompted
	end
end

function GiftController:PromptGift(giftingId, value: string?, value2: string?, value3: string?, gamepassId: number?, class: string?, name: string?)
	if self.isGifting then
		return
	end

	self.gamepassId = gamepassId
	self.name = name
	self.class = class
	local shop = playerGui:WaitForChild("hud"):WaitForChild("safezone"):WaitForChild("shop")
	local crates = playerGui:WaitForChild("SkinCrate"):WaitForChild("Crates")
	shop.Visible = false
	crates.Visible = false
	GeneralUtils.fastTween(
		workspace.CurrentCamera,
		TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		{
			FieldOfView = 70
		}
	)
	GeneralUtils.fastTween(Lighting.uiblur, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Size = 0
	})
	GeneralUtils.fastTween(Lighting.uicc, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Brightness = 0,
		TintColor = Color3.fromRGB(255, 255, 255),
		Saturation = 0
	})
	self.isGifting = true
	self.giftingId = giftingId
	imageLabel.Image = value3 or ""
	itemName.Text = value or ""
	description.Text = value2 or ""
	buyButton.Text = utf8.char(57346) .. "???"
	local note = gifting.Main.Frame.Preview:FindFirstChild("Note")

	if note then
		note.Text = ""
	end

	local productInfo = gamepassId and Monetization:GetProductInfo(gamepassId, true) or Monetization:GetProductInfo(giftingId)
	print(productInfo)

	if productInfo then
		if not value3 and productInfo.IconImageAssetId then
			imageLabel.Image = "rbxassetid://" .. productInfo.IconImageAssetId
		end

		if not value and productInfo.Name then
			itemName.Text = productInfo.Name
		end

		if not value2 and productInfo.Description then
			description.Text = productInfo.Description
		end

		local robuxPrice = gamepassId and Monetization:GetRobuxPrice(gamepassId, true) or Monetization:GetRobuxPrice(giftingId)

		if robuxPrice then
			buyButton.Text = utf8.char(57346) .. tostring(robuxPrice)
		end
	end

	remoteEvent2:FireServer(nil, giftingId)
	gifting.Enabled = true
end

function GiftController:EndPrompt()
	self.isGifting = false
	self.giftingId = nil
	self.giftingPlayer = nil
	self.gamepassId = nil
	self.name = nil
	self.class = nil
	headshot.Image = ""
	playerName.Text = ""
	buyButton.Text = utf8.char(57346) .. "???"
	imageLabel.Image = ""
	itemName.Text = ""
	description.Text = ""
	local note = gifting.Main.Frame.Preview:FindFirstChild("Note")

	if note then
		note.Text = ""
	end

	gifting.Enabled = false
	remoteEvent2:FireServer(nil, nil)
end

return GiftController