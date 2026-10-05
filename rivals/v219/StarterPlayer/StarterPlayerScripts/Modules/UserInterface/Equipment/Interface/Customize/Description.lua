local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local Description = {}
Description.__index = Description

function Description.new(customize)
	local self = setmetatable({}, Description)
	self.Customize = customize
	self.Frame = self.Customize.TopFrame:WaitForChild("Description")
	self.Background = self.Frame:WaitForChild("Background")
	self.Arrow = self.Frame:WaitForChild("Arrow")
	self.Title = self.Frame:WaitForChild("Title")
	self:_Init()
	return self
end

function Description:OnCustomizingStateChanged()
	self:_Update()
end

function Description:_UpdateArrow()
	local v = self.Background.AbsolutePosition.X + self.Background.AbsoluteSize.X / 2 - (self.Customize.NameDisplay.SlotContainer.AbsolutePosition.X + self.Customize.NameDisplay.SlotContainer.AbsoluteSize.X / 2)
	local v2 = math.min(math.abs(v), self.Background.AbsoluteSize.X / 2 - self.Arrow.AbsoluteSize.X - 8) * math.sign(v)
	self.Arrow.Position = UDim2.new(0.5, -v2, 0, 2)
end

function Description:_Update()
	local selectedCosmetic = self.Customize.Interface.Equipment:GetSelectedCosmetic()
	local cosmetic = CosmeticLibrary.Cosmetics[selectedCosmetic]
	local v = selectedCosmetic == "RANDOM_COSMETIC" and "Equips a random cosmetic every time you spawn" or cosmetic and cosmetic.GetDescription(true) or nil
	self.Frame.Visible = v ~= nil
	self.Title.Text = v or ""

	if self.Frame.Visible then
		self.Frame.Size = UDim2.new(0.5, 0.03125, 0)
		self.Frame:TweenSize(UDim2.new(1, 0, 0.0625, 0), "Out", "Back", 0.25, true)
	end
end

function Description:_UpdateBackground()
	self.Background.Size = UDim2.new(0, self.Title.TextBounds.X + self.Frame.AbsoluteSize.Y, 1, 0)
end

function Description:_Init()
	self.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
		self:_UpdateBackground()
	end)
	self.Background:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:_UpdateArrow()
	end)
	self.Background:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateArrow()
	end)
	self.Arrow:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateArrow()
	end)
	self.Customize.NameDisplay.SlotContainer:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:_UpdateArrow()
	end)
	self.Customize.NameDisplay.SlotContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateArrow()
	end)
	self:_UpdateBackground()
	self:_UpdateArrow()
end

return Description