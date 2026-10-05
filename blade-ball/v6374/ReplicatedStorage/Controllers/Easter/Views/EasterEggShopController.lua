local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("StarterGui")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local v = nil
local v2 = require3(ReplicatedStorage2.Packages.Net)
local v3 = require3(ReplicatedStorage2.Packages.Replion)
local v4 = require3(ReplicatedStorage2.Common.Utils.Utilities.ValueConvertor)
require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v5 = require3(ReplicatedStorage2.Shared.Easter.EasterSwordCrate)
local v6 = require3(ReplicatedStorage2.Shared.Easter.EasterShop)
local v7 = require3(ReplicatedStorage2.Controllers.Easter.EasterPageController)
local v8 = require3(ReplicatedStorage2.Common.Utils)
local remoteFunction = v2:RemoteFunction("PurchaseEasterShopItem")
local remoteFunction2 = v2:RemoteFunction("OpenEasterSwordCrate")
local eggShop = playerGui:WaitForChild("EasterEvent"):WaitForChild("Overview"):WaitForChild("Views"):WaitForChild("EggShop")
local odds = eggShop:WaitForChild("Odds")
local clones = {}
local clones2 = {}
local shopTemplate = eggShop.List.ShopTemplate
shopTemplate.Parent = nil
local flag = false
local oddsTemplate = odds.Main.List.OddsTemplate
oddsTemplate.Parent = nil
local EasterEggShopController = {
	Init = function(_)
		v7:RegisterPage("EggShop", eggShop)
	end,
	Start = function(_)
		v = v3.Client:WaitReplion("Data")
		eggShop.OddsButton.MouseButton1Click:Connect(function()
			if flag then
				return
			end

			if #clones2 == 0 then
				PopulateOddsFrame()
				return
			end

			flag = true
			task.delay(1, function()
				flag = false
			end)
			DestroyOddsFrame()
		end)
		v:OnChange({ "EasterEvent" }, UpdateShop)
		v:OnChange({ "CrateKeys" }, UpdateShop)
		UpdateShop()
	end
}

function DestroyOddsFrame()
	odds.Visible = false

	for _, v9 in ipairs(clones2) do
		v9:Destroy()
	end

	table.clear(clones2)
end

function PopulateOddsFrame()
	for _, v9 in ipairs(v5) do
		local clone = oddsTemplate:Clone()
		clone.Vector.Image = v9.Reward.Icon or ""
		clone.Label.Text = `{v9.Reward.DisplayName or "no_item"}`
		clone.Percentage.Text = `{v9.Chance * 100}%`
		clone.Percentage.TextColor3 = v9.ChanceColor
		clone.Percentage.UIStroke.Color = Color3.fromRGB(
			v9.ChanceColor.R * 0.2,
			v9.ChanceColor.G * 0.2,
			v9.ChanceColor.B * 0.2
		)
		clone.LayoutOrder = v9.Chance * -1000
		clone.Parent = odds.Main.List
		table.insert(clones2, clone)
	end

	odds.Visible = true
end

function UpdateShop()
	for i, v9 in ipairs(v6) do
		local clone = clones[i]

		if not clone then
			clone = shopTemplate:Clone()
			clone.BuyButton.Amount.Text = v4:AddCommas(v9.Price)
			clone.Label.Text = v9.Reward.DisplayName or "no_item"
			clone.Vector.Image = v9.Reward.Icon or ""
			local mouseButton1ClickConnection = nil
			local v10 = v9
			local v11 = i
			mouseButton1ClickConnection = clone.BuyButton.MouseButton1Click:Connect(function()
				if OwnsItem(v10) then
					return
				end

				if v10.Reward.Type == "CrateKey" then
					local v12 = v:Get({ "CrateKeys", v10.Reward.Value }) or 0

					if typeof(v12) == "number" and v12 > 0 then
						remoteFunction2:InvokeServer()
						return
					end
				end

				if remoteFunction:InvokeServer(v11) and v10.ReplionPath then
					mouseButton1ClickConnection:Disconnect()
				end
			end)
			clone.Parent = eggShop.List
			table.insert(clones, clone)
		end

		local buyButton = clone:FindFirstChild("BuyButton")

		if not buyButton then
			continue
		end

		local visible = OwnsItem(v9)

		if v9.Reward.Type == "CrateKey" then
			local v11 = v:Get({ "CrateKeys", v9.Reward.Value }) or 0

			if v11 and typeof(v11) == "number" and v11 > 0 then
				buyButton.Owned.Text = `Spin ({v11})`
				visible = true
			end
		end

		buyButton.Amount.Visible = not visible
		buyButton.Coin.Visible = not visible
		buyButton.Owned.Visible = visible
	end
end

function OwnsItem(p)
	if p.ReplionPath then
		return v8.RewardInfo.playerOwnsItem(localPlayer, p.Reward)
	end

	return false
end

return EasterEggShopController