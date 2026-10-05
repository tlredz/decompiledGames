local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local EmoteViewportFrame = require(Players.LocalPlayer.PlayerScripts.Modules.EmoteViewportFrame)
local emoteWheelSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("EmoteWheelSlot")
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local EmoteWheelSlot = {}
EmoteWheelSlot.__index = EmoteWheelSlot

function EmoteWheelSlot.new(equippedData)
	local self = setmetatable({}, EmoteWheelSlot)
	self.EquippedData = equippedData
	self.Name = self.EquippedData and self.EquippedData.Name
	self.Frame = emoteWheelSlot:Clone()
	self._emote_viewport_frame = self.Name and EmoteViewportFrame.new(self.Name, 4)
	self._is_highlighted = nil
	self._background = self.Frame.Background
	self._highlight = self._background.Highlight
	self._container = self.Frame.Container
	self._title = self._container.Title
	self._title_stroke = self._title.UIStroke
	self._highlight_tweens = {}
	self._equip_bounce_effect_ui_scale = Instance.new("UIScale")
	self:_Init()
	return self
end

function EmoteWheelSlot:GetContainerPosition()
	return self._container.AbsolutePosition + self._container.AbsoluteSize / 2
end

function EmoteWheelSlot:SetHighlighted(is_highlighted)
	if self._is_highlighted == is_highlighted then
		return
	end

	for _, _highlight_tween in pairs(self._highlight_tweens) do
		_highlight_tween:Pause()
		_highlight_tween:Destroy()
	end

	self._highlight_tweens = {}
	self._is_highlighted = is_highlighted
	self.Frame.ZIndex = is_highlighted and 1 or 0
	local tween = TweenService:Create(self.Frame, tweenInfo2, {
		Size = self._is_highlighted and UDim2.new(1.1, 0, 1.1, 0) or UDim2.new(1, 0, 1, 0)
	})
	tween:Play()
	table.insert(self._highlight_tweens, tween)
	local tween2 = TweenService:Create(self._highlight, tweenInfo2, {
		ImageTransparency = self._is_highlighted and 0 or 1
	})
	tween2:Play()
	table.insert(self._highlight_tweens, tween2)
	local tween3 = TweenService:Create(self._title, tweenInfo2, {
		Size = self._is_highlighted and UDim2.new(3, 0, 0.25, 0) or UDim2.new(3, 0, 0.175, 0),
		TextTransparency = self._is_highlighted and 0 or 0.5
	})
	tween3:Play()
	table.insert(self._highlight_tweens, tween3)
	local tween4 = TweenService:Create(self._title_stroke, tweenInfo2, {
		Transparency = self._is_highlighted and 0.75 or 0.875
	})
	tween4:Play()
	table.insert(self._highlight_tweens, tween4)

	if self._emote_viewport_frame then
		local tween5 = TweenService:Create(self._emote_viewport_frame.Frame, tweenInfo2, {
			Size = self._is_highlighted and UDim2.new(1.375, 0, 1.375, 0) or UDim2.new(1, 0, 1, 0)
		})
		tween5:Play()
		table.insert(self._highlight_tweens, tween5)
	end
end

function EmoteWheelSlot:SetRotation(rotation)
	self.Frame.Rotation = rotation
	self._container.Rotation = -rotation
end

function EmoteWheelSlot:EquipBounceEffect()
	self._equip_bounce_effect_ui_scale.Scale = 1.25
	TweenService:Create(self._equip_bounce_effect_ui_scale, tweenInfo, {
		Scale = 1
	}):Play()
end

function EmoteWheelSlot:Destroy()
	if self._emote_viewport_frame then
		self._emote_viewport_frame:Destroy()
	end

	self.Frame:Destroy()
end

function EmoteWheelSlot:_Setup()
	if self._emote_viewport_frame then
		self._emote_viewport_frame:SetParent(self._container)
	end

	self._background.ImageTransparency = self.Name and 0.25 or 0.5
	self._title.Text = self.Name or ""
	self._highlight.ImageColor3 = not self.Name and Color3.fromRGB(0, 0, 0) or CosmeticLibrary.Rarities[CosmeticLibrary.Cosmetics[self.Name].Rarity].Color
	self._equip_bounce_effect_ui_scale.Parent = self.Frame
end

function EmoteWheelSlot:_Init()
	self:_Setup()
	self:SetHighlighted(false)
end

return EmoteWheelSlot