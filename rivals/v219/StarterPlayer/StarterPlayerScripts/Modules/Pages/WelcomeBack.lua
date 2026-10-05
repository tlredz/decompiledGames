local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local RewardSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("RewardSlot"))
local Page = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Page"))
local object = setmetatable({}, Page)
object.__index = object

function object._new()
	local self = setmetatable(Page.new(script.Name), object)
	self.ClaimButton = self.PageFrame:WaitForChild("Claim")
	self.RewardsFrame = self.PageFrame:WaitForChild("Rewards")
	self.TitleText = self.PageFrame:WaitForChild("Title")
	self.HidePartyDisplay = true
	self:_Init()
	return self
end

function object.CloseRequest(p, ...)
	ReplicatedStorage.Remotes.Data.ClaimWelcomeBackGift:FireServer()
	Page.CloseRequest(p, ...)
end

function object:_Setup()
	self.TitleText.Text = "Welcome back, " .. Players.LocalPlayer.DisplayName .. "!"
	RewardSlot.new({
		Name = "Standard Weapon Crate",
		Quantity = 1
	}):SetParent(self.RewardsFrame)
end

function object:_Init()
	self.ClaimButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self:_Setup()
	ButtonEffect:Add(self.ClaimButton)
end

return object._new()