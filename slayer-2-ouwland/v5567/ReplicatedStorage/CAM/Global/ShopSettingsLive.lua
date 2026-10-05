local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SettingsLive = require(ReplicatedStorage.CAM.Global.SettingsLive)
local shopSettings = require(ReplicatedStorage.CAM.Global.shopSettings)
return SettingsLive.new("ShopSettings", shopSettings, shopSettings)