local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
local GUI = require(ReplicatedStorage.Client.GUI)
require(ReplicatedStorage.Client.Types.GUI)
local Gifting = require(ReplicatedStorage.Client.Gifting)
local Marketplace = require(ReplicatedStorage.Shared.Utils.Marketplace)
local price = Marketplace.Price
require(ReplicatedStorage.Data.Products)
local Products = require(ReplicatedStorage.Data.Products)
local Save = require(ReplicatedStorage.Shared.Save)
local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)
local Storefront = require(ReplicatedStorage.Client.Functions.Storefront)
local v = {
	Products.Directory.SpeedPower_150000,
	Products.Directory.SpeedPower_1000000,
	Products.Directory.SpeedPower_10000000,
	Products.Directory.SpeedPower_50000000,
	Products.Directory.SpeedPower_500000000,
	Products.Directory.SpeedPower_1000000000
}
return {
	Start = function()
		local speed = GUI.Shop().Frame.ScrollingFrame.Speed
		local v2 = {
			speed.c1,
			speed.c2,
			speed.c3,
			speed.c4,
			speed.c5,
			speed.c6
		}

		local function updateProductPrice(p, p2)
			if p2 == nil then
				p.Text = "???"
				return
			end

			local productId = p2.ProductId

			if productId <= 0 then
				p.Text = "???"
			else
				task.spawn(function()
					local v3 = price(productId, Enum.InfoType.Product)
					p.Text = `{Constants.ROBUX_ICON_STR}{v3 == nil and "???" or tostring(v3)}`
				end)
			end
		end

		local function bindSpeedPowerProductFrame(p, p2, color: Color3)
			local price2 = p.Btns.Buy.Price

			if p2 == nil then
				price2.Text = "???"
			else
				local productId = p2.ProductId

				if productId <= 0 then
					price2.Text = "???"
				else
					task.spawn(function()
						local v3 = price(productId, Enum.InfoType.Product)
						price2.Text = `{Constants.ROBUX_ICON_STR}{v3 == nil and "???" or tostring(v3)}`
					end)
				end
			end

			p.Title.RichText = true
			p.Title.Text = `<font color="#{color:ToHex()}">+{Simple.FormatCompact(p2.SpeedPowerReward, ".#")}</font> SPEED`
			ButtonFX(p.Btns.Buy, nil, function()
				Storefront.Prompt(p2.ProductId, true)
			end)
			Gifting.Bind(p.Btns.Gift, "Product", p2.ProductId)
		end

		Save.Await()

		for k, v3 in v2 do
			local v4 = v[k]
			local v5

			if k <= 3 then
				v5 = Color3.fromRGB(0, 255, 0)
			else
				v5 = Color3.fromRGB(255, 200, 0)
			end

			bindSpeedPowerProductFrame(v3, v4, v5)
		end
	end
}