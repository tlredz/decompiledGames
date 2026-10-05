local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local MonetizationLibrary = require(ReplicatedStorage.Modules.MonetizationLibrary)
local MonetizationController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("MonetizationController"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local BundleSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("BundleSlot"))
local Prompt = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Prompt"))
local object = setmetatable({}, Prompt)
object.__index = object

function object.new(name)
	local self = setmetatable(Prompt.new(script.Name), object)
	self.Container = self.PromptFrame:WaitForChild("Container")
	self.ButtonsFrame = self.PromptFrame:WaitForChild("Buttons")
	self.ButtonsContainer = self.ButtonsFrame:WaitForChild("Container")
	self.CloseButton = self.ButtonsContainer:WaitForChild("Close")
	self.BuyButton = self.ButtonsContainer:WaitForChild("Buy")
	self.BuyButtonOwnedFrame = self.BuyButton:WaitForChild("Owned")
	self.BuyButtonReadyFrame = self.BuyButton:WaitForChild("Ready")
	self.BuyButtonReadyText = self.BuyButtonReadyFrame:WaitForChild("Title")
	self.BuyButtonReadyBubbleFrame = self.BuyButtonReadyFrame:WaitForChild("Bubble")
	self.BuyButtonReadyBubbleText = self.BuyButtonReadyBubbleFrame:WaitForChild("Title")
	self.Name = name
	self.Info = MonetizationLibrary.Bundles[self.Name]
	self._bundle_slot = BundleSlot.new(self.Name)
	self:_Init()
	return self
end

function object:Destroy()
	self._bundle_slot:Destroy()
	Prompt.Destroy(self)
end

function object:_Update()
	if self._bundle_slot:IsAlreadyOwned() then
		self.BuyButton.Visible = true
		self.BuyButtonReadyFrame.Visible = false
		self.BuyButtonOwnedFrame.Visible = true
	else
		if self._bundle_slot:IsAvailableToPurchase() then
			self.BuyButton.Visible = true
			self.BuyButtonReadyFrame.Visible = true
		else
			self.BuyButton.Visible = false
			self.BuyButtonReadyFrame.Visible = false
		end

		self.BuyButtonOwnedFrame.Visible = false
	end
end

function object:_Setup()
	self.BuyButtonReadyBubbleText.RichText = true
	self.BuyButtonReadyBubbleText.Text = self.Info.BubbleText or ""
	self.BuyButtonReadyBubbleFrame.Visible = self.BuyButtonReadyBubbleText.Text ~= ""
	MonetizationController:SetRobuxText(
		self.BuyButtonReadyText,
		self._bundle_slot:GetAssetIDForRobuxText(),
		self._bundle_slot:GetInfoTypeForRobuxText()
	)
	self._bundle_slot:HideRobuxButton()
	self._bundle_slot:SetAlwaysSpotlighted(true)
	self._bundle_slot:SetSpotlightingInputsEnabled(false)
	self._bundle_slot:SetParent(self.Container)
	self._bundle_slot:StartLoops()
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.BuyButton.MouseButton1Click:Connect(function()
		self._bundle_slot:PurchaseRequest()
	end)
	self._bundle_slot.Tapped:Connect(function()
		self._bundle_slot:PurchaseRequest()
	end)
	self._bundle_slot.AvailabilityChanged:Connect(function()
		self:_Update()
	end)
	self._bundle_slot.OwnedChanged:Connect(function()
		self:_Update()
	end)
	self:_Setup()
	self:_Update()
	ButtonEffect:Add(self.BuyButton)
	ButtonEffect:Add(self.CloseButton)
end

return object