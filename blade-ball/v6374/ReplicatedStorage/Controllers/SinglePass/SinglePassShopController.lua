local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.Packages.Signal)
require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v2 = require3(ReplicatedStorage2.Common.Utils)
require3(ReplicatedStorage2.Common.RewardInfo)
local client = require3(ReplicatedStorage2.Shared.Inventory).Client
require3(ReplicatedStorage2.Shared.SinglePass.SinglePassRemotes)
local v3 = require3(ReplicatedStorage2.Packages.Replion)
local v4 = require3(ReplicatedStorage2.Controllers.NotificationController)
local v5 = require3(ReplicatedStorage2.Shared.CNYEvent.CNYEventItemData)
local v6 = require3(ReplicatedStorage2.Shared.CNYEvent.CNYEventCrate)
local v7 = nil
local playerGui = Players.LocalPlayer.PlayerGui
local remoteFunction = v:RemoteFunction("CNYEvent_PurchaseShopItem")
local v8 = {
	LowTier = {
		Text = Color3.fromRGB(61, 255, 39),
		Stroke = Color3.fromRGB(0, 62, 3)
	},
	MidTier = {
		Text = Color3.fromRGB(255, 255, 0),
		Stroke = Color3.fromRGB(103, 103, 0)
	},
	HighTier = {
		Text = Color3.fromRGB(245, 0, 0),
		Stroke = Color3.fromRGB(109, 0, 0)
	},
	SecretTier = {
		Text = Color3.fromRGB(166, 20, 179),
		Stroke = Color3.fromRGB(78, 9, 84)
	}
}
local main = playerGui:WaitForChild("SinglePass").MainFrame.Main
local items = main.Pages.Shop.Items
local shopTemplate = items.ShopTemplate
shopTemplate.Parent = nil
local oddTemplate = main.Odds.List.UIGridLayout.OddTemplate
oddTemplate.Parent = nil
local clones = {}
local SinglePassShopController = {
	Start = function(_)
		v7 = v3.Client:WaitReplion("Data")
		main.Odds.Close.Activated:Connect(function()
			main.Odds.Visible = false
		end)

		for k, v9 in v5.ItemShop do
			local clone = shopTemplate:Clone()
			clone.Name = k

			if v9.CustomReward then
				local oddsButton = clone.OddsButton
				oddsButton.Activated:Connect(function()
					main.Odds.Visible = not main.Odds.Visible
				end)
				oddsButton.Visible = true
				clone.Title.Size = UDim2.fromScale(0.693, 0.295)
			end

			clone.LayoutOrder = v9.Cost
			clone.Title.Text = v9.CustomDisplayName or typeof(v9.Reward) ~= "table" and "" or v9.Reward.DisplayName or ""
			clone.Vector.Image = v9.CustomImage or typeof(v9.Reward) ~= "table" and "" or v9.Reward.Icon or ""
			clone.Buy.Cost.Text = v2.ValueConvertor:AddCommas(v9.Cost)
			local v10

			if v9.CustomReward then
				v10 = false
			else
				local reward = v9.Reward
				v10 = #client:FindItems(v9.ItemType, reward.Value) > 0
			end

			if not v10 then
				local v11 = v9
				local v12 = k
				clone.Buy.Activated:Connect(function()
					if v7:Get("CNYEvent.Lanterns") < v11.Cost then
						v2.Sounds:Play("error")
						v4:SendNotification("You don't have enough Lanterns!")
					else
						if not remoteFunction:InvokeServer(v12) then
							v2.Sounds:Play("error")
							v4:SendNotification("An unexpected error has occured.")
						end

						v2.Sounds:Play("Purchase")
					end
				end)
			end

			clone.Parent = items
			table.insert(clones, clone)
		end

		client:OnChange("Explosion", InventoryChanged)
		client:OnChange("Sword", InventoryChanged)
		client:OnChange("Emote", InventoryChanged)
		InventoryChanged()
		SetOdds()
	end
}

function InventoryChanged()
	for i, v9 in ipairs(clones) do
		local v10 = v5.ItemShop[i]

		if not v10 or v10.CustomReward then
			continue
		end

		local reward = v10.Reward
		local visible = #client:FindItems(v10.ItemType, reward.Value) > 0
		v9.Claimed.Visible = visible
		v9.Buy.Visible = not visible
	end
end

function SetOdds()
	for _, item in v6.Items do
		local clone = oddTemplate:Clone()
		local v9 = GetTier(item.Probability)
		clone.Percentage.Text = `{item.Probability}%`
		clone.Percentage.TextColor3 = v8[v9].Text
		clone.Percentage.UIStroke.Color = v8[v9].Stroke
		clone.Label.Text = item.Reward.DisplayName
		clone.Vector.Image = item.Reward.Icon or ""
		clone.LayoutOrder = 100 * item.Probability
		clone.Parent = main.Odds.List
	end
end

function GetTier(p)
	if p <= 0.05 then
		return "SecretTier"
	end

	if p <= 0.5 then
		return "HighTier"
	end

	if p <= 22.5 then
		return "MidTier"
	end

	return "LowTier"
end

return SinglePassShopController