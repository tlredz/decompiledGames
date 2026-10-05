local Players = game:GetService("Players")
local WeaponStatusHandler = require(Players.LocalPlayer.PlayerScripts.Modules.WeaponStatusHandler)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules.ButtonEffect)
local equipmentButtonSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("EquipmentButtonSlot")
local EquipmentButtonSlot = {}
EquipmentButtonSlot.__index = EquipmentButtonSlot

function EquipmentButtonSlot.new(name, layout_order, is_unlocked, display_name, image, status, value)
	local self = setmetatable({}, EquipmentButtonSlot)
	self.Name = name
	self.Frame = equipmentButtonSlot:Clone()
	self.Button = self.Frame:WaitForChild("Button")
	self.Background = self.Button:WaitForChild("Background")
	self.LockedLeft = self.Button:WaitForChild("LockedLeft")
	self.LockedRight = self.Button:WaitForChild("LockedRight")
	self.Icon = self.Button:WaitForChild("Icon")
	self.Title = self.Button:WaitForChild("Title")
	self.Notification = self.Title:WaitForChild("Notification")
	self.NotificationTitle = self.Notification:WaitForChild("Title")
	self._layout_order = layout_order
	self._is_unlocked = is_unlocked
	self._display_name = display_name
	self._image = image
	self._status = status
	self._num_notifications = value or 0
	self._is_icon_locked = false
	self._is_active = false
	self:_Init()
	return self
end

function EquipmentButtonSlot.SetParent(p, parent)
	p.Frame.Parent = parent
end

function EquipmentButtonSlot:SetCareerIcon()
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0, 8)
	uICorner.Parent = self.Icon
	self.Icon.Size = UDim2.new(1.1, 0, 1.1, 0)
	self._is_icon_locked = true
end

function EquipmentButtonSlot:SetActive(is_active)
	if self._is_active == is_active then
		return
	end

	self._is_active = is_active
	local frame = self.Frame
	local v

	if self._is_active then
		v = UDim2.new(1, 0, 0.25, 0)
	else
		v = UDim2.new(1, 0, 0.2, 0)
	end

	frame:TweenSize(v, "Out", self._is_active and "Back" or "Quint", 0.5, true)
	local icon = self.Icon
	local v2

	if self._is_active and not self._is_icon_locked then
		v2 = UDim2.new(0.8, 0, 0.5, 0)
	else
		v2 = UDim2.new(0.2, 0, 0.5, 0)
	end

	icon:TweenPosition(v2, "Out", "Quint", 0.5, true)
	self.Background.Visible = self._is_active
	local lockedLeft = self.LockedLeft
	local size

	if self._is_active then
		size = UDim2.new(0.5, 0, 0.375, 0)
	else
		size = UDim2.new(0.75, 0, 0.375, 0)
	end

	lockedLeft.Size = size
	self.LockedRight.Size = self.LockedLeft.Size
	self.Icon.ImageTransparency = (self._is_active or self._is_unlocked) and 0 or 0.5
	local title = self.Title
	local textColor

	if self._is_active or self._is_unlocked then
		textColor = Color3.fromRGB(255, 255, 255)
	else
		textColor = Color3.fromRGB(0, 0, 0)
	end

	title.TextColor3 = textColor
	self.Title.TextTransparency = self._is_active and 0 or 0.5
	self.LockedLeft.ImageTransparency = self._is_active and 0 or 0.5
	local lockedLeft2 = self.LockedLeft
	local imageColor

	if self._is_active then
		imageColor = Color3.fromRGB(255, 255, 255)
	else
		imageColor = Color3.fromRGB(0, 0, 0)
	end

	lockedLeft2.ImageColor3 = imageColor
	self.LockedRight.ImageTransparency = self.LockedLeft.ImageTransparency
	self.LockedRight.ImageColor3 = self.LockedLeft.ImageColor3
	self.Frame.ClipsDescendants = not self._is_active
	self.Frame.ZIndex = self._is_active and 2 or 1
	self.Notification.Visible = not self._is_active and self._num_notifications > 0
end

function EquipmentButtonSlot:Destroy()
	self.Frame:Destroy()
end

function EquipmentButtonSlot:_Update()
	self.LockedLeft.Position = UDim2.new(0.5, -self.Title.TextBounds.X / 2, 0.5, 0)
	self.LockedRight.Position = UDim2.new(0.5, self.Title.TextBounds.X / 2, 0.5, 0)
	self.Notification.Position = UDim2.new(
		0.5,
		self.Title.TextBounds.X / 2 + self.Notification.AbsoluteSize.X / 2,
		0.5,
		0
	)
end

function EquipmentButtonSlot:_Setup()
	self.Frame.LayoutOrder = self._layout_order
	self.LockedLeft.Visible = not self._is_unlocked
	self.LockedRight.Visible = not self._is_unlocked
	self.Title.Text = self._display_name
	local title = self.Title
	local textColor

	if self._is_unlocked then
		textColor = Color3.fromRGB(255, 255, 255)
	else
		textColor = Color3.fromRGB(0, 0, 0)
	end

	title.TextColor3 = textColor
	self.Icon.Image = self._image
	self.Icon.ImageColor3 = self._is_unlocked and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
	self.Icon.ImageTransparency = self._is_unlocked and 0 or 0.5
	self.Icon.Visible = self._is_unlocked
	self.Notification.Visible = self._num_notifications > 0
	self.NotificationTitle.Text = self._num_notifications
	WeaponStatusHandler:ApplyItemStatusToText(self.Title, self._status)
	WeaponStatusHandler:ApplyItemStatusToImage(self.LockedLeft, self._status)
	WeaponStatusHandler:ApplyItemStatusToImage(self.LockedRight, self._status)
end

function EquipmentButtonSlot:_Init()
	self.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
		self:_Update()
	end)
	self.Notification:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_Update()
	end)
	self:_Setup()
	self:_Update()
	ButtonEffect:Add(self.Button, nil, {
		ReleaseRatio = 0.95,
		HoverRatio = 0.95
	})
end

return EquipmentButtonSlot