local Players = game:GetService("Players")
local RewardSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("RewardSlot"))
local parentModule = require(script.Parent)
local shopSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("ShopSlot")
local object = setmetatable({}, parentModule)
object.__index = object

function object.new(...)
	local self = setmetatable(parentModule.new(...), object)
	self.Frame = shopSlot:Clone()
	self.DetailsFrame = self.Frame.Details
	self.RewardSlot = nil
	self:_Init()
	return self
end

function object:OnClick(...)
	self.RewardSlot:OnClick(...)
end

function object.Destroy(p)
	p.Frame:Destroy()

	if p.RewardSlot then
		p.RewardSlot:Destroy()
	end

	parentModule.Destroy(p)
end

function object:_Setup()
	self.RewardSlot = RewardSlot.new(self.FirstRewardData, self.IsLocked or self.IsOwned)
	self.RewardSlot:SetNameText("")
	self.RewardSlot:SetParent(self.Frame.Container)
	self.DetailsFrame.Parent = self.RewardSlot.CosmeticSlot and self.RewardSlot.CosmeticSlot.Frame.Button or self.RewardSlot.Frame.Reward
end

function object:_Init()
	self:_Setup()
	self:_SetupBuyButton(self.DetailsFrame.Buy, self.DetailsFrame.Owned)
end

return object