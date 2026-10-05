local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local MonetizationLibrary = require(ReplicatedStorage.Modules.MonetizationLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local MonetizationController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("MonetizationController"))
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local BaseContractSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("BaseContractSlot"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local PromptSystem = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("PromptSystem"))
local RewardSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("RewardSlot"))
local Page = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Page"))
local uGCEmptySlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("UGCEmptySlot")
local uGCSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("UGCSlot")
local object = setmetatable({}, Page)
object.__index = object

function object._new()
	local self = setmetatable(Page.new(script.Name), object)
	self.CloseButton = self.PageFrame:WaitForChild("Close")
	self.PromptsFrame = self.PageFrame:WaitForChild("Prompts")
	self.List = self.PageFrame:WaitForChild("List")
	self.Container = self.List:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self.SlotsFrame = self.Container:WaitForChild("Slots")
	self.SlotsContainer = self.SlotsFrame:WaitForChild("Container")
	self.SlotsLayout = self.SlotsContainer:WaitForChild("Layout")
	self.CartFrame = self.Container:WaitForChild("Cart")
	self.CartContainer = self.CartFrame:WaitForChild("Container")
	self.ItemsText = self.CartContainer:WaitForChild("Items")
	self.BuyButton = self.CartContainer:WaitForChild("Buy")
	self.BuyDisclaimerFrame = self.BuyButton:WaitForChild("Disclaimer")
	self.BuyLockedFrame = self.BuyButton:WaitForChild("Locked")
	self.BuyRobuxFrame = self.BuyButton:WaitForChild("Robux")
	self.BuyText = self.BuyButton:WaitForChild("Value")
	self.NextRewardContainer = self.CartContainer:WaitForChild("NextRewardContainer")
	self.NextRewardTitle = self.CartContainer:WaitForChild("NextRewardTitle")
	self.NextRewardDescription = self.CartContainer:WaitForChild("NextRewardDescription")
	self.NextRewardProgressBFrame = self.CartContainer:WaitForChild("NextRewardProgress")
	self.NextRewardProgressBar = self.NextRewardProgressBFrame:WaitForChild("Bar")
	self.PromptSystem = PromptSystem.new(self.PromptsFrame)
	self._next_reward_slot = nil
	self._contract_slot = BaseContractSlot.new()
	self._verified_ugc = false
	self._ugc_slots = {}
	self._robux_prices = {}
	self._shopping_cart = {}
	self:_Init()
	return self
end

function object:Buy(p)
	MonetizationController:PromptPurchase(MonetizationLibrary.UGCs[p].AssetID)
end

function object:BuyCart()
	if not next(self._shopping_cart) then
		Utility:CreateSound("rbxassetid://17153811469", 2, 1, script, true, 5)
		return
	end

	local v = {}

	for k in pairs(self._shopping_cart) do
		table.insert(v, {
			Type = Enum.MarketplaceProductType.AvatarAsset,
			Id = tostring(MonetizationLibrary.UGCs[k].AssetID)
		})
	end

	MonetizationController:PromptBulkPurchase(v)
end

function object:Close(...)
	self:_ClearCart()
	Page.Close(self, ...)
end

function object:_GetNumItemsInCart()
	local count = 0
	local total = 0
	local v = false

	for k in pairs(self._shopping_cart) do
		count += 1
		total += self._robux_prices[k] or 0
		v = v or MonetizationLibrary.UGCs[k].CanBeMisleading
	end

	return count, total, v
end

function object:_UpdateCartVisuals()
	for k, _ugc_slot in pairs(self._ugc_slots) do
		_ugc_slot.Enabled.Button.Added.Visible = self._shopping_cart[k]
	end

	local _GetNumItemsInCart, v, visible = self:_GetNumItemsInCart()
	self.BuyText.Text = utf8.char(57346) .. " " .. Utility:PrettyNumber(v)
	self.ItemsText.Text = _GetNumItemsInCart .. " item" .. (_GetNumItemsInCart == 1 and "" or "s")
	local itemsText = self.ItemsText
	local textColor

	if _GetNumItemsInCart >= 20 then
		textColor = Color3.fromRGB(255, 50, 50)
	else
		textColor = Color3.fromRGB(255, 255, 255)
	end

	itemsText.TextColor3 = textColor
	self.BuyLockedFrame.Visible = _GetNumItemsInCart == 0
	self.BuyRobuxFrame.Visible = _GetNumItemsInCart > 0
	self.BuyDisclaimerFrame.Visible = visible
end

function object:_ClearCart()
	if not next(self._shopping_cart) then
		return false
	end

	self._shopping_cart = {}
	self:_UpdateCartVisuals()
	return true
end

function object:_AddToCart(p)
	if self._shopping_cart[p] or self:_GetNumItemsInCart() >= 20 then
		return false
	end

	self._shopping_cart[p] = true
	self:_UpdateCartVisuals()
	return true
end

function object:_RemoveFromCart(p)
	if not self._shopping_cart[p] then
		return false
	end

	self._shopping_cart[p] = nil
	self:_UpdateCartVisuals()
	return true
end

function object:_UpdateContractSlot()
	self._contract_slot:SetProgress(#PlayerDataController:Get("UGCPurchased"))
end

function object:_UpdateNextReward()
	if self._next_reward_slot then
		self._next_reward_slot:Destroy()
		self._next_reward_slot = nil
	end

	local count = #PlayerDataController:Get("UGCPurchased")
	local nextUGCMilestone, v = MonetizationLibrary:GetNextUGCMilestone(count)
	local visible = nextUGCMilestone ~= nil
	self.NextRewardContainer.Visible = visible
	self.NextRewardTitle.Visible = visible
	self.NextRewardDescription.Visible = visible
	self.NextRewardProgressBFrame.Visible = visible
	self.NextRewardProgressBar.Visible = visible
	self.CartFrame.Size = UDim2.new(1, 0, visible and 0.2 or 0.1, 0)

	if not visible then
		return
	end

	local v3 = nextUGCMilestone.PurchaseRequirement - count
	local v4 = not v and 0 or v.PurchaseRequirement
	self.NextRewardProgressBar.Size = UDim2.new(
		math.clamp((count - v4) / (nextUGCMilestone.PurchaseRequirement - v4), 0, 1),
		0,
		1,
		2
	)
	self.NextRewardDescription.Text = string.format(
		"Purchase %s more UGC item%s for a FREE reward!",
		v3,
		v3 == 1 and "" or "s"
	)

	if nextUGCMilestone.Reward then
		self._next_reward_slot = RewardSlot.new(nextUGCMilestone.Reward)
		self._next_reward_slot:SetParent(self.NextRewardContainer)
	end
end

function object:_UpdateLayout()
	self.List.CanvasSize = UDim2.new(0, 0, 0, self.Layout.AbsoluteContentSize.Y)
	self.SlotsFrame.Size = UDim2.new(
		1,
		0,
		0,
		self.SlotsLayout.AbsoluteContentSize.Y + self.SlotsFrame.AbsoluteSize.X * 0.042
	)
end

function object:_Setup()
	self._contract_slot:SetTitle("Exclusive Rewards")
	self._contract_slot:SetImage("rbxassetid://71823401853501", UDim2.new(1.5, 0, 0.75, 0))
	self._contract_slot:SetContractImage("rbxassetid://17619445340", UDim2.new(0.05, 0, 0.5, 0))
	self._contract_slot:SetDescription("Purchase UGC items for exclusive rewards in the game (RIVALS)")

	for _, v in pairs(MonetizationLibrary.UGCMilestoneOrder) do
		local uGCMilestone = MonetizationLibrary.UGCMilestones[v]
		self._contract_slot:AddMilestone(uGCMilestone.PurchaseRequirement, uGCMilestone.Reward)
	end

	self._contract_slot.Frame.Parent = self.Container

	for k, v in pairs(MonetizationLibrary.UGCOrder) do
		local UGC = MonetizationLibrary.UGCs[v]
		local v2 = nil
		local clone = uGCSlot:Clone()
		clone.Enabled.Visible = false
		clone.Waiting.Visible = true
		clone.Waiting.Dots:AddTag("UILoadingDots")
		clone.LayoutOrder = k
		clone.Parent = self.SlotsContainer
		ButtonEffect:Add(clone.Enabled.Button)
		self._ugc_slots[v] = clone
		-- equivalent calls inferred from this helper; original call sites unknown
		local v3 = v

		local function check_is_owned()
			return table.find(PlayerDataController:Get("UGCPurchased"), v3)
		end

		local v4 = v
		clone.Enabled.Button.MouseButton1Click:Connect(function()
			if table.find(PlayerDataController:Get("UGCPurchased"), v4) then
				Utility:CreateSound("rbxassetid://17153811469", 2, 1, script, true, 5)
			elseif not self._robux_prices[v4] then
				self:Buy(v4)
			elseif self._shopping_cart[v4] then
				self:_RemoveFromCart(v4)
			elseif not self:_AddToCart(v4) then
				Utility:CreateSound("rbxassetid://17153811469", 2, 1, script, true, 5)
			end
		end)
		local v5 = v

		local function update_owned()
			local v7 = check_is_owned() -- equivalent call inferred; original call site unknown
			clone.Enabled.Button.Description.Text = v7 and "✅ Owned" or not v2 and "• • •" or utf8.char(57346) .. " " .. Utility:PrettyNumber(v2.PriceInRobux or 0)

			if v7 then
				self:_RemoveFromCart(v5)
			end
		end

		PlayerDataController:GetDataChangedSignal("UGCPurchased"):Connect(update_owned)
		update_owned()
		local v8 = v
		local v9 = clone
		task.spawn(function()
			local success, productInfoAsync = pcall(
				MarketplaceService.GetProductInfoAsync,
				MarketplaceService,
				UGC.AssetID,
				Enum.InfoType.Asset
			)

			if not success then
				return
			end

			v2 = productInfoAsync
			self._robux_prices[v8] = v2.PriceInRobux

			if not table.find(PlayerDataController:Get("UGCPurchased"), v8) then
				local success2, result = pcall(
					MarketplaceService.PlayerOwnsAssetAsync,
					MarketplaceService,
					Players.LocalPlayer,
					UGC.AssetID
				)

				if not success2 then
					return
				end

				if result and not self._verified_ugc then
					self._verified_ugc = true
					MonetizationController:VerifyUGC()
				end
			end

			v9.Waiting.Visible = false
			v9.Enabled.Visible = true
			v9.Enabled.Button.Icon.Image = "rbxthumb://type=Asset&id=" .. UGC.AssetID .. "&w=150&h=150"
			v9.Enabled.Button.Title.Text = v2.Name or ""
		end)
	end

	for _ = 1, 6 - ((#MonetizationLibrary.UGCOrder - 1) % 6 + 1) do
		local clone = uGCEmptySlot:Clone()
		clone.LayoutOrder = 65535
		clone.Parent = self.SlotsContainer
	end
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_UpdateLayout()
	end)
	self.SlotsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_UpdateLayout()
	end)
	self.SlotsFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateLayout()
	end)
	self.BuyButton.MouseButton1Click:Connect(function()
		self:BuyCart()
	end)
	PlayerDataController:GetDataChangedSignal("UGCPurchased"):Connect(function()
		self:_UpdateNextReward()
		self:_UpdateContractSlot()
	end)
	self:_Setup()
	self:_UpdateLayout()
	self:_UpdateNextReward()
	self:_UpdateContractSlot()
	self:_UpdateCartVisuals()
	ButtonEffect:Add(self.BuyButton)
	ButtonEffect:Add(self.CloseButton)
end

return object._new()