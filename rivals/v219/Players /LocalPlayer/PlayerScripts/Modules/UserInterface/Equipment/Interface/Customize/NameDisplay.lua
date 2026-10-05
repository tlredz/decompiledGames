local Players = game:GetService("Players")
local CosmeticSlot = require(Players.LocalPlayer.PlayerScripts.Modules.CosmeticSlot)
local NameDisplay = {}
NameDisplay.__index = NameDisplay

function NameDisplay.new(customize)
	local self = setmetatable({}, NameDisplay)
	self.Customize = customize
	self.Frame = self.Customize.TopFrame:WaitForChild("NameDisplay")
	self.Background = self.Frame:WaitForChild("Background")
	self.ElementsFrame = self.Frame:WaitForChild("Elements")
	self.Layout = self.ElementsFrame:WaitForChild("Layout")
	self.SlotContainer = self.ElementsFrame:WaitForChild("Slot"):WaitForChild("Container")
	self.TitleContainer = self.ElementsFrame:WaitForChild("TitleContainer")
	self.Title = self.TitleContainer:WaitForChild("Title")
	self._cosmetic_slot = nil
	self:_Init()
	return self
end

function NameDisplay:OnCustomizingStateChanged()
	self:_Update()
end

function NameDisplay:_Update()
	if self._cosmetic_slot then
		self._cosmetic_slot:Destroy()
		self._cosmetic_slot = nil
	end

	local selectedCosmetic = self.Customize.Interface.Equipment:GetSelectedCosmetic()
	self.Frame.Visible = selectedCosmetic ~= nil
	self.Title.Text = selectedCosmetic == "RANDOM_COSMETIC" and "Random" or selectedCosmetic or ""

	if selectedCosmetic then
		self._cosmetic_slot = CosmeticSlot.new(selectedCosmetic)
		self._cosmetic_slot:SetWeapon(nil)
		self._cosmetic_slot:OverrideNameText("")
		self._cosmetic_slot:SetInteractable(false)
		self._cosmetic_slot.Frame.Parent = self.SlotContainer
	end
end

function NameDisplay:_UpdateLayout()
	self.TitleContainer.Size = UDim2.new(0, self.Title.TextBounds.X, 0.75, 0)
	self.Background.Size = UDim2.new(
		0,
		self.Layout.AbsoluteContentSize.X + self.TitleContainer.AbsoluteSize.Y * 0.5,
		1,
		0
	)
end

function NameDisplay:_Init()
	self.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
		self:_UpdateLayout()
	end)
	self.TitleContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateLayout()
	end)
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_UpdateLayout()
	end)
	self:_UpdateLayout()
end

return NameDisplay