local Players = game:GetService("Players")
require(Players.LocalPlayer.PlayerScripts.Controllers.ShopController)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules.ButtonEffect)
local BottomTabs = {}
BottomTabs.__index = BottomTabs

function BottomTabs.new(shop)
	local self = setmetatable({}, BottomTabs)
	self.Shop = shop
	self.Frame = self.Shop.List:WaitForChild("BottomTabs")
	self.Container = self.Frame:WaitForChild("Container")
	self.GiftingButton = self.Container:WaitForChild("Gifting")
	self.RewardsButton = self.Container:WaitForChild("Rewards")
	self:_Init()
	return self
end

function BottomTabs.Open(_) end

function BottomTabs.Close(_) end

function BottomTabs.Setup(_) end

function BottomTabs:_Init()
	self.GiftingButton.MouseButton1Click:Connect(function()
		self.Shop:SetPage("Gifting")
	end)
	self.RewardsButton.MouseButton1Click:Connect(function()
		self.Shop:SetPage("Rewards")
	end)
	ButtonEffect:Add(self.GiftingButton)
	ButtonEffect:Add(self.RewardsButton)
end

return BottomTabs