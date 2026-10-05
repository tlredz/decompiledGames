local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Pages)
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules.UILibrary)
local Customize = require(script:WaitForChild("Customize"))
local Right = require(script:WaitForChild("Right"))
local Left = require(script:WaitForChild("Left"))
local Interface = {}
Interface.__index = Interface

function Interface.new(equipment)
	local self = setmetatable({}, Interface)
	self.Equipment = equipment
	self.Frame = UILibrary:GetTo("MainFrame", "Equipment")
	self.Customize = Customize.new(self)
	self.Right = Right.new(self)
	self.Left = Left.new(self)
	self:_Init()
	return self
end

function Interface:OnCustomizingStateChanged(...)
	self.Customize:OnCustomizingStateChanged(...)
end

function Interface:OnStateChanged(...)
	self.Right:OnStateChanged(...)
	self.Left:OnStateChanged(...)
	self.Customize:OnStateChanged(...)
end

function Interface:OnOpen(...)
	self.Right:OnOpen(...)
	self.Left:OnOpen(...)
	self:_UpdateComponentsVisibility()
end

function Interface:Update(...)
	self.Left:Update(...)
end

function Interface:_UpdateComponentsVisibility()
	local isOpen = self.Equipment.IsOpen
	local isOpenEffectDone = self.Equipment:IsOpenEffectDone()
	local isUnlocking = self.Equipment:IsUnlocking()
	local v = isOpen and isOpenEffectDone and not isUnlocking and not (Pages.PageSystem.CurrentPage or GuiService.MenuIsOpen)
	local isCustomizing = self.Equipment:IsCustomizing()
	self.Right:SetVisible(v and not isCustomizing and true)
	self.Left:SetVisible(v and not isCustomizing and true)
	self.Customize:SetVisible(v and isCustomizing and true)
end

function Interface:_Init()
	self.Equipment.CustomizingChanged:Connect(function()
		self:_UpdateComponentsVisibility()
	end)
	self.Equipment.UnlockingChanged:Connect(function()
		self:_UpdateComponentsVisibility()
	end)
	self.Equipment.FinishedOpenEffect:Connect(function()
		self:_UpdateComponentsVisibility()
	end)
	self.Equipment.SpinControls.MouseDownChanged:Connect(function()
		self:_UpdateComponentsVisibility()
	end)
	Pages.PageSystem.PagesActivity:Connect(function()
		self:_UpdateComponentsVisibility()
	end)
	GuiService:GetPropertyChangedSignal("MenuIsOpen"):Connect(function()
		self:_UpdateComponentsVisibility()
	end)
	self:_UpdateComponentsVisibility()
end

return Interface