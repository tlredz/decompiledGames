local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
local Hud = require(ReplicatedStorage.Client.Hud)
local ShopNavigation = require(ReplicatedStorage.Client.ShopNavigation)
return {
	Start = function()
		for _, v in Hud.Every("SpeedShopButton") do
			ButtonFX(v, 1.08, function()
				ShopNavigation.Open("SpeedProducts")
			end)
		end
	end
}