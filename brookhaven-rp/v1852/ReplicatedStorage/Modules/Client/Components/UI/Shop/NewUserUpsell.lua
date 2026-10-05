local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemProvider = require(ReplicatedStorage.Modules.Client.Components.UI.Shop.ItemProvider)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local ShopItems = require(ReplicatedStorage.Modules.Shared.DB.Shop.ShopItems)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
require(ReplicatedStorage.Modules.Shared.PlayerData.Purchasable)
local RobloxUnicode = require(ReplicatedStorage.Modules.Shared.Utils.RobloxUnicode)
local v = Component.new({
	Tag = "NewUserUpsell"
})

-- equivalent calls inferred from this helper; original call sites unknown
local function getShopItem(name: string)
	for _, v2 in ShopItems.GetConfig() do
		if v2.Name == name then
			return v2
		end
	end

	return nil
end

local function populateControl(instance, purchasable, infoClient)
	local shopItem = getShopItem(purchasable:GetName()) -- equivalent call inferred; original call site unknown

	if shopItem == nil then
		return false
	end

	local outerBox = instance:WaitForChild("OuterBox")
	local contentBox = outerBox:WaitForChild("ContentBox")
	local imageLabel = outerBox:WaitForChild("ItemIcon"):WaitForChild("ImageLabel")
	local title = contentBox:WaitForChild("Title")
	local description = contentBox:WaitForChild("Description")
	local items = contentBox:WaitForChild("GamepassPaddingBox"):WaitForChild("GamepassOuterBox"):WaitForChild("TextBox"):WaitForChild("Items")
	imageLabel.Image = "rbxassetid://" .. infoClient.IconImageAssetId
	title.Text = shopItem.UpsellTitle
	description.Text = shopItem.UpsellDescription

	for _, child in items:GetChildren() do
		if child.Name == "Item" then
			child:Destroy()
		end
	end

	local clone = table.clone(shopItem.Featured)

	for _, v2 in ItemProvider.GetItemsPurchasable(purchasable) do
		if table.find(clone, v2) == nil then
			table.insert(clone, v2)
		end
	end

	local template = items:WaitForChild("Template")

	for _, image in clone do
		local clone2 = template:Clone()
		local imageLabel_2 = clone2:WaitForChild("ImageLabel")
		imageLabel_2.Image = image
		clone2.Visible = true
		clone2.Name = "Item"
		clone2.Parent = items
	end

	if #clone <= 2 then
		local uIGridLayout = items:WaitForChild("UIGridLayout")
		uIGridLayout.CellSize = UDim2.new(0.5, 0, 0, 1)
	end

	local X = items.AbsoluteCanvasSize.X
	items.CanvasSize = UDim2.new(0, 0, 0, math.ceil(X / 5) * math.ceil(#clone / 5))
	return true
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:SetPurchasable(purchasable)
	local infoClient = purchasable:GetInfoClient()

	if infoClient == nil or self.Instance.Name == "NewUserUpsellControl" and not populateControl(
		self.Instance,
		purchasable,
		infoClient
	) then
		return false
	end

	local value = self.Instance.PriceLabelValue.Value
	value.Text = RobloxUnicode.ROBUX
	task.spawn(function()
		local priceAsync = purchasable:GetPriceAsync()

		if priceAsync ~= nil then
			value.Text = RobloxUnicode.ROBUX .. priceAsync
		end
	end)
	self.Purchasable = purchasable
	return true
end

function v:Start()
	local value = self.Instance.PurchaseButtonValue.Value
	self._Janitor:Add(value.Activated:Connect(function()
		if self.Purchasable == nil then
			return
		end

		local id = Gamepasses.GetId(assert(self.Purchasable:ToGamepass()))
		Remotes.fireServer("PromptGamepassPurchase", id, "New User Popup", (tostring(id)))
	end))
	self._Janitor:Add(Remotes.connect("GamepassPromptPurchaseFinished", function(p: number, flag: boolean)
		if self.Purchasable == nil or not flag or p ~= self.Purchasable:GetId() then
			return
		end

		PanelController.Close("MainGUIHandler", self.Instance.Name)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v