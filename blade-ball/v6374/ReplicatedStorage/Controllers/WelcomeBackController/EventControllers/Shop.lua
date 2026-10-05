local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Packages.Replion)
local v3 = require3(ReplicatedStorage2.Common.Utils.Utilities.ValueConvertor)
local v4 = require3(ReplicatedStorage2.Shared.WelcomeBackData)
local client = require3(ReplicatedStorage2.Shared.Inventory).Client
local playerGui = Players.LocalPlayer.PlayerGui
local v5 = nil
local welcomeBackReturnCoinShop = v4.WelcomeBackReturnCoinShop
local remoteFunction = v:RemoteFunction("PurchaseWelcomeBackShopItem")
local shop = playerGui:WaitForChild("NewWelcomeBack").Frame.Views.Shop
local template = shop.Items.Template
template.Parent = nil
local clones = {}
local Shop = {
	Start = function(_)
		v5 = v2.Client:WaitReplion("Data")
		UpdateAllShopTiles()
		client:OnChange("Emote", UpdateAllShopTiles)
		client:OnChange("Explosion", UpdateAllShopTiles)
		client:OnChange("Sword", UpdateAllShopTiles)
	end,
	OwnsShopItem = function(self, p)
		if v5 then
			return v5:Get({ "WelcomeBackEventShopItems", p.Reward.Value }) == true
		end

		return false
	end
}

function UpdateShopTile(p: number)
	local v6 = welcomeBackReturnCoinShop[p]
	local ownsShopItem = Shop:OwnsShopItem(v6)
	local clone = clones[p]

	if not clone then
		clone = template:Clone()
		clone.Vector.Image = v6.Reward.Icon or ""
		clone.Title.Text = v6.Reward.DisplayName or ""
		clone.Buy.Cost.Text = v3:AddCommas(v6.Cost)

		if not ownsShopItem then
			local mouseButton1ClickConnection = nil
			mouseButton1ClickConnection = clone.Buy.MouseButton1Click:Connect(function()
				if remoteFunction:InvokeServer(p) then
					mouseButton1ClickConnection:Disconnect()
				end
			end)
		end

		clone.Parent = shop.Items
		clones[p] = clone
	end

	if clone then
		clone.Buy.Visible = not ownsShopItem
		clone.Claimed.Visible = ownsShopItem
	end
end

function UpdateAllShopTiles()
	for i in ipairs(welcomeBackReturnCoinShop) do
		UpdateShopTile(i)
	end
end

return Shop