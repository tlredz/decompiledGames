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
local RodsShopItems = require(datas.RodsShopItems)
local NotificationController = require(controllers.NotificationController)
local SoundController = require(controllers.SoundController)
local Updates = require(shared.Updates)
local remoteFunction = Net:RemoteFunction("RodsShopService/RequestBuy")
local remoteFunction2 = Net:RemoteFunction("RodsShopService/RequestEquip")
local remoteEvent = Net:RemoteEvent("RodsShopService/UpdateOwnedRods")
local remoteEvent2 = Net:RemoteEvent("RodsShopService/UpdateEquippedRod")
local localPlayer = Players.LocalPlayer
local v = {
	["Starter Rod"] = true
}
local v2 = "Starter Rod"
local rodsShop = localPlayer.PlayerGui:WaitForChild("RodsShop"):WaitForChild("RodsShop")
local items = rodsShop.Content.Items
local template = items.UIListLayout.Template
local close = rodsShop.Header.Close
local v3 = nil
local maid = Trove.new()

local function CreateRodsShopItems()
	maid:Destroy()
	local v4 = Synchronizer:Get(localPlayer)

	if not v4 then
		return
	end

	for k, rodsShopItem in pairs(RodsShopItems) do
		if rodsShopItem.Currency ~= "Coins" then
			continue
		end

		local clone = maid:Clone(template)
		local itemInformation = clone.ItemInformation
		local itemName = itemInformation.ItemName
		local itemDescription = itemInformation.ItemDescription
		local itemImage = clone.ItemImage
		local buy = clone.Buy
		local price = buy.Price
		local locked = clone.Locked
		local txt = locked.Txt
		clone.Name = k
		itemName.Text = k
		itemDescription.Text = rodsShopItem.Description
		itemImage.Image = rodsShopItem.Icon
		clone.Luck.Text = `[{rodsShopItem.Luck}x Cast Luck]`
		clone.LayoutOrder = rodsShopItem.LayoutOrder or 0
		local v8 = rodsShopItem

		local function updateLockState()
			locked.Visible = true
			txt.Visible = true
			buy.Visible = true

			if v8.RebirthRequired then
				if (v4:Get("Rebirth") or 0) >= v8.RebirthRequired then
					locked.Visible = false
					return
				end

				txt.Text = "YOU NEED " .. v8.RebirthRequired .. " REBIRTHS"
				buy.Visible = false
			else
				locked.Visible = false
				txt.Visible = false
			end
		end

		maid:Add(v4:OnChanged("Rebirth", updateLockState))
		locked.Visible = true
		txt.Visible = true
		buy.Visible = true

		if rodsShopItem.RebirthRequired then
			if (v4:Get("Rebirth") or 0) >= rodsShopItem.RebirthRequired then
				locked.Visible = false
			else
				txt.Text = "YOU NEED " .. rodsShopItem.RebirthRequired .. " REBIRTHS"
				buy.Visible = false
			end
		else
			locked.Visible = false
			txt.Visible = false
		end

		local maid2 = maid:Extend()
		local v9 = rodsShopItem
		local v11 = k
		local buy2 = buy

		local function updateBuyState()
			maid2:Clean()
			local v13 = (v4:Get("Coins") or 0) >= v9.Price
			price.Text = v2 == v11 and "OWNED" or v[v11] and "EQUIP" or "$ " .. NumberUtils:ToString(v9.Price, 2)

			if v2 == v11 then
				buy2.ImageColor3 = Color3.fromRGB(138, 138, 138)
				return
			end

			buy2.ImageColor3 = Color3.fromRGB(255, 255, 255)
			local v14 = maid2:Add(AnimatedButton.new(buy2))
			v14:Animate()
			maid2:Add(v14.OnActivated:Connect(function()
				local v15

				if v[v11] then
					v15 = remoteFunction2
				else
					v15 = remoteFunction
				end

				local v16, v17 = v15:InvokeServer(v11)

				if v16 then
					NotificationController:Success(v17)
					SoundController:PlaySound("Sounds.Sfx.Success")
				else
					NotificationController:Error(v17)
					SoundController:PlaySound("Sounds.Sfx.Error")
				end
			end))
		end

		maid:Add(v4:OnChanged("Coins", updateBuyState))
		updateBuyState()
		clone.Visible = not rodsShopItem.IsEnabled or rodsShopItem.IsEnabled()
		clone.Parent = items
	end
end

return {
	Start = function(_)
		v3 = InterfaceController:Register("RodsShop", rodsShop, "TopQuint")
		v3:AttachCloseButton(close)
		v3:Close()
		Synchronizer:WaitAndCall(localPlayer, function(_)
			Updates.OnUpdateEnabled:Connect(function()
				CreateRodsShopItems()
			end)
			Updates.OnUpdateDisabled:Connect(function()
				CreateRodsShopItems()
			end)
			CreateRodsShopItems()
		end)
		remoteEvent.OnClientEvent:Connect(function(items2)
			table.clear(v)

			for k, item in items2 do
				v[k] = item
			end

			CreateRodsShopItems()
		end)
		remoteEvent2.OnClientEvent:Connect(function(p)
			v2 = p
			CreateRodsShopItems()
		end)
		remoteEvent:FireServer()
	end
}