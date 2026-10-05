local Players = game:GetService("Players")
local SettingSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("SettingSlot"))
local object = setmetatable({}, SettingSlot)
object.__index = object

function object.new(...)
	local self = setmetatable(SettingSlot.new(...), object)
	self:_Init()
	return self
end

function object.SetDividerSpacing(object2, p)
	object2:ResizeYSize(p)
	object2.Background.Size = UDim2.new(1, 0, 1 / p, 0)
end

function object:_Setup()
	self.Background.ImageTransparency = 0.25
	self.BackgroundGradient.Enabled = false
	self.DetailsDisplayTitleText.FontFace = Font.fromId(12187365977, Enum.FontWeight.ExtraBold)
	self.Container.Position = UDim2.new(0, 0, 1, 0)
	self.Container.AnchorPoint = Vector2.new(0, 1)
	self.DetailsDisplayTitleContainer.Size = UDim2.new(
		self.DetailsDisplayTitleContainer.Size.X.Scale,
		self.DetailsDisplayTitleContainer.Size.X.Offset,
		self.DetailsDisplayTitleContainer.Size.Y.Scale * 1.5,
		self.DetailsDisplayTitleContainer.Size.Y.Offset * 1.5
	)
	self.SettingFrame.Size = UDim2.new(
		self.SettingFrame.Size.X.Scale,
		self.SettingFrame.Size.X.Offset,
		self.SettingFrame.Size.Y.Scale * 0.84,
		self.SettingFrame.Size.Y.Offset * 0.84
	)
	self.DetailsDisplayTitleContainer.Position = UDim2.new(0.0125, 0, 0.5, 0)
end

function object:_Init()
	self:_Setup()
end

return object