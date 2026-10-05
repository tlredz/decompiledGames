local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
game:GetService("TweenService")
local packages = ReplicatedStorage:WaitForChild("Packages")
local controllers = ReplicatedStorage:WaitForChild("Controllers")
local classes = ReplicatedStorage:WaitForChild("Classes")
local utils = ReplicatedStorage:WaitForChild("Utils")
local datas = ReplicatedStorage:WaitForChild("Datas")
local shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(packages.Net)
local Trove = require(packages.Trove)
local InterfaceController = require(controllers.InterfaceController)
require(controllers.CameraController)
local AnimatedButton = require(classes.AnimatedButton)
local Synchronizer = require(packages.Synchronizer)
local NumberUtils = require(utils.NumberUtils)
local ShopItems = require(datas.ShopItems)
local NotificationController = require(controllers.NotificationController)
local SoundController = require(controllers.SoundController)
local Updates = require(shared.Updates)
local remoteFunction = Net:RemoteFunction("CoinsShopService/RequestBuy")
local remoteFunction2 = Net:RemoteFunction("CoinsShopService/ToggleAutoBuy")
local localPlayer = Players.LocalPlayer
local v = {}
local coinsShop = localPlayer.PlayerGui:WaitForChild("CoinsShop"):WaitForChild("CoinsShop")
local items = coinsShop.Content.Items
local template = items.Template
local close = coinsShop.Header.Close
local v2 = nil
local maid = Trove.new()

local function CountPlayerTools(k: string)
	local count = 0

	for _, child in localPlayer.Backpack:GetChildren() do
		if child.Name == k then
			count += 1
		end
	end

	local character = localPlayer.Character
	local tool = character and character:FindFirstChildOfClass("Tool")

	if tool and tool.Name == k then
		count += 1
	end

	return count
end

local function CreateCoinsShopItems()
	maid:Destroy()
	local v3 = Synchronizer:Get(localPlayer)

	if not v3 then
		return
	end

	for k, shopItem in pairs(ShopItems) do
		if shopItem.Currency ~= "Coins" then
			continue
		end

		local clone = maid:Clone(template)
		local itemInformation = clone.ItemInformation
		local itemName = itemInformation.ItemName
		local itemDescription = itemInformation.ItemDescription
		local itemImage = clone.ItemImage
		local buy = clone.Buy
		local auto = clone.Auto
		local _ = clone.AutoLabel
		local price = buy.Price
		local locked = clone.Locked
		local txt = locked.Txt
		clone.Name = k
		itemName.Text = k
		itemDescription.Text = shopItem.Description
		itemImage.Image = shopItem.Icon
		clone.LayoutOrder = shopItem.LayoutOrder or 0
		local v4 = AnimatedButton.new(auto)
		v4:Animate()
		local v5 = k
		v4.OnActivated:Connect(function()
			local v6, v7 = remoteFunction2:InvokeServer(v5)

			if not v6 then
				if v7 then
					NotificationController:Error(v7)
				end

				SoundController:PlaySound("Sounds.Sfx.Error")
			end
		end)
		auto.Yes.Visible = v3:Get((`AutoBuy.{k}`)) == true
		maid:Add(v3:OnChanged(`AutoBuy.{k}`, function(p)
			auto.Yes.Visible = p == true
		end))
		local auto2 = auto
		local v11 = shopItem

		local function updateLockState()
			auto2.Visible = true
			locked.Visible = true
			txt.Visible = true
			buy.Visible = true

			if v11.RebirthRequired then
				if (v3:Get("Rebirth") or 0) >= v11.RebirthRequired then
					locked.Visible = false
					return
				end

				txt.Text = "YOU NEED " .. v11.RebirthRequired .. " REBIRTHS"
				buy.Visible = false
				auto2.Visible = false
			else
				locked.Visible = false
				txt.Visible = false
			end
		end

		maid:Add(v3:OnChanged("Rebirth", updateLockState))
		auto.Visible = true
		locked.Visible = true
		txt.Visible = true
		buy.Visible = true

		if shopItem.RebirthRequired then
			if (v3:Get("Rebirth") or 0) >= shopItem.RebirthRequired then
				locked.Visible = false
			else
				txt.Text = "YOU NEED " .. shopItem.RebirthRequired .. " REBIRTHS"
				buy.Visible = false
				auto.Visible = false
			end
		else
			locked.Visible = false
			txt.Visible = false
		end

		v[k] = CountPlayerTools(k)
		local maid2 = maid:Extend()
		local v12 = shopItem
		local v13 = k
		local buy2 = buy

		local function updateBuyState()
			maid2:Clean()
			local v16 = (v3:Get("Coins") or 0) >= v12.Price

			if v16 then
				if v13 == "Trap" then
					v16 = (localPlayer:GetAttribute("TrapCount") or 0) < 5
					price.Text = v16 and "$ " .. NumberUtils:ToString(v12.Price, 2) or "OWNED"
				else
					v16 = not v[v13] or v[v13] <= 0
				end
			end

			price.Text = v[v13] and v[v13] > 0 and "OWNED" or "$ " .. NumberUtils:ToString(v12.Price, 2)

			if not v16 then
				buy2.ImageColor3 = Color3.fromRGB(138, 138, 138)
				return
			end

			buy2.ImageColor3 = Color3.fromRGB(255, 255, 255)
			local v17 = maid2:Add(AnimatedButton.new(buy2))
			v17:Animate()
			maid2:Add(v17.OnActivated:Connect(function()
				local v18, v19 = remoteFunction:InvokeServer(v13)

				if v18 then
					NotificationController:Success(v19)
					SoundController:PlaySound("Sounds.Sfx.Success")
					v[v13] = (v[v13] or 0) + 1
				else
					NotificationController:Error(v19)
					SoundController:PlaySound("Sounds.Sfx.Error")
				end
			end))
		end

		if k == "Trap" then
			maid:Add(localPlayer:GetAttributeChangedSignal("TrapCount"):Connect(updateBuyState))
		end

		maid:Add(v3:OnChanged("Coins", updateBuyState))
		updateBuyState()
		clone.Visible = not shopItem.IsEnabled or shopItem.IsEnabled()
		clone.Parent = items
	end
end

return {
	Start = function(_)
		v2 = InterfaceController:Register("CoinsShop", coinsShop, "TopQuint")
		v2:AttachCloseButton(close)
		v2:Close()
		Synchronizer:WaitAndCall(localPlayer, function(_)
			Updates.OnUpdateEnabled:Connect(function()
				CreateCoinsShopItems()
			end)
			Updates.OnUpdateDisabled:Connect(function()
				CreateCoinsShopItems()
			end)
			CreateCoinsShopItems()
		end)
	end
}